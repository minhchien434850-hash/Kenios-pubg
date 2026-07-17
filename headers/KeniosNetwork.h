#ifndef KENIOS_NETWORK_H
#define KENIOS_NETWORK_H

#import <Foundation/Foundation.h>

@interface KeniosNetwork : NSObject
+ (instancetype)sharedInstance;
- (void)startMonitoring;
- (void)stopMonitoring;
- (int)getCurrentPing;
@end

#endif
