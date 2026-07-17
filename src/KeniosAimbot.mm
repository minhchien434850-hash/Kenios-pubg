#import "KeniosCommon.h"
#import "KeniosOffsets.h"
#import "KeniosConfig.h"
#import "KeniosAntiBanPro.h"

@interface KeniosAimbot ()
@property (nonatomic, strong) KeniosAimbotConfig *config;
@property (nonatomic, strong) NSMutableArray *playerList;
@property (nonatomic, assign) KeniosPlayer selectedTarget;
@property (nonatomic, assign) BOOL hasSelectedTarget;
@end

@implementation KeniosAimbot

+ (instancetype)sharedInstance {
    static KeniosAimbot *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[KeniosAimbot alloc] init]; });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) { self.playerList = [[NSMutableArray alloc] init]; self.config = [KeniosConfig sharedInstance].aimbot; }
    return self;
}

- (void)processAimbot {
    if (!self.config.enabled || !g_GWorld || !g_UE4Base) return;
    if ([[KeniosAntiBanPro sharedInstance] shouldDisableFeature:@"aimbot"]) return;
    
    KeniosOffsets *o = [KeniosOffsets sharedInstance];
    uint64_t localController = [self getLocalPlayerController];
    if (!localController) return;
    uint64_t localPawn = *(uint64_t *)(localController + o.Pawn);
    if (!localPawn) return;
    uint64_t localPlayerState = *(uint64_t *)(localPawn + o.PlayerState);
    int localTeamID = localPlayerState ? *(int *)(localPlayerState + o.TeamID) : -1;
    
    uint64_t cameraManager = *(uint64_t *)(localController + o.PlayerCameraManager);
    if (!cameraManager) return;
    
    KeniosVector3 cameraPos = *(KeniosVector3 *)(cameraManager + o.CameraCache);
    KeniosMatrix4x4 viewMatrix = *(KeniosMatrix4x4 *)(cameraManager + o.ViewMatrix);
    
    [self scanPlayers:localPawn localTeamID:localTeamID cameraPos:cameraPos];
    if ([self findBestTarget:cameraPos viewMatrix:viewMatrix]) {
        KeniosPlayer target = self.selectedTarget;
        [self aimAtTarget:&target cameraPos:cameraPos localController:localController];
    }
}

- (uint64_t)getLocalPlayerController {
    KeniosOffsets *o = [KeniosOffsets sharedInstance];
    uint64_t gameInstance = *(uint64_t *)(g_GWorld + o.OwningGameInstance);
    if (!gameInstance) return 0;
    uint64_t localPlayers = *(uint64_t *)(gameInstance + 0x38);
    if (!localPlayers) return 0;
    return *(uint64_t *)localPlayers;
}

- (void)scanPlayers:(uint64_t)localPawn localTeamID:(int)localTeamID cameraPos:(KeniosVector3)cameraPos {
    [self.playerList removeAllObjects];
    KeniosOffsets *o = [KeniosOffsets sharedInstance];
    uint64_t persistentLevel = *(uint64_t *)(g_GWorld + o.PersistentLevel);
    if (!persistentLevel) return;
    uint64_t actorsArray = persistentLevel + o.Actors;
    int actorCount = *(int *)(actorsArray + 0x8);
    if (actorCount <= 0 || actorCount > 50000) return;
    uint64_t actorsPtr = *(uint64_t *)(actorsArray);
    if (!actorsPtr) return;
    
    for (int i = 0; i < actorCount; i++) {
        uint64_t actor = *(uint64_t *)(actorsPtr + i * 8);
        if (!actor || actor == localPawn) continue;
        uint64_t mesh = *(uint64_t *)(actor + o.Mesh);
        if (!mesh) continue;
        uint64_t playerState = *(uint64_t *)(actor + o.PlayerState);
        if (!playerState) continue;
        
        KeniosPlayer p;
        memset(&p, 0, sizeof(KeniosPlayer));
        p.address = actor; p.meshAddress = mesh;
        p.teamID = *(int *)(playerState + o.TeamID);
        p.isBot = *(BOOL *)(playerState + o.bIsABot);
        p.health = *(float *)(playerState + o.Health);
        p.isTeammate = (p.teamID == localTeamID);
        p.isAlive = (p.health > 0);
        [self getBonePositions:&p];
        KeniosVector3 delta = {p.pelvis.x - cameraPos.x, p.pelvis.y - cameraPos.y, p.pelvis.z - cameraPos.z};
        p.distance = sqrt(delta.x*delta.x + delta.y*delta.y + delta.z*delta.z) / 100.0f;
        [self.playerList addObject:[NSValue valueWithBytes:&p objCType:@encode(KeniosPlayer)]];
    }
}

