#!/usr/bin/env bash

set -euo pipefail

[[ -z "${VERBOSE:-}" ]] || set -x

REPO_ROOT=$(git rev-parse --show-toplevel)
HOSTNAME=$(hostname -s | tr '[:upper:]' '[:lower:]')
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case "$ARCH" in
x86_64) ARCH="amd64" ;;
aarch64 | arm64) ARCH="arm64" ;;
esac
echo "INFO: Detected OS: $OS, ARCH: $ARCH"

# Default configuration (can be overridden by host config)
DOTFILES_SRC_DIR="$HOME/src"
declare -a DOTFILES_PACKAGES=()
declare -a DOTFILES_GIT_REPOS=(
    "git@github.com:johnstcn/flux|$HOME/src/flux|main"
    "git@github.com:johnstcn/cianjohnston.ie|$HOME/src/cianjohnston.ie|main"
    "git@gitlab.com:johnstcn/cv.git|$HOME/src/cv|master"
)
declare -a DOTFILES_BINARIES=()
declare -a DOTFILES_FILES=(
    "bash_aliases|$HOME/.bash_aliases"
    "bash_profile|$HOME/.bash_profile"
    "bashrc|$HOME/.bashrc"
    "gitconfig|$HOME/.gitconfig"
    "vimrc|$HOME/.vimrc"
    "zshrc|$HOME/.zshrc"
)

# Source OS config if it exists
if [[ -f "${REPO_ROOT}/os/${OS}.sh" ]]; then
    echo "INFO: Loading configuration for OS: ${OS}"
    # shellcheck source=/dev/null
    source "${REPO_ROOT}/os/${OS}.sh"
fi

# Ensure mandatory configuration files are included
DOTFILES_FILES+=(
    "config-nvim-init.lua|$HOME/.config/nvim/init.lua"
    "plug.vim|$HOME/.local/share/nvim/site/autoload/plug.vim"
)

setup_git_signing() {
    echo "INFO: Setting up git signing"
    mkdir -p "$HOME/.ssh"
    local email
    email=$(git config --get user.email || echo "user@example.com")
    local pubkey_file="$HOME/.ssh/id_ed25519.pub"
    if [[ -f "$pubkey_file" ]]; then
        local pubkey
        pubkey=$(cat "$pubkey_file")
        echo "$email namespaces=\"git\" $pubkey" >"$HOME/.ssh/allowed_signers"
        echo "INFO: Updated ~/.ssh/allowed_signers"
    else
        echo "WARNING: $pubkey_file not found, skipping signing setup"
    fi
}

install_packages() {
    local pkgs=("git" "curl" "${DOTFILES_PACKAGES[@]}")
    echo "INFO: Installing packages: ${pkgs[*]}"
    if [[ "$OS" == "darwin" ]]; then
        if ! command -v brew &>/dev/null; then
            echo "INFO: Installing Homebrew"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        brew install "${pkgs[@]}"
    elif [[ -f "/etc/debian_version" ]]; then
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
        mkdir -p "$(dirname "$dest")"
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
            echo "  Updating $repo_dest"
            git -C "$repo_dest" pull
        fi
    done
}

download_binaries() {
    if [[ ${#DOTFILES_BINARIES[@]} -eq 0 ]]; then
        return
    fi
    echo "INFO: Downloading binaries"
    for item in "${DOTFILES_BINARIES[@]}"; do
        local url dest
        url="${item%%|*}"
        dest="${item#*|}"

        # Replace placeholders
        url="${url//\$\{OS\}/$OS}"
        url="${url//\$\{ARCH\}/$ARCH}"

        echo "  Processing $url -> $dest"

        local sudo_cmd=""
        if [[ "$dest" == /opt/* || "$dest" == /usr/local/bin/* ]]; then
            sudo_cmd="sudo"
        fi

        $sudo_cmd mkdir -p "$(dirname "$dest")"

        if [[ "$url" == *.tar.gz ]]; then
            local tmpdir
            tmpdir=$(mktemp -d)
            curl -sSL "$url" | tar -C "$tmpdir" -xz

            if [[ "$url" == *nvim* ]]; then
                echo "    Detected Neovim tarball, installing to /opt"
                local nvim_dir
                nvim_dir=$(find "$tmpdir" -maxdepth 1 -type d -name "nvim-*" -print -quit)
                if [[ -n "$nvim_dir" ]]; then
                    sudo cp -r "$nvim_dir/"* /opt/
                    sudo chmod +x /opt/bin/nvim
                else
                    echo "ERROR: Could not find nvim directory in tarball"
                    rm -rf "$tmpdir"
                    exit 1
                fi
            else
                local bin_name
                bin_name=$(basename "$dest")
                local src_bin
                src_bin=$(find "$tmpdir" -type f -name "$bin_name" -print -quit)
                if [[ -n "$src_bin" ]]; then
                    $sudo_cmd mv "$src_bin" "$dest"
                else
                    echo "ERROR: Could not find binary '$bin_name' in tarball $url"
                    rm -rf "$tmpdir"
                    exit 1
                fi
            fi
            rm -rf "$tmpdir"
        else
            $sudo_cmd curl -sSL "$url" -o "$dest"
        fi
        $sudo_cmd chmod +x "$dest"
    done
}

# Main execution
install_packages
setup_git_signing
copy_files
clone_repos
download_binaries

echo "INFO: Done!"
