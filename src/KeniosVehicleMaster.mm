#import "KeniosCommon.h"
#import "KeniosOffsets.h"
#import "KeniosConfig.h"

@interface KeniosVehicleMaster ()
@property (nonatomic, strong) KeniosVehicleMasterConfig *config;
@end

@implementation KeniosVehicleMaster

+ (instancetype)sharedInstance {
    static KeniosVehicleMaster *i = nil; static dispatch_once_t t; dispatch_once(&t, ^{ i = [[KeniosVehicleMaster alloc] init]; }); return i;
}

- (instancetype)init { self = [super init]; if (self) self.config = [KeniosConfig sharedInstance].vehicleMaster; return self; }

- (void)applyVehicleMaster {
    if (!self.config.enabled || !g_GWorld) return;
    KeniosOffsets *o = [KeniosOffsets sharedInstance];
    uint64_t lc = [self getLocalController];
    if (!lc) return;
    uint64_t lp = *(uint64_t *)(lc + o.Pawn);
    if (!lp) return;
    
    uint64_t pl = *(uint64_t *)(g_GWorld + o.PersistentLevel);
    if (!pl) return;
    uint64_t aa = pl + o.Actors;
    int ac = *(int *)(aa + 0x8);
    if (ac <= 0) return;
    uint64_t ap = *(uint64_t *)(aa);
    if (!ap) return;
    
    for (int i = 0; i < ac; i++) {
        uint64_t actor = *(uint64_t *)(ap + i * 8);
        if (!actor) continue;
        int vt = *(int *)(actor + o.VehicleType);
        if (vt == 0) continue;
        
        if (self.config.godMode) {
            *(float *)(actor + o.MaxSpeed) = 999999.0f;
        }
        if (self.config.speedBoost > 1.0f) {
            float ms = *(float *)(actor + o.MaxSpeed);
            *(float *)(actor + o.MaxSpeed) = ms * self.config.speedBoost;
        }
    }
}

- (uint64_t)getLocalController {
    KeniosOffsets *o = [KeniosOffsets sharedInstance];
    uint64_t gi = *(uint64_t *)(g_GWorld + o.OwningGameInstance);
    if (!gi) return 0;
    uint64_t lp = *(uint64_t *)(gi + 0x38);
    return lp ? *(uint64_t *)lp : 0;
}
@end
