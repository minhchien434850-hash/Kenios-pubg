# KENIOS HAX - Makefile for iOS 16.0 - 26.5
# Build với Theos (Rootless)

export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:16.0
export THEOS_PACKAGE_SCHEME = rootless
export INSTALL_TARGET_PROCESSES = PUBGM

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = KeniosHax

KeniosHax_FILES = \
	src/KENIOS_HAX_FULL.mm \
	src/KeniosAimbot.mm \
	src/KeniosESP.mm \
	src/KeniosMagicBullet.mm \
	src/KeniosSkinChanger.mm \
	src/KeniosAntiBanPro.mm \
	src/KeniosFPS.mm \
	src/KeniosMenu.mm \
	src/KeniosMemory.mm \
	src/KeniosNetwork.mm \
	src/KeniosKeyAuth.mm \
	src/KeniosIPAValidator.mm \
	src/KeniosBombAlert.mm \
	src/KeniosVehicleMaster.mm \
	src/KeniosEventShop.mm \
	src/KeniosUtils.mm

KeniosHax_CFLAGS = \
	-I./headers \
	-I$(THEOS)/include \
	-F$(THEOS)/vendor/lib \
	-fobjc-arc \
	-Wno-error \
	-Wno-unguarded-availability \
	-O2 \
	-DIOS_16_SUPPORT \
	-DIOS_26_SUPPORT

KeniosHax_FRAMEWORKS = \
	UIKit \
	Foundation \
	CoreGraphics \
	QuartzCore \
	Security \
	CFNetwork \
	CoreTelephony \
	SystemConfiguration \
	AudioToolbox

KeniosHax_PRIVATE_FRAMEWORKS = \
	AppSupport \
	GraphicsServices \
	BackBoardServices

KeniosHax_LIBRARIES = substrate

KeniosHax_LDFLAGS = \
	-L$(THEOS)/vendor/lib \
	-lsubstrate \
	-Wl,-segalign,4000 \
	-Wl,-dead_strip

KeniosHax_VERSION = 4.5.0
KeniosHax_PACKAGE_VERSION = $(KeniosHax_VERSION)-$(shell date +%Y%m%d)
KeniosHax_BUNDLE_ID = com.kenios.hax
KeniosHax_AUTHOR = KENIOS HAX Team
KeniosHax_DESCRIPTION = KENIOS HAX - PUBG Mobile iOS Ultimate Hack (iOS 16.0-26.5)

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard || killall -9 backboardd || ldrestart"

clean::
	rm -rf .theos packages obj
	rm -f *.deb *.ipa
	find . -name "*.dylib" -delete

# Compile the tweak
compile: package
	@echo "✅ Compilation successful!"

# Create IPA from compiled tweak
ipa: package
	@echo "[*] Building IPA package..."
	@mkdir -p packages/Payload/PUBGM.app
	@if [ -f ".theos/obj/debug/arm64/KeniosHax.dylib" ]; then \
		echo "[+] Found arm64 dylib"; \
		cp .theos/obj/debug/arm64/KeniosHax.dylib packages/Payload/PUBGM.app/; \
	elif [ -f ".theos/obj/debug/arm64e/KeniosHax.dylib" ]; then \
		echo "[+] Found arm64e dylib"; \
		cp .theos/obj/debug/arm64e/KeniosHax.dylib packages/Payload/PUBGM.app/; \
	else \
		echo "[-] Error: dylib not found!"; \
		exit 1; \
	fi
	@echo "[*] Creating IPA package..."
	@cd packages && zip -qr KeniosHax_iOS16_26.ipa Payload/ 2>/dev/null || true
	@if [ -f "packages/KeniosHax_iOS16_26.ipa" ]; then \
		echo ""; \
		echo "✅ ========================================="; \
		echo "✅ IPA BUILD SUCCESS!"; \
		echo "✅ ========================================="; \
		echo ""; \
		echo "📦 IPA File: packages/KeniosHax_iOS16_26.ipa"; \
		ls -lh packages/KeniosHax_iOS16_26.ipa; \
		echo ""; \
	else \
		echo "❌ Error: Failed to create IPA"; \
		exit 1; \
	fi

# Create DEB package for Cydia/Sileo
deb: package
	@echo "📦 Building DEB package..."
	@if [ -f "packages/com.kenios.hax_$(KeniosHax_PACKAGE_VERSION)_iphoneos-arm.deb" ]; then \
		echo "✅ DEB created successfully"; \
		ls -lh packages/com.kenios.hax_$(KeniosHax_PACKAGE_VERSION)_iphoneos-arm.deb; \
	else \
		echo "❌ Error: DEB not found"; \
		exit 1; \
	fi

# Install to device
install-device: package
	@echo "📱 Installing to device..."
	install.exec "killall -9 PUBGM || true"
	@sleep 1
	install.exec "uicache -p /Library/MobileSubstrate/DynamicLibraries/KeniosHax.plist"
	@sleep 1
	@echo "✅ Installation complete! Respringing..."
	install.exec "killall -9 SpringBoard || ldrestart"

# Help command
help:
	@echo "KENIOS HAX - Build Commands"
	@echo "============================="
	@echo "make package      - Compile tweak into DEB"
	@echo "make ipa          - Build IPA file"
	@echo "make deb          - Build DEB package"
	@echo "make install      - Install to connected device"
	@echo "make clean        - Clean build files"
	@echo "make help         - Show this help message"

.PHONY: clean ipa deb compile install-device help
