#ifndef KENIOS_AIMBOT_H
#define KENIOS_AIMBOT_H

#import "KeniosTypes.h"

@interface KeniosAimbot : NSObject
+ (instancetype)sharedInstance;
- (void)processAimbot;
- (void)updateConfig:(KeniosAimbotConfig *)config;
@end

#endif
