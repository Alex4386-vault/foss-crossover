// RUN: %clang_cc1 -triple x86_64-apple-macosx10.13.0-wine32 -emit-llvm -o - %s | FileCheck %s

struct Point {
  double x;
  double y;
};

struct Size {
  double width;
  double height;
};

struct Rect {
  struct Point origin;
  struct Size size;
};

@interface Foo {
  signed char _bar;
  struct Rect _baz;
}

@property(readonly) signed char bar;
@property(readonly) struct Rect baz;

@end

@implementation Foo

@synthesize bar = _bar;
// CHECK: %[[IVAR:.*]] = load i64, i64* @"OBJC_IVAR_$_Foo._bar", align 8
// CHECK: %[[IVAR_PTR:.*]] = getelementptr inbounds i8, i8* %{{.*}}, i64 %[[IVAR]]
// CHECK: %[[VAL:.*]] = load atomic i8, i8* %[[IVAR_PTR]] unordered, align 1
// CHECK: ret i8 %[[VAL]]

@synthesize baz = _baz;

@end

double quux(Foo *f) {
  struct Rect baz = [f baz];
  return baz.size.height;
  // CHECK: msgSend.call:
  // CHECK:   %[[SRET:.*]] = addrspacecast %struct.Rect addrspace(32)* %{{.*}} to %struct.Rect*
  // CHECK:   call void bitcast (void (i8*, i8*, ...)* @objc_msgSend_stret to void (%struct.Rect*, i8*, i8*)*)(%struct.Rect* sret %[[SRET]]
  // CHECK: msgSend.null-receiver:
  // CHECK:   %[[DEST:.*]] = bitcast %struct.Rect addrspace(32)* %{{.*}} to i8 addrspace(32)*
  // CHECK:   call void @llvm.memset.p32i8.i64(i8 addrspace(32)* align 8 %[[DEST]], i8 0, i64 32, i1 false)
}
