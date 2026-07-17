
---

### 📄 File 5: `src/KeniosSafeMode.mm` (chống crash)

```objc
#import "KeniosCommon.h"
#import "KeniosConfig.h"

@interface KeniosSafeMode : NSObject
+ (instancetype)sharedInstance;
- (void)enableSafeMode;
- (void)disableSafeMode;
@end

@implementation KeniosSafeMode {
    BOOL _safeModeActive;
    int _crashCount;
}

+ (instancetype)sharedInstance {
    static KeniosSafeMode *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[KeniosSafeMode alloc] init]; });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _safeModeActive = NO;
        _crashCount = 0;
        NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    }
    return self;
}

void uncaughtExceptionHandler(NSException *exception) {
    [[KeniosSafeMode sharedInstance] handleException:exception];
}

- (void)handleException:(NSException *)exception {
    KENIOS_LOG_ERROR(@"CRASH: %@ - %@", exception.name, exception.reason);
    _crashCount++;
    if (_crashCount >= 3) {
        [self enableSafeMode];
    }
}

- (void)enableSafeMode {
    if (_safeModeActive) return;
    _safeModeActive = YES;
    KENIOS_LOG_WARN(@"⚠️ SAFE MODE ACTIVATED");
    [KeniosConfig sharedInstance].aimbot.enabled = NO;
    [KeniosConfig sharedInstance].magicBullet.enabled = NO;
    [KeniosConfig sharedInstance].movement.speedHack = NO;
    [KeniosConfig sharedInstance].movement.flyMode = NO;
    [KeniosConfig sharedInstance].antiBan.mode = KeniosAntiBanModeSafe;
}

- (void)disableSafeMode {
    _safeModeActive = NO;
    _crashCount = 0;
    [[KeniosConfig sharedInstance] loadDefaults];
}

- (BOOL)isSafeModeActive { return _safeModeActive; }

@end
