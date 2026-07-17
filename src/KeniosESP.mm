#import "KeniosCommon.h"
#import "KeniosConfig.h"

@interface KeniosESP ()
@property (nonatomic, strong) NSArray *activeBombs;
@end

@implementation KeniosESP

+ (instancetype)sharedInstance {
    static KeniosESP *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[KeniosESP alloc] init]; });
    return instance;
}

- (void)renderESP {
    if (![KeniosConfig sharedInstance].esp.enabled || !g_GWorld) return;
}

- (void)updateBombs:(NSArray *)bombs {
    self.activeBombs = [bombs copy];
}

@end
