#ifndef KENIOS_OFFSETS_H
#define KENIOS_OFFSETS_H

#import <Foundation/Foundation.h>

@interface KeniosOffsets : NSObject

@property (nonatomic, assign) uint64_t GWorld;
@property (nonatomic, assign) uint64_t GNames;
@property (nonatomic, assign) uint64_t PersistentLevel;
@property (nonatomic, assign) uint64_t GameState;
@property (nonatomic, assign) uint64_t OwningGameInstance;
@property (nonatomic, assign) uint64_t Levels;
@property (nonatomic, assign) uint64_t Actors;
@property (nonatomic, assign) uint64_t Actors_Count;
@property (nonatomic, assign) uint64_t RootComponent;
@property (nonatomic, assign) uint64_t PlayerController;
@property (nonatomic, assign) uint64_t Mesh;
@property (nonatomic, assign) uint64_t PlayerState;
@property (nonatomic, assign) uint64_t ComponentToWorld;
@property (nonatomic, assign) uint64_t RelativeLocation;
@property (nonatomic, assign) uint64_t ComponentSpaceTransformsArray;
@property (nonatomic, assign) uint64_t BoneSpaceTransforms;
@property (nonatomic, assign) uint64_t BoneCount;
@property (nonatomic, assign) uint64_t PlayerCameraManager;
@property (nonatomic, assign) uint64_t ControlRotation;
@property (nonatomic, assign) uint64_t Pawn;
@property (nonatomic, assign) uint64_t CameraCache;
@property (nonatomic, assign) uint64_t ViewMatrix;
@property (nonatomic, assign) uint64_t Translation;
@property (nonatomic, assign) uint64_t Rotation;
@property (nonatomic, assign) uint64_t Scale3D;
@property (nonatomic, assign) uint64_t TeamID;
@property (nonatomic, assign) uint64_t PlayerName;
@property (nonatomic, assign) uint64_t Health;
@property (nonatomic, assign) uint64_t Armor;
@property (nonatomic, assign) uint64_t Kills;
@property (nonatomic, assign) uint64_t bIsABot;
@property (nonatomic, assign) uint64_t CurrentAmmo;
@property (nonatomic, assign) uint64_t FireRate;
@property (nonatomic, assign) uint64_t RecoilPattern;
@property (nonatomic, assign) uint64_t Spread;
@property (nonatomic, assign) uint64_t BulletSpeed;
@property (nonatomic, assign) uint64_t PelletCount;
@property (nonatomic, assign) uint64_t PelletSpread;
@property (nonatomic, assign) uint64_t BombType;
@property (nonatomic, assign) uint64_t ExplosionRadius;
@property (nonatomic, assign) uint64_t ExplosionTime;
@property (nonatomic, assign) uint64_t BombLocation;
@property (nonatomic, assign) uint64_t VehicleType;
@property (nonatomic, assign) uint64_t MaxSpeed;

@property (nonatomic, assign) int BONE_HEAD;
@property (nonatomic, assign) int BONE_NECK;
@property (nonatomic, assign) int BONE_CHEST;
@property (nonatomic, assign) int BONE_PELVIS;
@property (nonatomic, assign) int BONE_LEFT_SHOULDER;
@property (nonatomic, assign) int BONE_RIGHT_SHOULDER;
@property (nonatomic, assign) int BONE_LEFT_ELBOW;
@property (nonatomic, assign) int BONE_RIGHT_ELBOW;
@property (nonatomic, assign) int BONE_LEFT_WRIST;
@property (nonatomic, assign) int BONE_RIGHT_WRIST;
@property (nonatomic, assign) int BONE_LEFT_THIGH;
@property (nonatomic, assign) int BONE_RIGHT_THIGH;
@property (nonatomic, assign) int BONE_LEFT_KNEE;
@property (nonatomic, assign) int BONE_RIGHT_KNEE;
@property (nonatomic, assign) int BONE_LEFT_FOOT;
@property (nonatomic, assign) int BONE_RIGHT_FOOT;

+ (instancetype)sharedInstance;
- (BOOL)loadFromJSON:(NSString *)filePath;
- (BOOL)loadFromServer;
- (BOOL)saveToJSON:(NSString *)filePath;
- (void)updateFromDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;

@end
#endif
