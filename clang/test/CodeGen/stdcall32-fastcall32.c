// RUN: %clang_cc1 -triple x86_64-unknown-unknown-wine32 -emit-llvm < %s | FileCheck -check-prefixes=CHECK,CHECK32 %s
// RUN: %clang_cc1 -triple x86_64-unknown-unknown-wine32sp64 -emit-llvm < %s | FileCheck -check-prefixes=CHECK,CHECK64 %s

void __attribute__((fastcall32)) f1(void);
void __attribute__((stdcall32)) f2(void);
void __attribute__((thiscall32)) f3(void);
void __attribute__((cdecl32)) f4(void);
void __attribute__((fastcall32)) f5(void) {
// CHECK-LABEL: define x86_fastcallcc void @f5({ [6 x i64] } addrspace(32)* noalias thunkdata %thunk.data)
// CHECK: %thunk.storage = alloca { [6 x i64] }, align 8
// CHECK64: %[[CAST:.*]] = addrspacecast { [6 x i64] }* %thunk.storage to { [6 x i64] } addrspace(32)*
  f1();
// CHECK32: call x86_fastcallcc void @f1({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage)
// CHECK64: call x86_fastcallcc void @f1({ [6 x i64] } addrspace(32)* thunkdata %[[CAST]])
}
void __attribute__((stdcall32)) f6(void) {
// CHECK-LABEL: define x86_stdcallcc void @f6({ [6 x i64] } addrspace(32)* noalias thunkdata %thunk.data)
// CHECK: %thunk.storage = alloca { [6 x i64] }, align 8
// CHECK64: %[[CAST:.*]] = addrspacecast { [6 x i64] }* %thunk.storage to { [6 x i64] } addrspace(32)*
  f2();
// CHECK32: call x86_stdcallcc void @f2({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage)
// CHECK64: call x86_stdcallcc void @f2({ [6 x i64] } addrspace(32)* thunkdata %[[CAST]])
}
void __attribute__((thiscall32)) f7(void) {
// CHECK-LABEL: define x86_thiscallcc void @f7({ [6 x i64] } addrspace(32)* noalias thunkdata %thunk.data)
// CHECK: %thunk.storage = alloca { [6 x i64] }, align 8
// CHECK64: %[[CAST:.*]] = addrspacecast { [6 x i64] }* %thunk.storage to { [6 x i64] } addrspace(32)*
  f3();
// CHECK32: call x86_thiscallcc void @f3({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage)
// CHECK64: call x86_thiscallcc void @f3({ [6 x i64] } addrspace(32)* thunkdata %[[CAST]])
}
void __attribute__((cdecl32)) f8(void) {
// CHECK-LABEL: define x86_64_c32cc void @f8({ [6 x i64] } addrspace(32)* noalias thunkdata %thunk.data)
// CHECK: %thunk.storage = alloca { [6 x i64] }, align 8
// CHECK64: %[[CAST:.*]] = addrspacecast { [6 x i64] }* %thunk.storage to { [6 x i64] } addrspace(32)*
  f4();
// CHECK32: call x86_64_c32cc void @f4({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage)
// CHECK64: call x86_64_c32cc void @f4({ [6 x i64] } addrspace(32)* thunkdata %[[CAST]])
}

// PR5280
void (__attribute__((fastcall32)) *pf1)(void) = f1;
void (__attribute__((stdcall32)) *pf2)(void) = f2;
void (__attribute__((thiscall32)) *pf3)(void) = f3;
void (__attribute__((cdecl32)) *pf4)(void) = f4;
void (__attribute__((fastcall32)) *pf5)(void) = f5;
void (__attribute__((stdcall32)) *pf6)(void) = f6;
void (__attribute__((thiscall32)) *pf7)(void) = f7;
void (__attribute__((cdecl32)) *pf8)(void) = f8;

