#!/bin/bash
# KENIOS HAX - Build Script for iOS 16.0-26.5
set -euo pipefail

echo "╔══════════════════════════════════════════╗"
echo "║   🔥 KENIOS HAX Build System 🔥         ║"
echo "║   iOS 16.0 - 26.5 Support               ║"
echo "╚══════════════════════════════════════════╝"
if [ ! -d "$THEOS" ]; then echo "❌ THEOS not found!"; exit 1; fi
echo "✅ THEOS: $THEOS"
make clean 2>/dev/null
make package
DYLIB_SRC=""
if [ -f ".theos/obj/debug/arm64/KeniosHax.dylib" ]; then
  DYLIB_SRC=".theos/obj/debug/arm64/KeniosHax.dylib"
elif [ -f ".theos/obj/debug/arm64e/KeniosHax.dylib" ]; then
  DYLIB_SRC=".theos/obj/debug/arm64e/KeniosHax.dylib"
fi

if [ -z "$DYLIB_SRC" ]; then
  echo "❌ Build failed! KeniosHax.dylib not found in .theos output."
  exit 1
fi

mkdir -p packages
cp "$DYLIB_SRC" packages/KeniosHax.dylib
echo "✅ Build successful! Dylib: packages/KeniosHax.dylib"
