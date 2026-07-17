#ifndef KENIOS_GIFT_CHECKER_H
#define KENIOS_GIFT_CHECKER_H

#import "KeniosTypes.h"

typedef NS_ENUM(NSInteger, KeniosGiftType) {
    KeniosGiftTypeDaily = 0,
    KeniosGiftTypeEvent = 1,
    KeniosGiftTypeReward = 2,
    KeniosGiftTypeMission = 3,
    KeniosGiftTypeSeasonal = 4
};

typedef NS_ENUM(NSInteger, KeniosGiftRarity) {
    KeniosGiftRarityCommon = 0,
    KeniosGiftRarityUncommon = 1,
    KeniosGiftRarityRare = 2,
    KeniosGiftRarityEpic = 3,
    KeniosGiftRarityLegendary = 4
};

@interface KeniosGiftItem : NSObject
@property (nonatomic, assign) int giftID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *giftDescription;
@property (nonatomic, assign) KeniosGiftType type;
@property (nonatomic, assign) KeniosGiftRarity rarity;
@property (nonatomic, strong) NSDate *expiryDate;
@property (nonatomic, assign) BOOL isClaimed;
@property (nonatomic, assign) int quantity;
@end

@interface KeniosGiftChecker : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) KeniosGiftCheckerConfig *config;
@property (nonatomic, strong) NSMutableArray<KeniosGiftItem *> *availableGifts;
@property (nonatomic, assign) int unclaimedCount;

- (void)startAutoCheck;
- (void)stopAutoCheck;
- (void)checkGiftsNow:(void(^)(NSArray<KeniosGiftItem *> *gifts, NSError *error))completion;
- (void)claimGift:(int)giftID completion:(void(^)(BOOL success, NSString *message))completion;
- (void)claimAllGifts:(void(^)(int claimed, int failed))completion;
- (NSArray<KeniosGiftItem *> *)getUnclaimedGifts;
- (NSArray<KeniosGiftItem *> *)getGiftsByType:(KeniosGiftType)type;
- (void)showGiftCheckerUI;

@end

#endif
