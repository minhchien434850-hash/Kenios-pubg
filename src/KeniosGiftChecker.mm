// =============================================
// KENIOS HAX - GIFT CHECKER MODULE
// Kiểm tra và nhận quà tặng tự động
// =============================================

#import "KeniosCommon.h"
#import "KeniosConfig.h"
#import "KeniosGiftChecker.h"

@implementation KeniosGiftItem
@end

@interface KeniosGiftChecker ()
@property (nonatomic, strong) NSTimer *autoCheckTimer;
@end

@implementation KeniosGiftChecker

+ (instancetype)sharedInstance {
    static KeniosGiftChecker *i = nil;
    static dispatch_once_t t;
    dispatch_once(&t, ^{ i = [[KeniosGiftChecker alloc] init]; });
    return i;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.availableGifts = [NSMutableArray new];
        self.unclaimedCount = 0;
        [self loadConfig];
    }
    return self;
}

- (void)loadConfig {
    self.config = [KeniosConfig sharedInstance].giftChecker;
    if (!self.config) {
        self.config = [[KeniosGiftCheckerConfig alloc] init];
        self.config.enabled = YES;
        self.config.autoCheck = YES;
        self.config.notifyOnNewGift = YES;
        self.config.autoClaim = NO;
        self.config.checkIntervalMinutes = 30;
        self.config.claimedGiftIDs = [NSMutableArray new];
    }
}

- (void)startAutoCheck {
    if (!self.config.enabled || !self.config.autoCheck) return;
    [self stopAutoCheck];
    NSTimeInterval interval = self.config.checkIntervalMinutes * 60.0;
    self.autoCheckTimer = [NSTimer scheduledTimerWithTimeInterval:interval repeats:YES block:^(NSTimer *t) {
        [self checkGiftsNow:^(NSArray<KeniosGiftItem *> *gifts, NSError *error) {
            if (error) {
                KENIOS_LOG(@"[GiftChecker] Auto-check error: %@", error.localizedDescription);
                return;
            }
            NSArray<KeniosGiftItem *> *unclaimed = [self getUnclaimedGifts];
            self.unclaimedCount = (int)unclaimed.count;
            KENIOS_LOG(@"[GiftChecker] Auto-check: %d unclaimed gifts", self.unclaimedCount);
            if (self.unclaimedCount > 0 && self.config.notifyOnNewGift) {
                [self showNewGiftNotification:self.unclaimedCount];
            }
            if (self.unclaimedCount > 0 && self.config.autoClaim) {
                [self claimAllGifts:^(int claimed, int failed) {
                    KENIOS_LOG(@"[GiftChecker] Auto-claimed: %d, failed: %d", claimed, failed);
                }];
            }
        }];
    }];
    // Run an immediate check
    [self checkGiftsNow:nil];
    KENIOS_LOG(@"[GiftChecker] Auto-check started (every %d min)", self.config.checkIntervalMinutes);
}

- (void)stopAutoCheck {
    [self.autoCheckTimer invalidate];
    self.autoCheckTimer = nil;
}

- (void)checkGiftsNow:(void(^)(NSArray<KeniosGiftItem *> *gifts, NSError *error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/gifts/check",
                      [KeniosConfig sharedInstance].serverURL]];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url
                                    cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                    timeoutInterval:15.0];
        req.HTTPMethod = @"GET";
        [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];

        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:req
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error || !data) {
                // Offline fallback: return cached gifts
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) completion([self.availableGifts copy], nil);
                });
                return;
            }
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *rawGifts = json[@"gifts"];
            NSMutableArray<KeniosGiftItem *> *parsed = [NSMutableArray new];
            for (NSDictionary *d in rawGifts) {
                KeniosGiftItem *item = [[KeniosGiftItem alloc] init];
                item.giftID   = [d[@"id"] intValue];
                item.name     = d[@"name"] ?: @"Unknown Gift";
                item.descriptionText = d[@"description"] ?: @"";
                item.type     = (KeniosGiftType)[d[@"type"] integerValue];
                item.rarity   = (KeniosGiftRarity)[d[@"rarity"] integerValue];
                item.quantity = [d[@"quantity"] intValue] ?: 1;
                item.isClaimed = [self.config.claimedGiftIDs containsObject:@(item.giftID)];
                if (d[@"expiry"]) {
                    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
                    fmt.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
                    item.expiryDate = [fmt dateFromString:d[@"expiry"]];
                }
                [parsed addObject:item];
            }
            self.availableGifts = parsed;
            self.config.lastCheckDate = [NSDate date];
            self.unclaimedCount = (int)[self getUnclaimedGifts].count;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion([self.availableGifts copy], nil);
            });
        }];
        [task resume];
    });
}

