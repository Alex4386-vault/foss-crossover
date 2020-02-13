; RUN: llc < %s -mtriple=x86_64-linux-wine32sp64 | FileCheck -check-prefix=CHECK %s

declare void @bar(i32 addrspace(32)*, i32 addrspace(32)*, i32 addrspace(32)*, i32 addrspace(32)*, i32 addrspace(32)*, i64 addrspace(32)*, i64, i64, i64)

; Function Attrs: nounwind uwtable
define void @foo() {
entry:
  %i1 = alloca i32, align 4
  %i2 = alloca i32, align 4
  %i3 = alloca i32, align 4
  %i4 = alloca i32, align 4
  %i5 = alloca i32, align 4
  %i6 = alloca i64, align 8
  store i32 1, i32* %i1, align 4
; CHECK: movl $1, 28(%rsp)
  store i32 2, i32* %i2, align 4
; CHECK-NEXT: movl $2, 24(%rsp)
  store i32 3, i32* %i3, align 4
; CHECK-NEXT: movl $3, 20(%rsp)
  store i32 4, i32* %i4, align 4
; CHECK-NEXT: movl $4, 16(%rsp)
  store i32 5, i32* %i5, align 4
; CHECK-NEXT: movl $5, 12(%rsp)
  store i64 6, i64* %i6, align 8
; CHECK-NEXT: movq $6, 32(%rsp)
; CHECK: leaq 28(%rsp), %rdi
; CHECK-NEXT: leaq 24(%rsp), %rsi
; CHECK-NEXT: leaq 20(%rsp), %rdx
; CHECK-NEXT: leaq 16(%rsp), %rcx
; CHECK-NEXT: leaq 12(%rsp), %r8
; CHECK-NEXT: leaq 32(%rsp), %r9
; CHECK-NEXT: subq $8, %rsp
; CHECK: pushq $0
; CHECK: pushq $0
; CHECK: pushq $0
  %i1.0 = addrspacecast i32* %i1 to i32 addrspace(32)*
  %i2.0 = addrspacecast i32* %i2 to i32 addrspace(32)*
  %i3.0 = addrspacecast i32* %i3 to i32 addrspace(32)*
  %i4.0 = addrspacecast i32* %i4 to i32 addrspace(32)*
  %i5.0 = addrspacecast i32* %i5 to i32 addrspace(32)*
  %i6.0 = addrspacecast i64* %i6 to i64 addrspace(32)*
  call void @bar(i32 addrspace(32)* nonnull %i1.0, i32 addrspace(32)* nonnull %i2.0, i32 addrspace(32)* nonnull %i3.0, i32 addrspace(32)* nonnull %i4.0, i32 addrspace(32)* nonnull %i5.0, i64 addrspace(32)* nonnull %i6.0, i64 0, i64 0, i64 0)
  ret void
}
