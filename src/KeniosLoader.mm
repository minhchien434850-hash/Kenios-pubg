// KeniosLoader.mm – Entry point không cần jailbreak
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import "KeniosCommon.h"
#import "KeniosConfig.h"

uint64_t g_UE4Base = 0;
uint64_t g_GWorld = 0;
BOOL g_isHackInitialized = NO;
BOOL g_isKeyValid = YES;   // Bỏ qua key cho dễ test
BOOL g_isIPAValid = YES;

// Forward declarations
@interface KeniosMainController : NSObject
+ (instancetype)sharedInstance;
- (void)initialize;
@end

__attribute__((constructor))
static void kenios_auto_init() {
    // Chờ game load xong (3 giây)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[KeniosMainController sharedInstance] initialize];
    });
}