- (void)claimGift:(int)giftID completion:(void(^)(BOOL success, NSString *message))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/gifts/claim",
                      [KeniosConfig sharedInstance].serverURL]];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        req.HTTPMethod = @"POST";
        [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        req.HTTPBody = [NSJSONSerialization dataWithJSONObject:@{@"gift_id": @(giftID)} options:0 error:nil];

        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:req
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            BOOL success = NO;
            NSString *message = @"Lỗi kết nối";
            if (data && !error) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                success = [json[@"success"] boolValue];
                message = json[@"message"] ?: (success ? @"Nhận quà thành công!" : @"Thất bại");
                if (success) {
                    [self.config.claimedGiftIDs addObject:@(giftID)];
                    for (KeniosGiftItem *item in self.availableGifts) {
                        if (item.giftID == giftID) { item.isClaimed = YES; break; }
                    }
                    self.unclaimedCount = (int)[self getUnclaimedGifts].count;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(success, message);
            });
        }];
        [task resume];
    });
}

- (void)claimAllGifts:(void(^)(int claimed, int failed))completion {
    NSArray<KeniosGiftItem *> *unclaimed = [self getUnclaimedGifts];
    if (unclaimed.count == 0) {
        if (completion) completion(0, 0);
        return;
    }
    __block int claimed = 0, failed = 0;
    dispatch_group_t group = dispatch_group_create();
    for (KeniosGiftItem *item in unclaimed) {
        dispatch_group_enter(group);
        [self claimGift:item.giftID completion:^(BOOL success, NSString *msg) {
            if (success) claimed++; else failed++;
            dispatch_group_leave(group);
        }];
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completion) completion(claimed, failed);
    });
}

- (NSArray<KeniosGiftItem *> *)getUnclaimedGifts {
    NSMutableArray<KeniosGiftItem *> *result = [NSMutableArray new];
    for (KeniosGiftItem *item in self.availableGifts) {
        if (!item.isClaimed) [result addObject:item];
    }
    return [result copy];
}

- (NSArray<KeniosGiftItem *> *)getGiftsByType:(KeniosGiftType)type {
    NSMutableArray<KeniosGiftItem *> *result = [NSMutableArray new];
    for (KeniosGiftItem *item in self.availableGifts) {
        if (item.type == type) [result addObject:item];
    }
    return [result copy];
}

