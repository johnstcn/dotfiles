#!/usr/bin/env bash

set -euo pipefail

# Shell files to format check (exclude zshrc)
FMT_FILES=$(
    {
        shfmt -f .
        find files -maxdepth 1 -type f | grep -E 'bash'
    } | sort -u
)

# Shell files to lint (include zshrc)
LINT_FILES=$(
    {
        echo "$FMT_FILES"
        find files -maxdepth 1 -type f | grep -E 'shrc'
    } | sort -u
)

# Check formatting
echo "$FMT_FILES" | xargs shfmt -i 4 -d

# Run shellcheck
# Note: --shell=bash is used for files without a shebang
echo "$LINT_FILES" | xargs shellcheck --shell=bash
