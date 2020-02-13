// RUN: %clang_cc1 -triple x86_64-apple-macosx10.13.0-wine32 -O2 -emit-llvm -o - %s | FileCheck %s

void foo(int * __ptr32 a, void (* __ptr32 b)(int, int * __ptr32, int *)) {
  int c;
  b(*a, &c, &c);
  // CHECK-LABEL: @foo(i32 addrspace(32)*{{.*}} %a, void (i32, i32 addrspace(32)*, i32*) addrspace(32)*{{.*}} %b)
  // CHECK: %[[PF:[0-9a-zA-Z_]*]] = addrspacecast void (i32, i32 addrspace(32)*, i32*) addrspace(32)* %b to void (i32, i32 addrspace(32)*, i32*)*
  // CHECK: %[[VAL:[0-9a-zA-Z_]*]] = load i32, i32 addrspace(32)* %a
  // CHECK: call void %[[PF]](i32 %[[VAL]], i32 addrspace(32)* {{.*}}, i32* {{.*}}){{.*}}
}
