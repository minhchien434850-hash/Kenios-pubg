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
echo "🔨 Project: $PROJECT_NAME"
echo ""

# Clean
echo "🧹 Cleaning previous builds..."
make clean 2>/dev/null || true
rm -rf "$OUTPUT_DIR" 2>/dev/null || true

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Compile tweak
echo "🔨 Compiling tweak with Theos..."
if make package; then
  echo "✅ Tweak compiled successfully!"
else
  echo "❌ Tweak compilation failed!"
  exit 1
fi

echo ""

# Check if dylib was created (arm64)
DYLIB_PATH_ARM64=".theos/obj/debug/arm64/${PROJECT_NAME}.dylib"
DYLIB_PATH_ARM64E=".theos/obj/debug/arm64e/${PROJECT_NAME}.dylib"

DYLIB_FOUND=0
if [ -f "$DYLIB_PATH_ARM64" ]; then
  echo "✅ Found arm64 dylib: $DYLIB_PATH_ARM64"
  DYLIB_PATH="$DYLIB_PATH_ARM64"
  DYLIB_FOUND=1
elif [ -f "$DYLIB_PATH_ARM64E" ]; then
  echo "✅ Found arm64e dylib: $DYLIB_PATH_ARM64E"
  DYLIB_PATH="$DYLIB_PATH_ARM64E"
  DYLIB_FOUND=1
fi

if [ $DYLIB_FOUND -eq 0 ]; then
  echo "❌ Error: Dylib not found at:"
  echo "   - $DYLIB_PATH_ARM64"
  echo "   - $DYLIB_PATH_ARM64E"
  exit 1
fi

echo ""

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

echo ""

# Create IPA
echo "📦 Packaging IPA..."
cd "$OUTPUT_DIR"
zip -qr "${IPA_NAME}_v${VERSION}.ipa" Payload/ 2>/dev/null || true
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
  echo "✨ Build process completed successfully!"
else
  echo "❌ Error: IPA file not created!"
  exit 1
fi
