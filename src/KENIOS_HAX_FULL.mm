// =============================================
// KENIOS HAX - MAIN ENTRY POINT (iOS 16.0-26.5)
// =============================================

#import "KeniosCommon.h"
#import "KeniosConfig.h"
#import "KeniosOffsets.h"
#import "KeniosKeyAuth.h"
#import "KeniosAntiBanPro.h"
#import "KeniosIPAValidator.h"

uint64_t g_UE4Base = 0;
uint64_t g_GWorld = 0;
BOOL g_isHackInitialized = NO;
BOOL g_isKeyValid = NO;
BOOL g_isIPAValid = NO;
NSString *g_iosVersion = nil;

static NSTimer *g_mainLoopTimer;
static NSTimer *g_heartbeatTimer;
static NSTimer *g_anticheatTimer;
static NSTimer *g_fpsTimer;
static int g_currentFPS = 60;
static int g_currentPing = 0;

@class KeniosAimbot, KeniosESP, KeniosMagicBullet, KeniosSkinChanger;
@class KeniosFPS, KeniosMenu, KeniosNetwork, KeniosBombAlert;
@class KeniosVehicleMaster, KeniosEventShop;

@interface KeniosMainController : NSObject
+ (instancetype)sharedInstance;
- (void)initialize;
- (void)shutdown;
- (void)mainLoop;
@end

@implementation KeniosMainController

+ (instancetype)sharedInstance {
    static KeniosMainController *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[KeniosMainController alloc] init]; });
    return instance;
}

- (void)initialize {
    // Lấy phiên bản iOS
    g_iosVersion = [[UIDevice currentDevice] systemVersion];
    KENIOS_LOG(@"========================================");
    KENIOS_LOG(@"  KENIOS HAX v%@ Initializing...", KENIOS_VERSION);
    KENIOS_LOG(@"  iOS Version: %@", g_iosVersion);
    KENIOS_LOG(@"  Support: iOS %@ - %@", KENIOS_IOS_MIN, KENIOS_IOS_MAX);
    KENIOS_LOG(@"========================================");
    
    // Kiểm tra phiên bản iOS
    if (![self checkiOSVersion]) {
        [self showError:@"iOS không được hỗ trợ!\nYêu cầu iOS 16.0 - 26.5"];
        return;
    }
    
    // Tìm UE4 base
    [self findUE4Base];
    if (g_UE4Base == 0) {
        [self showError:@"Không tìm thấy game engine!"];
        return;
    }
    KENIOS_LOG(@"[1/10] UE4 Base: 0x%llx", g_UE4Base);
    
    // Load offsets
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *keniosPath = [docPath stringByAppendingPathComponent:@"KeniosHax"];
    [[NSFileManager defaultManager] createDirectoryAtPath:keniosPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *offsetPath = [keniosPath stringByAppendingPathComponent:@"offsets.json"];
    if (![[KeniosOffsets sharedInstance] loadFromJSON:offsetPath]) {
        [[KeniosOffsets sharedInstance] loadFromJSON:[[NSBundle mainBundle] pathForResource:@"offsets" ofType:@"json"]];
    }
    KENIOS_LOG(@"[2/10] Offsets loaded");
    
    // Load config
    [KeniosConfig sharedInstance].currentLanguage = @"vi";
    [[KeniosConfig sharedInstance] loadDefaults];
    NSString *configPath = [keniosPath stringByAppendingPathComponent:@"config.json"];
    [[KeniosConfig sharedInstance] loadFromFile:configPath];
    KENIOS_LOG(@"[3/10] Config loaded");
    
    // Anti-Ban Pro
    [[KeniosAntiBanPro sharedInstance] startMonitoring];
    [[KeniosAntiBanPro sharedInstance] bypassJailbreakDetection];
    [[KeniosAntiBanPro sharedInstance] bypassDebuggerDetection];
    [[KeniosAntiBanPro sharedInstance] blockAnalytics];
    [[KeniosAntiBanPro sharedInstance] blockCrashReports];
    KENIOS_LOG(@"[4/10] Anti-Ban Pro activated");
    
    // Kiểm tra IPA
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        BOOL ipaValid = [[KeniosIPAValidator sharedInstance] validateCurrentIPA];
        g_isIPAValid = ipaValid;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!ipaValid) {
                KENIOS_LOG(@"IPA validation failed!");
                [[KeniosIPAValidator sharedInstance] showIPAInvalidAlert];
            } else {
                KENIOS_LOG(@"[5/10] IPA validated");
                [self continueInit];
            }
        });
    });
}

