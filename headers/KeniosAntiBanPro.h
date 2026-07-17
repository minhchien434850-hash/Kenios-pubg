#ifndef KENIOS_ANTI_BAN_PRO_H
#define KENIOS_ANTI_BAN_PRO_H

#import "KeniosTypes.h"

@interface KeniosAntiBanPro : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, assign, readonly) BOOL isActive;
@property (nonatomic, assign, readonly) KeniosAntiBanMode currentMode;
@property (nonatomic, assign, readonly) int banWarningCount;
@property (nonatomic, assign, readonly) BOOL isInSafeMode;

- (void)startMonitoring;
- (void)stopMonitoring;
- (NSArray *)detectAntiCheatModules;
- (BOOL)isBeingSpectated;
- (BOOL)isBeingReported;
- (void)bypassJailbreakDetection;
- (void)bypassDebuggerDetection;
- (void)bypassMemoryScanners;
- (void)bypassIntegrityChecks;
- (void)bypassHookDetection;
- (void)blockAnalytics;
- (void)blockCrashReports;
- (void)blockTelemetry;
- (void)monitorNetworkTraffic;
- (void)switchToSafeMode;
- (void)switchToAggressiveMode;
- (void)autoSwitchMode;
- (BOOL)shouldDisableFeature:(NSString *)featureName;
- (float)getHumanizedAimAngle:(float)originalAngle;
- (float)getRandomMissChance;
- (float)getReactionDelay;
- (void)checkForBanMessages;
- (void)handleBanWarning;
- (BOOL)isAccountFlagged;
- (void)trackKill;
- (void)trackHeadshot;
- (float)getHeadshotPercentage;
- (int)getKillsThisMatch;
- (void)resetMatchStats;

@end
#endif