- (void)getBonePositions:(KeniosPlayer *)p {
    KeniosOffsets *o = [KeniosOffsets sharedInstance];
    uint64_t boneArray = *(uint64_t *)(p->meshAddress + o.ComponentSpaceTransformsArray);
    if (!boneArray) return;
    uint64_t ctw = p->meshAddress + o.ComponentToWorld;
    KeniosVector3 wp = *(KeniosVector3 *)(ctw + o.Translation);
    #define GB(idx, dest) { uint64_t ba = boneArray + (idx * 0x40); KeniosVector3 lp = *(KeniosVector3 *)(ba + o.Translation); dest.x = lp.x + wp.x; dest.y = lp.y + wp.y; dest.z = lp.z + wp.z; }
    GB(o.BONE_HEAD, p->head); GB(o.BONE_NECK, p->neck); GB(o.BONE_CHEST, p->chest); GB(o.BONE_PELVIS, p->pelvis);
    GB(o.BONE_LEFT_SHOULDER, p->leftShoulder); GB(o.BONE_RIGHT_SHOULDER, p->rightShoulder);
    GB(o.BONE_LEFT_ELBOW, p->leftElbow); GB(o.BONE_RIGHT_ELBOW, p->rightElbow);
    GB(o.BONE_LEFT_WRIST, p->leftWrist); GB(o.BONE_RIGHT_WRIST, p->rightWrist);
    GB(o.BONE_LEFT_KNEE, p->leftKnee); GB(o.BONE_RIGHT_KNEE, p->rightKnee);
    GB(o.BONE_LEFT_FOOT, p->leftFoot); GB(o.BONE_RIGHT_FOOT, p->rightFoot);
    #undef GB
}

- (BOOL)findBestTarget:(KeniosVector3)cameraPos viewMatrix:(KeniosMatrix4x4)vm {
    KeniosPlayer best;
    BOOL found = NO;
    float bestScore = -999999;
    CGFloat sw = [UIScreen mainScreen].bounds.size.width, sh = [UIScreen mainScreen].bounds.size.height;
    KeniosVector2 sc = {sw/2, sh/2};
    for (NSValue *v in self.playerList) {
        KeniosPlayer p;
        [v getValue:&p];
        if (!p.isAlive || (p.isTeammate && !self.config.aimTeammates)) continue;
        if (p.isBot && !self.config.aimOnBots) continue;
        if (!p.isBot && !self.config.aimOnPlayers) continue;
        if (p.distance > self.config.maxDistance) continue;
        KeniosVector3 tp = self.config.targetBone == KeniosAimTargetHead ? p.head : self.config.targetBone == KeniosAimTargetNeck ? p.neck : self.config.targetBone == KeniosAimTargetChest ? p.chest : p.pelvis;
        float w = vm.m[3][0]*tp.x + vm.m[3][1]*tp.y + vm.m[3][2]*tp.z + vm.m[3][3];
        if (w < 0.01f) continue;
        float sx = (vm.m[0][0]*tp.x + vm.m[0][1]*tp.y + vm.m[0][2]*tp.z + vm.m[0][3]) / w;
        float sy = (vm.m[1][0]*tp.x + vm.m[1][1]*tp.y + vm.m[1][2]*tp.z + vm.m[1][3]) / w;
        sx = (sx*0.5f+0.5f)*sw; sy = (1.0f-sy*0.5f-0.5f)*sh;
        if (sx < 0 || sx > sw || sy < 0 || sy > sh) continue;
        float dx = sx - sc.x, dy = sy - sc.y;
        float angle = atan2(sqrt(dx*dx+dy*dy), 500.0f) * (180.0f/M_PI);
        if (angle > self.config.fov/2.0f) continue;
        float score = (1.0f-angle/(self.config.fov/2.0f))*1000.0f + (1.0f-p.distance/self.config.maxDistance)*500.0f;
        if (p.isBot) score *= 0.7f;
        if (score > bestScore) { bestScore = score; best = p; found = YES; }
    }
    self.hasSelectedTarget = found;
    if (found) self.selectedTarget = best;
    return found;
}

- (void)aimAtTarget:(KeniosPlayer *)t cameraPos:(KeniosVector3)cp localController:(uint64_t)lc {
    KeniosOffsets *o = [KeniosOffsets sharedInstance];
    KeniosVector3 tp = self.config.targetBone == KeniosAimTargetHead ? t->head : self.config.targetBone == KeniosAimTargetNeck ? t->neck : self.config.targetBone == KeniosAimTargetChest ? t->chest : t->pelvis;
    KeniosVector3 dir = {tp.x - cp.x, tp.y - cp.y, (tp.z+20.0f) - cp.z};
    float ny = atan2(dir.y, dir.x) * (180.0f/M_PI);
    float hd = sqrt(dir.x*dir.x + dir.y*dir.y);
    float np = atan2(dir.z, hd) * (180.0f/M_PI);
    if (ny > 180.0f) ny -= 360.0f; if (ny < -180.0f) ny += 360.0f;
    uint64_t cra = lc + o.ControlRotation;
    float cy = *(float *)(cra), cp2 = *(float *)(cra + 4);
    float dy = ny - cy, dp = np - cp2;
    if (dy > 180.0f) dy -= 360.0f; if (dy < -180.0f) dy += 360.0f;
    float smooth = self.config.smooth;
    float fy = cy + dy/smooth, fp = cp2 + dp/smooth;
    if ([KeniosAntiBanPro sharedInstance].isInSafeMode) {
        fy = [[KeniosAntiBanPro sharedInstance] getHumanizedAimAngle:fy];
        fp = [[KeniosAntiBanPro sharedInstance] getHumanizedAimAngle:fp];
    }
    *(float *)(cra) = fy; *(float *)(cra + 4) = fp;
}

- (void)updateConfig:(KeniosAimbotConfig *)c { self.config = c; }
@end
