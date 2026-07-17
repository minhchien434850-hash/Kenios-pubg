#!/bin/bash
# KENIOS HAX - Inject dylib into base IPA for eSign signing
set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: ./scripts/inject.sh <path_to_base_ipa> [output_ipa]"
  exit 1
fi

BASE_IPA="$1"
OUTPUT_IPA="${2:-KENIOS_Hax_Injected_unsigned.ipa}"

if [ ! -f "$BASE_IPA" ]; then
  echo "❌ Base IPA not found: $BASE_IPA"
  exit 1
fi

DYLIB_PATH=""
if [ -f "packages/KeniosHax.dylib" ]; then
  DYLIB_PATH="packages/KeniosHax.dylib"
elif [ -f ".theos/obj/debug/arm64/KeniosHax.dylib" ]; then
  DYLIB_PATH=".theos/obj/debug/arm64/KeniosHax.dylib"
elif [ -f ".theos/obj/debug/arm64e/KeniosHax.dylib" ]; then
  DYLIB_PATH=".theos/obj/debug/arm64e/KeniosHax.dylib"
fi

if [ -z "$DYLIB_PATH" ]; then
  echo "❌ KeniosHax.dylib not found. Build first with: make package"
  exit 1
fi

WORK_DIR="$(mktemp -d /tmp/kenios-ipa-inject-XXXXXX)"
trap 'rm -rf "$WORK_DIR"' EXIT

echo "📦 Injecting KENIOS HAX into: $BASE_IPA"
echo "📚 Using dylib: $DYLIB_PATH"

unzip -q "$BASE_IPA" -d "$WORK_DIR"

APP_DIR="$(find "$WORK_DIR/Payload" -maxdepth 1 -type d -name "*.app" | head -n 1)"
if [ -z "$APP_DIR" ] || [ ! -d "$APP_DIR" ]; then
  echo "❌ Invalid IPA: cannot find app bundle in Payload/"
  exit 1
fi

cp "$DYLIB_PATH" "$APP_DIR/"

if [ -d "config" ]; then
  mkdir -p "$APP_DIR/KeniosConfig"
  cp config/*.json "$APP_DIR/KeniosConfig/" 2>/dev/null || true
fi

# eSign sẽ ký lại toàn bộ gói => dọn chữ ký cũ để tránh lỗi install
rm -rf "$APP_DIR/_CodeSignature" \
       "$APP_DIR/SC_Info" \
       "$APP_DIR/PlugIns"/*.appex/_CodeSignature 2>/dev/null || true
rm -f "$APP_DIR/CodeResources" \
      "$APP_DIR/embedded.mobileprovision" 2>/dev/null || true

(cd "$WORK_DIR" && zip -qr "$PWD/$OUTPUT_IPA" Payload/)

echo "✅ Output IPA (unsigned, ready for eSign signing): $OUTPUT_IPA"
echo "➡️  Open eSign > import cert+mobileprovision > sign this IPA > install"
