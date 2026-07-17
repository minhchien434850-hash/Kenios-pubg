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
    src/KeniosAntiCheat.mm \
    src/KeniosFPS.mm \
    src/KeniosMenu.mm \
    src/KeniosMemory.mm \
    src/KeniosNetwork.mm \
    src/KeniosUtils.mm \
    src/KeniosKeyAuth.mm \
    src/KeniosAntiBanPro.mm \
    src/KeniosIPAValidator.mm \
    src/KeniosBombAlert.mm \
    src/KeniosVehicleMaster.mm \
    src/KeniosEventShop.mm

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
	rm -f *.deb

ipa: package
	@mkdir -p packages/Payload/PUBGM.app
	@cp .theos/obj/debug/arm64/KeniosHax.dylib packages/Payload/PUBGM.app/
	@cd packages && zip -r KeniosHax_iOS16_26.ipa Payload/
	@echo "✅ IPA created: packages/KeniosHax_iOS16_26.ipa"

.PHONY: clean ipa
