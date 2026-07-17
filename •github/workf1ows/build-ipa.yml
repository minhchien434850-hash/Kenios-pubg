// =============================================
// KENIOS HAX - Anti-Cheat Module (iOS 16.0-26.5)
// Tự động phát hiện & bypass anti-cheat
// =============================================

#import "KeniosCommon.h"
#import "KeniosOffsets.h"
#import "KeniosConfig.h"
#import <substrate.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <sys/sysctl.h>
#import <objc/runtime.h>

@interface KeniosAntiCheat : NSObject
+ (instancetype)sharedInstance;
- (void)startProtection;
- (void)stopProtection;
- (BOOL)detectAntiCheatModules;
- (void)bypassAll;
- (NSArray *)getDetectedModules;
@end

@implementation KeniosAntiCheat {
    NSMutableArray *_detectedModules;
    BOOL _isActive;
    NSTimer *_scanTimer;
}

+ (instancetype)sharedInstance {
    static KeniosAntiCheat *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[KeniosAntiCheat alloc] init]; });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _detectedModules = [[NSMutableArray alloc] init];
        _isActive = NO;
    }
    return self;
}

- (void)startProtection {
    if (_isActive) return;
    _isActive = YES;
    KENIOS_LOG(@"Anti-Cheat protection started");
    
    [self bypassAll];
    
    _scanTimer = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                  repeats:YES
                                                    block:^(NSTimer *timer) {
        [self detectAntiCheatModules];
    }];
}

- (void)stopProtection {
    _isActive = NO;
    [_scanTimer invalidate];
    _scanTimer = nil;
    KENIOS_LOG(@"Anti-Cheat protection stopped");
}

- (BOOL)detectAntiCheatModules {
    [_detectedModules removeAllObjects];
    
    NSArray *knownModules = @[
        @"ACE", @"TPProtect", @"MTP", @"tersafe",
        @"GCloud", @"bugly", @"tdm", @"CrashSight",
        @"MSDK", @"TDataMaster", @"SecShell",
        @"libprotect", @"libtprt", @"libanogs",
        @"libanort", @"libcrosCurl", @"libcros_protect",
        @"libgcloudcore", @"libgcloudvoice",
        @"libTDataMaster", @"libtgpa", @"libtersafe",
        @"libturing", @"libvmp", @"libtss", @"libBosa",
        @"libturingbase", @"libtbs", @"libxguardian",
        @"libgcloud", @"libMidasOversea",
        @"libMSDKPIXCore", @"libMSDKPIXWebView"
    ];
    
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (!name) continue;
        
        NSString *moduleName = [NSString stringWithUTF8String:name];
        for (NSString *target in knownModules) {
            if ([moduleName containsString:target]) {
                [_detectedModules addObject:@{
                    @"name": target,
                    @"path": moduleName,
                    @"index": @(i)
                }];
                KENIOS_LOG(@"Detected anti-cheat: %@", target);
            }
        }
    }
    
    // Kiểm tra Objective-C classes
    NSArray *knownClasses = @[@"ACE", @"TPProtect", @"TssSDK", @"MSDKPIX"];
    for (NSString *className in knownClasses) {
        Class cls = objc_getClass([className UTF8String]);
        if (cls) {
            [_detectedModules addObject:@{
                @"name": className,
                @"path": @"Objective-C Class",
                @"index": @(-1)
            }];
            KENIOS_LOG(@"Detected anti-cheat class: %@", className);
        }
    }
    
    return _detectedModules.count > 0;
}

- (void)bypassAll {
    [self bypassJailbreakDetection];
    [self bypassDebuggerDetection];
    [self bypassFileChecks];
    [self bypassSysctlChecks];
    [self bypassSandboxChecks];
    [self bypassIntegrityChecks];
    [self bypassHookDetection];
}

