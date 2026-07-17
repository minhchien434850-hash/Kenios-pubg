#import "KeniosCommon.h"
#import "KeniosConfig.h"

@interface KeniosEventShop ()
@property (nonatomic, strong) KeniosEventShopConfig *config;
@property (nonatomic, strong) NSArray *events;
@end

@implementation KeniosEventShop

+ (instancetype)sharedInstance {
    static KeniosEventShop *i = nil; static dispatch_once_t t; dispatch_once(&t, ^{ i = [[KeniosEventShop alloc] init]; }); return i;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.config = [KeniosConfig sharedInstance].eventShop;
        self.config.purchasedItems = [NSMutableArray new];
        [self loadEvents];
    }
    return self;
}

- (void)loadEvents {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"KeniosHax/skins.json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data) {
        NSDictionary *db = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        self.events = db[@"events"];
    }
}

- (void)syncEventItems {
    if (!self.config.enabled) return;
    KENIOS_LOG(@"Event shop synced");
}

- (NSArray *)getEventItems:(int)eventID {
    for (NSDictionary *event in self.events) {
        if ([event[@"eventID"] intValue] == eventID) return event[@"items"];
    }
    return nil;
}

- (void)purchaseItem:(int)itemID fromEvent:(int)eventID {
    KENIOS_LOG(@"Purchased item %d from event %d", itemID, eventID);
    [self.config.purchasedItems addObject:@{@"itemID": @(itemID), @"eventID": @(eventID), @"date": [NSDate date]}];
}
@end
