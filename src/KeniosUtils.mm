// =============================================
// KENIOS HAX - Utilities Module
// iOS 16.0-26.5
// =============================================

#import "KeniosCommon.h"
#import <CommonCrypto/CommonCrypto.h>
#import <sys/utsname.h>
#import <UIKit/UIKit.h>

@interface KeniosUtils : NSObject
@end

@implementation KeniosUtils

#pragma mark - Device Info

+ (NSString *)getDeviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (NSString *)getDeviceName {
    return [[UIDevice currentDevice] name];
}

+ (NSString *)getiOSVersion {
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)getAppVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)getAppBuild {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

+ (NSString *)getBundleID {
    return [[NSBundle mainBundle] bundleIdentifier];
}

#pragma mark - Jailbreak Detection

+ (BOOL)isJailbroken {
    // Kiểm tra file jailbreak
    NSArray *jbPaths = @[
        @"/Applications/Cydia.app",
        @"/Library/MobileSubstrate",
        @"/usr/sbin/sshd",
        @"/etc/apt",
        @"/var/lib/cydia",
        @"/var/jb",
        @"/private/preboot/",
        @"/usr/lib/libsubstrate.dylib",
        @"/usr/lib/libellekit.dylib"
    ];
    
    for (NSString *path in jbPaths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return YES;
        }
    }
    
    // Kiểm tra có thể ghi vào thư mục hệ thống
    if ([[NSFileManager defaultManager] isWritableFileAtPath:@"/private"]) {
        return YES;
    }
    
    // Kiểm tra URL schemes
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Color Utilities

+ (UIColor *)colorFromHex:(NSString *)hexString {
    return [self colorFromHex:hexString alpha:1.0];
}

+ (UIColor *)colorFromHex:(NSString *)hexString alpha:(CGFloat)alpha {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    if (cleanString.length == 6) {
        unsigned int rgb = 0;
        [[NSScanner scannerWithString:cleanString] scanHexInt:&rgb];
        return [UIColor colorWithRed:((rgb & 0xFF0000) >> 16) / 255.0
                               green:((rgb & 0x00FF00) >> 8) / 255.0
                                blue:(rgb & 0x0000FF) / 255.0
                               alpha:alpha];
    }
    
    return [UIColor whiteColor];
}

+ (NSString *)hexFromColor:(UIColor *)color {
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return [NSString stringWithFormat:@"#%02X%02X%02X", (int)(r*255), (int)(g*255), (int)(b*255)];
}

#pragma mark - Math Utilities

+ (float)distanceBetweenVector3:(KeniosVector3)a and:(KeniosVector3)b {
    float dx = a.x - b.x;
    float dy = a.y - b.y;
    float dz = a.z - b.z;
    return sqrt(dx*dx + dy*dy + dz*dz);
}

+ (float)distanceBetweenVector2:(KeniosVector2)a and:(KeniosVector2)b {
    float dx = a.x - b.x;
    float dy = a.y - b.y;
    return sqrt(dx*dx + dy*dy);
}

+ (float)angleBetweenVector3:(KeniosVector3)a and:(KeniosVector3)b {
    float dot = a.x*b.x + a.y*b.y + a.z*b.z;
    float magA = sqrt(a.x*a.x + a.y*a.y + a.z*a.z);
    float magB = sqrt(b.x*b.x + b.y*b.y + b.z*b.z);
    return acos(dot / (magA * magB));
}

#pragma mark - File Utilities

+ (NSString *)documentsPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

+ (NSString *)keniosPath {
    NSString *path = [[self documentsPath] stringByAppendingPathComponent:@"KeniosHax"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (BOOL)saveJSON:(NSDictionary *)json toFile:(NSString *)filename {
    NSString *path = [[self keniosPath] stringByAppendingPathComponent:filename];
    NSData *data = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    return [data writeToFile:path atomically:YES];
}

+ (NSDictionary *)loadJSONFromFile:(NSString *)filename {
    NSString *path = [[self keniosPath] stringByAppendingPathComponent:filename];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) return nil;
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

#pragma mark - Crypto Utilities

+ (NSString *)sha256:(NSString *)input {
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, hash);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", hash[i]];
    }
    return output;
}

+ (NSString *)md5:(NSString *)input {
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char hash[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, hash);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", hash[i]];
    }
    return output;
}

+ (NSString *)randomString:(int)length {
    NSString *letters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    for (int i = 0; i < length; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random_uniform((uint32_t)[letters length])]];
    }
    return randomString;
}

#pragma mark - UI Utilities

+ (void)showAlert:(NSString *)title message:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

+ (void)showToast:(NSString *)message duration:(NSTimeInterval)duration {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window) return;
        
        UILabel *toast = [[UILabel alloc] init];
        toast.text = message;
        toast.textColor = [UIColor whiteColor];
        toast.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        toast.textAlignment = NSTextAlignmentCenter;
        toast.font = [UIFont systemFontOfSize:14];
        toast.layer.cornerRadius = 20;
        toast.clipsToBounds = YES;
        toast.alpha = 0;
        
        CGSize size = [message sizeWithAttributes:@{NSFontAttributeName: toast.font}];
        toast.frame = CGRectMake(0, 0, size.width + 40, 40);
        toast.center = CGPointMake(window.center.x, window.frame.size.height - 100);
        
        [window addSubview:toast];
        
        [UIView animateWithDuration:0.3 animations:^{
            toast.alpha = 1;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 delay:duration options:0 animations:^{
                toast.alpha = 0;
            } completion:^(BOOL finished) {
                [toast removeFromSuperview];
            }];
        }];
    });
}

#pragma mark - Time Utilities

+ (NSString *)currentTimestamp {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [formatter stringFromDate:[NSDate date]];
}

+ (NSString *)formatTimeInterval:(NSTimeInterval)interval {
    int days = (int)(interval / 86400);
    int hours = (int)((int)interval % 86400) / 3600;
    int minutes = (int)((int)interval % 3600) / 60;
    
    if (days > 0) return [NSString stringWithFormat:@"%dd %dh", days, hours];
    if (hours > 0) return [NSString stringWithFormat:@"%dh %dm", hours, minutes];
    return [NSString stringWithFormat:@"%dm", minutes];
}

@end
