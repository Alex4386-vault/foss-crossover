// RUN: %clang_cc1 -triple x86_64-linux-wine32 -emit-llvm -o - %s | FileCheck %s

struct foo {
  int a;
};

struct bar {
  int b;
  int c;
  long d;
  long e;
};

int __attribute__((thiscall32)) baz(struct foo * __ptr32 f, struct bar b) {
  return f->a * b.b + b.c - (int)(b.d / b.e);
  // CHECK-LABEL: define x86_thiscallcc i32 @baz(
  // CHECK-SAME:, %struct.foo addrspace(32)* %[[F:.*]], %struct.bar addrspace(32)* byval align 4)
  // CHECK: %[[COERCE:.*]] = alloca %struct.bar, align 8, addrspace(32)
  // CHECK: %[[DEST:.*]] = bitcast %struct.bar addrspace(32)* %[[COERCE]] to i8 addrspace(32)*
  // CHECK: %[[SRC:.*]] = bitcast %struct.bar addrspace(32)* %0 to i8 addrspace(32)*
  // CHECK: call void @llvm.memcpy.p32i8.p32i8.i64(i8 addrspace(32)* align 8 %[[DEST]], i8 addrspace(32)* align 4 %[[SRC]],
}

