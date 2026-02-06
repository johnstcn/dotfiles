#!/usr/bin/env bash

set -euo pipefail

# Format all shell files found by shfmt and specific dotfiles
# Note: files/zshrc is excluded from shfmt because it uses zsh-specific syntax not supported by shfmt
{
    shfmt -f .
    find files -maxdepth 1 -type f | grep -E 'bash'
} | sort -u | xargs shfmt -i 4 -w
