// =============================================
// KENIOS HAX - Memory Read/Write Module
// iOS 16.0-26.5
// =============================================

#import "KeniosCommon.h"
#import <mach/mach.h>
#import <mach/mach_vm.h>

@interface KeniosMemory : NSObject
@end

@implementation KeniosMemory

#pragma mark - Basic Memory Operations

+ (uint64_t)readPtr:(uint64_t)addr {
    if (addr == 0 || addr < 0x100000000) return 0;
    @try {
        return *(uint64_t *)addr;
    } @catch (NSException *e) {
        return 0;
    }
}

+ (float)readFloat:(uint64_t)addr {
    if (addr == 0 || addr < 0x100000000) return 0.0f;
    @try {
        return *(float *)addr;
    } @catch (NSException *e) {
        return 0.0f;
    }
}

+ (int)readInt:(uint64_t)addr {
    if (addr == 0 || addr < 0x100000000) return 0;
    @try {
        return *(int *)addr;
    } @catch (NSException *e) {
        return 0;
    }
}

+ (double)readDouble:(uint64_t)addr {
    if (addr == 0 || addr < 0x100000000) return 0.0;
    @try {
        return *(double *)addr;
    } @catch (NSException *e) {
        return 0.0;
    }
}

+ (BOOL)readBool:(uint64_t)addr {
    if (addr == 0 || addr < 0x100000000) return NO;
    @try {
        return *(BOOL *)addr;
    } @catch (NSException *e) {
        return NO;
    }
}

+ (void)writeFloat:(uint64_t)addr value:(float)value {
    if (addr == 0 || addr < 0x100000000) return;
    @try {
        *(float *)addr = value;
    } @catch (NSException *e) {
        KENIOS_LOG_ERROR(@"Failed to write float at 0x%llx", addr);
    }
}

+ (void)writeInt:(uint64_t)addr value:(int)value {
    if (addr == 0 || addr < 0x100000000) return;
    @try {
        *(int *)addr = value;
    } @catch (NSException *e) {
        KENIOS_LOG_ERROR(@"Failed to write int at 0x%llx", addr);
    }
}

+ (void)writePtr:(uint64_t)addr value:(uint64_t)value {
    if (addr == 0 || addr < 0x100000000) return;
    @try {
        *(uint64_t *)addr = value;
    } @catch (NSException *e) {
        KENIOS_LOG_ERROR(@"Failed to write ptr at 0x%llx", addr);
    }
}

+ (void)writeDouble:(uint64_t)addr value:(double)value {
    if (addr == 0 || addr < 0x100000000) return;
    @try {
        *(double *)addr = value;
    } @catch (NSException *e) {
        KENIOS_LOG_ERROR(@"Failed to write double at 0x%llx", addr);
    }
}

+ (void)writeBool:(uint64_t)addr value:(BOOL)value {
    if (addr == 0 || addr < 0x100000000) return;
    @try {
        *(BOOL *)addr = value;
    } @catch (NSException *e) {
        KENIOS_LOG_ERROR(@"Failed to write bool at 0x%llx", addr);
    }
}

+ (KeniosVector3)readVector3:(uint64_t)addr {
    KeniosVector3 vec = {0, 0, 0};
    if (addr == 0 || addr < 0x100000000) return vec;
    @try {
        vec.x = *(float *)(addr);
        vec.y = *(float *)(addr + 4);
        vec.z = *(float *)(addr + 8);
    } @catch (NSException *e) {}
    return vec;
}

+ (void)writeVector3:(uint64_t)addr value:(KeniosVector3)value {
    if (addr == 0 || addr < 0x100000000) return;
    @try {
        *(float *)(addr) = value.x;
        *(float *)(addr + 4) = value.y;
        *(float *)(addr + 8) = value.z;
    } @catch (NSException *e) {}
}

#pragma mark - Advanced Memory Operations

+ (uint64_t)getModuleBase:(const char *)moduleName {
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && strstr(name, moduleName)) {
            return _dyld_get_image_vmaddr_slide(i) + 0x100000000;
        }
    }
    return 0;
}

+ (uint64_t)getModuleSize:(const char *)moduleName {
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && strstr(name, moduleName)) {
            const struct mach_header_64 *header = (const struct mach_header_64 *)_dyld_get_image_header(i);
            if (header && header->magic == MH_MAGIC_64) {
                uint64_t size = 0;
                struct load_command *lc = (struct load_command *)((uint64_t)header + sizeof(struct mach_header_64));
                for (uint32_t j = 0; j < header->ncmds; j++) {
                    if (lc->cmd == LC_SEGMENT_64) {
                        struct segment_command_64 *seg = (struct segment_command_64 *)lc;
                        uint64_t segEnd = seg->vmaddr + seg->vmsize;
                        if (segEnd > size) size = segEnd;
                    }
                    lc = (struct load_command *)((uint64_t)lc + lc->cmdsize);
                }
                return size;
            }
        }
    }
    return 0;
}

+ (uint64_t)findPattern:(const unsigned char *)pattern mask:(const char *)mask length:(size_t)length inModule:(const char *)moduleName {
    uint64_t base = [self getModuleBase:moduleName];
    uint64_t size = [self getModuleSize:moduleName];
    
    if (base == 0 || size == 0) return 0;
    
    for (uint64_t addr = base; addr < base + size - length; addr++) {
        BOOL found = YES;
        for (size_t k = 0; k < length; k++) {
            if (mask[k] == 'x' && *(unsigned char *)(addr + k) != pattern[k]) {
                found = NO;
                break;
            }
        }
        if (found) return addr;
    }
    
    return 0;
}

+ (BOOL)isValidAddress:(uint64_t)addr {
    if (addr == 0 || addr < 0x100000000) return NO;
    
    vm_region_basic_info_data_t info;
    mach_msg_type_number_t count = VM_REGION_BASIC_INFO_COUNT_64;
    mach_vm_address_t address = addr;
    mach_vm_size_t size = 0;
    memory_object_name_t object;
    
    kern_return_t kr = mach_vm_region(mach_task_self(), &address, &size,
                                       VM_REGION_BASIC_INFO,
                                       (vm_region_info_t)&info, &count, &object);
    
    return (kr == KERN_SUCCESS && info.protection & VM_PROT_READ);
}

+ (void)nopFunction:(uint64_t)addr {
    // ARM64 NOP: 0xD503201F (4 bytes)
    unsigned char nop[] = {0x1F, 0x20, 0x03, 0xD5};
    vm_protect(mach_task_self(), (vm_address_t)addr, sizeof(nop), NO,
               VM_PROT_READ | VM_PROT_WRITE | VM_PROT_EXECUTE);
    memcpy((void *)addr, nop, sizeof(nop));
    sys_icache_invalidate((void *)addr, sizeof(nop));
}

+ (void)retFunction:(uint64_t)addr {
    // ARM64 RET: 0xD65F03C0 (4 bytes)
    unsigned char ret[] = {0xC0, 0x03, 0x5F, 0xD6};
    vm_protect(mach_task_self(), (vm_address_t)addr, sizeof(ret), NO,
               VM_PROT_READ | VM_PROT_WRITE | VM_PROT_EXECUTE);
    memcpy((void *)addr, ret, sizeof(ret));
    sys_icache_invalidate((void *)addr, sizeof(ret));
}

@end
