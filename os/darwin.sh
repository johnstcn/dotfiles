# shellcheck shell=bash
# shellcheck disable=SC2034
DOTFILES_PACKAGES=(
    bat
    fd
    fluxcd/tap/flux
    fzf
    go
    kubectl
    kubectx
    jq
    less
    neovim
    powerline-go
    shellcheck
    shfmt
    tmux
    tree
    vim
)

# On macOS, most things are handled via Homebrew packages.
DOTFILES_BINARIES=()
