// RUN: %clang_cc1 -triple x86_64-apple-macosx10.14.0-wine32 -fsyntax-only -verify
// expected-no-diagnostics
#pragma clang default_addr_space(ptr32)

extern void __attribute__((stdcall32)) foo(void);
void (__attribute__((stdcall32)) *bar(_Bool c))(void) {
  return c ? foo : ((void *)0);
}