- (void)bypassJailbreakDetection {
    // Hook sysctl
    MSHookFunction((void *)sysctl, (void *)&hooked_sysctl, NULL);
    MSHookFunction((void *)sysctlbyname, (void *)&hooked_sysctlbyname, NULL);
    
    // Hook fopen
    MSHookFunction((void *)fopen, (void *)&hooked_fopen, NULL);
    
    // Hook access
    MSHookFunction((void *)access, (void *)&hooked_access, NULL);
    
    // Hook stat
    MSHookFunction((void *)stat, (void *)&hooked_stat, NULL);
    
    // Hook NSFileManager
    Class fileManager = NSClassFromString(@"NSFileManager");
    if (fileManager) {
        Method method = class_getInstanceMethod(fileManager, @selector(fileExistsAtPath:));
        if (method) {
            method_setImplementation(method, (IMP)hooked_fileExistsAtPath);
        }
    }
    
    KENIOS_LOG(@"Jailbreak detection bypassed");
}

- (void)bypassDebuggerDetection {
    // Hook ptrace
    MSHookFunction((void *)ptrace, (void *)&hooked_ptrace, NULL);
    
    // Hook task_get_exception_ports
    MSHookFunction((void *)task_get_exception_ports, (void *)&hooked_task_get_exception_ports, NULL);
    
    KENIOS_LOG(@"Debugger detection bypassed");
}

- (void)bypassFileChecks {
    // Đã xử lý trong bypassJailbreakDetection
}

- (void)bypassSysctlChecks {
    // Đã xử lý trong bypassJailbreakDetection
}

- (void)bypassSandboxChecks {
    // Hook sandbox_check
    void *sandbox_check_ptr = dlsym(RTLD_DEFAULT, "sandbox_check");
    if (sandbox_check_ptr) {
        MSHookFunction(sandbox_check_ptr, (void *)&hooked_sandbox_check, NULL);
    }
}

- (void)bypassIntegrityChecks {
    // Hook mach_vm_region
    void *mach_vm_region_ptr = dlsym(RTLD_DEFAULT, "mach_vm_region");
    if (mach_vm_region_ptr) {
        MSHookFunction(mach_vm_region_ptr, (void *)&hooked_mach_vm_region, NULL);
    }
    
    // Hook vm_region_recurse_64
    void *vm_region_ptr = dlsym(RTLD_DEFAULT, "vm_region_recurse_64");
    if (vm_region_ptr) {
        MSHookFunction(vm_region_ptr, (void *)&hooked_vm_region_recurse_64, NULL);
    }
}

- (void)bypassHookDetection {
    // Ẩn các dấu hiệu của Substrate/Substitute
    // Hook dlsym để ẩn symbol
    MSHookFunction((void *)dlsym, (void *)&hooked_dlsym, NULL);
}

- (NSArray *)getDetectedModules {
    return [_detectedModules copy];
}

@end

// ============ HOOKED FUNCTIONS ============

static int hooked_sysctl(int *name, u_int namelen, void *oldp, size_t *oldlenp, void *newp, size_t newlen) {
    // Chặn kiểm tra jailbreak
    if (name && namelen >= 2 && name[0] == CTL_KERN) {
        if (name[1] == KERN_PROC) {
            // Giả mạo không có debugger
            if (oldp && oldlenp) {
                struct kinfo_proc *info = (struct kinfo_proc *)oldp;
                memset(info, 0, sizeof(struct kinfo_proc));
                info->kp_proc.p_flag = 0;
                *oldlenp = sizeof(struct kinfo_proc);
                return 0;
            }
        }
        if (name[1] == KERN_BOOTTIME) {
            return 0;
        }
    }
    return 0;
}

static int hooked_sysctlbyname(const char *name, void *oldp, size_t *oldlenp, void *newp, size_t newlen) {
    if (!name) return 0;
    
    // Chặn kiểm tra jailbreak
    NSArray *blocked = @[
        @"kern.bootargs",
        @"security.mac.proc_enforce",
        @"security.mac.vnode_enforce"
    ];
    
    NSString *nameStr = [NSString stringWithUTF8String:name];
    for (NSString *blockedName in blocked) {
        if ([nameStr isEqualToString:blockedName]) {
            if (oldp && oldlenp) {
                memset(oldp, 0, *oldlenp);
            }
            return 0;
        }
    }
    
    return 0;
}

