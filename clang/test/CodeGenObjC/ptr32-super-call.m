// RUN: %clang_cc1 -triple x86_64-apple-macosx10.13.0-wine32 -emit-llvm -o - %s | FileCheck %s

@interface Foo

- bar;

@end

@interface Baz : Foo

- bar;

@end

@implementation Baz

- bar {
  return [super bar];
  // CHECK: %[[SUPER:.*]] = addrspacecast %struct._objc_super addrspace(32)* %{{.*}} to %struct._objc_super
  // CHECK: %{{.*}} = call i8* bitcast (i8* (%struct._objc_super*, i8*, ...)* @objc_msgSendSuper2 to i8* (%struct._objc_super*, i8*)*)(%struct._objc_super* %[[SUPER]]
}

@end

