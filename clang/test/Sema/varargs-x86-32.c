// RUN: %clang_cc1 -fsyntax-only -verify %s -triple i386-apple-darwin9

void foo(int a, ...) {
  __builtin_ms_va_start((void *)0, a); // expected-error {{this builtin is only available on x86-64 and aarch64 targets}}
  __builtin_va_start32((void *)0, a); // expected-error {{this builtin is only available on Wine32 targets}}
}