static FILE *hooked_fopen(const char *filename, const char *mode) {
    if (!filename) return NULL;
    
    NSString *path = [NSString stringWithUTF8String:filename];
    NSArray *blocked = @[
        @"Cydia", @"MobileSubstrate", @"cydia",
        @"ssh", @"apt", @"dpkg", @"sbin"
    ];
    
    for (NSString *block in blocked) {
        if ([path containsString:block]) {
            errno = ENOENT;
            return NULL;
        }
    }
    
    return fopen(filename, mode);
}

static int hooked_access(const char *path, int mode) {
    if (!path) return -1;
    
    NSString *pathStr = [NSString stringWithUTF8String:path];
    NSArray *blocked = @[@"Cydia", @"MobileSubstrate", @"cydia", @"ssh", @"apt"];
    
    for (NSString *block in blocked) {
        if ([pathStr containsString:block]) {
            errno = ENOENT;
            return -1;
        }
    }
    
    return access(path, mode);
}

static int hooked_stat(const char *path, struct stat *buf) {
    if (!path) return -1;
    
    NSString *pathStr = [NSString stringWithUTF8String:path];
    NSArray *blocked = @[@"Cydia", @"MobileSubstrate", @"cydia"];
    
    for (NSString *block in blocked) {
        if ([pathStr containsString:block]) {
            errno = ENOENT;
            return -1;
        }
    }
    
    return stat(path, buf);
}

static BOOL hooked_fileExistsAtPath(id self, SEL _cmd, NSString *path) {
    NSArray *blocked = @[@"Cydia", @"MobileSubstrate", @"cydia", @"ssh", @"apt", @"sbin"];
    for (NSString *block in blocked) {
        if ([path containsString:block]) return NO;
    }
    return NO;
}

static int hooked_ptrace(int request, pid_t pid, caddr_t addr, int data) {
    // Chặn ptrace
    if (request == PT_DENY_ATTACH) return 0;
    if (request == PT_TRACE_ME) return 0;
    return 0;
}

static kern_return_t hooked_task_get_exception_ports(
    task_t task, exception_mask_t exception_mask,
    exception_mask_array_t masks, mach_msg_type_number_t *masksCnt,
    exception_handler_array_t old_handlers,
    exception_behavior_array_t old_behaviors,
    exception_flavor_array_t old_flavors) {
    *masksCnt = 0;
    return KERN_SUCCESS;
}

static kern_return_t hooked_mach_vm_region(
    vm_map_t target_task, mach_vm_address_t *address,
    mach_vm_size_t *size, vm_region_flavor_t flavor,
    vm_region_info_t info, mach_msg_type_number_t *infoCnt,
    mach_port_t *object_name) {
    return KERN_INVALID_ADDRESS;
}

static kern_return_t hooked_vm_region_recurse_64(
    vm_map_t target_task, mach_vm_address_t *address,
    mach_vm_size_t *size, uint32_t *depth,
    vm_region_recurse_info_t info, mach_msg_type_number_t *infoCnt) {
    return KERN_INVALID_ADDRESS;
}

static int hooked_sandbox_check(pid_t pid, const char *operation, int type, ...) {
    return 0; // Cho phép tất cả
}

static void *hooked_dlsym(void *handle, const char *symbol) {
    // Ẩn các symbol liên quan đến jailbreak
    NSArray *hidden = @[@"MSHookFunction", @"MSHookMessageEx", @"MSFindSymbol"];
    NSString *sym = [NSString stringWithUTF8String:symbol];
    for (NSString *h in hidden) {
        if ([sym containsString:h]) return NULL;
    }
    return dlsym(handle, symbol);
}
