#ifndef KENIOS_SKIN_CHANGER_H
#define KENIOS_SKIN_CHANGER_H

#import <Foundation/Foundation.h>

@interface KeniosSkinChanger : NSObject
+ (instancetype)sharedInstance;
- (void)applyAllBestSkins;
- (void)randomizeSkins;
- (void)applyWeaponSkin:(int)skinID;
- (void)applyCharacterSkin:(int)skinID;
- (void)applyVehicleSkin:(int)skinID;
- (void)applyVehicleEffect:(int)effectID;
@end

#endif
