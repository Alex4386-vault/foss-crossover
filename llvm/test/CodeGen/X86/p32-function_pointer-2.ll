; RUN: llc < %s -mtriple=x86_64-apple-darwin17-wine32 | FileCheck %s
; RUN: llc < %s -mtriple=x86_64-apple-darwin17-wine32 -fast-isel | FileCheck %s

; Test call function pointer with function argument
;
; void bar (void * h, void (*foo) (void *))
;    {
;      foo (h);
;      foo (h);
;    }

%baz = type { [6 x i64] }

define void @bar(i8 addrspace(32)* %h, void (%baz addrspace(32)*, i8 addrspace(32)*) addrspace(32)* nocapture %foo) nounwind {
entry:
  %td = alloca %baz, align 8, addrspace(32)
  tail call x86_64_c32cc addrspace(32) void %foo(%baz addrspace(32)* thunkdata %td, i8 addrspace(32)* %h) nounwind
; CHECK-LABEL: _bar:
; CHECK: movq	%rsi, 8(%eax)
; CHECK: callq	___i386_on_x86_64_invoke32_0
  tail call addrspace(32) void %foo(%baz addrspace(32)* thunkdata %td, i8 addrspace(32)* %h) nounwind
; CHECK: movl	%esi, %eax
; CHECK: jmpq	*%rax
  ret void
}

; CHECK-LABEL: ___i386_on_x86_64_invoke32_0:
; CHECK: movq ___i386_on_x86_64_cs64@GOTPCREL(%rip), %r9
; CHECK-NEXT: cmpw (%r9), %r8w
; CHECK: movq ___i386_on_x86_64_cs32@GOTPCREL(%rip), %r9
; CHECK-NEXT: movw (%r9), %r9w
