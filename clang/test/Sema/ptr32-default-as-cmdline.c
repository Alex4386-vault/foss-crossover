// RUN: %clang_cc1 -triple x86_64-apple-macosx10.13.0-wine32 -mdefault-address-space=ptr32 -mstorage-address-space=ptr32 -isystem %S/Inputs -fsyntax-only -verify %s

#include <ptr32-system-as.h>

extern void * p32;
extern void * __ptr64 p64;

_Static_assert(sizeof(void *) == 4, "__ptr32 should be 4 bytes long!");
_Static_assert(_Alignof(void *) == 4, "__ptr32 should be aligned to 4 bytes!");
_Static_assert(sizeof(void * __ptr64) == 8, "__ptr64 should be 8 bytes long!");
_Static_assert(_Alignof(void * __ptr64) == 8, "__ptr64 should be aligned to 8 bytes!");
_Static_assert(sizeof(p32) == 4, "__ptr32 should be 4 bytes long!");
_Static_assert(sizeof(&p32) == 4, "__ptr32 should be 4 bytes long!");
_Static_assert(sizeof(p64) == 8, "__ptr64 should be 8 bytes long!");
_Static_assert(sizeof(&p64) == 4, "__ptr32 should be 4 bytes long!");

_Static_assert(sizeof(other_pointer) == 8, "Pointer from system header should be 8 bytes long!");
_Static_assert(_Alignof(other_pointer) == 8, "Pointer from system header should be aligned to 8 bytes!");
_Static_assert(sizeof(system_pointer) == 8, "Pointer from system header should be 8 bytes long!");
_Static_assert(_Alignof(system_pointer) == 8, "Pointer from system header should be aligned to 8 bytes!");
_Static_assert(sizeof(&quux) == 8, "Pointer from system header should be aligned to 8 bytes!");

#pragma clang default_addr_space(push, default)

int bar;

_Static_assert(sizeof(void *) == 8, "__ptr64 should be 8 bytes long!");
_Static_assert(_Alignof(void *) == 8, "__ptr64 should be aligned to 8 bytes!");
_Static_assert(sizeof(p32) == 4, "__ptr32 should be 4 bytes long!");
_Static_assert(sizeof(p64) == 8, "__ptr64 should be 8 bytes long!");
_Static_assert(sizeof(&bar) == 4, "__ptr32 should be 4 bytes long!");
_Static_assert(sizeof(&quux) == 8, "Pointer from system header should be aligned to 8 bytes!");

#pragma clang default_addr_space()

_Static_assert(sizeof(void *) == 4, "__ptr32 should be 4 bytes long!");
_Static_assert(_Alignof(void *) == 4, "__ptr32 should be aligned to 4 bytes!");
_Static_assert(sizeof(&bar) == 4, "__ptr32 should be 4 bytes long!");
_Static_assert(sizeof(&quux) == 8, "Pointer from system header should be aligned to 8 bytes!");

#pragma clang storage_addr_space(push, default)

int baz;

_Static_assert(sizeof(void *) == 4, "__ptr32 should be 4 bytes long!");
_Static_assert(_Alignof(void *) == 4, "__ptr32 should be aligned to 4 bytes!");
_Static_assert(sizeof(&bar) == 4, "__ptr32 should be 4 bytes long!");
_Static_assert(sizeof(&baz) == 8, "__ptr64 should be 8 bytes long!");
_Static_assert(sizeof(&quux) == 8, "Pointer from system header should be aligned to 8 bytes!");

#pragma clang storage_addr_space(pop)

void foo() {
  void *p = p64;
  // expected-error@-1{{initializing '__storage32 void *__storage32' with an expression of type 'void * __ptr64 __storage32' changes address space of pointer}}
  p = p32;  // no-warning
  p32 = p64;
  // expected-error@-1{{assigning 'void * __ptr64 __storage32' to '__storage32 void *__storage32' changes address space of pointer}}
}
