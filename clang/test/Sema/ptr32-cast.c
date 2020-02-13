// RUN: %clang_cc1 -triple x86_64-apple-macosx10.14.0-wine32 -Wint-to-pointer-cast-truncates -Wpointer-to-int-cast-truncates -Wpointer-to-int-cast -fsyntax-only -verify %s

extern int **foo;
extern int * __ptr32 *bar;
extern int *baz;
extern long *quux;

extern int ** __ptr32 foo32;
extern int * __ptr32 * __ptr32 bar32;
extern int * __ptr32 baz32;
extern long * __ptr32 quux32;

void test(void) {
  foo = (int **)foo32; // no-warning
  bar = (int * __ptr32 *)bar32; // no-warning

  foo32 = (int ** __ptr32)foo; // expected-error{{changes address space of pointer}}
  bar32 = (int * __ptr32 * __ptr32)bar; // expected-error{{changes address space of pointer}}

  foo32 = (__addrspace int ** __ptr32)foo; // no-warning
  bar32 = (__addrspace int * __ptr32 * __ptr32)bar; // no-warning

  foo32 = (__truncate int ** __ptr32)foo; // no-warning
  bar32 = (__truncate int * __ptr32 * __ptr32)bar; // no-warning

  bar = (int * __ptr32 *)foo; // expected-error{{changes address space of pointer}}
  foo = (int **)bar; // expected-error{{changes address space of pointer}}

  bar = (__addrspace int * __ptr32 *)foo; // expected-error{{changes address space of pointer}}
  foo = (__addrspace int **)bar; // expected-error{{changes address space of pointer}}

  bar = (__truncate int * __ptr32 *)foo; // no-warning
  foo = (__truncate int **)bar; // no-warning

  bar = (int * __ptr32 *)foo32; // expected-error{{changes address space of pointer}}
  foo = (int **)bar32; // expected-error{{changes address space of pointer}}

  bar = (__addrspace int * __ptr32 *)foo32; // expected-error{{changes address space of pointer}}
  foo = (__addrspace int **)bar32; // expected-error{{changes address space of pointer}}

  bar = (__truncate int * __ptr32 *)foo32; // no-warning
  foo = (__truncate int **)bar32; // no-warning

  bar32 = (int * __ptr32 * __ptr32)foo; // expected-error{{changes address space of pointer}}
  foo32 = (int ** __ptr32)bar; // expected-error{{changes address space of pointer}}

  bar32 = (__addrspace int * __ptr32 * __ptr32)foo; // expected-error{{changes address space of pointer}}
  foo32 = (__addrspace int ** __ptr32)bar; // expected-error{{changes address space of pointer}}

  bar32 = (__truncate int * __ptr32 * __ptr32)foo; // no-warning
  foo32 = (__truncate int ** __ptr32)bar; // no-warning

  baz = (int *)foo; // expected-warning{{cast to 'int' from larger pointer type 'int *'}}
  baz = (__addrspace int *)foo; // expected-warning{{cast to 'int' from larger pointer type 'int *'}}
  baz = (__truncate int *)foo; // no-warning
  quux = (long *)foo; // no-warning

  foo = (int **)baz; // expected-warning{{cast to 'int *' from smaller integer type 'int'}}
  foo = (__addrspace int **)baz; // expected-warning{{cast to 'int *' from smaller integer type 'int'}}
  foo = (__truncate int **)baz; // no-warning
  foo = (int **)quux; // no-warning

  baz = (int *)bar; // no-warning
  quux = (long *)bar; // expected-warning{{cast to 'long' from smaller pointer type '__storage32 int * __ptr32'}}
  quux = (__addrspace long *)bar; // expected-warning{{cast to 'long' from smaller pointer type '__storage32 int * __ptr32'}}
  quux = (__truncate long *)bar; // no-warning

  bar = (int * __ptr32 *)baz; // no-warning
  bar = (int * __ptr32 *)quux; // expected-warning{{cast to '__storage32 int * __ptr32' from larger integer type 'long'}}
  bar = (__addrspace int * __ptr32 *)quux; // expected-warning{{cast to '__storage32 int * __ptr32' from larger integer type 'long'}}
  bar = (__truncate int * __ptr32 *)quux; // no-warning

  baz32 = (int * __ptr32)foo; // expected-error{{changes address space of pointer}} expected-warning{{cast to '__storage32 int' from larger pointer type 'int *'}}
  baz32 = (__addrspace int * __ptr32)foo; // expected-warning{{cast to '__storage32 int' from larger pointer type 'int *'}}
  baz32 = (__truncate int * __ptr32)foo; // no-warning
  quux32 = (long * __ptr32)foo; // expected-error{{changes address space of pointer}}
  quux32 = (__addrspace long * __ptr32)foo; // no-warning
  quux32 = (__truncate long * __ptr32)foo; // no-warning

  foo32 = (int ** __ptr32)baz; // expected-error{{changes address space of pointer}} expected-warning{{cast to 'int *__storage32' from smaller integer type 'int'}}
  foo32 = (__addrspace int ** __ptr32)baz; // expected-warning{{cast to 'int *__storage32' from smaller integer type 'int'}}
  foo32 = (__truncate int ** __ptr32)baz; // no-warning
  foo32 = (int ** __ptr32)quux; // expected-error{{changes address space of pointer}}
  foo32 = (__addrspace int ** __ptr32)quux; // no-warning
  foo32 = (__truncate int ** __ptr32)quux; // no-warning

  baz32 = (int * __ptr32)bar; // expected-error{{changes address space of pointer}}
  baz32 = (__addrspace int * __ptr32)bar; // no-warning
  baz32 = (__truncate int * __ptr32)bar; // no-warning
  quux32 = (long * __ptr32)bar; // expected-error{{changes address space of pointer}} expected-warning{{cast to '__storage32 long' from smaller pointer type '__storage32 int * __ptr32'}}
  quux32 = (__addrspace long * __ptr32)bar; // expected-warning{{cast to '__storage32 long' from smaller pointer type '__storage32 int * __ptr32'}}
  quux32 = (__truncate long * __ptr32)bar; // no-warning

  bar32 = (int * __ptr32 * __ptr32)baz; // expected-error{{changes address space of pointer}}
  bar32 = (__addrspace int * __ptr32 * __ptr32)baz; // no-warning
  bar32 = (__truncate int * __ptr32 * __ptr32)baz; // no-warning
  bar32 = (int * __ptr32 * __ptr32)quux; // expected-error{{changes address space of pointer}} expected-warning{{cast to '__storage32 int * __ptr32 __storage32' from larger integer type 'long'}}
  bar32 = (__addrspace int * __ptr32 * __ptr32)quux; // expected-warning{{cast to '__storage32 int * __ptr32 __storage32' from larger integer type 'long'}}
  bar32 = (__truncate int * __ptr32 * __ptr32)quux; // no-warning
}
