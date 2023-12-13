#!/usr/bin/env bash

set -euo pipefail

[[ -z "${VERBOSE:-}" ]] || set -x

REPO_ROOT=$(git rev-parse --show-toplevel)

# Ensure python3 is available
if ! command -v python3; then
  echo "INFO: installing python3"
  DEBIAN_FRONTEND=noninteractive sudo apt-get install --no-install-recommends -y python3 python3-virtualenv python3-apt
fi

# Ensure virtualenv  is available
if ! command -v virtualenv; then
  echo "INFO: installing virtualenv"
  DEBIAN_FRONTEND=noninteractive sudo apt-get install --no-install-recommends -y python3-virtualenv
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
ansible-playbook playbook.yaml ${ANSIBLE_VERBOSE}