int main(void) {
    // CHECK-LABEL: define i32 @main
    // CHECK: %thunk.storage = alloca { [6 x i64] }, align 8
    // CHECK-NOT: %thunk.storage = alloca { [6 x i64] }, align 8
    // CHECK64: %[[CAST:.*]] = addrspacecast { [6 x i64] }* %thunk.storage to { [6 x i64] } addrspace(32)*
    f5(); f6(); f7(); f8();
    // CHECK32: call x86_fastcallcc void @f5({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage)
    // CHECK32: call x86_stdcallcc void @f6({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage)
    // CHECK32: call x86_thiscallcc void @f7({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage)
    // CHECK32: call x86_64_c32cc void @f8({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage)
    // CHECK64: call x86_fastcallcc void @f5({ [6 x i64] } addrspace(32)* thunkdata %[[CAST]])
    // CHECK64: call x86_stdcallcc void @f6({ [6 x i64] } addrspace(32)* thunkdata %[[CAST]])
    // CHECK64: call x86_thiscallcc void @f7({ [6 x i64] } addrspace(32)* thunkdata %[[CAST]])
    // CHECK64: call x86_64_c32cc void @f8({ [6 x i64] } addrspace(32)* thunkdata %[[CAST]])
    pf1(); pf2(); pf3(); pf4(); pf5(); pf6(); pf7(); pf8();
    // CHECK32: call x86_fastcallcc void %{{.*}}({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage)
    // CHECK32: call x86_stdcallcc void %{{.*}}({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage)
    // CHECK32: call x86_thiscallcc void %{{.*}}({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage)
    // CHECK32: call x86_64_c32cc void %{{.*}}({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage)
    // CHECK32: call x86_fastcallcc void %{{.*}}({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage)
    // CHECK32: call x86_stdcallcc void %{{.*}}({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage)
    // CHECK32: call x86_thiscallcc void %{{.*}}({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage)
    // CHECK32: call x86_64_c32cc void %{{.*}}({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage)
    // CHECK64: call x86_fastcallcc void %{{.*}}({ [6 x i64] } addrspace(32)* thunkdata %[[CAST]])
    // CHECK64: call x86_stdcallcc void %{{.*}}({ [6 x i64] } addrspace(32)* thunkdata %[[CAST]])
    // CHECK64: call x86_thiscallcc void %{{.*}}({ [6 x i64] } addrspace(32)* thunkdata %[[CAST]])
    // CHECK64: call x86_64_c32cc void %{{.*}}({ [6 x i64] } addrspace(32)* thunkdata %[[CAST]])
    // CHECK64: call x86_fastcallcc void %{{.*}}({ [6 x i64] } addrspace(32)* thunkdata %[[CAST]])
    // CHECK64: call x86_stdcallcc void %{{.*}}({ [6 x i64] } addrspace(32)* thunkdata %[[CAST]])
    // CHECK64: call x86_thiscallcc void %{{.*}}({ [6 x i64] } addrspace(32)* thunkdata %[[CAST]])
    // CHECK64: call x86_64_c32cc void %{{.*}}({ [6 x i64] } addrspace(32)* thunkdata %[[CAST]])
    return 0;
}

// PR7117
void __attribute((stdcall32)) f9(foo) int foo; {}
void f10(void) {
  // CHECK-LABEL: define void @f10
  f9(0);
  // CHECK32: call x86_stdcallcc void @f9({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage, i32 0)
  // CHECK64: call x86_stdcallcc void @f9({ [6 x i64] } addrspace(32)* thunkdata %{{.*}}, i32 0)
}

void __attribute__((fastcall32)) foo1(int y);
void bar1(int y) {
  // CHECK-LABEL: define void @bar1
  // CHECK32: call x86_fastcallcc void @foo1({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage, i32 inreg %
  // CHECK64: call x86_fastcallcc void @foo1({ [6 x i64] } addrspace(32)* thunkdata %{{.*}}, i32 inreg %
  foo1(y);
}

struct S1 {
  int x;
};
void __attribute__((fastcall32)) foo2(struct S1 y);
void bar2(struct S1 y) {
  // CHECK-LABEL: define void @bar2
  // CHECK32: call x86_fastcallcc void @foo2({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage, i32 inreg undef, i32 %
  // CHECK64: call x86_fastcallcc void @foo2({ [6 x i64] } addrspace(32)* thunkdata %{{.*}}, i32 inreg undef, i32 %
  foo2(y);
}

void __attribute__((fastcall32)) foo3(int * __ptr32 y);
void bar3(int * __ptr32 y) {
  // CHECK-LABEL: define void @bar3
  // CHECK32: call x86_fastcallcc void @foo3({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage, i32 addrspace(32)* inreg %
  // CHECK64: call x86_fastcallcc void @foo3({ [6 x i64] } addrspace(32)* thunkdata %{{.*}}, i32 addrspace(32)* inreg %
  foo3(y);
}

