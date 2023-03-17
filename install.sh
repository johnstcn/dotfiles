#!/usr/bin/env bash

GOVERSION="go1.20.1"
DOTFILES=(.bashrc .bash_profile .bash_aliases .vimrc .gitconfig .gitignore)
SRC_DIR="${HOME}/src"
declare -A REPO_MAP
REPO_MAP=(
#  ["https://github.com/user/repo"]="${SRC_DIR}/repo"
)
for GITHUB_REPO in "${!REPO_MAP[@]}"; do
  DEST_DIR="${REPO_MAP[$GITHUB_REPO]}"
  if [ ! -d "${DEST_DIR}" ]; then
    echo "INFO: Cloning ${GITHUB_REPO} under ${DEST_DIR}"
    git clone "${GITHUB_REPO}" "${DEST_DIR}"
  else
    echo "INFO: Updating ${GITHUB_REPO} already cloned under ${DEST_DIR}"
    ( cd "${DEST_DIR}" && git fetch )
  fi
done

for DOTFILE in "${DOTFILES[@]}"; do
  SRC="${PWD}/${DOTFILE}"
  DEST="${HOME}/${DOTFILE}"
  echo "INFO: Copying ${SRC} to ${DEST}"
  cp -fv "${SRC}" "${DEST}"
done

echo "INFO: Installing software for Debian/Ubuntu"

sudo apt-get update -qqy
sudo apt-get install -y software-properties-common

sudo apt-get upgrade -qqy
sudo apt-get install -qqy -o Dpkg::Options::="--force-overwrite" \
  less \
  tree \
  bat \
  byobu \
  fd-find \
  fzf \
  jq \
  shellcheck \
  vim

if [ ! -e "/usr/local/go/bin/go" ]; then
  echo "INFO: Installing Go ${GOVERSION}"
  wget -c "https://go.dev/dl/${GOVERSION}.linux-amd64.tar.gz" -O "/tmp/${GOVERSION}.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go && \
  sudo tar -C /usr/local -xzf "/tmp/${GOVERSION}.linux-amd64.tar.gz" && \
  rm -f "/tmp/${GOVERSION}.linux-amd64.tar.gz"
fi

mkdir -p "${HOME}/bin"

# Alias batcat to bat the wrong way
if [ ! -e "${HOME}/bin/bat" ]; then
  ln -s $(which batcat) "${HOME}/bin/bat"
fi

if ! command -v powerline-go; then
  echo "INFO: Installing powerline-go"
  wget -c "https://github.com/justjanne/powerline-go/releases/download/v1.22.1/powerline-go-linux-amd64" -O ~/bin/powerline-go && chmod +x ~/bin/powerline-go
fi

# enable byobu
byobu-enable

echo "INFO: Done!"
cd "${OLDPWD}" || exit
