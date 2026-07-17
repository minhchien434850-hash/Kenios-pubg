#!/bin/bash
# KENIOS HAX - Inject dylib into IPA
if [ -z "$1" ]; then echo "Usage: ./inject.sh <path_to_ipa>"; exit 1; fi
IPA="$1"
echo "📦 Injecting KENIOS HAX into $IPA..."
# Unzip IPA
unzip -q "$IPA" -d temp_ipa
# Inject dylib
cp packages/KeniosHax.dylib temp_ipa/Payload/PUBGM.app/
# Re-sign (cần ldone tool)
# Repack
cd temp_ipa && zip -qr ../KENIOS_Hax_Injected.ipa Payload/ && cd ..
rm -rf temp_ipa
echo "✅ Injected IPA: KENIOS_Hax_Injected.ipa"
