// RUN: %clang_cc1 -triple x86_64-apple-macosx10.13.0-wine32 -isystem %S/Inputs -fsyntax-only -verify %s
// RUN: %clang_cc1 -triple x86_64-apple-macosx10.13.0-wine32 -I %S/Inputs -fsyntax-only -verify %s

#pragma clang default_addr_space(push, ptr32)

#include <ptr32-system-as.h>

extern void * p32;
extern void * __ptr64 p64;

_Static_assert(sizeof(void *) == 4, "__ptr32 should be 4 bytes long!");
_Static_assert(_Alignof(void *) == 4, "__ptr32 should be aligned to 4 bytes!");
_Static_assert(sizeof(void * __ptr64) == 8, "__ptr64 should be 8 bytes long!");
_Static_assert(_Alignof(void * __ptr64) == 8, "__ptr64 should be aligned to 8 bytes!");

_Static_assert(sizeof(other_pointer) == 8, "Pointer from system header should be 8 bytes long!");
_Static_assert(_Alignof(other_pointer) == 8, "Pointer from system header should be aligned to 8 bytes!");
_Static_assert(sizeof(other_pointer*) == 8, "Pointer from system header should be 8 bytes long!");
_Static_assert(_Alignof(other_pointer*) == 8, "Pointer from system header should be aligned to 8 bytes!");

_Static_assert(sizeof(system_pointer) == 8, "Pointer from system header should be 8 bytes long!");
_Static_assert(_Alignof(system_pointer) == 8, "Pointer from system header should be aligned to 8 bytes!");
_Static_assert(sizeof(system_pointer*) == 8, "Pointer from system header should be 8 bytes long!");
_Static_assert(_Alignof(system_pointer*) == 8, "Pointer from system header should be aligned to 8 bytes!");

#pragma clang default_addr_space(pop)

_Static_assert(sizeof(void *) == 8, "__ptr64 should be 8 bytes long!");
_Static_assert(_Alignof(void *) == 8, "__ptr64 should be aligned to 8 bytes!");
_Static_assert(sizeof(p64) == 8, "__ptr64 should be 8 bytes long!");

void foo() {
  void *p = p64;  // no-warning
  // It should be possible to convert 32->64...
  p = p32;  // no-warning
  // ...but not 64->32.
  p32 = p64;
  // expected-error@-1{{assigning 'void * __ptr64' to '__storage32 void *' changes address space of pointer}}
}
