// RUN: %clang_cc1 -triple x86_64-apple-macosx10.13.0-wine32 -fblocks -emit-llvm -o - %s | FileCheck %s

int foo() {
  __block int bar;
  return ^{
    return bar;
  }();

  // CHECK: %[[BAR:.*]] = addrspacecast %struct.__block_byref_bar addrspace(32)* %{{.*}} to %struct.__block_byref_bar*
  // CHECK: store %struct.__block_byref_bar* %[[BAR]], %struct.__block_byref_bar* addrspace(32)* %{{.*}}, align 8

  // CHECK: %[[BAR:.*]] = addrspacecast %struct.__block_byref_bar addrspace(32)* %{{.*}} to %struct.__block_byref_bar*
  // CHECK: %[[CAPTURED:.*]] = bitcast %struct.__block_byref_bar* %[[BAR]] to i8*
  // CHECK: store i8* %[[CAPTURED]], i8* addrspace(32)* %{{.*}}, align 8

  // CHECK: %[[BAR:.*]] = addrspacecast %struct.__block_byref_bar addrspace(32)* %{{.*}} to %struct.__block_byref_bar*
  // CHECK: %[[DISPOSED:.*]] = bitcast %struct.__block_byref_bar* %[[BAR]] to i8*
  // CHECK: call void @_Block_object_dispose(i8* %[[DISPOSED]], i32 8)
}
