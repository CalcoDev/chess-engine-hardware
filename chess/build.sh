#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD="$ROOT/build"

mkdir -p "$BUILD"

if ! command -v verilator >/dev/null 2>&1; then
    echo "error: verilator not found"
    exit 1
fi

if ! command -v pkg-config >/dev/null 2>&1; then
    echo "error: pkg-config not found"
    exit 1
fi

if ! pkg-config --exists raylib; then
    echo "error: raylib not found by pkg-config"
    exit 1
fi

RAYLIB_CFLAGS="$(pkg-config --cflags raylib)"
RAYLIB_LIBS="$(pkg-config --libs raylib)"

echo "raylib: $(pkg-config --modversion raylib)"
echo "building..."

echo "==>[1/2] generating verilator model"

verilator \
    --cc \
    --exe \
    --top-module demo_not \
    --Mdir "$BUILD/obj_dir" \
    -CFLAGS "-std=c++20 -I$ROOT/backend $(pkg-config --cflags raylib)" \
    -LDFLAGS "$(pkg-config --libs raylib)" \
    "$ROOT/rtl/demo_not.sv" \
    "$ROOT/backend/rtl_backend.cpp" \
    "$ROOT/ui/main.cpp"

echo "==> [2/2] compiling application"

make \
    -C "$BUILD/obj_dir" \
    -f Vdemo_not.mk \
    -j"$(nproc)"

echo "...done!"

