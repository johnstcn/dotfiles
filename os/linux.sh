# shellcheck shell=bash
# shellcheck disable=SC2034
DOTFILES_PACKAGES=(
    bat
    byobu
    fd-find
    fzf
    jq
    less
    neovim
    shellcheck
    shfmt
    tree
    vim
)

DOTFILES_BINARIES=(
    "https://github.com/ahmetb/kubectx/releases/download/v0.9.5/kubectx_v0.9.5_linux_x86_64.tar.gz|$HOME/bin/kubectx"
    "https://github.com/ahmetb/kubectx/releases/download/v0.9.5/kubens_v0.9.5_linux_x86_64.tar.gz|$HOME/bin/kubens"
    "https://github.com/justjanne/powerline-go/releases/download/v1.26/powerline-go-${OS}-${ARCH}|$HOME/bin/powerline-go"
    "https://github.com/neovim/neovim/releases/download/v0.11.6/nvim-linux-x86_64.tar.gz|/opt/bin/nvim"
    "https://github.com/fluxcd/flux2/releases/download/v2.7.5/flux_2.7.5_linux_amd64.tar.gz|$HOME/bin/flux"
)
