#!/usr/bin/env bash
set -euo pipefail

command -v hyprctl >/dev/null 2>&1 || exit 0

if hyprctl devices -j 2>/dev/null | jq -e 'any(.keyboards[]; .capsLock == true)' >/dev/null 2>&1; then
    printf 'Caps Lock is on\n'
fi
