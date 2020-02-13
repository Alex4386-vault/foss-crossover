// RUN: %clang_cc1 -triple x86_64-apple-macosx10.13.0-wine32 -std=c++11 -fsyntax-only -verify %s

#pragma clang default_addr_space(ptr32)
#pragma clang default_addr_space(default)

#pragma clang default_addr_space(0)
#pragma clang default_addr_space(32)
#pragma clang default_addr_space(0x3ffff0)

#pragma clang default_addr_space(push, ptr32)
#pragma clang default_addr_space(pop)
#pragma clang default_addr_space()

#pragma clang default_addr_space(0x800000)  // expected-warning{{expected integer between 0 and 4194293 inclusive}}

// FIXME: Better diagnostics here?
#pragma clang default_addr_space(global)  // expected-warning{{expected address space name}}
#pragma clang default_addr_space(local)  // expected-warning{{expected address space name}}
#pragma clang default_addr_space(constant)  // expected-warning{{expected address space name}}
#pragma clang default_addr_space(generic)  // expected-warning{{expected address space name}}
#pragma clang default_addr_space(device)  // expected-warning{{expected address space name}}
#pragma clang default_addr_space(shared)  // expected-warning{{expected address space name}}

#pragma clang default_addr_space(goto)  // expected-warning{{expected identifier or integer}}

#pragma clang default_addr_space(push)  // expected-warning{{expected ')' or ','}}
#pragma clang default_addr_space(pop, ptr32)  // expected-warning{{missing ')' after}}

#pragma clang default_addr_space foo  // expected-warning{{missing '(' after}}
#pragma clang default_addr_space(default  // expected-warning{{missing ')' after}}
#pragma clang default_addr_space(pop  // expected-warning{{missing ')' after}}
#pragma clang default_addr_space(  // expected-warning{{expected identifier or integer}}

#pragma clang default_addr_space(default) foo  // expected-warning{{extra tokens at end}}
