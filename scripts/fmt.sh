#!/usr/bin/env bash

set -euo pipefail

# Format all shell files found by shfmt
shfmt -f . | xargs shfmt -i 4 -w
