// RUN: %clang_cc1 -triple x86_64-apple-macosx10.13.0-wine32 -emit-llvm -o - %s | FileCheck %s

@class NSArray;

void foo(NSArray* a) {
  for (id obj in a) {
    [obj release];
  }
  // CHECK: %[[STATE_PTR:.*]] = addrspacecast %struct.__objcFastEnumerationState addrspace(32)* %{{.*}} to %struct.__objcFastEnumerationState*
  // CHECK: %[[ITEMS_PTR:.*]] = addrspacecast [16 x i8*] addrspace(32)* %{{.*}} to [16 x i8*]*
  // CHECK: %call = call i64 bitcast (i8* (i8*, i8*, ...)* @objc_msgSend to i64 (i8*, i8*, %struct.__objcFastEnumerationState*, [16 x i8*]*, i64)*)(i8* %{{.*}}, i8* %{{.*}}, %struct.__objcFastEnumerationState* %[[STATE_PTR]], [16 x i8*]* %[[ITEMS_PTR]], i64 16)
}