- (void)showGiftCheckerUI {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self checkGiftsNow:^(NSArray<KeniosGiftItem *> *gifts, NSError *error) {
            NSArray<KeniosGiftItem *> *unclaimed = [self getUnclaimedGifts];
            NSString *msg;
            if (unclaimed.count == 0) {
                msg = @"🎁 Không có quà nào mới!\nTất cả quà đã được nhận.";
            } else {
                NSMutableString *list = [NSMutableString new];
                for (KeniosGiftItem *item in unclaimed) {
                    NSString *rarityStr = @"";
                    switch (item.rarity) {
                        case KeniosGiftRarityLegendary: rarityStr = @"🟡"; break;
                        case KeniosGiftRarityEpic:      rarityStr = @"🟣"; break;
                        case KeniosGiftRarityRare:      rarityStr = @"🔵"; break;
                        case KeniosGiftRarityUncommon:  rarityStr = @"🟢"; break;
                        default:                        rarityStr = @"⚪"; break;
                    }
                    [list appendFormat:@"%@ %@ (x%d)\n", rarityStr, item.name, item.quantity];
                }
                msg = [NSString stringWithFormat:@"🎁 %d quà chưa nhận:\n\n%@", (int)unclaimed.count, list];
            }

            UIAlertController *alert = [UIAlertController
                alertControllerWithTitle:@"🎁 KENIOS - Kiểm Tra Quà Tặng"
                message:msg
                preferredStyle:UIAlertControllerStyleAlert];

            if (unclaimed.count > 0) {
                [alert addAction:[UIAlertAction actionWithTitle:@"Nhận Tất Cả" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
                    [self claimAllGifts:^(int c, int f) {
                        NSString *result = [NSString stringWithFormat:@"✅ Nhận thành công: %d\n❌ Thất bại: %d", c, f];
                        UIAlertController *ok = [UIAlertController alertControllerWithTitle:@"Kết Quả" message:result preferredStyle:UIAlertControllerStyleAlert];
                        [ok addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                        UIViewController *vc = [self topViewController];
                        if (vc) [vc presentViewController:ok animated:YES completion:nil];
                    }];
                }]];
            }
            [alert addAction:[UIAlertAction actionWithTitle:@"Làm Mới" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
                [self showGiftCheckerUI];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Đóng" style:UIAlertActionStyleCancel handler:nil]];
            UIViewController *vc = [self topViewController];
            if (vc) [vc presentViewController:alert animated:YES completion:nil];
        }];
    });
}

- (UIViewController *)topViewController {
    UIWindow *activeWindow = nil;
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (scene.activationState != UISceneActivationStateForegroundActive) continue;
        if (![scene isKindOfClass:[UIWindowScene class]]) continue;
        for (UIWindow *window in ((UIWindowScene *)scene).windows) {
            if (window.isKeyWindow) { activeWindow = window; break; }
        }
        if (activeWindow) break;
    }
    if (!activeWindow) activeWindow = [UIApplication sharedApplication].windows.firstObject;
    UIViewController *vc = activeWindow.rootViewController;
    while (vc.presentedViewController) vc = vc.presentedViewController;
    return vc;
}

- (void)showNewGiftNotification:(int)count {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        if (!window) return;
        UIView *banner = [[UIView alloc] initWithFrame:CGRectMake(10, -80, window.frame.size.width - 20, 60)];
        banner.backgroundColor = [UIColor colorWithRed:0.04 green:0.04 blue:0.1 alpha:0.96];
        banner.layer.cornerRadius = 12;
        banner.layer.borderWidth = 1.5;
        banner.layer.borderColor = [UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:0.9].CGColor;
        banner.layer.shadowColor = [UIColor magentaColor].CGColor;
        banner.layer.shadowRadius = 8;
        banner.layer.shadowOpacity = 0.6;
        banner.layer.shadowOffset = CGSizeZero;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, banner.frame.size.width - 20, 50)];
        label.text = [NSString stringWithFormat:@"🎁 Có %d quà tặng mới chờ bạn nhận!", count];
        label.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:1.0];
        label.font = [UIFont boldSystemFontOfSize:13];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 2;
        [banner addSubview:label];
        [window addSubview:banner];
        [UIView animateWithDuration:0.4 animations:^{
            banner.frame = CGRectMake(10, 40, banner.frame.size.width, 60);
        } completion:^(BOOL done) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.3 animations:^{
                    banner.frame = CGRectMake(10, -80, banner.frame.size.width, 60);
                } completion:^(BOOL f) { [banner removeFromSuperview]; }];
            });
        }];
    });
}

@end
