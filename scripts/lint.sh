#!/usr/bin/env bash

set -euo pipefail

# Check formatting
shfmt -f . | xargs shfmt -i 4 -d

# Run shellcheck
shfmt -f . | xargs shellcheck