enum Enum {Eval};
void __attribute__((fastcall32)) foo4(enum Enum y);
void bar4(enum Enum y) {
  // CHECK-LABEL: define void @bar4
  // CHECK32: call x86_fastcallcc void @foo4({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage, i32 inreg %
  // CHECK64: call x86_fastcallcc void @foo4({ [6 x i64] } addrspace(32)* thunkdata %{{.*}}, i32 inreg %
  foo4(y);
}

struct S2 {
  int x1;
  double x2;
  double x3;
};
void __attribute__((fastcall32)) foo5(struct S2 y);
void bar5(struct S2 y) {
  // CHECK-LABEL: define void @bar5
  // CHECK32: call x86_fastcallcc void @foo5({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage, %struct.S2 addrspace(32)* byval align 4 %
  // CHECK64: call x86_fastcallcc void @foo5({ [6 x i64] } addrspace(32)* thunkdata %{{.*}}, %struct.S2* byval align 4 %
  foo5(y);
}

void __attribute__((fastcall32)) foo6(long long y);
void bar6(long long y) {
  // CHECK-LABEL: define void @bar6
  // CHECK32: call x86_fastcallcc void @foo6({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage, i64 %
  // CHECK64: call x86_fastcallcc void @foo6({ [6 x i64] } addrspace(32)* thunkdata %{{.*}}, i64 %
  foo6(y);
}

void __attribute__((fastcall32)) foo7(int a, struct S1 b, int c);
void bar7(int a, struct S1 b, int c) {
  // CHECK-LABEL: define void @bar7
  // CHECK32: call x86_fastcallcc void @foo7({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage, i32 inreg %{{.*}}, i32 %{{.*}}, i32 %{{.*}}
  // CHECK64: call x86_fastcallcc void @foo7({ [6 x i64] } addrspace(32)* thunkdata %{{.*}}, i32 inreg %{{.*}}, i32 %{{.*}}, i32 %{{.*}}
  foo7(a, b, c);
}

void __attribute__((fastcall32)) foo8(struct S1 a, int b);
void bar8(struct S1 a, int b) {
  // CHECK-LABEL: define void @bar8
  // CHECK32: call x86_fastcallcc void @foo8({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage, i32 inreg undef, i32 %{{.*}}, i32 inreg %
  // CHECK64: call x86_fastcallcc void @foo8({ [6 x i64] } addrspace(32)* thunkdata %{{.*}}, i32 inreg undef, i32 %{{.*}}, i32 inreg %
  foo8(a, b);
}

void __attribute__((fastcall32)) foo9(struct S2 a, int b);
void bar9(struct S2 a, int b) {
  // CHECK-LABEL: define void @bar9
  // CHECK32: call x86_fastcallcc void @foo9({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage, %struct.S2 addrspace(32)* byval align 4 %{{.*}}, i32 %
  // CHECK64: call x86_fastcallcc void @foo9({ [6 x i64] } addrspace(32)* thunkdata %{{.*}}, %struct.S2* byval align 4 %{{.*}}, i32 %
  foo9(a, b);
}

void __attribute__((fastcall32)) foo10(float y, int x);
void bar10(float y, int x) {
  // CHECK-LABEL: define void @bar10
  // CHECK32: call x86_fastcallcc void @foo10({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage, float %{{.*}}, i32 inreg %
  // CHECK64: call x86_fastcallcc void @foo10({ [6 x i64] } addrspace(32)* thunkdata %{{.*}}, float %{{.*}}, i32 inreg %
  foo10(y, x);
}

void __attribute__((fastcall32)) foo11(double y, int x);
void bar11(double y, int x) {
  // CHECK-LABEL: define void @bar11
  // CHECK32: call x86_fastcallcc void @foo11({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage, double %{{.*}}, i32 inreg %
  // CHECK64: call x86_fastcallcc void @foo11({ [6 x i64] } addrspace(32)* thunkdata %{{.*}}, double %{{.*}}, i32 inreg %
  foo11(y, x);
}

struct S3 {
  float x;
};
void __attribute__((fastcall32)) foo12(struct S3 y, int x);
void bar12(struct S3 y, int x) {
  // CHECK-LABEL: define void @bar12
  // CHECK32: call x86_fastcallcc void @foo12({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage, float %{{.*}}, i32 inreg %
  // CHECK64: call x86_fastcallcc void @foo12({ [6 x i64] } addrspace(32)* thunkdata %{{.*}}, float %{{.*}}, i32 inreg %
  foo12(y, x);
}
