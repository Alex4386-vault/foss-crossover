// RUN: %clang_cc1 -triple x86_64-apple-darwin17-wine32 -emit-llvm < %s | FileCheck %s

struct foo {
  int x;
  float y;
  char z;
};
// CHECK-DAG: %[[STRUCT_FOO:.*]] = type { i32, float, i8 }
// CHECK-DAG: %[[VA_LIST:.*]] = type { i8 }

void __attribute__((cdecl32)) foo(int a, ...) {
  // CHECK-LABEL: define x86_64_c32cc void @foo
  __builtin_va_list32 ap;
  __builtin_va_start32(ap, a);
  // CHECK: %[[AP0:.*]] = alloca %[[VA_LIST]] addrspace(32)*
  // CHECK: %[[AP0_0:.*]] = addrspacecast %[[VA_LIST]] addrspace(32)* addrspace(32)* %[[AP0]]
  // CHECK: call void @llvm.va_start
  int b = __builtin_va_arg(ap, int);
  // CHECK: %[[AP:.*]] = bitcast %[[VA_LIST]] addrspace(32)* addrspace(32)* %[[AP0]] to i8 addrspace(32)* addrspace(32)*
  // CHECK-NEXT: %[[AP_CUR:.*]] = load i8 addrspace(32)*, i8 addrspace(32)* addrspace(32)* %[[AP]]
  // CHECK-NEXT: %[[AP_NEXT:.*]] = getelementptr inbounds i8, i8 addrspace(32)* %[[AP_CUR]], i64 4
  // CHECK-NEXT: store i8 addrspace(32)* %[[AP_NEXT]], i8 addrspace(32)* addrspace(32)* %[[AP]]
  // CHECK-NEXT: bitcast i8 addrspace(32)* %[[AP_CUR]] to i32 addrspace(32)*
  double _Complex c = __builtin_va_arg(ap, double _Complex);
  // CHECK: %[[AP:.*]] = bitcast %[[VA_LIST]] addrspace(32)* addrspace(32)* %[[AP0]] to i8 addrspace(32)* addrspace(32)*
  // CHECK-NEXT: %[[AP_CUR:.*]] = load i8 addrspace(32)*, i8 addrspace(32)* addrspace(32)* %[[AP]]
  // CHECK-NEXT: %[[AP_NEXT:.*]] = getelementptr inbounds i8, i8 addrspace(32)* %[[AP_CUR]], i64 16
  // CHECK-NEXT: store i8 addrspace(32)* %[[AP_NEXT]], i8 addrspace(32)* addrspace(32)* %[[AP]]
  // CHECK-NEXT: bitcast i8 addrspace(32)* %[[AP_CUR]] to { double, double } addrspace(32)*
  struct foo d = __builtin_va_arg(ap, struct foo);
  // CHECK: %[[AP:.*]] = bitcast %[[VA_LIST]] addrspace(32)* addrspace(32)* %[[AP0]] to i8 addrspace(32)* addrspace(32)*
  // CHECK-NEXT: %[[AP_CUR:.*]] = load i8 addrspace(32)*, i8 addrspace(32)* addrspace(32)* %[[AP]]
  // CHECK-NEXT: %[[AP_NEXT:.*]] = getelementptr inbounds i8, i8 addrspace(32)* %[[AP_CUR]], i64 12
  // CHECK-NEXT: store i8 addrspace(32)* %[[AP_NEXT]], i8 addrspace(32)* addrspace(32)* %[[AP]]
  // CHECK-NEXT: bitcast i8 addrspace(32)* %[[AP_CUR]] to %[[STRUCT_FOO]] addrspace(32)*
  __builtin_va_list32 ap2;
  __builtin_va_copy32(ap2, ap);
  // CHECK: %[[AP:.*]] = bitcast %[[VA_LIST]] addrspace(32)* addrspace(32)* %[[AP0]] to i8 addrspace(32)* addrspace(32)*
  // CHECK: %[[AP_VAL:.*]] = load i8 addrspace(32)*, i8 addrspace(32)* addrspace(32)* %[[AP]]
  // CHECK-NEXT: store i8 addrspace(32)* %[[AP_VAL]], i8 addrspace(32)* addrspace(32)* %[[AP2:.*]]
  __builtin_va_end32(ap);
  // CHECK: call void @llvm.va_end
}
