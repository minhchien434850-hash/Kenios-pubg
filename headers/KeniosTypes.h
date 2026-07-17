#ifndef KENIOS_TYPES_H
#define KENIOS_TYPES_H
#import "KeniosCommon.h"

@interface KeniosAimbotConfig : NSObject <NSCoding>
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) KeniosAimTarget targetBone;
@property (nonatomic, assign) float fov, smooth, maxDistance;
@property (nonatomic, assign) BOOL aimOnBots, aimOnPlayers, aimTeammates;
@property (nonatomic, assign) BOOL aimBehindWall, visibilityCheck, predictionEnabled;
@property (nonatomic, assign) float predictionFactor;
@end

@interface KeniosShotgunConfig : NSObject <NSCoding>
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) int aimMode, pelletCount;
@property (nonatomic, assign) float spreadReduction, fov, smooth;
@end

@interface KeniosESPConfig : NSObject <NSCoding>
@property (nonatomic, assign) BOOL enabled, boxEnabled, skeletonEnabled;
@property (nonatomic, assign) BOOL healthBarEnabled, nameEnabled, distanceEnabled;
@property (nonatomic, assign) BOOL lineEnabled, lootEnabled, vehicleEnabled;
@property (nonatomic, assign) BOOL fovCircleEnabled, crosshairEnabled, bombAlertEnabled;
@property (nonatomic, strong) UIColor *boxColorVisible, *boxColorHidden, *boxColorTeam, *boxColorBot;
@property (nonatomic, strong) UIColor *skeletonColorVisible, *skeletonColorHidden;
@property (nonatomic, strong) UIColor *nameColor, *distanceColor, *lineColor;
@property (nonatomic, strong) UIColor *fovCircleColor, *crosshairColor, *vehicleColor;
@property (nonatomic, assign) float boxThickness, skeletonThickness, nameFontSize;
@property (nonatomic, assign) float fovCircleRadius, fovCircleAlpha, crosshairSize;
@property (nonatomic, assign) float lootDistance, bombAlertRange;
@property (nonatomic, assign) int boxType, healthBarPosition, crosshairType, lootMinRarity;
@end

@interface KeniosMagicBulletConfig : NSObject <NSCoding>
@property (nonatomic, assign) BOOL enabled; @property (nonatomic, assign) float radius;
@property (nonatomic, assign) BOOL allGuns, excludeShotgun;
@end

@interface KeniosWeaponConfig : NSObject <NSCoding>
@property (nonatomic, assign) BOOL noRecoil, instantHit, noSpread;
@property (nonatomic, assign) BOOL rapidFire, autoReload, quickScope, infiniteAmmo;
@property (nonatomic, assign) float recoilControl, rapidFireMultiplier;
@end

@interface KeniosMovementConfig : NSObject <NSCoding>
@property (nonatomic, assign) BOOL speedHack, noFallDamage, flyMode;
@property (nonatomic, assign) float speedMultiplier, jumpHeight;
@end

@interface KeniosPerformanceConfig : NSObject <NSCoding>
@property (nonatomic, assign) BOOL fpsDisplay, fpsBoost, pingDisplay, graphicsOptimization;
@property (nonatomic, assign) int fpsPosition, fpsLimit;
@property (nonatomic, strong) UIColor *fpsColor;
@end

@interface KeniosAntiBanConfig : NSObject <NSCoding>
@property (nonatomic, assign) BOOL enabled, autoSwitch, disableOnSpectate;
@property (nonatomic, assign) BOOL disableOnReport, humanize, blockCrash, blockAnalytics, networkMonitor;
@property (nonatomic, assign) KeniosAntiBanMode mode;
@property (nonatomic, assign) float humanizeStrength, missChance;
@property (nonatomic, assign) int killLimit, headshotLimit;
@end

@interface KeniosKeyData : NSObject <NSSecureCoding>
@property (nonatomic, strong) NSString *key, *token;
@property (nonatomic, assign) int type, maxDevices;
@property (nonatomic, strong) NSDate *expiryDate;
@property (nonatomic, assign) BOOL isValid;
@property (nonatomic, strong) NSArray *features;
@end

@interface KeniosIPAData : NSObject
@property (nonatomic, strong) NSString *bundleID, *version, *sha256, *md5;
@property (nonatomic, assign) uint64_t fileSize; @property (nonatomic, assign) BOOL isValid;
@property (nonatomic, strong) NSString *errorMessage;
@end

@interface KeniosBombAlertConfig : NSObject <NSCoding>
@property (nonatomic, assign) BOOL enabled, alertGrenade, alertMolotov, alertC4;
@property (nonatomic, assign) BOOL soundAlert, vibrateAlert;
@property (nonatomic, assign) float range;
@end

@interface KeniosVehicleMasterConfig : NSObject <NSCoding>
@property (nonatomic, assign) BOOL enabled, unlockAll, godMode;
@property (nonatomic, assign) float speedBoost; @property (nonatomic, assign) int selectedVehicle;
@end

@interface KeniosEventShopConfig : NSObject <NSCoding>
@property (nonatomic, assign) BOOL enabled; @property (nonatomic, assign) int selectedEvent;
@property (nonatomic, strong) NSArray *purchasedItems;
@end

#endif
