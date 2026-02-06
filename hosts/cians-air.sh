DOTFILES_SRC_DIR="$HOME/src"

DOTFILES_PACKAGES=(
    bat
    byobu
    fd
    flux
    fzf
    go
    jq
    kubectl
    kubectx
    less
    neovim
    powerline-go
    shellcheck
    tree
    vim
)

# Format: "src|dest|version"
DOTFILES_GIT_REPOS=(
    "git@github.com:johnstcn/flux|$HOME/src/flux|main"
    "git@github.com:johnstcn/cianjohnston.ie|$HOME/src/cianjohnston.ie|main"
    "git@gitlab.com:johnstcn/cv.git|$HOME/src/cv|master"
)

DOTFILES_BINARIES=()
DOTFILES_FILES=()
