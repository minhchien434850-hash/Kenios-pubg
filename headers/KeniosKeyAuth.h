#ifndef KENIOS_KEY_AUTH_H
#define KENIOS_KEY_AUTH_H

#import "KeniosTypes.h"

@interface KeniosKeyAuth : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong, readonly) KeniosKeyData *currentKey;
@property (nonatomic, assign, readonly) BOOL isAuthenticated;
@property (nonatomic, assign, readonly) BOOL isKeyValid;
@property (nonatomic, strong, readonly) NSString *deviceID;

- (void)activateKey:(NSString *)key completion:(void(^)(BOOL success, NSString *error))completion;
- (void)deactivateKey;
- (void)refreshKeyStatus;
- (BOOL)validateKeyLocally:(NSString *)key;
- (void)sendHeartbeat;
- (void)checkKeyExpiry;
- (NSString *)generateDeviceID;
- (NSString *)getDeviceFingerprint;
- (BOOL)isDeviceAuthorized;
- (BOOL)saveKeyData;
- (BOOL)loadKeyData;
- (void)clearKeyData;
- (void)showKeyInputDialog;
- (void)showKeyStatusOnMenu;

@end
#endif
