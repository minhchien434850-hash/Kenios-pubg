#ifndef KENIOS_MAGIC_BULLET_H
#define KENIOS_MAGIC_BULLET_H

#import "KeniosTypes.h"

@interface KeniosMagicBullet : NSObject
+ (instancetype)sharedInstance;
- (void)processMagicBullet;
@end

#endif
