#import "KeniosCommon.h"

@interface KeniosNetwork ()
@property (nonatomic, assign) int currentPing;
@end

@implementation KeniosNetwork

+ (instancetype)sharedInstance {
    static KeniosNetwork *i = nil; static dispatch_once_t t; dispatch_once(&t, ^{ i = [[KeniosNetwork alloc] init]; }); return i;
}

- (void)startMonitoring { self.currentPing = 0; }
- (int)getCurrentPing { return self.currentPing; }
@end
