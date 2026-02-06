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

log() {
    local step="$1"
    shift
    echo "[$step] $*"
}

log system "Detected OS: $OS, ARCH: $ARCH"

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
    log system "Loading configuration for OS: ${OS}"
    # shellcheck source=/dev/null
    source "${REPO_ROOT}/os/${OS}.sh"
fi

# Ensure mandatory configuration files are included
DOTFILES_FILES+=(
    "config-nvim-init.lua|$HOME/.config/nvim/init.lua"
    "plug.vim|$HOME/.local/share/nvim/site/autoload/plug.vim"
    "nvim-lspconfig|$HOME/.local/share/nvim/site/pack/vendor/start/nvim-lspconfig"
)

setup_coder_ssh() {
    if [[ -z "${CODER_AGENT_URL:-}" || -z "${CODER_AGENT_TOKEN:-}" ]]; then
        return
    fi

    local privkey_file="$HOME/.ssh/id_ed25519"
    if [[ -f "$privkey_file" ]]; then
        log setup_coder_ssh "SSH key already exists at $privkey_file, skipping Coder fetch"
        return
    fi

    log setup_coder_ssh "Fetching Git SSH key from Coder"
    mkdir -p "$HOME/.ssh"
    if ! curl -fsSL -H "Cookie: coder_session_token=${CODER_AGENT_TOKEN}" "${CODER_AGENT_URL}api/v2/workspaceagents/me/gitsshkey" | jq -r .private_key >"$privkey_file"; then
        log setup_coder_ssh "Failed to fetch Git SSH key from Coder"
        return 1
    fi

    chmod 600 "$privkey_file"
    ssh-keygen -y -f "$privkey_file" >"${privkey_file}.pub"
    log setup_coder_ssh "Successfully fetched and configured Coder Git SSH key"
}

setup_git_signing() {
    log setup_git_signing "Setting up git signing"
    mkdir -p "$HOME/.ssh"
    local email
    email=$(git config --get user.email || echo "user@example.com")
    local pubkey_file="$HOME/.ssh/id_ed25519.pub"
    if [[ -f "$pubkey_file" ]]; then
        local pubkey
        pubkey=$(cat "$pubkey_file")
        echo "$email namespaces=\"git\" $pubkey" >"$HOME/.ssh/allowed_signers"
        log setup_git_signing "Updated ~/.ssh/allowed_signers"
    else
        log setup_git_signing "$pubkey_file not found, skipping signing setup"
    fi
}

