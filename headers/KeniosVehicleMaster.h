#ifndef KENIOS_VEHICLE_MASTER_H
#define KENIOS_VEHICLE_MASTER_H

#import "KeniosTypes.h"

@interface KeniosVehicleMaster : NSObject
+ (instancetype)sharedInstance;
- (void)applyVehicleMaster;
@end

#endif
