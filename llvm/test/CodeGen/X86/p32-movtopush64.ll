; RUN: llc < %s -mtriple=x86_64-linux-wine32 | FileCheck %s

declare void @bar(i32 addrspace(32)*, i32 addrspace(32)*, i32 addrspace(32)*, i32 addrspace(32)*, i32 addrspace(32)*, i64 addrspace(32)*, i64, i64, i64)

; Function Attrs: nounwind uwtable
define void @foo() {
entry:
  %i1 = alloca i32, align 4, addrspace(32)
  %i2 = alloca i32, align 4, addrspace(32)
  %i3 = alloca i32, align 4, addrspace(32)
  %i4 = alloca i32, align 4, addrspace(32)
  %i5 = alloca i32, align 4, addrspace(32)
  %i6 = alloca i64, align 8, addrspace(32)
  store i32 1, i32 addrspace(32)* %i1, align 4
; CHECK: movl $1, 28(%esp)
  store i32 2, i32 addrspace(32)* %i2, align 4
; CHECK-NEXT: movl $2, 24(%esp)
  store i32 3, i32 addrspace(32)* %i3, align 4
; CHECK-NEXT: movl $3, 20(%esp)
  store i32 4, i32 addrspace(32)* %i4, align 4
; CHECK-NEXT: movl $4, 16(%esp)
  store i32 5, i32 addrspace(32)* %i5, align 4
; CHECK-NEXT: movl $5, 12(%esp)
  store i64 6, i64 addrspace(32)* %i6, align 8
; CHECK-NEXT: movq $6, 32(%esp)
; CHECK-NEXT: subl $8, %esp
; CHECK: leal 36(%rsp), %edi
; CHECK-NEXT: leal 32(%rsp), %esi
; CHECK-NEXT: leal 28(%rsp), %edx
; CHECK-NEXT: leal 24(%rsp), %ecx
; CHECK-NEXT: leal 20(%rsp), %r8d
; CHECK-NEXT: leal 40(%rsp), %r9d
; CHECK: pushq $0
; CHECK: pushq $0
; CHECK: pushq $0
  call void @bar(i32 addrspace(32)* nonnull %i1, i32 addrspace(32)* nonnull %i2, i32 addrspace(32)* nonnull %i3, i32 addrspace(32)* nonnull %i4, i32 addrspace(32)* nonnull %i5, i64 addrspace(32)* nonnull %i6, i64 0, i64 0, i64 0)
  ret void
}
