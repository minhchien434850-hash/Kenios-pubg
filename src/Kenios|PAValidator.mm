#import "KeniosCommon.h"

@interface KeniosIPAValidator ()
@property (nonatomic, assign) BOOL isIPAValid;
@property (nonatomic, strong) KeniosIPAData *ipaData;
@end

@implementation KeniosIPAValidator

+ (instancetype)sharedInstance {
    static KeniosIPAValidator *i = nil; static dispatch_once_t t; dispatch_once(&t, ^{ i = [[KeniosIPAValidator alloc] init]; }); return i;
}

- (instancetype)init {
    self = [super init];
    if (self) { self.isIPAValid = NO; [self validateCurrentIPA]; }
    return self;
}

- (BOOL)validateCurrentIPA {
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    if (![self checkBundleID:bundleID]) {
        self.isIPAValid = NO;
        return NO;
    }
    if (![self checkVersion:version]) {
        self.isIPAValid = NO;
        return NO;
    }
    
    self.ipaData = [[KeniosIPAData alloc] init];
    self.ipaData.bundleID = bundleID;
    self.ipaData.version = version;
    self.ipaData.isValid = YES;
    self.isIPAValid = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KENIOS_NOTIF_IPA_VALIDATED object:nil];
    return YES;
}

- (BOOL)validateIPAAtPath:(NSString *)path {
    NSString *sha = [self calculateSHA256:path];
    return [self validateIPAChecksum:sha];
}

- (BOOL)validateIPAChecksum:(NSString *)checksum { return YES; }
- (BOOL)checkBundleID:(NSString *)bundleID {
    return [bundleID isEqualToString:@"com.tencent.ig"] || [bundleID isEqualToString:@"com.tencent.pubgm"];
}
- (BOOL)checkVersion:(NSString *)version {
    float v = [version floatValue];
    return v >= 4.0 && v <= 5.0;
}
- (BOOL)checkFileSize:(uint64_t)size { return size > 1000000000 && size < 5000000000; }
- (NSString *)getIPAPath { return [[NSBundle mainBundle] bundlePath]; }

- (NSString *)calculateSHA256:(NSString *)filePath {
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (!data) return @"";
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, hash);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) [output appendFormat:@"%02x", hash[i]];
    return output;
}

- (NSString *)calculateMD5:(NSString *)filePath {
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (!data) return @"";
    unsigned char hash[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, hash);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) [output appendFormat:@"%02x", hash[i]];
    return output;
}

- (uint64_t)getFileSize:(NSString *)filePath {
    NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    return [attr fileSize];
}

- (void)validateWithServer:(void(^)(BOOL, NSString*))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (completion) completion(self.isIPAValid, nil);
    });
}

- (void)downloadWhitelist {}
- (void)showIPAInvalidAlert {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"📱 IPA KHÔNG HỢP LỆ" message:@"Vui lòng sử dụng IPA gốc từ App Store!\n\nCách lấy IPA:\n• App Store++\n• iMazing\n• Apple Configurator 2" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Chọn File IPA" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) { [self showIPASelectorDialog]; }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Thoát" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a) { exit(0); }]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

- (void)showIPASelectorDialog {
    // Mở document picker để chọn file IPA
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *types = @[@"public.data"];
        UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:types inMode:UIDocumentPickerModeImport];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
    });
}

- (void)updateIPAStatusOnMenu {}
@end
