// RUN: %clang_cc1 -triple x86_64-apple-macosx10.13.0-wine32 -emit-llvm -o - %s | FileCheck %s

extern int foo(unsigned short* a);

int bar(void) {
  return foo((unsigned short[]){'f', 'o', 'o', 0});
}

// CHECK-LABEL: define i32 @bar()
// CHECK: %[[LITERAL:.*]] = alloca [4 x i16], align 2, addrspace(32)
// CHECK: %[[DECAY_AS:.*]] = addrspacecast [4 x i16] addrspace(32)* %[[LITERAL]] to [4 x i16]*
// CHECK: %[[DECAY:.*]] = getelementptr inbounds [4 x i16], [4 x i16]* %[[DECAY_AS]], i32 0, i32 0
// CHECK: %[[CALL:.*]] = call i32 @foo(i16* %[[DECAY]])
