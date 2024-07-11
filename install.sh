#!/usr/bin/env bash

set -euo pipefail

[[ -z "${VERBOSE:-}" ]] || set -x

REPO_ROOT=$(git rev-parse --show-toplevel)


install_package() {
    if [[ -f "/etc/debian-release" ]]; then
        DEBIAN_FRONTEND=noninteractive sudo apt-get install --no-install-recommends -y "$@"
    elif [[ -f "/etc/fedora-release" ]]; then
        sudo dnf install -y "$@"
    elif [[ -f "/etc/redhat-release" ]]; then
        sudo yum install -y "$@"
    else
        echo "ERROR: Unsupported OS"
        exit 1
    fi
}

# Ensure python3 is available
if ! command -v python3; then
  echo "INFO: installing python3"
  install_package python3 python3-virtualenv python3-apt
fi

# Ensure virtualenv  is available
if ! command -v virtualenv; then
  echo "INFO: installing virtualenv"
  install_package python3-virtualenv
fi

# Create a virtualenv
if [[ ! -d "${REPO_ROOT}/.venv" ]]; then
  echo "INFO: Creating virtualenv"
  virtualenv "${REPO_ROOT}/.venv"
fi

# Activate the virtualenv
source "${REPO_ROOT}/.venv/bin/activate"

# Check if Ansible is installed
if ! command -v ansible 2>&1>/dev/null; then
  echo "INFO: Installing Ansible via pip"
  python3 -m pip install ansible
fi

# Also install ansible-lint
if ! command -v ansible-lint 2>&1>/dev/null; then
  echo "INFO: Installing ansible-lint via pip"
  python3 -m pip install ansible-lint
fi

ANSIBLE_VERBOSE=""
if [[ -n "${VERBOSE:-}" ]]; then
  ANSIBLE_VERBOSE="-vvv"
fi

# Run the playbook
cd "${REPO_ROOT}/ansible"
ansible-playbook playbook.yaml --forks $(nproc) ${ANSIBLE_VERBOSE}
