// RUN: %clang_cc1 -fsyntax-only -verify %s -m64-32-interop -triple x86_64-apple-darwin9-wine32

// rdar://6726818
void f1() {
  const __builtin_va_list args2;
  (void)__builtin_va_arg(args2, int); // expected-error {{first argument to 'va_arg' is of type 'const __storage32 __builtin_va_list' and not 'va_list'}}
}

void f2(int a, ...) {
  __builtin_ms_va_list ap;
  __builtin_va_list32 ap32;
  __builtin_ms_va_start(ap, a); // expected-error {{'__builtin_ms_va_start' used in System V ABI function}}
  __builtin_va_start32(ap, a); // expected-error {{'__builtin_va_start32' used in System V ABI function}}
}

void __attribute__((ms_abi)) g1(int a) {
  __builtin_ms_va_list ap;

  __builtin_ms_va_start(ap, a, a); // expected-error {{too many arguments to function}}
  __builtin_ms_va_start(ap, a); // expected-error {{'va_start' used in function with fixed args}}
}

void __attribute__((ms_abi)) g2(int a, int b, ...) {
  __builtin_ms_va_list ap;

  __builtin_ms_va_start(ap, 10); // expected-warning {{second argument to 'va_start' is not the last named parameter}}
  __builtin_ms_va_start(ap, a); // expected-warning {{second argument to 'va_start' is not the last named parameter}}
  __builtin_ms_va_start(ap, b);
}

void __attribute__((ms_abi)) g3(float a, ...) { // expected-note 2{{parameter of type '__storage32 float' is declared here}}
  __builtin_ms_va_list ap;

  __builtin_ms_va_start(ap, a); // expected-warning {{passing an object that undergoes default argument promotion to 'va_start' has undefined behavior}}
  __builtin_ms_va_start(ap, (a)); // expected-warning {{passing an object that undergoes default argument promotion to 'va_start' has undefined behavior}}
}

void __attribute__((ms_abi)) g5() {
  __builtin_ms_va_list ap;
  __builtin_ms_va_start(ap, ap); // expected-error {{'va_start' used in function with fixed args}}
}

void __attribute__((ms_abi)) g6(int a, ...) {
  __builtin_ms_va_list ap;
  __builtin_ms_va_start(ap); // expected-error {{too few arguments to function}}
}

void __attribute__((ms_abi))
bar(__builtin_ms_va_list authors, ...) {
  __builtin_ms_va_start(authors, authors);
  (void)__builtin_va_arg(authors, int);
  __builtin_ms_va_end(authors);
}

void __attribute__((ms_abi)) g7(int a, ...) {
  __builtin_ms_va_list ap;
  __builtin_ms_va_start(ap, a);
  // FIXME: This error message is sub-par.
  __builtin_va_arg(ap, int) = 1; // expected-error {{expression is not assignable}}
  int *x = &__builtin_va_arg(ap, int); // expected-error {{cannot take the address of an rvalue}}
  __builtin_ms_va_end(ap);
}

void __attribute__((ms_abi)) g8(int a, ...) {
  __builtin_ms_va_list ap;
  __builtin_ms_va_start(ap, a);
  (void)__builtin_va_arg(ap, void); // expected-error {{second argument to 'va_arg' is of incomplete type 'void'}}
  __builtin_ms_va_end(ap);
}

enum E { x = -1, y = 2, z = 10000 };
void __attribute__((ms_abi)) g9(__builtin_ms_va_list args) {
  (void)__builtin_va_arg(args, float); // expected-warning {{second argument to 'va_arg' is of promotable type 'float'}}
  (void)__builtin_va_arg(args, enum E); // no-warning
  (void)__builtin_va_arg(args, short); // expected-warning {{second argument to 'va_arg' is of promotable type 'short'}}
  (void)__builtin_va_arg(args, char); // expected-warning {{second argument to 'va_arg' is of promotable type 'char'}}
}

void __attribute__((ms_abi)) g10(int a, ...) {
  __builtin_va_list ap;
  __builtin_va_list32 ap32;
  __builtin_va_start(ap, a); // expected-error {{'va_start' used in Win64 ABI function}}
  __builtin_va_start32(ap32, a); // expected-error {{'__builtin_va_start32' used in Win64 ABI function}}
}

