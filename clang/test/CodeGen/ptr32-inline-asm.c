// RUN: %clang_cc1 -triple x86_64-unknown-linux-wine32 -emit-llvm -o - %s | FileCheck %s

void foo(void) {
  unsigned short cw;
  asm volatile("fnstcw %0" : "=m" (cw));
  cw = (cw & ~0xf3f) | 0x3f;
  asm volatile("fldcw %0" : : "m" (cw));
}

// CHECK-LABEL: define void @foo(
// CHECK: %[[CAST0:.*]] = addrspacecast i16 addrspace(32)* %[[CW:.*]] to i16*
// CHECK: call void asm sideeffect "fnstcw $0", "=*m{{.*}}"(i16* %[[CAST0]])
// CHECK: %[[CAST1:.*]] = addrspacecast i16 addrspace(32)* %[[CW]] to i16*
// CHECK: call void asm sideeffect "fldcw $0", "*m{{.*}}"(i16* %[[CAST1]])
