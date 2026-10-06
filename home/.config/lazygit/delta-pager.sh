#!/usr/bin/env bash
set -euo pipefail
 
# Lazygit invokes this as the pager; stdin is the diff. Extra args from lazygit
# are forwarded after our defaults.
 
if defaults read -g AppleInterfaceStyle &>/dev/null; then
  exec delta \
    --dark \
    --paging=never \
    --syntax-theme Dracula \
    --side-by-side \
    "$@"
else
  exec delta \
    --light \
    --paging=never \
    --syntax-theme GitHub \
    --side-by-side \
    "$@"
fi
