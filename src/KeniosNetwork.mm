// =============================================
// KENIOS HAX - Network Monitor Module
// iOS 16.0-26.5
// =============================================

#import "KeniosCommon.h"
#import <CFNetwork/CFNetwork.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@interface KeniosNetwork ()
@property (nonatomic, assign) int currentPing;
@property (nonatomic, strong) NSTimer *pingTimer;
@property (nonatomic, strong) NSMutableArray *blockedIPs;
@property (nonatomic, strong) NSMutableArray *blockedDomains;
@property (nonatomic, assign) BOOL isMonitoring;
@end

@implementation KeniosNetwork

+ (instancetype)sharedInstance {
    static KeniosNetwork *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[KeniosNetwork alloc] init]; });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.currentPing = 0;
        self.isMonitoring = NO;
        self.blockedIPs = [[NSMutableArray alloc] init];
        self.blockedDomains = [[NSMutableArray alloc] initWithArray:@[
            @"intlgame.com",
            @"tencent.com",
            @"pubgmobile.com",
            @"bugly.qq.com",
            @"tdm.qq.com",
            @"gcloud.com",
            @"tss.qq.com"
        ]];
    }
    return self;
}

- (void)startMonitoring {
    if (self.isMonitoring) return;
    self.isMonitoring = YES;
    
    KENIOS_LOG(@"Network monitoring started");
    
    self.pingTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                     repeats:YES
                                                       block:^(NSTimer *timer) {
        [self pingServer];
    }];
    
    [self blockMaliciousDomains];
}

- (void)stopMonitoring {
    self.isMonitoring = NO;
    [self.pingTimer invalidate];
    self.pingTimer = nil;
    KENIOS_LOG(@"Network monitoring stopped");
}

- (void)pingServer {
    // Ping đơn giản đến server game
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        // Giả lập ping (thực tế cần kết nối đến server game)
        self.currentPing = 20 + arc4random_uniform(30);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[KeniosFPS sharedInstance] setPing:self.currentPing];
        });
    });
}

- (void)blockMaliciousDomains {
    // Chặn các domain thu thập dữ liệu
    for (NSString *domain in self.blockedDomains) {
        [self blockDomain:domain];
    }
    KENIOS_LOG(@"Blocked %lu malicious domains", (unsigned long)self.blockedDomains.count);
}

- (void)blockDomain:(NSString *)domain {
    // Sử dụng /etc/hosts hoặc hook DNS resolution
    // Trên iOS jailbreak, có thể sửa file hosts
    NSString *hostsPath = @"/etc/hosts";
    NSString *entry = [NSString stringWithFormat:@"127.0.0.1 %@\n127.0.0.1 *.%@\n", domain, domain];
    
    // Ghi vào hosts (cần quyền root)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:hostsPath];
        if (fileHandle) {
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:[entry dataUsingEncoding:NSUTF8StringEncoding]];
            [fileHandle closeFile];
        }
    });
}

- (int)getCurrentPing {
    return self.currentPing;
}

- (void)addBlockedDomain:(NSString *)domain {
    if (![self.blockedDomains containsObject:domain]) {
        [self.blockedDomains addObject:domain];
        [self blockDomain:domain];
    }
}

- (void)removeBlockedDomain:(NSString *)domain {
    [self.blockedDomains removeObject:domain];
}

- (NSArray *)getBlockedDomains {
    return [self.blockedDomains copy];
}

@end
