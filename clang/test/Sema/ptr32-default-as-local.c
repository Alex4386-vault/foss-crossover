// RUN: %clang_cc1 -triple x86_64-apple-macosx10.13.0-wine32 -ilocal %S/Inputs -fsyntax-only -verify %s
// expected-no-diagnostics

#pragma clang default_addr_space(push, ptr32)

#include <ptr32-system-as.h>

_Static_assert(sizeof(other_pointer) == 4, "Pointer from local header should be 8 bytes long!");
_Static_assert(_Alignof(other_pointer) == 4, "Pointer from local header should be aligned to 8 bytes!");
_Static_assert(sizeof(other_pointer*) == 4, "Pointer from local header should be 8 bytes long!");
_Static_assert(_Alignof(other_pointer*) == 4, "Pointer from local header should be aligned to 8 bytes!");

_Static_assert(sizeof(system_pointer) == 4, "Pointer from local header should be 8 bytes long!");
_Static_assert(_Alignof(system_pointer) == 4, "Pointer from local header should be aligned to 8 bytes!");
_Static_assert(sizeof(system_pointer*) == 4, "Pointer from local header should be 8 bytes long!");
_Static_assert(_Alignof(system_pointer*) == 4, "Pointer from local header should be aligned to 8 bytes!");

#pragma clang default_addr_space(pop)

