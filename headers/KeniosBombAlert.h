#ifndef KENIOS_BOMB_ALERT_H
#define KENIOS_BOMB_ALERT_H

#import "KeniosTypes.h"

@interface KeniosBombAlert : NSObject
+ (instancetype)sharedInstance;
- (void)scanForBombs;
@end

#endif
