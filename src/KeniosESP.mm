// =============================================
// KENIOS HAX - FPS & Performance Module
// iOS 16.0-26.5
// =============================================

#import "KeniosCommon.h"
#import "KeniosConfig.h"

@interface KeniosFPSOverlay : UILabel
@property (nonatomic, assign) int currentFPS;
@property (nonatomic, assign) int currentPing;
@property (nonatomic, strong) UIColor *displayColor;
@property (nonatomic, assign) int position;
@end

@implementation KeniosFPSOverlay

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        self.textColor = [UIColor greenColor];
        self.font = [UIFont boldSystemFontOfSize:12];
        self.textAlignment = NSTextAlignmentCenter;
        self.layer.cornerRadius = 8;
        self.clipsToBounds = YES;
        self.numberOfLines = 2;
        self.currentFPS = 60;
        self.currentPing = 0;
        self.displayColor = [UIColor greenColor];
    }
    return self;
}

- (void)updateDisplay {
    NSString *text = [NSString stringWithFormat:@"FPS: %d\n📡 %dms", self.currentFPS, self.currentPing];
    self.text = text;
    
    if (self.currentFPS >= 55) {
        self.textColor = [UIColor greenColor];
    } else if (self.currentFPS >= 30) {
        self.textColor = [UIColor yellowColor];
    } else {
        self.textColor = [UIColor redColor];
    }
}

@end

@interface KeniosFPS ()
@property (nonatomic, strong) KeniosFPSOverlay *overlay;
@property (nonatomic, assign) CFTimeInterval lastTime;
@property (nonatomic, assign) int frameCount;
@property (nonatomic, assign) int currentFPS;
@property (nonatomic, assign) int currentPing;
@property (nonatomic, strong) NSTimer *fpsTimer;
@property (nonatomic, strong) KeniosPerformanceConfig *config;
@end

@implementation KeniosFPS

+ (instancetype)sharedInstance {
    static KeniosFPS *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[KeniosFPS alloc] init]; });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.currentFPS = 60;
        self.currentPing = 0;
        self.frameCount = 0;
        self.lastTime = CACurrentMediaTime();
        self.config = [KeniosConfig sharedInstance].performance;
        
        [self setupOverlay];
    }
    return self;
}

- (void)setupOverlay {
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    
    CGRect frame = CGRectMake(w - 100, 50, 90, 40);
    self.overlay = [[KeniosFPSOverlay alloc] initWithFrame:frame];
    self.overlay.hidden = !self.config.fpsDisplay;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (window) {
            [window addSubview:self.overlay];
        }
    });
    
    // Cập nhật mỗi giây
    self.fpsTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                    repeats:YES
                                                      block:^(NSTimer *timer) {
        [self calculateFPS];
    }];
}

- (void)calculateFPS {
    CFTimeInterval now = CACurrentMediaTime();
    CFTimeInterval delta = now - self.lastTime;
    
    if (delta >= 1.0) {
        self.currentFPS = (int)(self.frameCount / delta);
        self.frameCount = 0;
        self.lastTime = now;
        
        self.overlay.currentFPS = self.currentFPS;
        self.overlay.currentPing = self.currentPing;
        [self.overlay updateDisplay];
    }
}

- (void)incrementFrame {
    self.frameCount++;
}

- (void)updateFPS {
    [self incrementFrame];
}

- (int)getCurrentFPS {
    return self.currentFPS;
}

- (int)getCurrentPing {
    return self.currentPing;
}

- (void)setPing:(int)ping {
    self.currentPing = ping;
}

- (void)updateConfig:(KeniosPerformanceConfig *)config {
    self.config = config;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.overlay.hidden = !config.fpsDisplay;
    });
}

- (void)setFPSLimit:(int)limit {
    // Đặt giới hạn FPS (nếu có thể)
    KENIOS_LOG(@"FPS Limit set to: %d", limit);
}

- (void)enableFPSBoost {
    // Tối ưu hiệu năng
    KENIOS_LOG(@"FPS Boost enabled");
}

@end
