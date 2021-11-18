#!/usr/bin/env bash

set -euo pipefail

echo "INFO: Installing software for Arch"

if ! command -v fzf; then
  echo "INFO: Installing fzf"
  sudo pacman -S --noconfirm fzf
fi

if ! command -v powerline-go; then
  echo "INFO: Installing powerline-go"
  brew install powerline-go
fi

if ! command -v bat; then
  echo "INFO: Installing bat"
  sudo pacman -S --noconfirm bat
fi

if ! command -v shellcheck; then
  echo "INFO: Installing shellcheck"
  sudo pacman -S --noconfirm shellcheck
fi

if ! command -v byobu; then
  echo "INFO: Installing byobu"
  sudo pacman -S --noconfirm byobu 
fi

if ! command -v kubectl; then
  echo "INFO: Installing kubectl"
  sudo pacman -S --noconfirm kubectl
fi

if ! command -v helm; then
  echo "INFO: Installing helm"
  sudo pacman -S --noconfirm helm
fi

echo "INFO: Done!"
cd "${OLDPWD}" || exit
