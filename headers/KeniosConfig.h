#ifndef KENIOS_CONFIG_H
#define KENIOS_CONFIG_H

#import "KeniosTypes.h"

@interface KeniosConfig : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) KeniosAimbotConfig *aimbot;
@property (nonatomic, strong) KeniosShotgunConfig *shotgun;
@property (nonatomic, strong) KeniosESPConfig *esp;
@property (nonatomic, strong) KeniosMagicBulletConfig *magicBullet;
@property (nonatomic, strong) KeniosWeaponConfig *weapons;
@property (nonatomic, strong) KeniosMovementConfig *movement;
@property (nonatomic, strong) KeniosPerformanceConfig *performance;
@property (nonatomic, strong) KeniosAntiBanConfig *antiBan;
@property (nonatomic, strong) KeniosBombAlertConfig *bombAlert;
@property (nonatomic, strong) KeniosVehicleMasterConfig *vehicleMaster;
@property (nonatomic, strong) KeniosEventShopConfig *eventShop;
@property (nonatomic, strong) KeniosGiftCheckerConfig *giftChecker;

@property (nonatomic, assign) BOOL autoUpdate;
@property (nonatomic, assign) BOOL soundEnabled;
@property (nonatomic, strong) NSString *serverURL;
@property (nonatomic, strong) NSString *currentLanguage;
@property (nonatomic, assign) int weaponSkinID;
@property (nonatomic, assign) int characterSkinID;
@property (nonatomic, assign) int vehicleSkinID;
@property (nonatomic, assign) int vehicleEffectID;
@property (nonatomic, assign) int parachuteSkinID;
@property (nonatomic, assign) int backpackSkinID;
@property (nonatomic, assign) int helmetSkinID;

- (void)loadDefaults;
- (BOOL)loadFromFile:(NSString *)filePath;
- (BOOL)saveToFile:(NSString *)filePath;
- (BOOL)loadFromJSON:(NSDictionary *)json;
- (NSDictionary *)toJSON;
- (void)resetAll;

@end
#endif
