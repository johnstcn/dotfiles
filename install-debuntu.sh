#!/usr/bin/env bash

set -euo pipefail

echo "INFO: Installing software for Debian/Ubuntu"

sudo apt-get update -qqy
sudo apt-get install -y software-properties-common

sudo apt-get upgrade -qqy
sudo apt-get install -qqy -o Dpkg::Options::="--force-overwrite" \
  less \
  bat \
  byobu \
  fd-find \
  fzf \
  jq \
  shellcheck \
  awscli

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
