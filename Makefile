# KENIOS HAX - Makefile for iOS 16.0 - 26.5
export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:16.0
export THEOS_PACKAGE_SCHEME = rootless

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
    -F$(THEOS)/vendor/lib \
    -fobjc-arc \
    -Wno-error \
    -Wno-unguarded-availability \
    -Wno-unused-variable \
    -Wno-unused-function \
    -O2

KeniosHax_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore Security CFNetwork CoreTelephony SystemConfiguration AudioToolbox
KeniosHax_PRIVATE_FRAMEWORKS = AppSupport GraphicsServices BackBoardServices
KeniosHax_LIBRARIES = substrate

KeniosHax_VERSION = 4.5.0
KeniosHax_BUNDLE_ID = com.kenios.hax

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"

clean::
	rm -rf .theos packages obj *.deb
