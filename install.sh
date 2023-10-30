#!/usr/bin/env bash
#!/usr/bin/env bash

set -euo pipefail

[[ -z "${VERBOSE:-}" ]] || set -x

REPO_ROOT=$(git rev-parse --show-toplevel)

# Create a virtualenv
if [[ ! -d "${REPO_ROOT}/.venv" ]]; then
  echo "INFO: Creating virtualenv"
  python3 -m venv "${REPO_ROOT}/.venv"
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
