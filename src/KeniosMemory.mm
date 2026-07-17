#import "KeniosCommon.h"

@implementation KeniosMemory

+ (uint64_t)readPtr:(uint64_t)addr {
    if (addr == 0 || addr < 0x100000000) return 0;
    return *(uint64_t *)addr;
}

+ (float)readFloat:(uint64_t)addr {
    if (addr == 0 || addr < 0x100000000) return 0.0f;
    return *(float *)addr;
}

+ (int)readInt:(uint64_t)addr {
    if (addr == 0 || addr < 0x100000000) return 0;
    return *(int *)addr;
}

+ (void)writeFloat:(uint64_t)addr value:(float)value {
    if (addr == 0 || addr < 0x100000000) return;
    *(float *)addr = value;
}

+ (void)writeInt:(uint64_t)addr value:(int)value {
    if (addr == 0 || addr < 0x100000000) return;
    *(int *)addr = value;
}

+ (KeniosVector3)readVector3:(uint64_t)addr {
    KeniosVector3 v = {0,0,0};
    if (addr == 0 || addr < 0x100000000) return v;
    v.x = *(float *)addr;
    v.y = *(float *)(addr + 4);
    v.z = *(float *)(addr + 8);
    return v;
}

@end
