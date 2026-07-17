#ifndef KENIOS_EVENT_SHOP_H
#define KENIOS_EVENT_SHOP_H

#import "KeniosTypes.h"

@interface KeniosEventShop : NSObject
+ (instancetype)sharedInstance;
- (void)syncEventItems;
- (NSArray *)getEventItems:(int)eventID;
- (void)purchaseItem:(int)itemID fromEvent:(int)eventID;
@end

#endif
