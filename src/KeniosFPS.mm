#import "KeniosCommon.h"

@interface KeniosFPS ()
@property (nonatomic, assign) int currentFPS;
@property (nonatomic, assign) CFTimeInterval lastTime;
@property (nonatomic, assign) int frameCount;
@end

@implementation KeniosFPS

+ (instancetype)sharedInstance {
    static KeniosFPS *i = nil; static dispatch_once_t t; dispatch_once(&t, ^{ i = [[KeniosFPS alloc] init]; }); return i;
}

- (instancetype)init {
    self = [super init];
    if (self) { self.currentFPS = 60; self.lastTime = CACurrentMediaTime(); self.frameCount = 0; }
    return self;
}

- (void)updateFPS {
    self.frameCount++;
    CFTimeInterval now = CACurrentMediaTime();
    CFTimeInterval delta = now - self.lastTime;
    if (delta >= 1.0) {
        self.currentFPS = (int)(self.frameCount / delta);
        self.frameCount = 0;
        self.lastTime = now;
    }
}

- (int)getCurrentFPS { return self.currentFPS; }
@end
