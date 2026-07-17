#import "KeniosCommon.h"
#import "fishhook.h"
#import <sys/sysctl.h>

static int (*orig_sysctl)(int *, u_int, void *, size_t *, void *, size_t);
static int my_sysctl(int *name, u_int namelen, void *oldp, size_t *oldlenp, void *newp, size_t newlen) {
    if (name && namelen >= 2 && name[0] == CTL_KERN && name[1] == KERN_PROC) {
        if (oldp && oldlenp) {
            memset(oldp, 0, *oldlenp);
        }
        return 0;
    }
    return orig_sysctl(name, namelen, oldp, oldlenp, newp, newlen);
}

__attribute__((constructor))
static void init_anticheat() {
    rebind_symbols((struct rebinding[1]){{"sysctl", my_sysctl, (void*)&orig_sysctl}}, 1);
}
