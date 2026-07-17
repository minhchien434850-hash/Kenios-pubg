#import "KeniosCommon.h"
#import "KeniosOffsets.h"
#import "KeniosConfig.h"

@interface KeniosMagicBullet ()
@property (nonatomic, strong) KeniosMagicBulletConfig *config;
@end

@implementation KeniosMagicBullet

+ (instancetype)sharedInstance {
    static KeniosMagicBullet *i = nil; static dispatch_once_t t; dispatch_once(&t, ^{ i = [[KeniosMagicBullet alloc] init]; }); return i;
}

- (instancetype)init { self = [super init]; if (self) self.config = [KeniosConfig sharedInstance].magicBullet; return self; }

- (void)processMagicBullet {
    if (!self.config.enabled || !g_GWorld) return;
    KeniosOffsets *o = [KeniosOffsets sharedInstance];
    uint64_t lc = [self getLocalController];
    if (!lc) return;
    uint64_t lp = *(uint64_t *)(lc + o.Pawn);
    if (!lp) return;
    uint64_t lps = *(uint64_t *)(lp + o.PlayerState);
    int lt = lps ? *(int *)(lps + o.TeamID) : -1;
    KeniosVector3 lpos = [self getPosition:lp];
    
    uint64_t pl = *(uint64_t *)(g_GWorld + o.PersistentLevel);
    if (!pl) return;
    uint64_t aa = pl + o.Actors;
    int ac = *(int *)(aa + 0x8);
    if (ac <= 0 || ac > 50000) return;
    uint64_t ap = *(uint64_t *)(aa);
    if (!ap) return;
    
    for (int i = 0; i < ac; i++) {
        uint64_t actor = *(uint64_t *)(ap + i * 8);
        if (!actor || actor == lp) continue;
        uint64_t ps = *(uint64_t *)(actor + o.PlayerState);
        if (!ps) continue;
        int tid = *(int *)(ps + o.TeamID);
        if (tid == lt) continue;
        KeniosVector3 tpos = [self getPosition:actor];
        float dx = tpos.x - lpos.x, dy = tpos.y - lpos.y, dz = tpos.z - lpos.z;
        float dist = sqrt(dx*dx+dy*dy+dz*dz) / 100.0f;
        if (dist < self.config.radius) {
            *(KeniosVector3 *)(actor + o.RelativeLocation) = lpos;
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

- (KeniosVector3)getPosition:(uint64_t)pawn {
    KeniosOffsets *o = [KeniosOffsets sharedInstance];
    uint64_t rc = *(uint64_t *)(pawn + o.RootComponent);
    if (rc) return *(KeniosVector3 *)(rc + o.ComponentToWorld + o.Translation);
    return (KeniosVector3){0,0,0};
}
@end
