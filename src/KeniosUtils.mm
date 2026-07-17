#import "KeniosCommon.h"

@implementation KeniosUtils

+ (NSString *)getDeviceModel {
    size_t size; sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    return [NSString stringWithUTF8String:machine];
}

+ (NSString *)getiOSVersion { return [[UIDevice currentDevice] systemVersion]; }

+ (BOOL)isJailbroken {
    NSArray *paths = @[@"/Applications/Cydia.app", @"/Library/MobileSubstrate", @"/usr/sbin/sshd", @"/var/jb"];
    for (NSString *path in paths) { if ([[NSFileManager defaultManager] fileExistsAtPath:path]) return YES; }
    return NO;
}

+ (UIColor *)colorFromHex:(NSString *)hex {
    unsigned int r, g, b;
    if ([hex hasPrefix:@"#"]) hex = [hex substringFromIndex:1];
    if (hex.length == 6) {
        [[NSScanner scannerWithString:[hex substringWithRange:NSMakeRange(0,2)]] scanHexInt:&r];
        [[NSScanner scannerWithString:[hex substringWithRange:NSMakeRange(2,2)]] scanHexInt:&g];
        [[NSScanner scannerWithString:[hex substringWithRange:NSMakeRange(4,2)]] scanHexInt:&b];
        return KENIOS_RGB(r, g, b);
    }
    return [UIColor whiteColor];
}

@end
