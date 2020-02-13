// RUN: %clang_cc1 -triple x86_64-apple-macosx10.13.0-wine32 -msystem-address-space=ptr32 -isystem %S/Inputs -fsyntax-only -verify %s
// expected-no-diagnostics

#include <ptr32-system-as.h>

extern void * __ptr32 p32;
extern void * p64;

_Static_assert(sizeof(void * __ptr32) == 4, "__ptr32 should be 4 bytes long!");
_Static_assert(_Alignof(void * __ptr32) == 4, "__ptr32 should be aligned to 4 bytes!");
_Static_assert(sizeof(void *) == 8, "__ptr64 should be 8 bytes long!");
_Static_assert(_Alignof(void *) == 8, "__ptr64 should be aligned to 8 bytes!");
_Static_assert(sizeof(p32) == 4, "__ptr32 should be 4 bytes long!");

_Static_assert(sizeof(system_pointer) == 4, "Pointer from system header should be 4 bytes long!");
_Static_assert(_Alignof(system_pointer) == 4, "Pointer from system header should be aligned to 4 bytes!");

