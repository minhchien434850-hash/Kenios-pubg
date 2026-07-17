#ifndef KENIOS_IPA_VALIDATOR_H
#define KENIOS_IPA_VALIDATOR_H

#import "KeniosTypes.h"

@interface KeniosIPAValidator : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, assign, readonly) BOOL isIPAValid;
@property (nonatomic, strong, readonly) KeniosIPAData *ipaData;
@property (nonatomic, strong, readonly) NSString *currentBundleID;
@property (nonatomic, strong, readonly) NSString *currentVersion;

- (BOOL)validateCurrentIPA;
- (BOOL)validateIPAAtPath:(NSString *)path;
- (BOOL)validateIPAChecksum:(NSString *)checksum;
- (BOOL)checkBundleID:(NSString *)bundleID;
- (BOOL)checkVersion:(NSString *)version;
- (BOOL)checkFileSize:(uint64_t)size;
- (NSString *)getIPAPath;
- (NSString *)calculateSHA256:(NSString *)filePath;
- (NSString *)calculateMD5:(NSString *)filePath;
- (uint64_t)getFileSize:(NSString *)filePath;
- (void)validateWithServer:(void(^)(BOOL valid, NSString *error))completion;
- (void)downloadWhitelist;
- (void)showIPAInvalidAlert;
- (void)showIPASelectorDialog;
- (void)updateIPAStatusOnMenu;

@end
#endif
