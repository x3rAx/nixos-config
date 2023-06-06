#!/usr/bin/env bash

set -eu

SCRIPT="$(readlink -f "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT")"

if [[ $# -lt 1 ]]; then
    echo >&2 "ERROR: Missing argument <mount-point>"
    exit 1
fi

target="$1"
shift

exec nixos-install --root "$target" --no-root-passwd "$@"