install_packages() {
    local pkgs=("git" "curl" "jq" "${DOTFILES_PACKAGES[@]}")
    local missing_pkgs=()

    for pkg in "${pkgs[@]}"; do
        local installed=0
        if [[ "$OS" == "darwin" ]]; then
            if command -v brew &>/dev/null && brew list --formula "$pkg" &>/dev/null; then
                installed=1
            fi
        elif [[ -f "/etc/debian_version" ]]; then
            if dpkg -s "$pkg" &>/dev/null; then
                installed=1
            fi
        elif [[ -f "/etc/fedora-release" ]] || [[ -f "/etc/redhat-release" ]]; then
            if rpm -q "$pkg" &>/dev/null; then
                installed=1
            fi
        fi

        if [[ $installed -eq 0 ]]; then
            missing_pkgs+=("$pkg")
        fi
    done

    if [[ ${#missing_pkgs[@]} -eq 0 ]]; then
        log install_packages "All packages already installed"
        return
    fi

    log install_packages "Installing packages: ${missing_pkgs[*]}"
    if [[ "$OS" == "darwin" ]]; then
        if ! command -v brew &>/dev/null; then
            log install_packages "Installing Homebrew"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        brew install "${missing_pkgs[@]}"
    elif [[ -f "/etc/debian_version" ]]; then
        sudo apt-get update -qq
        DEBIAN_FRONTEND=noninteractive sudo apt-get install --no-install-recommends -y "${missing_pkgs[@]}"
    elif [[ -f "/etc/fedora-release" ]]; then
        sudo dnf install -y "${missing_pkgs[@]}"
    elif [[ -f "/etc/redhat-release" ]]; then
        sudo yum install -y "${missing_pkgs[@]}"
    else
        log install_packages "Unsupported OS, skipping package installation"
    fi
}

copy_files() {
    if [[ ${#DOTFILES_FILES[@]} -eq 0 ]]; then
        return
    fi
    log copy_files "Copying dotfiles"
    for item in "${DOTFILES_FILES[@]}"; do
        local src dest full_src
        src="${item%%|*}"
        dest="${item#*|}"
        full_src="${REPO_ROOT}/files/$src"

        if [[ -d "$full_src" ]]; then
            log copy_files "  $src -> $dest (directory)"
            mkdir -p "$dest"
            cp -R "$full_src/." "$dest/"
            continue
        fi

        if [[ -f "$dest" ]] && cmp -s "$full_src" "$dest"; then
            log copy_files "  $src -> $dest (skipped, identical)"
            continue
        fi
        log copy_files "  $src -> $dest"
        mkdir -p "$(dirname "$dest")"
        cp "$full_src" "$dest"
    done
}

clone_repos() {
    log clone_repos "Ensuring source directory exists: $DOTFILES_SRC_DIR"
    mkdir -p "$DOTFILES_SRC_DIR"

    if [[ ${#DOTFILES_GIT_REPOS[@]} -eq 0 ]]; then
        return
    fi

    log clone_repos "Cloning git repositories"
    for item in "${DOTFILES_GIT_REPOS[@]}"; do
        (
            # Format: "src|dest|version"
            local repo_src repo_dest repo_ver
            repo_src=$(echo "$item" | cut -d'|' -f1)
            repo_dest=$(echo "$item" | cut -d'|' -f2)
            repo_ver=$(echo "$item" | cut -d'|' -f3)

            if [[ ! -d "$repo_dest" ]]; then
                log clone_repos "  Cloning $repo_src to $repo_dest (branch: $repo_ver)"
                git clone -b "$repo_ver" "$repo_src" "$repo_dest"
            else
                log clone_repos "  Updating $repo_dest"
                git -C "$repo_dest" pull
            fi
        ) &
    done
    wait
}

download_binaries() {
    if [[ ${#DOTFILES_BINARIES[@]} -eq 0 ]]; then
        return
    fi
    log download_binaries "Downloading binaries"
    for item in "${DOTFILES_BINARIES[@]}"; do
        (
            local url dest
            url="${item%%|*}"
            dest="${item#*|}"

            # Replace placeholders
            url="${url//\$\{OS\}/$OS}"
            url="${url//\$\{ARCH\}/$ARCH}"

            if [[ -f "$dest" ]]; then
                log download_binaries "  $dest already exists, skipping"
                exit 0
            fi

            log download_binaries "  Processing $url -> $dest"

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
                    local nvim_version nvim_install_dir nvim_dir
                    nvim_version=$(echo "$url" | cut -d/ -f8)
                    nvim_install_dir="$HOME/.nvim-$nvim_version"
                    log download_binaries "    Detected Neovim tarball, installing to $nvim_install_dir"
                    nvim_dir=$(find "$tmpdir" -maxdepth 1 -type d -name "nvim-*" -print -quit)
                    if [[ -n "$nvim_dir" ]]; then
                        mkdir -p "$nvim_install_dir"
                        cp -r "$nvim_dir/"* "$nvim_install_dir/"
                        $sudo_cmd ln -sf "$nvim_install_dir/bin/nvim" "$dest"
                    else
                        log download_binaries "Could not find nvim directory in tarball"
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
                        log download_binaries "Could not find binary '$bin_name' in tarball $url"
                        rm -rf "$tmpdir"
                        exit 1
                    fi
                fi
                rm -rf "$tmpdir"
            else
                $sudo_cmd curl -sSL "$url" -o "$dest"
            fi
            $sudo_cmd chmod +x "$dest"
        ) &
    done
    wait
}

# Main execution
install_packages
setup_coder_ssh

setup_git_signing &
copy_files &
clone_repos &
download_binaries &

wait

log system "Done!"