void __attribute__((cdecl32)) h1(int a) {
  __builtin_va_list32 ap;

  __builtin_va_start32(ap, a, a); // expected-error {{too many arguments to function}}
  __builtin_va_start32(ap, a); // expected-error {{'va_start' used in function with fixed args}}
}

void __attribute__((cdecl32)) h2(int a, int b, ...) {
  __builtin_va_list32 ap;

  __builtin_va_start32(ap, 10); // expected-warning {{second argument to 'va_start' is not the last named parameter}}
  __builtin_va_start32(ap, a); // expected-warning {{second argument to 'va_start' is not the last named parameter}}
  __builtin_va_start32(ap, b);
}

void __attribute__((cdecl32)) h3(float a, ...) { // expected-note 2{{parameter of type '__storage32 float' is declared here}}
  __builtin_va_list32 ap;

  __builtin_va_start32(ap, a); // expected-warning {{passing an object that undergoes default argument promotion to 'va_start' has undefined behavior}}
  __builtin_va_start32(ap, (a)); // expected-warning {{passing an object that undergoes default argument promotion to 'va_start' has undefined behavior}}
}

void __attribute__((cdecl32)) h5() {
  __builtin_va_list32 ap;
  __builtin_va_start32(ap, ap); // expected-error {{'va_start' used in function with fixed args}}
}

void __attribute__((cdecl32)) h6(int a, ...) {
  __builtin_va_list32 ap;
  __builtin_va_start32(ap); // expected-error {{too few arguments to function}}
}

void __attribute__((cdecl32))
baz(__builtin_va_list32 authors, ...) {
  __builtin_va_start32(authors, authors);
  (void)__builtin_va_arg(authors, int);
  __builtin_va_end32(authors);
}

void __attribute__((cdecl32)) h7(int a, ...) {
  __builtin_va_list32 ap;
  __builtin_va_start32(ap, a);
  // FIXME: This error message is sub-par.
  __builtin_va_arg(ap, int) = 1; // expected-error {{expression is not assignable}}
  int *x = &__builtin_va_arg(ap, int); // expected-error {{cannot take the address of an rvalue}}
  __builtin_va_end32(ap);
}

void __attribute__((cdecl32)) h8(int a, ...) {
  __builtin_va_list32 ap;
  __builtin_va_start32(ap, a);
  (void)__builtin_va_arg(ap, void); // expected-error {{second argument to 'va_arg' is of incomplete type 'void'}}
  __builtin_va_end32(ap);
}

void __attribute__((cdecl32)) h9(__builtin_va_list32 args) {
  (void)__builtin_va_arg(args, float); // expected-warning {{second argument to 'va_arg' is of promotable type 'float'}}
  (void)__builtin_va_arg(args, enum E); // no-warning
  (void)__builtin_va_arg(args, short); // expected-warning {{second argument to 'va_arg' is of promotable type 'short'}}
  (void)__builtin_va_arg(args, char); // expected-warning {{second argument to 'va_arg' is of promotable type 'char'}}
}

void __attribute__((cdecl32)) h10(int a, ...) {
  __builtin_va_list ap;
  __builtin_ms_va_list mp;
  __builtin_va_start(ap, a); // expected-error {{'va_start' used in 32-bit ABI function}}
  __builtin_ms_va_start(mp, a); // expected-error {{'__builtin_ms_va_start' used in 32-bit ABI function}}
}

void i1(__builtin_va_list ap) {
  (void)__builtin_va_arg(ap, int);  // no-warning
}

void i2(__builtin_ms_va_list ap) {
  (void)__builtin_va_arg(ap, int);  // no-warning
}

void i3(__builtin_va_list32 ap) {
  (void)__builtin_va_arg(ap, int);  // no-warning
}

struct foo {
  __builtin_ms_va_list list;
};

void i4(struct foo *f) {
  (void)__builtin_va_arg(f->list, int);  // no-warning
}

struct bar {
  __builtin_va_list32 list;
};

void i5(struct bar *b) {
  (void)__builtin_va_arg(b->list, int);  // no-warning
}
