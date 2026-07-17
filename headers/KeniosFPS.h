#ifndef KENIOS_FPS_H
#define KENIOS_FPS_H

#import <Foundation/Foundation.h>

@interface KeniosFPS : NSObject
+ (instancetype)sharedInstance;
- (void)updateFPS;
- (int)getCurrentFPS;
- (int)getCurrentPing;
- (void)setPing:(int)ping;
@end

#endif
