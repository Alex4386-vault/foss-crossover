; RUN: llc < %s | FileCheck %s
target datalayout = "e-m:o-p32:32:32-A32-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.13.0-wine32"

%struct.__va_list_tag = type { i32, i32, i8*, i8* }

; Function Attrs: nounwind ssp uwtable
define void @ppy_error(i8* %s, ...) local_unnamed_addr #0 {
entry:
  %ap = alloca [1 x %struct.__va_list_tag], align 16, addrspace(32)
  ret void
}

; CHECK: movq	___stack_chk_guard@GOTPCREL(%rip), %[[PTR:.*]]
; CHECK: movq	(%[[PTR]]), %[[VAL:.*]]
; CHECK: movq	%[[VAL]], -8(%ebp)
; CHECK: movq	___stack_chk_guard@GOTPCREL(%rip), %[[PTR:.*]]
; CHECK: movq	(%[[PTR]]), %[[VAL:.*]]
; CHECK: cmpq	-8(%ebp), %[[VAL]]
; CHECK: jne

attributes #0 = { nounwind ssp "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "stack-protector-buffer-size"="8" }

