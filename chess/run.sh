#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXE="$ROOT/build/obj_dir/Vdemo_not"

if [[ ! -x "$EXE" ]]; then
    echo "project is not built; running build.sh"
    "$ROOT/build.sh"
fi

exec "$EXE"
