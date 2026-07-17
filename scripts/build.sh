#!/bin/bash
# KENIOS HAX - Build Script for iOS 16.0-26.5
echo "╔══════════════════════════════════════════╗"
echo "║   🔥 KENIOS HAX Build System 🔥         ║"
echo "║   iOS 16.0 - 26.5 Support               ║"
echo "╚══════════════════════════════════════════╝"
if [ ! -d "$THEOS" ]; then echo "❌ THEOS not found!"; exit 1; fi
echo "✅ THEOS: $THEOS"
make clean 2>/dev/null
make package
if [ -f ".theos/obj/debug/arm64/KeniosHax.dylib" ]; then
    mkdir -p packages
    cp .theos/obj/debug/arm64/KeniosHax.dylib packages/
    echo "✅ Build successful! Dylib: packages/KeniosHax.dylib"
else
    echo "❌ Build failed!"
    exit 1
fi
