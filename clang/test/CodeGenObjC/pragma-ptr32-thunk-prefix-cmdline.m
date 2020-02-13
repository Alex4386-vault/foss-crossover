// RUN: %clang_cc1 -triple x86_64-apple-macosx10.13.0-wine32 -emit-llvm -fblocks -minterop64-32-thunk-prefix=__wine32 -minterop64-32-cs32-name=__wine32_cs32 -minterop64-32-cs64-name=__wine32_cs64 -o - %s | FileCheck %s

#define nil ((id)0)

@interface Foo
+ (instancetype)new;
- bar: (id (^)())block;
@end

@implementation Foo
+ (instancetype)new {
  // CHECK: define internal i8* @"\01+[Foo new]"({{.*}}) #[[ATTR:[0-9]+]]
  return nil;
}

- bar: (id (^)())block {
  // CHECK: define internal i8* @"\01-[Foo bar:]"({{.*}}) #[[ATTR]]
  return block();
}
@end

id baz() {
  // CHECK: define i8* @baz({{.*}}) #[[ATTR]]
  // CHECK: define internal i8* @__baz_block_invoke({{.*}}) #[[ATTR]]
  return [[Foo new] bar: ^{ return nil; }];
}

// CHECK: attributes #[[ATTR]] = { {{.*}} "thunk-cs32-name"="__wine32_cs32" "thunk-cs64-name"="__wine32_cs64" "thunk-prefix"="__wine32" {{.*}} }
