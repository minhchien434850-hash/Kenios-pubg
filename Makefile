# Makefile cho dylib thường (ESign compatible)
ARCHS = arm64 arm64e
SDK = $(shell xcrun --sdk iphoneos --show-sdk-path)
CC = $(shell xcrun --sdk iphoneos --find clang)
CFLAGS = -arch arm64 -isysroot $(SDK) -miphoneos-version-min=16.0 -fobjc-arc -O2
LDFLAGS = -dynamiclib -install_name @executable_path/KeniosHax.dylib -framework Foundation -framework UIKit -framework CoreGraphics -framework QuartzCore -framework Security -framework CFNetwork -framework AudioToolbox -lobjc

SOURCES = src/KeniosLoader.mm \
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
          src/KeniosBombAlert.mm \
          src/KeniosVehicleMaster.mm \
          src/KeniosEventShop.mm \
          fishhook.c

all: KeniosHax.dylib

KeniosHax.dylib: $(SOURCES)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

package: KeniosHax.dylib
	mkdir -p .theos/obj/debug/arm64 .theos/obj/debug/arm64e
	cp KeniosHax.dylib .theos/obj/debug/arm64/KeniosHax.dylib
	cp KeniosHax.dylib .theos/obj/debug/arm64e/KeniosHax.dylib

clean:
	rm -f KeniosHax.dylib
	rm -rf .theos
