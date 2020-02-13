// RUN: %clang_cc1 -triple x86_64-apple-macosx10.13.0-wine32 -fsyntax-only -verify %s
// expected-no-diagnostics
#pragma clang default_addr_space(ptr32)

void (* __ptr64 foo)(void);
