#!/usr/bin/env bash

set -euo pipefail

[[ -z "${VERBOSE:-}" ]] || set -x

REPO_ROOT=$(git rev-parse --show-toplevel)
HOSTNAME=$(hostname -s | tr '[:upper:]' '[:lower:]')

# Default configuration (can be overridden by host config)
DOTFILES_SRC_DIR="$HOME/src"
declare -a DOTFILES_PACKAGES=()
declare -a DOTFILES_GIT_REPOS=()
declare -a DOTFILES_BINARIES=()
declare -a DOTFILES_FILES=()

# Source host config if it exists
if [[ -f "${REPO_ROOT}/hosts/${HOSTNAME}.sh" ]]; then
    echo "INFO: Loading configuration for host: ${HOSTNAME}"
    # shellcheck disable=SC1090
    source "${REPO_ROOT}/hosts/${HOSTNAME}.sh"
else
    echo "WARNING: No configuration found for host: ${HOSTNAME}"
fi

install_packages() {
    # Always ensure git and curl are present
    local pkgs=("git" "curl" "${DOTFILES_PACKAGES[@]}")
    
    echo "INFO: Installing packages: ${pkgs[*]}"
    if [[ -f "/etc/debian_version" ]]; then
        sudo apt-get update -qq
        DEBIAN_FRONTEND=noninteractive sudo apt-get install --no-install-recommends -y "${pkgs[@]}"
    elif [[ -f "/etc/fedora-release" ]]; then
        sudo dnf install -y "${pkgs[@]}"
    elif [[ -f "/etc/redhat-release" ]]; then
        sudo yum install -y "${pkgs[@]}"
    else
        echo "WARNING: Unsupported OS, skipping package installation"
    fi
}

copy_files() {
    if [[ ${#DOTFILES_FILES[@]} -eq 0 ]]; then
        return
    fi
    echo "INFO: Copying dotfiles"
    for item in "${DOTFILES_FILES[@]}"; do
        local src dest
        src="${item%%|*}"
        dest="${item#*|}"
        echo "  $src -> $dest"
        cp -v "${REPO_ROOT}/files/$src" "$dest"
    done
}

clone_repos() {
    echo "INFO: Ensuring source directory exists: $DOTFILES_SRC_DIR"
    mkdir -p "$DOTFILES_SRC_DIR"

    if [[ ${#DOTFILES_GIT_REPOS[@]} -eq 0 ]]; then
        return
    fi

    echo "INFO: Cloning git repositories"
    for item in "${DOTFILES_GIT_REPOS[@]}"; do
        # Format: "src|dest|version"
        local repo_src repo_dest repo_ver
        repo_src=$(echo "$item" | cut -d'|' -f1)
        repo_dest=$(echo "$item" | cut -d'|' -f2)
        repo_ver=$(echo "$item" | cut -d'|' -f3)
        
        if [[ ! -d "$repo_dest" ]]; then
            echo "  Cloning $repo_src to $repo_dest (branch: $repo_ver)"
            git clone -b "$repo_ver" "$repo_src" "$repo_dest"
        else
            echo "  $repo_dest already exists, skipping clone"
        fi
    done
}

download_binaries() {
    if [[ ${#DOTFILES_BINARIES[@]} -eq 0 ]]; then
        return
    fi
    echo "INFO: Downloading binaries"
    mkdir -p "$HOME/bin"
    for item in "${DOTFILES_BINARIES[@]}"; do
        local url dest
        url="${item%%|*}"
        dest="${item#*|}"
        echo "  Downloading $url to $dest"
        curl -sSL "$url" -o "$dest"
        chmod +x "$dest"
    done
}

# Main execution
install_packages
copy_files
clone_repos
download_binaries

echo "INFO: Done!"
