#import "KeniosCommon.h"
#import "KeniosConfig.h"

@implementation KeniosKeyData
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.key = [coder decodeObjectForKey:@"key"];
        self.token = [coder decodeObjectForKey:@"token"];
        self.type = [coder decodeIntForKey:@"type"];
        self.maxDevices = [coder decodeIntForKey:@"maxDevices"];
        self.expiryDate = [coder decodeObjectForKey:@"expiryDate"];
        self.isValid = [coder decodeBoolForKey:@"isValid"];
        self.features = [coder decodeObjectForKey:@"features"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.key forKey:@"key"];
    [coder encodeObject:self.token forKey:@"token"];
    [coder encodeInt:self.type forKey:@"type"];
    [coder encodeInt:self.maxDevices forKey:@"maxDevices"];
    [coder encodeObject:self.expiryDate forKey:@"expiryDate"];
    [coder encodeBool:self.isValid forKey:@"isValid"];
    [coder encodeObject:self.features forKey:@"features"];
}
@end

@interface KeniosKeyAuth ()
@property (nonatomic, strong) KeniosKeyData *currentKey;
@property (nonatomic, strong) NSString *deviceID;
@end

@implementation KeniosKeyAuth

static UIViewController *KeniosTopViewController(void) {
    UIWindow *activeWindow = nil;
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (scene.activationState != UISceneActivationStateForegroundActive) continue;
        if (![scene isKindOfClass:[UIWindowScene class]]) continue;
        for (UIWindow *window in ((UIWindowScene *)scene).windows) {
            if (window.isKeyWindow) { activeWindow = window; break; }
        }
        if (activeWindow) break;
    }
    if (!activeWindow) {
        activeWindow = [UIApplication sharedApplication].windows.firstObject;
    }
    UIViewController *vc = activeWindow.rootViewController;
    while (vc.presentedViewController) vc = vc.presentedViewController;
    return vc;
}

+ (instancetype)sharedInstance {
    static KeniosKeyAuth *i = nil; static dispatch_once_t t; dispatch_once(&t, ^{ i = [[KeniosKeyAuth alloc] init]; }); return i;
}

- (instancetype)init {
    self = [super init];
    if (self) { self.deviceID = [self generateDeviceID]; }
    return self;
}

- (BOOL)isAuthenticated { return self.isKeyValid; }
- (BOOL)isKeyValid { return self.currentKey && self.currentKey.isValid; }

- (void)activateKey:(NSString *)key completion:(void(^)(BOOL, NSString*))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/validate-key", [KeniosConfig sharedInstance].serverURL]];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        req.HTTPMethod = @"POST";
        [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSDictionary *body = @{@"key":key, @"device_id":self.deviceID};
        req.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
        
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
            if (d && !e) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
                if ([json[@"valid"] boolValue]) {
                    self.currentKey = [[KeniosKeyData alloc] init];
                    self.currentKey.key = key;
                    self.currentKey.isValid = YES;
                    self.currentKey.token = json[@"token"];
                    [self saveKeyData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:KENIOS_NOTIF_KEY_VALIDATED object:nil];
                    });
                    if (completion) completion(YES, nil);
                } else {
                    if (completion) completion(NO, json[@"error"]);
                }
            } else {
                BOOL localValid = [self validateKeyLocally:key];
                if (completion) completion(localValid, localValid ? nil : @"Network error");
            }
        }];
        [task resume];
    });
}

- (BOOL)validateKeyLocally:(NSString *)key {
    return [key hasPrefix:@"KEN-"] && key.length == 19;
}

- (void)deactivateKey {
    self.currentKey = nil;
    [self clearKeyData];
}

- (void)refreshKeyStatus {
    if (!self.currentKey) return;
    [self activateKey:self.currentKey.key completion:nil];
}

- (void)sendHeartbeat {
    // Gửi heartbeat lên server
}

- (void)checkKeyExpiry {
    if (self.currentKey && self.currentKey.expiryDate && [self.currentKey.expiryDate timeIntervalSinceNow] < 0) {
        self.currentKey.isValid = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:KENIOS_NOTIF_KEY_EXPIRED object:nil];
    }
}

- (NSString *)generateDeviceID {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString] ?: [[NSUUID UUID] UUIDString];
}

- (NSString *)getDeviceFingerprint {
    return [NSString stringWithFormat:@"%@_%@_%@", [KeniosUtils getDeviceModel], [KeniosUtils getiOSVersion], self.deviceID];
}

- (BOOL)isDeviceAuthorized { return YES; }

- (BOOL)saveKeyData {
    if (!self.currentKey) return NO;
    NSString *basePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"KeniosHax"];
    [[NSFileManager defaultManager] createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *path = [basePath stringByAppendingPathComponent:@"key.dat"];
    NSError *error = nil;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.currentKey requiringSecureCoding:NO error:&error];
    return data && [data writeToFile:path options:NSDataWritingAtomic error:&error];
}

- (BOOL)loadKeyData {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"KeniosHax/key.dat"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) return NO;
    NSError *error = nil;
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&error];
    if (!unarchiver) return NO;
    unarchiver.requiresSecureCoding = NO;
    self.currentKey = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [unarchiver finishDecoding];
    [self checkKeyExpiry];
    return self.currentKey != nil;
}

- (void)clearKeyData {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"KeniosHax/key.dat"];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (void)showKeyInputDialog {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🔑 KENIOS HAX" message:@"Nhập key kích hoạt:" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) { tf.placeholder = @"KEN-XXXX-XXXX-XXXX"; }];
        [alert addAction:[UIAlertAction actionWithTitle:@"Kích Hoạt" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
            NSString *key = alert.textFields[0].text;
            [self activateKey:key completion:^(BOOL success, NSString *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        UIAlertController *ok = [UIAlertController alertControllerWithTitle:@"✅ Thành Công" message:@"Key đã được kích hoạt!" preferredStyle:UIAlertControllerStyleAlert];
                        [ok addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                        UIViewController *vc = KeniosTopViewController();
                        if (vc) [vc presentViewController:ok animated:YES completion:nil];
                    } else {
                        UIAlertController *err = [UIAlertController alertControllerWithTitle:@"❌ Lỗi" message:error ?: @"Key không hợp lệ" preferredStyle:UIAlertControllerStyleAlert];
                        [err addAction:[UIAlertAction actionWithTitle:@"Thử Lại" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) { [self showKeyInputDialog]; }]];
                        UIViewController *vc = KeniosTopViewController();
                        if (vc) [vc presentViewController:err animated:YES completion:nil];
                    }
                });
            }];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Hủy" style:UIAlertActionStyleCancel handler:nil]];
        UIViewController *vc = KeniosTopViewController();
        if (vc) [vc presentViewController:alert animated:YES completion:nil];
    });
}

- (void)showKeyStatusOnMenu {}
@end
