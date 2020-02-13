#include <stdarg.h>

typedef __builtin_ms_va_list __ms_va_list;
#define __ms_va_start(ap, a) __builtin_ms_va_start(ap, a)
#define __ms_va_end(ap) __builtin_ms_va_end(ap)

#ifdef __i386_on_x86_64__
typedef __builtin_va_list32 __va_list32;
#define __va_start32(ap, a) __builtin_va_start32(ap, a)
#define __va_end32(ap, a) __builtin_va_end32(ap)
#endif
