#import "KeniosCommon.h"
#import "KeniosConfig.h"

@interface KeniosSkinChanger ()
@property (nonatomic, strong) NSDictionary *skinsDB;
@end

@implementation KeniosSkinChanger

+ (instancetype)sharedInstance {
    static KeniosSkinChanger *i = nil; static dispatch_once_t t; dispatch_once(&t, ^{ i = [[KeniosSkinChanger alloc] init]; }); return i;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"skins" ofType:@"json"];
        if (!path) path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"KeniosHax/skins.json"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        if (data) self.skinsDB = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    return self;
}

- (void)applyWeaponSkin:(int)skinID {
    KeniosConfig *c = [KeniosConfig sharedInstance];
    c.weaponSkinID = skinID;
    KENIOS_LOG(@"Applied weapon skin ID: %d", skinID);
}

- (void)applyCharacterSkin:(int)skinID {
    KeniosConfig *c = [KeniosConfig sharedInstance];
    c.characterSkinID = skinID;
    KENIOS_LOG(@"Applied character skin ID: %d", skinID);
}

- (void)applyVehicleSkin:(int)skinID {
    KeniosConfig *c = [KeniosConfig sharedInstance];
    c.vehicleSkinID = skinID;
    KENIOS_LOG(@"Applied vehicle skin ID: %d", skinID);
}

- (void)applyVehicleEffect:(int)effectID {
    KeniosConfig *c = [KeniosConfig sharedInstance];
    c.vehicleEffectID = effectID;
    KENIOS_LOG(@"Applied vehicle effect ID: %d", effectID);
}

- (void)applyParachuteSkin:(int)skinID {
    KeniosConfig *c = [KeniosConfig sharedInstance];
    c.parachuteSkinID = skinID;
}

- (void)applyBackpackSkin:(int)skinID {
    KeniosConfig *c = [KeniosConfig sharedInstance];
    c.backpackSkinID = skinID;
}

- (void)applyHelmetSkin:(int)skinID {
    KeniosConfig *c = [KeniosConfig sharedInstance];
    c.helmetSkinID = skinID;
}

- (void)applyAllBestSkins {
    [self applyWeaponSkin:2];
    [self applyCharacterSkin:101];
    [self applyVehicleSkin:271];
    [self applyVehicleEffect:7];
    [self applyParachuteSkin:303];
    [self applyBackpackSkin:331];
    [self applyHelmetSkin:351];
    KENIOS_LOG(@"Applied all best skins");
}

- (void)randomizeSkins {
    [self applyWeaponSkin:arc4random_uniform(76) + 1];
    [self applyCharacterSkin:arc4random_uniform(55) + 100];
    [self applyVehicleSkin:arc4random_uniform(94) + 200];
    [self applyVehicleEffect:arc4random_uniform(10) + 1];
    [self applyParachuteSkin:arc4random_uniform(11) + 300];
    [self applyBackpackSkin:arc4random_uniform(16) + 320];
    [self applyHelmetSkin:arc4random_uniform(16) + 340];
    KENIOS_LOG(@"Randomized all skins");
}

- (NSDictionary *)getSkinInfo:(int)skinID {
    for (NSString *key in self.skinsDB) {
        NSArray *items = self.skinsDB[key];
        if ([items isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item in items) {
                if ([item[@"skinID"] intValue] == skinID) return item;
            }
        }
    }
    return nil;
}
@end
