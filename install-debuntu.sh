#!/usr/bin/env bash

set -euo pipefail

echo "INFO: Updating /etc/apt/sources.list.d to europe-west1"
sudo sed -i 's/us-central1/europe-west1/g' /etc/apt/sources.list

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
  kubectl \
  shellcheck \
  awscli

mkdir -p "${HOME}/bin"

# Alias batcat to bat the wrong way
if [ ! -e "${HOME}/bin/bat" ]; then
  ln -s $(which batcat) "${HOME}/bin/bat"
fi

if ! command -v powerline-go; then
  echo "INFO: Installing powerline-go"
  wget -c 'https://github.com/justjanne/powerline-go/releases/download/v1.21.0/powerline-go-linux-amd64' -O ~/bin/powerline-go && chmod +x ~/bin/powerline-go
fi

if ! command -v kubectx; then
  echo "INFO: Installing kubectx"
  wget -c 'https://github.com/ahmetb/kubectx/releases/download/v0.9.4/kubectx' -O ~/bin/kubectx && chmod +x ~/bin/kubectx
fi

if ! command -v kubens; then
  echo "INFO: Installing kubens"
  wget -c 'https://github.com/ahmetb/kubectx/releases/download/v0.9.4/kubens' -O ~/bin/kubens && chmod +x ~/bin/kubens
fi

# install krew
if [ ! -x "${HOME}/.krew/bin/kubectl-krew" ]; then
  cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz" &&
  tar zxvf krew.tar.gz &&
  KREW=./krew-"${OS}_${ARCH}" &&
  "$KREW" install krew
fi

# install eksctl
if [ ! -x ${HOME}/bin/eksctl ]; then
  echo "INFO: Installing eksctl"
  curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
  mv /tmp/eksctl "${HOME}/bin/eksctl"
fi

# enable byobu
byobu-enable

echo "INFO: Done!"
cd "${OLDPWD}" || exit
