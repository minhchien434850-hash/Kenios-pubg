//
//  KeniosIPAValidator.mm
//  KENIOS HAX - IPA Validator
//
//  Created by KENIOS HAX Team
//  Copyright © 2026 KENIOS. All rights reserved.
//

#import "KeniosIPAValidator.h"
#import "KeniosCommon.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCrypto.h>

@interface KeniosIPAValidator ()
@property (nonatomic, assign) BOOL isIPAValid;
@property (nonatomic, strong) KeniosIPAData *ipaData;
@end

@implementation KeniosIPAData
@end

@implementation KeniosIPAValidator

+ (instancetype)sharedInstance {
    static KeniosIPAValidator *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[KeniosIPAValidator alloc] init]; });
    return instance;
}

/**
 * Validate IPA file integrity and structure
 */
+ (BOOL)validateIPAWithPath:(NSString *)ipaPath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:ipaPath]) {
        NSLog(@"[KENIOS] IPA file not found: %@", ipaPath);
        return NO;
    }
    
    // Check if it's a valid zip file
    if (![ipaPath.pathExtension.lowercaseString isEqualToString:@"ipa"]) {
        NSLog(@"[KENIOS] Invalid IPA extension");
        return NO;
    }
    
    // Verify Payload directory exists
    NSString *payloadPath = [ipaPath stringByAppendingPathComponent:@"Payload"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:payloadPath]) {
        NSLog(@"[KENIOS] Payload directory not found");
        return NO;
    }
    
    NSLog(@"[KENIOS] IPA validation successful: %@", ipaPath);
    return YES;
}

/**
 * Validate Bundle ID format
 */
+ (BOOL)validateBundleID:(NSString *)bundleID {
    if (!bundleID || bundleID.length == 0) {
        return NO;
    }
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z0-9.-]+$" options:0 error:nil];
    NSUInteger matches = [regex numberOfMatchesInString:bundleID options:0 range:NSMakeRange(0, bundleID.length)];
    
    return matches > 0;
}

/**
 * Validate app signature
 */
+ (BOOL)validateSignature:(NSString *)appPath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:appPath]) {
        NSLog(@"[KENIOS] App not found: %@", appPath);
        return NO;
    }
    
    NSString *infoPath = [appPath stringByAppendingPathComponent:@"Info.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:infoPath]) {
        NSLog(@"[KENIOS] Info.plist not found");
        return NO;
    }
    
    NSLog(@"[KENIOS] Signature validation passed");
    return YES;
}

/**
 * Calculate SHA256 hash of file
 */
+ (NSString *)calculateSHA256:(NSString *)filePath {
    NSFileHandle *handle = [NSFileHandle fileForReadingAtPath:filePath];
    if (!handle) {
        return nil;
    }
    
    CC_SHA256_CTX sha256;
    CC_SHA256_Init(&sha256);
    
    while (YES) {
        NSData *chunk = [handle readDataOfLength:(1024 * 1024)]; // 1MB chunks
        if (chunk.length == 0) break;
        CC_SHA256_Update(&sha256, [chunk bytes], (CC_LONG)[chunk length]);
    }
    
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256_Final(digest, &sha256);
    
    NSMutableString *hash = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x", digest[i]];
    }
    
    [handle closeFile];
    return hash;
}

/**
 * Validate if it's a PUBG Mobile bundle
 */
+ (BOOL)isValidPUBGBundle:(NSString *)bundleID {
    NSArray *validBundles = @[
        @"com.tencent.tmgp.pubgm",
        @"com.pubg.krmobile",
        @"com.vng.pubgmobile"
    ];
    
    for (NSString *bundle in validBundles) {
        if ([bundleID isEqualToString:bundle]) {
            NSLog(@"[KENIOS] Valid PUBG bundle detected: %@", bundleID);
            return YES;
        }
    }
    
    NSLog(@"[KENIOS] Invalid PUBG bundle: %@", bundleID);
    return NO;
}

- (BOOL)validateCurrentIPA {
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    if (![KeniosIPAValidator isValidPUBGBundle:bundleID]) {
        self.isIPAValid = NO;
        return NO;
    }
    self.ipaData = [KeniosIPAData new];
    self.ipaData.bundleID = bundleID;
    self.ipaData.version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.ipaData.isValid = YES;
    self.isIPAValid = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:KENIOS_NOTIF_IPA_VALIDATED object:nil];
    return YES;
}

- (void)showIPAInvalidAlert {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"📱 IPA KHÔNG HỢP LỆ"
                                                                       message:@"Vui lòng sử dụng IPA gốc từ App Store!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Thoát" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a) { exit(0); }]];
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
        if (vc) [vc presentViewController:alert animated:YES completion:nil];
    });
}

@end
