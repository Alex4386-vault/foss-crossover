// RUN: %clang_cc1 -fsyntax-only -verify -triple x86_64-apple-darwin10-wine32 %s

// CC qualifier can be applied only to functions
int __attribute__((stdcall32)) var1; // expected-warning{{'stdcall32' only applies to function types; type here is 'int'}}
int __attribute__((fastcall32)) var2; // expected-warning{{'fastcall32' only applies to function types; type here is 'int'}}

// Different CC qualifiers are not compatible
void __attribute__((stdcall32, fastcall32)) foo3(void); // expected-error{{fastcall32 and stdcall32 attributes are not compatible}}
void __attribute__((stdcall32)) foo4(); // expected-note{{previous declaration is here}} expected-error{{function with no prototype cannot use the stdcall32 calling convention}}
void __attribute__((fastcall32)) foo4(void); // expected-error{{function declared 'fastcall32' here was previously declared 'stdcall32'}}

// rdar://8876096
void rdar8876096foo1(int i, int j) __attribute__((fastcall32, cdecl32)); // expected-error {{not compatible}}
void rdar8876096foo2(int i, int j) __attribute__((fastcall32, stdcall32)); // expected-error {{not compatible}}
void rdar8876096foo3(int i, int j) __attribute__((fastcall32, regparm(2))); // expected-error {{not compatible}}
void rdar8876096foo4(int i, int j) __attribute__((stdcall32, cdecl32)); // expected-error {{not compatible}}
void rdar8876096foo5(int i, int j) __attribute__((stdcall32, fastcall32)); // expected-error {{not compatible}}
void rdar8876096foo6(int i, int j) __attribute__((cdecl32, fastcall32)); // expected-error {{not compatible}}
void rdar8876096foo7(int i, int j) __attribute__((cdecl32, stdcall32)); // expected-error {{not compatible}}
void rdar8876096foo8(int i, int j) __attribute__((regparm(2), fastcall32)); // expected-error {{not compatible}}
