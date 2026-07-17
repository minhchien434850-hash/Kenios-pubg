#!/bin/bash

# =====================================================
# KENIOS HAX - Build IPA Script
# Tự động build IPA từ Theos
# =====================================================

set -e

PROJECT_NAME="KeniosHax"
IPA_NAME="KENIOS_Hax"
VERSION="4.5.0"
OUTPUT_DIR="packages"

echo "🚀 [KENIOS HAX] Starting IPA Build Process..."
echo "=============================================="

# Kiểm tra Theos
if [ -z "$THEOS" ]; then
  echo "❌ Error: THEOS environment variable not set!"
  echo "   Please run: export THEOS=~/theos"
  exit 1
fi

echo "📁 Theos Path: $THEOS"

# Clean
echo "🧹 Cleaning previous builds..."
make clean 2>/dev/null || true
rm -rf "$OUTPUT_DIR" 2>/dev/null || true

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Compile tweak
echo "🔨 Compiling tweak..."
if make package; then
  echo "✅ Tweak compiled successfully!"
else
  echo "❌ Tweak compilation failed!"
  exit 1
fi

# Check if dylib was created
DYLIB_PATH=".theos/obj/debug/arm64/${PROJECT_NAME}.dylib"
if [ ! -f "$DYLIB_PATH" ]; then
  echo "❌ Error: Dylib not found at $DYLIB_PATH"
  exit 1
fi

echo "✅ Found dylib: $DYLIB_PATH"

# Create IPA structure
echo "📦 Creating IPA structure..."
mkdir -p "$OUTPUT_DIR/Payload/PUBGM.app"
mkdir -p "$OUTPUT_DIR/Payload/PUBGM.app/KeniosConfig"

# Copy dylib
echo "📋 Copying dylib..."
cp "$DYLIB_PATH" "$OUTPUT_DIR/Payload/PUBGM.app/"

# Copy config files if exist
if [ -d "config" ]; then
  echo "📋 Copying config files..."
  cp config/*.json "$OUTPUT_DIR/Payload/PUBGM.app/KeniosConfig/" 2>/dev/null || true
fi

# Create IPA
echo "📦 Packaging IPA..."
cd "$OUTPUT_DIR"
zip -qr "${IPA_NAME}_v${VERSION}.ipa" Payload/
cd ..

# Check if IPA was created
IPA_FILE="$OUTPUT_DIR/${IPA_NAME}_v${VERSION}.ipa"
if [ -f "$IPA_FILE" ]; then
  IPA_SIZE=$(du -h "$IPA_FILE" | cut -f1)
  echo ""
  echo "✅ ========================================="
  echo "✅ IPA BUILD SUCCESSFUL!"
  echo "✅ ========================================="
  echo ""
  echo "📦 IPA File: $IPA_FILE"
  echo "📊 Size: $IPA_SIZE"
  echo ""
  ls -lh "$IPA_FILE"
  echo ""
else
  echo "❌ Error: IPA file not created!"
  exit 1
fi

echo "✨ Build process completed successfully!"
