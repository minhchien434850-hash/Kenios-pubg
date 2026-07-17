#import "KeniosCommon.h"
#import "KeniosOffsets.h"
#import "KeniosConfig.h"
#import "KeniosESP.h"

@interface KeniosBombAlert ()
@property (nonatomic, strong) KeniosBombAlertConfig *config;
@property (nonatomic, strong) NSMutableArray *activeBombs;
@end

@implementation KeniosBombAlert

+ (instancetype)sharedInstance {
    static KeniosBombAlert *i = nil; static dispatch_once_t t; dispatch_once(&t, ^{ i = [[KeniosBombAlert alloc] init]; }); return i;
}

- (instancetype)init {
    self = [super init];
    if (self) { self.activeBombs = [NSMutableArray new]; self.config = [KeniosConfig sharedInstance].bombAlert; }
    return self;
}

- (void)clearActiveBombs {
    for (NSValue *v in self.activeBombs) {
        KeniosBomb *bomb = (KeniosBomb *)[v pointerValue];
        if (bomb) free(bomb);
    }
    [self.activeBombs removeAllObjects];
}

- (void)scanForBombs {
    if (!self.config.enabled || !g_GWorld) return;
    [self clearActiveBombs];
    KeniosOffsets *o = [KeniosOffsets sharedInstance];
    uint64_t persistentLevel = *(uint64_t *)(g_GWorld + o.PersistentLevel);
    if (!persistentLevel) return;
    uint64_t actorsArray = persistentLevel + o.Actors;
    int actorCount = *(int *)(actorsArray + 0x8);
    if (actorCount <= 0 || actorCount > 50000) return;
    uint64_t actorsPtr = *(uint64_t *)(actorsArray);
    if (!actorsPtr) return;
    
    uint64_t localController = [self getLocalController];
    if (!localController) return;
    uint64_t localPawn = *(uint64_t *)(localController + o.Pawn);
    if (!localPawn) return;
    KeniosVector3 localPos = [self getPosition:localPawn];
    
    for (int i = 0; i < actorCount; i++) {
        uint64_t actor = *(uint64_t *)(actorsPtr + i * 8);
        if (!actor) continue;
        int bombType = *(int *)(actor + o.BombType);
        if (bombType == 0) continue;
        if (bombType == 1 && !self.config.alertGrenade) continue;
        if (bombType == 2 && !self.config.alertMolotov) continue;
        if (bombType == 3 && !self.config.alertC4) continue;
        
        KeniosVector3 bombPos = *(KeniosVector3 *)(actor + o.BombLocation);
        float dx = bombPos.x - localPos.x, dy = bombPos.y - localPos.y, dz = bombPos.z - localPos.z;
        float dist = sqrt(dx*dx + dy*dy + dz*dz) / 100.0f;
        if (dist > self.config.range) continue;
        
        KeniosBomb *bomb = (KeniosBomb *)malloc(sizeof(KeniosBomb));
        bomb->position = bombPos; bomb->type = bombType;
        bomb->radius = *(float *)(actor + o.ExplosionRadius);
        bomb->timeToExplode = *(float *)(actor + o.ExplosionTime);
        bomb->isActive = YES;
        [self.activeBombs addObject:[NSValue valueWithPointer:bomb]];
        
        if (self.config.vibrateAlert) AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [[NSNotificationCenter defaultCenter] postNotificationName:KENIOS_NOTIF_BOMB_DETECTED object:nil];
    }
    [[KeniosESP sharedInstance] updateBombs:self.activeBombs];
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

- (void)dealloc { [self clearActiveBombs]; }
@end
