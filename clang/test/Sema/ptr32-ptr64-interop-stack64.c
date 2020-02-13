// RUN: %clang_cc1 -triple x86_64-apple-macosx10.13.0-wine32sp64 -fsyntax-only -verify %s

extern void * __ptr32 p32;
extern void * __ptr64 p64;

_Static_assert(sizeof(void * __ptr32) == 4, "__ptr32 should be 4 bytes long!");
_Static_assert(_Alignof(void * __ptr32) == 4, "__ptr32 should be aligned to 4 bytes!");
_Static_assert(sizeof(void * __ptr64) == 8, "__ptr64 should be 8 bytes long!");
_Static_assert(_Alignof(void * __ptr64) == 8, "__ptr64 should be aligned to 8 bytes!");

extern void bar(int * __ptr32);  // expected-note{{passing argument to parameter here}}
extern void baz(int *);

typedef void (__attribute__((stdcall32))* __ptr32 fp32)(int * __ptr32);
typedef void (__attribute__((stdcall32))* __ptr64 fp64)(int * __ptr32);
fp32 pquux;
extern void __attribute__((stdcall32)) quux(int * __ptr32);

void foo() {
  void *p = p64;  // no-warning
  // It should be possible to convert 32->64...
  p = p32;  // no-warning
  // ...but not 64->32.
  p32 = p64;
  // expected-error@-1{{assigning 'void * __ptr64' to '__storage32 void * __ptr32' changes address space of pointer}}
  // Stack variables in this sp64 environment may be anywhere in the address
  // space (i.e. they're __ptr64). Test that we cannot pass addresses of stack
  // variables around as though they were __ptr32.
  int x;
  bar(&x);
  // expected-error@-1{{passing 'int *' to parameter of type '__storage32 int * __ptr32' changes address space of pointer}}
  baz(&x);  // no-warning
  // It is possible to downcast 64-bit function pointers with a 32-bit
  // convention to a 32-bit pointer.
  if (pquux != quux)  // no-warning
    pquux = quux;  // no-warning
  fp32 blah = quux;  // no-warning
  fp32 blah2 = (fp32)quux;  // no-warning
  fp64 blah3 = quux;  // no-warning
  fp64 blah4 = (fp64)quux;  // no-warning
  blah = blah3; // no-warning
  //blah = (fp32)blah3; // FIXME
}
