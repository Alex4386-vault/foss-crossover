; RUN: llc -mtriple=x86_64-apple-macosx10.13.0-wine32 < %s | FileCheck %s
; RUN: llc -mtriple=x86_64-apple-macosx10.13.0-wine32sp64 < %s | FileCheck %s

define void @foo(i8 addrspace(32)* %a, i8* %b, i64 %c, i64 %d) {
  %1 = getelementptr i8, i8 addrspace(32)* %a, i64 %c
  call void @llvm.memset.p32i8.i64(i8 addrspace(32)* align 1 %1, i8 0, i64 %d, i1 false)
  call void @llvm.memcpy.p32i8.p0i8.i64(i8 addrspace(32)* align 1 %a, i8* align 1 %b, i64 %c, i1 false)
  ret void
}

; CHECK-LABEL: _foo:
; CHECK:      pushq	%r15
; CHECK:      pushq	%r14
; CHECK:      pushq	%rbx
; CHECK:      movq	%rdx, %r15
; CHECK-NEXT: movq	%rsi, %r14
; CHECK-NEXT: movl	%edi, %ebx
; CHECK-NEXT: leal	(%rbx,%rdx), %edi
; CHECK-NEXT: movq	%rcx, %rsi
; CHECK-NEXT: callq	___bzero
; CHECK-NEXT: movq	%rbx, %rdi
; CHECK-NEXT: movq	%r14, %rsi
; CHECK-NEXT: movq	%r15, %rdx
; CHECK-NEXT: callq	_memcpy
; CHECK-NEXT: popq	%rbx
; CHECK-NEXT: popq	%r14
; CHECK-NEXT: popq	%r15
; CHECK-NEXT: retq

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p32i8.i64(i8 addrspace(32)* nocapture writeonly, i8, i64, i1) #3

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p32i8.p0i8.i64(i8 addrspace(32)* nocapture writeonly, i8* nocapture readonly, i64, i1) #3

attributes #3 = { argmemonly nounwind }
