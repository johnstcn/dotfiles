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

# Neovim uses different OS/ARCH naming
local nvim_os="linux"
local nvim_arch="x86_64"

DOTFILES_BINARIES=(
    "https://github.com/ahmetb/kubectx/releases/download/v0.9.5/kubectx_v0.9.5_linux_x86_64.tar.gz|$HOME/bin/kubectx"
    "https://github.com/ahmetb/kubectx/releases/download/v0.9.5/kubens_v0.9.5_linux_x86_64.tar.gz|$HOME/bin/kubens"
    "https://github.com/justjanne/powerline-go/releases/download/v1.26/powerline-go-\${OS}-\${ARCH}|$HOME/bin/powerline-go"
    "https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-${nvim_os}-${nvim_arch}.tar.gz|/opt/bin/nvim"
)
