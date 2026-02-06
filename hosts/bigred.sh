DOTFILES_SRC_DIR="$HOME/src"

DOTFILES_PACKAGES=(
    bat
    byobu
    fd-find
    fzf
    jq
    less
    neovim
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

# Format: "url|dest"
DOTFILES_BINARIES=(
    "https://github.com/ahmetb/kubectx/releases/download/v0.9.5/kubectx_v0.9.5_linux_x86_64.tar.gz|$HOME/bin/kubectx"
    "https://github.com/ahmetb/kubectx/releases/download/v0.9.5/kubens_v0.9.5_linux_x86_64.tar.gz|$HOME/bin/kubens"
)

# Format: "src|dest"
DOTFILES_FILES=(
    "bashrc|$HOME/.bashrc"
    "bash_profile|$HOME/.bash_profile"
    "bash_aliases|$HOME/.bash_aliases"
    "gitconfig|$HOME/.gitconfig"
    "vimrc|$HOME/.vimrc"
)
