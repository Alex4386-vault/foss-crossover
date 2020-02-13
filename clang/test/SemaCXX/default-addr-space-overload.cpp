// RUN: %clang_cc1 -fsyntax-only -verify %s
// expected-no-diagnostics

typedef __UINT8_TYPE__ uint8_t;
typedef __UINT16_TYPE__ uint16_t;
typedef __UINT32_TYPE__ uint32_t;

#pragma clang default_addr_space(1)
uint8_t foo(void *p);

#pragma clang default_addr_space(2)
uint16_t foo(void *p);

#pragma clang default_addr_space(4)
uint32_t foo(void *p);

#pragma clang default_addr_space(default)
void __attribute__((address_space(1))) *a;
void __attribute__((address_space(2))) *b;
void __attribute__((address_space(4))) *c;

void bar() {
  static_assert(sizeof(foo(a)) == 1, "Should've picked the first overload!");
  static_assert(sizeof(foo(b)) == 2, "Should've picked the second overload!");
  static_assert(sizeof(foo(c)) == 4, "Should've picked the third overload!");
}
