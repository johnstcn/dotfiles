# shellcheck shell=bash
# shellcheck disable=SC2034
NVIM_ARCH=$(uname -m)
if [[ "$NVIM_ARCH" == "aarch64" ]]; then
    NVIM_ARCH="arm64"
fi
NVIM_URL="https://github.com/neovim/neovim/releases/download/v0.11.6/nvim-linux-${NVIM_ARCH}.tar.gz"

if command -v nvim &>/dev/null; then
    SYSTEM_NVIM_VER=$(nvim --version | head -n1 | cut -d' ' -f2 | sed 's/^v//')
    if [[ "$SYSTEM_NVIM_VER" == 0.9.* ]]; then
        log system "WARNING: Outdated system Neovim detected ($SYSTEM_NVIM_VER). Configuration requires v0.10+."
    fi
fi

DOTFILES_PACKAGES=(
    bat
    byobu
    fd-find
    fzf
    jq
    less
    shellcheck
    shfmt
    tree
    vim
)

DOTFILES_BINARIES=(
    "https://github.com/ahmetb/kubectx/releases/download/v0.9.5/kubectx_v0.9.5_linux_x86_64.tar.gz|$HOME/bin/kubectx"
    "https://github.com/ahmetb/kubectx/releases/download/v0.9.5/kubens_v0.9.5_linux_x86_64.tar.gz|$HOME/bin/kubens"
    "https://github.com/justjanne/powerline-go/releases/download/v1.26/powerline-go-${OS}-${ARCH}|$HOME/bin/powerline-go"
    "$NVIM_URL|$HOME/bin/nvim"
    "https://github.com/fluxcd/flux2/releases/download/v2.7.5/flux_2.7.5_linux_amd64.tar.gz|$HOME/bin/flux"
)
