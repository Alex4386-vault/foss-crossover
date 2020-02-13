; RUN: llc < %s -mtriple=x86_64-linux-wine32 -relocation-model=pic  | FileCheck %s
; RUN: llc < %s -mtriple=x86_64-linux-wine32 -relocation-model=pic -fast-isel | FileCheck %s

; Test for 32-bit function pointers with 32-bit calling conventions

%struct.__thunk_data = type { i64, i64, i64, i64, i64, i64 }

@foo = external global void (%struct.__thunk_data addrspace(32)*, i8 addrspace(32)*, i64) addrspace(32)*
@bar = external global void (%struct.__thunk_data addrspace(32)*, i8 addrspace(32)*, i64) addrspace(32)*
@baz = external global void (%struct.__thunk_data addrspace(32)*, i8 addrspace(32)*, i32, i64) addrspace(32)*
@quux = external global void (%struct.__thunk_data addrspace(32)*, i8 addrspace(32)*, i64) addrspace(32)*

define void @test(i8 addrspace(32)* %h) nounwind uwtable {
entry:
  %td = alloca %struct.__thunk_data, align 8, addrspace(32)
  %0 = load void (%struct.__thunk_data addrspace(32)*, i8 addrspace(32)*, i64) addrspace(32)*, void (%struct.__thunk_data addrspace(32)*, i8 addrspace(32)*, i64) addrspace(32)** @foo, align 4
; CHECK:      movq	foo@GOTPCREL(%rip), %rax
; CHECK-NEXT: movl	(%rax), %{{[er]}}[[REG:[a-z]*|[0-9]+]]{{d?}}
  tail call x86_64_c32cc addrspace(32) void %0(%struct.__thunk_data addrspace(32)* thunkdata %td, i8 addrspace(32)* %h, i64 0) nounwind
; CHECK: movl	%edi, (%esp)
; CHECK: movq	$0, 4(%esp)
; CHECK: movq	%r[[REG]], 8(%eax)
; CHECK: callq	__i386_on_x86_64_invoke32_0
  %1 = load void (%struct.__thunk_data addrspace(32)*, i8 addrspace(32)*, i64) addrspace(32)*, void (%struct.__thunk_data addrspace(32)*, i8 addrspace(32)*, i64) addrspace(32)** @bar, align 4
; CHECK:      movq	bar@GOTPCREL(%rip), %rax
; CHECK-NEXT: movl	(%rax), %{{[er]}}[[REG2:[a-z]*|[0-9]+]]{{d?}}
  tail call x86_stdcallcc addrspace(32) void %1(%struct.__thunk_data addrspace(32)* thunkdata %td, i8 addrspace(32)* %h, i64 0) nounwind
; The callee will pop only 12 bytes from the stack. Make sure the stack
; gets readjusted after the call.
; CHECK: movl	%edi, (%esp)
; CHECK: movq	$0, 4(%esp)
; CHECK: movq	%r[[REG2]], 8(%eax)
; CHECK: callq	__i386_on_x86_64_invoke32_12
; CHECK: subl	$12, %esp
  %2 = load void (%struct.__thunk_data addrspace(32)*, i8 addrspace(32)*, i32, i64) addrspace(32)*, void (%struct.__thunk_data addrspace(32)*, i8 addrspace(32)*, i32, i64) addrspace(32)** @baz, align 4
; CHECK: movq	baz@GOTPCREL(%rip), %rax
; CHECK: movl	(%rax), %{{[er]}}[[REG3:[a-z]*|[0-9]+]]{{d?}}
  tail call x86_fastcallcc addrspace(32) void %2(%struct.__thunk_data addrspace(32)* thunkdata %td, i8 addrspace(32)* inreg %h, i32 inreg 0, i64 0) nounwind
; CHECK: movq	$0, (%esp)
; CHECK: xorl	%edx, %edx
; CHECK: movl	%edi, %ecx
; CHECK: movq	%r[[REG3]], 8(%eax)
; CHECK: callq  __i386_on_x86_64_invoke32_8
; CHECK: subl	$8, %esp
  %3 = load void (%struct.__thunk_data addrspace(32)*, i8 addrspace(32)*, i64) addrspace(32)*, void (%struct.__thunk_data addrspace(32)*, i8 addrspace(32)*, i64) addrspace(32)** @quux, align 4
; CHECK: movq	quux@GOTPCREL(%rip), %rax
; CHECK: movl	(%rax), %{{[er]}}[[REG4:[a-z]*|[0-9]+]]{{d?}}
  tail call x86_thiscallcc addrspace(32) void %3(%struct.__thunk_data addrspace(32)* thunkdata %td, i8 addrspace(32)* inreg %h, i64 0) nounwind
; CHECK: movq	$0, (%esp)
; CHECK: movl	%edi, %ecx
; CHECK: movq	%r[[REG4]], 8(%eax)
; CHECK: callq  __i386_on_x86_64_invoke32_8
; We should only have to pop 64 bytes, since the callee popped 8 bytes.
; CHECK: addl	$64, %esp
  ret void
}

; CHECK-LABEL: __i386_on_x86_64_invoke32_0:
; CHECK: jmpq *%r8
; CHECK: movq __i386_on_x86_64_cs64@GOTPCREL(%rip), %r9
; CHECK-NEXT: cmpw (%r9), %r8w
; CHECK: movq __i386_on_x86_64_cs32@GOTPCREL(%rip), %r9
; CHECK-NEXT: movw (%r9), %r9w
; Should really be 'popl', since this is 32-bit code, but we can't use that
; in 64-bit mode.
; CHECK: popq (%rbx)
; CHECK: popq 4(%rbx)
; CHECK: callq *8(%rbx)
; CHECK: pushq 4(%rbx)
; CHECK: pushq (%rbx)
; CHECK: lretl
; CHECK-LABEL: __i386_on_x86_64_invoke32_12:
; CHECK: callq *%r8
; CHECK: retq $12
; CHECK-LABEL: __i386_on_x86_64_invoke32_8:
; CHECK: callq *%r8
; CHECK: retq $8
; CHECK-NOT: __i386_on_x86_64_invoke32_8:
