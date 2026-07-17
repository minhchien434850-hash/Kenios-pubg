// fishhook.h – Header only (không cần file .c nếu dùng bản prebuilt)
#ifndef FISHHOOK_H
#define FISHHOOK_H

#include <stdint.h>
#include <mach-o/dyld.h>

#ifdef __cplusplus
extern "C" {
#endif

struct rebinding {
    const char *name;
    void *replacement;
    void **replaced;
};

int rebind_symbols(struct rebinding rebindings[], size_t rebindings_nel);
int rebind_symbols_image(void *header, intptr_t slide, struct rebinding rebindings[], size_t rebindings_nel);

#ifdef __cplusplus
}
#endif

#endif
