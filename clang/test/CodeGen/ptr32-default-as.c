// RUN: %clang_cc1 -triple x86_64-apple-macosx10.13.0-wine32 -O2 -emit-llvm -o - %s | FileCheck %s

#pragma clang default_addr_space(ptr32)
#pragma clang storage_addr_space(ptr32)

int x;

void foo(int *a, void (*b)(int, const char *, int *)) {
  b(*a, "Hello, world!", &x);
  // CHECK-LABEL: @foo(i32 addrspace(32)*{{.*}} %a, void (i32, i8 addrspace(32)*, i32 addrspace(32)*) addrspace(32)*{{.*}} %b)
  // CHECK: %[[PF:[0-9a-zA-Z_]*]] = addrspacecast void (i32, i8 addrspace(32)*, i32 addrspace(32)*) addrspace(32)* %b to void (i32, i8 addrspace(32)*, i32 addrspace(32)*)*
  // CHECK: %[[VAL:[0-9a-zA-Z_]*]] = load i32, i32 addrspace(32)* %a{{.*}}
  // CHECK: tail call void %[[PF]](i32 %[[VAL]], i8 addrspace(32)* {{.*}}, i32 addrspace(32)* @x){{.*}}
}
