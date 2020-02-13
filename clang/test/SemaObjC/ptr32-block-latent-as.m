// RUN: %clang_cc1 -triple x86_64-apple-macosx10.13.0-wine32 -mdefault-address-space=ptr32 -mstorage-address-space=ptr32 -fblocks -fsyntax-only -verify %s
// expected-no-diagnostics

#pragma clang default_addr_space(push, default)
#pragma clang storage_addr_space(push, default)

@interface Foo

- (void)bar:(_Bool (^)(int))block;

@end

void baz(Foo* foo) {
  [foo bar:^_Bool (int a) {
    return a > 0;
  }];
}

#pragma clang storage_addr_space(pop)
#pragma clang default_addr_space(pop)
