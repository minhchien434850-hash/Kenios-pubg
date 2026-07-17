#import "KeniosCommon.h"
#import "KeniosConfig.h"

static int hooked_sysctl(int *name, u_int namelen, void *oldp, size_t *oldlenp, void *newp, size_t newlen);
static int hooked_sysctlbyname(const char *name, void *oldp, size_t *oldlenp, void *newp, size_t newlen);

@interface KeniosAntiBanPro ()
@property (nonatomic, assign) KeniosAntiBanMode currentMode;
@property (nonatomic, assign) int banWarningCount;
@property (nonatomic, assign) int killsThisMatch;
@property (nonatomic, assign) int headshotsThisMatch;
@property (nonatomic, assign) BOOL isActive;
@end

@implementation KeniosAntiBanPro

+ (instancetype)sharedInstance {
    static KeniosAntiBanPro *i = nil; static dispatch_once_t t; dispatch_once(&t, ^{ i = [[KeniosAntiBanPro alloc] init]; }); return i;
}

- (instancetype)init {
    self = [super init];
    if (self) { self.currentMode = KeniosAntiBanModeAuto; self.isActive = YES; }
    return self;
}

- (void)startMonitoring { self.isActive = YES; KENIOS_LOG(@"Anti-Ban monitoring started"); }
- (void)stopMonitoring { self.isActive = NO; }

- (NSArray *)detectAntiCheatModules {
    NSMutableArray *detected = [NSMutableArray new];
    uint32_t count = _dyld_image_count();
    NSArray *targets = @[@"ACE", @"TPProtect", @"MTP", @"tersafe", @"GCloud", @"bugly"];
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name) {
            NSString *mn = [NSString stringWithUTF8String:name];
            for (NSString *t in targets) { if ([mn containsString:t]) [detected addObject:t]; }
        }
    }
    return detected;
}

- (BOOL)isBeingSpectated { return NO; }
- (BOOL)isBeingReported { return NO; }

- (void)bypassJailbreakDetection {
    MSHookFunction(dlsym(RTLD_DEFAULT, "sysctl"), (void *)&hooked_sysctl, NULL);
    MSHookFunction(dlsym(RTLD_DEFAULT, "sysctlbyname"), (void *)&hooked_sysctlbyname, NULL);
}

static int hooked_sysctl(int *name, u_int namelen, void *oldp, size_t *oldlenp, void *newp, size_t newlen) {
    return 0;
}

static int hooked_sysctlbyname(const char *name, void *oldp, size_t *oldlenp, void *newp, size_t newlen) {
    return 0;
}

- (void)bypassDebuggerDetection {}
- (void)bypassMemoryScanners {}
- (void)bypassIntegrityChecks {}
- (void)bypassHookDetection {}
- (void)blockAnalytics {}
- (void)blockCrashReports {}
- (void)blockTelemetry {}
- (void)monitorNetworkTraffic {}

- (void)switchToSafeMode { self.currentMode = KeniosAntiBanModeSafe; }
- (void)switchToAggressiveMode { self.currentMode = KeniosAntiBanModeAggressive; }
- (void)autoSwitchMode {
    if (self.banWarningCount >= 2) [self switchToSafeMode];
}

- (BOOL)shouldDisableFeature:(NSString *)feature { return NO; }

- (float)getHumanizedAimAngle:(float)angle {
    float randomOffset = ((float)(arc4random() % 100) / 100.0f - 0.5f) * 2.0f;
    return angle + randomOffset * 0.5f;
}

- (float)getRandomMissChance { return 5.0f; }
- (float)getReactionDelay { return 0.2f; }
- (void)checkForBanMessages {}
- (void)handleBanWarning { self.banWarningCount++; [self autoSwitchMode]; }
- (BOOL)isAccountFlagged { return self.banWarningCount > 0; }
- (void)trackKill { self.killsThisMatch++; }
- (void)trackHeadshot { self.headshotsThisMatch++; }
- (float)getHeadshotPercentage { return self.killsThisMatch > 0 ? (float)self.headshotsThisMatch / self.killsThisMatch * 100.0f : 0; }
- (int)getKillsThisMatch { return self.killsThisMatch; }
- (void)resetMatchStats { self.killsThisMatch = 0; self.headshotsThisMatch = 0; }
- (BOOL)isInSafeMode { return self.currentMode == KeniosAntiBanModeSafe; }
@end
