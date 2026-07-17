#!/bin/bash
set -e

PROJECT_NAME="KeniosHax"
IPA_NAME="KENIOS_Hax"
VERSION="4.5.0"
OUTPUT_DIR="packages"

echo "🚀 Building IPA..."

if [ -z "$THEOS" ]; then
  echo "❌ THEOS not set! Run: export THEOS=~/theos"
  exit 1
fi

make clean 2>/dev/null || true
rm -rf "$OUTPUT_DIR" 2>/dev/null || true
mkdir -p "$OUTPUT_DIR"

make package

DYLIB_PATH=".theos/obj/debug/arm64/${PROJECT_NAME}.dylib"
[ ! -f "$DYLIB_PATH" ] && { echo "❌ Dylib not found"; exit 1; }

mkdir -p "$OUTPUT_DIR/Payload/PUBGM.app/KeniosConfig"
cp "$DYLIB_PATH" "$OUTPUT_DIR/Payload/PUBGM.app/"
cp config/*.json "$OUTPUT_DIR/Payload/PUBGM.app/KeniosConfig/" 2>/dev/null || true

cd "$OUTPUT_DIR"
zip -qr "${IPA_NAME}_v${VERSION}.ipa" Payload/
cd ..

IPA_FILE="$OUTPUT_DIR/${IPA_NAME}_v${VERSION}.ipa"
[ -f "$IPA_FILE" ] && echo "✅ IPA created: $IPA_FILE" || { echo "❌ IPA failed"; exit 1; }