- (BOOL)checkiOSVersion {
    float version = [g_iosVersion floatValue];
    return (version >= 16.0 && version <= 26.5);
}

- (void)continueInit {
    // Key check
    [[KeniosKeyAuth sharedInstance] loadKeyData];
    if (![[KeniosKeyAuth sharedInstance] isKeyValid]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[KeniosKeyAuth sharedInstance] showKeyInputDialog];
        });
    } else {
        g_isKeyValid = YES;
        [self startAllModules];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyValidated:) name:KENIOS_NOTIF_KEY_VALIDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyExpired:) name:KENIOS_NOTIF_KEY_EXPIRED object:nil];
}

- (void)onKeyValidated:(NSNotification *)n { g_isKeyValid = YES; [self startAllModules]; }
- (void)onKeyExpired:(NSNotification *)n { g_isKeyValid = NO; [self stopAllModules]; [[KeniosKeyAuth sharedInstance] showKeyInputDialog]; }

- (void)startAllModules {
    g_mainLoopTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 repeats:YES block:^(NSTimer *t) { [self mainLoop]; }];
    g_heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 repeats:YES block:^(NSTimer *t) { [[KeniosKeyAuth sharedInstance] sendHeartbeat]; }];
    g_anticheatTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 repeats:YES block:^(NSTimer *t) { [[KeniosAntiBanPro sharedInstance] detectAntiCheatModules]; }];
    g_fpsTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer *t) { g_currentFPS = (int)(1.0 / (CACurrentMediaTime() - g_currentFPS)); }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[KeniosMenu sharedInstance] showMenu];
    });
    
    g_isHackInitialized = YES;
    KENIOS_LOG(@"KENIOS HAX Initialized Successfully!");
}

- (void)stopAllModules {
    [g_mainLoopTimer invalidate]; g_mainLoopTimer = nil;
    [g_heartbeatTimer invalidate]; g_heartbeatTimer = nil;
    [g_anticheatTimer invalidate]; g_anticheatTimer = nil;
    [g_fpsTimer invalidate]; g_fpsTimer = nil;
    [[KeniosMenu sharedInstance] hideMenu];
    g_isHackInitialized = NO;
}

- (void)mainLoop {
    if (!g_isHackInitialized || !g_isKeyValid || !g_isIPAValid) return;
    @autoreleasepool {
        KeniosOffsets *o = [KeniosOffsets sharedInstance];
        g_GWorld = *(uint64_t *)(g_UE4Base + o.GWorld);
        if (!g_GWorld) return;
        
        if ([[KeniosAntiBanPro sharedInstance] shouldDisableFeature:@"aimbot"]) return;
        
        if ([KeniosConfig sharedInstance].aimbot.enabled) [[KeniosAimbot sharedInstance] processAimbot];
        if ([KeniosConfig sharedInstance].magicBullet.enabled) [[KeniosMagicBullet sharedInstance] processMagicBullet];
        if ([KeniosConfig sharedInstance].esp.enabled) [[KeniosESP sharedInstance] renderESP];
        if ([KeniosConfig sharedInstance].bombAlert.enabled) [[KeniosBombAlert sharedInstance] scanForBombs];
        if ([KeniosConfig sharedInstance].vehicleMaster.enabled) [[KeniosVehicleMaster sharedInstance] applyVehicleMaster];
        if ([KeniosConfig sharedInstance].eventShop.enabled) [[KeniosEventShop sharedInstance] syncEventItems];
        
        [[KeniosMenu sharedInstance] updateMenuStatus];
    }
}

- (void)findUE4Base {
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && strstr(name, "libUE4")) {
            g_UE4Base = _dyld_get_image_vmaddr_slide(i) + 0x100000000;
            break;
        }
    }
}

- (void)showError:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *a = [UIAlertController alertControllerWithTitle:@"KENIOS HAX" message:msg preferredStyle:UIAlertControllerStyleAlert];
        [a addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:a animated:YES completion:nil];
    });
}

- (void)shutdown { [self stopAllModules]; [[KeniosAntiBanPro sharedInstance] stopMonitoring]; }
@end

%ctor {
    @autoreleasepool {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[KeniosMainController sharedInstance] initialize];
        });
    }
}
