// RUN: %clang_cc1 -triple x86_64-apple-macosx10.13.0-wine32 -emit-llvm -o - %s | FileCheck %s

struct rect {
  int left, top, right, bottom;
};

struct rect __attribute__((ms_abi)) foo(void) {
  static struct rect rc = { 0, 0, 800, 600 };
  return rc;
}

struct rect bar(void) {
  return foo();
}

// CHECK-LABEL: define { i64, i64 } @bar()
// CHECK: %[[RETVAL:.*]] = alloca %struct.rect, align 4, addrspace(32)
// CHECK: %[[CAST:.*]] = addrspacecast %struct.rect addrspace(32)* %[[RETVAL]] to %struct.rect*
// CHECK: call win64cc void @foo(%struct.rect* sret %[[CAST]])

