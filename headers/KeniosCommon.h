#ifndef KENIOS_COMMON_H
#define KENIOS_COMMON_H

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <substrate.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <sys/sysctl.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <AudioToolbox/AudioToolbox.h>

#define KENIOS_VERSION @"4.5.0"
#define KENIOS_BUILD 20260717
#define KENIOS_IOS_MIN @"16.0"
#define KENIOS_IOS_MAX @"26.5"

#ifdef DEBUG
#define KENIOS_LOG(fmt, ...) NSLog(@"[KENIOS] " fmt, ##__VA_ARGS__)
#else
#define KENIOS_LOG(fmt, ...)
#endif

#define KENIOS_LOG_ERROR(fmt, ...) NSLog(@"[KENIOS][ERROR] " fmt, ##__VA_ARGS__)
#define KENIOS_LOG_WARN(fmt, ...) NSLog(@"[KENIOS][WARN] " fmt, ##__VA_ARGS__)

#define KENIOS_RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define KENIOS_RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define DEG2RAD(deg) ((deg) * M_PI / 180.0)
#define RAD2DEG(rad) ((rad) * 180.0 / M_PI)
#define CLAMP(x, min, max) MAX(min, MIN(max, x))

extern uint64_t g_UE4Base;
extern uint64_t g_GWorld;
extern BOOL g_isHackInitialized;
extern BOOL g_isKeyValid;
extern BOOL g_isIPAValid;
extern NSString *g_iosVersion;

#define KENIOS_NOTIF_KEY_VALIDATED @"com.kenios.hax.key.validated"
#define KENIOS_NOTIF_KEY_EXPIRED @"com.kenios.hax.key.expired"
#define KENIOS_NOTIF_IPA_VALIDATED @"com.kenios.hax.ipa.validated"
#define KENIOS_NOTIF_IPA_INVALID @"com.kenios.hax.ipa.invalid"
#define KENIOS_NOTIF_BAN_WARNING @"com.kenios.hax.ban.warning"
#define KENIOS_NOTIF_BOMB_DETECTED @"com.kenios.hax.bomb.detected"

typedef NS_ENUM(NSInteger, KeniosAimTarget) { KeniosAimTargetHead=0, KeniosAimTargetNeck=1, KeniosAimTargetChest=2, KeniosAimTargetBody=3 };
typedef NS_ENUM(NSInteger, KeniosAntiBanMode) { KeniosAntiBanModeSafe=0, KeniosAntiBanModeAggressive=1, KeniosAntiBanModeAuto=2 };
typedef NS_ENUM(NSInteger, KeniosESPBoxType) { KeniosESPBoxType2D=0, KeniosESPBoxType3D=1, KeniosESPBoxTypeCorner=2 };
typedef NS_ENUM(NSInteger, KeniosShotgunAimMode) { KeniosShotgunAimCenterMass=0, KeniosShotgunAimHead=1, KeniosShotgunAimSpread=2 };
typedef NS_ENUM(NSInteger, KeniosKeyType) { KeniosKeyTypeTrial=0, KeniosKeyTypeWeekly=1, KeniosKeyTypeMonthly=2, KeniosKeyTypeLifetime=3, KeniosKeyTypeAdmin=4 };

typedef struct { float x,y,z; } KeniosVector3;
typedef struct { float x,y; } KeniosVector2;
typedef struct { float m[4][4]; } KeniosMatrix4x4;
typedef struct { KeniosVector3 position; float pitch,yaw,roll,fov; } KeniosCamera;

typedef struct {
    uint64_t address, meshAddress;
    KeniosVector3 head, neck, chest, pelvis;
    KeniosVector3 leftShoulder, rightShoulder, leftElbow, rightElbow, leftWrist, rightWrist, leftKnee, rightKnee, leftFoot, rightFoot;
    KeniosVector2 screenHead, screenChest, screenPelvis;
    float distance, health, armor;
    int teamID, playerID;
    BOOL isBot, isVisible, isAlive, isTeammate, isTarget;
    char name[64];
} KeniosPlayer;

typedef struct { KeniosVector3 position; int type; float radius, timeToExplode; BOOL isActive; } KeniosBomb;

@protocol KeniosModuleProtocol <NSObject>
@required
- (void)initialize;
- (void)shutdown;
- (BOOL)isEnabled;
- (NSString *)moduleName;
@end

#endif
