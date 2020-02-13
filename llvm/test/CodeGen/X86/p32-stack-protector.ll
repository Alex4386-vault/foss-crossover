; RUN: llc < %s | FileCheck %s
; RUN: llc -fast-isel < %s | FileCheck %s

target datalayout = "e-m:e-p32:32:32-A32-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-wine32"

define void @foo() ssp {
  %1 = alloca [1024 x i8], align 4, addrspace(32)
  ret void
; CHECK-LABEL: foo:
; CHECK:      subl	$1032, %esp
; CHECK:      leal	1024(%rsp), %eax
; CHECK-NEXT: movq	%fs:40, %rcx
; CHECK-NEXT: movq	%rcx, 1024(%esp)
; CHECK-NEXT: movq	%fs:40, %rcx
; CHECK:      cmpq	{{.*}}, %rcx
; CHECK-NEXT: jne	[[CallStackCheckFailBlk:.*]]
; CHECK:      addl	$1032, %esp
; CHECK:      retq
; CHECK: [[CallStackCheckFailBlk]]:
; CHECK:      callq	__stack_chk_fail
}

