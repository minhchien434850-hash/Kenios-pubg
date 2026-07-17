#ifndef KENIOS_ESP_H
#define KENIOS_ESP_H

#import "KeniosTypes.h"

@interface KeniosESP : NSObject
+ (instancetype)sharedInstance;
- (void)renderESP;
- (void)updateBombs:(NSArray *)bombs;
@end

#endif
