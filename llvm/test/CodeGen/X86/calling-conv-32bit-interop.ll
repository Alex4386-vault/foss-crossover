; RUN: llc < %s -mtriple=x86_64-apple-darwin17-wine32 | FileCheck %s -check-prefixes=CHECK,CHECK-SDAG
; RUN: llc < %s -mtriple=x86_64-apple-darwin17-wine32 -fast-isel | FileCheck %s -check-prefixes=CHECK,CHECK-FAST

%struct.__thunk_data = type { i64, i64, i64 }

define x86_64_c32cc i64 @foo(%struct.__thunk_data addrspace(32)* thunkdata %td, i32 %a, i64 %b, i8 addrspace(32)* %c, ...) {
; CHECK-LABEL: _foo:
  %1 = load i8, i8 addrspace(32)* %c
; CHECK: movl 32(%esp), %eax
  %2 = zext i8 %1 to i32
; CHECK-NEXT: movzbl (%eax), %eax
  %3 = add i32 %2, %a
; CHECK-NEXT: addl 20(%esp), %eax
  %4 = sext i32 %3 to i64
; CHECK-NEXT: cltq
  %5 = sub i64 %4, %b
; CHECK-NEXT: subq 24(%esp), %rax
  ret i64 %5
; CHECK-NEXT: movq %rax, %rdx
; CHECK-NEXT: shrq $32, %rdx
; CHECK: retq{{$}}
}

define i64 @call_foo() {
; CHECK-LABEL: _call_foo:
  %td = alloca %struct.__thunk_data, align 8, addrspace(32)
; CHECK: subl $56, %esp
  %1 = call x86_64_c32cc i64 (%struct.__thunk_data addrspace(32)*, i32, i64, i8 addrspace(32)*, ...) @foo(%struct.__thunk_data addrspace(32)* %td, i32 0, i64 0, i8 addrspace(32)* null)
; CHECK-NOT: movb $0, %al
; CHECK-DAG: movl $0, 12(%esp)
; CHECK-DAG: movq $0, 16(%esp)
; CHECK-DAG: movl $0, 24(%esp)
; CHECK-DAG: leal 32(%rsp), %eax
; CHECK-NOT: movb $0, %al
; CHECK: callq _foo
  %2 = add i64 %1, 10
; CHECK: shlq $32, %rdx
; CHECK-SDAG: leaq 10(%rax,%rdx), %rax
; CHECK-FAST: orq %rdx, %rax
; CHECK-FAST: addq $10, %rax
  ret i64 %2
; CHECK: addl $56, %esp
; CHECK: retq
}

define x86_stdcallcc i64 @bar(%struct.__thunk_data addrspace(32)* thunkdata %td, i32 %a, i64 %b, i8 addrspace(32)* %c) {
; CHECK-LABEL: _bar:
  %1 = load i8, i8 addrspace(32)* %c
; CHECK: movl 32(%esp), %eax
  %2 = zext i8 %1 to i32
; CHECK-NEXT: movzbl (%eax), %eax
  %3 = add i32 %2, %a
; CHECK-NEXT: addl 20(%esp), %eax
  %4 = sext i32 %3 to i64
; CHECK-NEXT: cltq
  %5 = sub i64 %4, %b
; CHECK-NEXT: subq 24(%esp), %rax
  ret i64 %5
; CHECK-NEXT: movq %rax, %rdx
; CHECK-NEXT: shrq $32, %rdx
; CHECK: retq{{$}}
}

define void @call_bar() {
; CHECK-LABEL: _call_bar:
  %td = alloca %struct.__thunk_data, align 8, addrspace(32)
; CHECK: subl $56, %esp
  %1 = call x86_stdcallcc i64 @bar(%struct.__thunk_data addrspace(32)* %td, i32 0, i64 0, i8 addrspace(32)* null)
; CHECK-DAG: movl $0, 12(%esp)
; CHECK-DAG: movq $0, 16(%esp)
; CHECK-DAG: movl $0, 24(%esp)
; CHECK-DAG: leal 32(%rsp), %eax
; CHECK: callq _bar
; CHECK: addl $56, %esp
; CHECK: retq
  ret void
}

define x86_fastcallcc i64 @baz(%struct.__thunk_data addrspace(32)* thunkdata %td, i32 inreg %a, i64 inreg %b, i8 addrspace(32)* %c) {
; CHECK-LABEL: _baz:
  %1 = load i8, i8 addrspace(32)* %c
; CHECK: movl 28(%esp), %eax
  %2 = zext i8 %1 to i32
; CHECK-NEXT: movzbl (%eax), %eax
  %3 = add i32 %2, %a
; CHECK-NEXT: addl %ecx, %eax
  %4 = sext i32 %3 to i64
; CHECK-NEXT: cltq
  %5 = sub i64 %4, %b
; CHECK-NEXT: subq 20(%esp), %rax
  ret i64 %5
; CHECK-NEXT: movq %rax, %rdx
; CHECK-NEXT: shrq $32, %rdx
; CHECK: retq{{$}}
}

define void @call_baz() {
; CHECK-LABEL: _call_baz:
  %td = alloca %struct.__thunk_data, align 8, addrspace(32)
; CHECK: subl $56, %esp
  %1 = call x86_fastcallcc i64 @baz(%struct.__thunk_data addrspace(32)* %td, i32 inreg 0, i64 inreg 0, i8 addrspace(32)* null)
; CHECK-DAG: xorl %ecx, %ecx
; CHECK-DAG: movq $0, 12(%esp)
; CHECK-DAG: movl $0, 20(%esp)
; CHECK-DAG: leal 32(%rsp), %eax
; CHECK: callq _baz
; CHECK: addl $56, %esp
; CHECK: retq
  ret void
}

%s = type { i64 }

define x86_thiscallcc void @quux(%struct.__thunk_data addrspace(32)* thunkdata %td, %s addrspace(32)* sret %sret, i32 inreg %a, i64 %b, i8 addrspace(32)* %c) #1 {
; CHECK-LABEL: _quux:
; CHECK: movl 20(%esp), %eax
  %1 = load i8, i8 addrspace(32)* %c
; CHECK: movl 32(%esp), %edx
  %2 = zext i8 %1 to i32
; CHECK: movzbl (%edx), %edx
  %3 = add i32 %2, %a
; CHECK-NEXT: addl %ecx, %edx
  %4 = sext i32 %3 to i64
; CHECK-NEXT: movslq %edx, %rcx
  %5 = sub i64 %4, %b
; CHECK-NEXT: subq 24(%esp), %rcx
  %6 = getelementptr inbounds %s, %s addrspace(32)* %sret, i32 0, i32 0
  store i64 %5, i64 addrspace(32)* %6
  ret void
; CHECK-NEXT: movq %rcx, (%eax)
; CHECK: retq{{$}}
}

define void @call_quux() {
; CHECK-LABEL: _call_quux:
  %td = alloca %struct.__thunk_data, align 8, addrspace(32)
  %sr = alloca %s, align 8, addrspace(32)
; CHECK: subl $72, %esp
  call x86_thiscallcc void @quux(%struct.__thunk_data addrspace(32)* %td, %s addrspace(32)* sret %sr, i32 inreg 0, i64 0, i8 addrspace(32)* null)
; CHECK: leal 40(%rsp), %eax
; CHECK: movl %eax, 12(%esp)
; CHECK-DAG: xorl %ecx, %ecx
; CHECK-DAG: movq $0, 16(%esp)
; CHECK-DAG: movl $0, 24(%esp)
; CHECK-DAG: leal 48(%rsp), %eax
; CHECK: callq _quux
; CHECK: addl $72, %esp
; CHECK: retq
  ret void
}

module asm "___i386_on_x86_64_thunk_baz:
  lretl"

; Check that thunks are generated and that they have the correct form.
; Every thunk must be immediately preceded by a magic number. The
; extra goop is to ensure that the magic number directly abuts the thunk, and
; that the thunk and the magic number are on the same page.
; CHECK: .p2align 5, 0x90
; CHECK: .quad _foo-[[PB:.*]]
; CHECK: .quad 8595522607861216050
; CHECK-LABEL: ___i386_on_x86_64_thunk_foo:
; CHECK:         movl %edi, %edi
; CHECK-NEXT:    callq [[PB]]
; CHECK:       [[PB]]:
; CHECK-NEXT:    popl %eax
; CHECK:         pushq %rax
; CHECK-NEXT:    pushq %rax
; CHECK-NEXT:    leal [[FOO64:[^-]*]]-[[PB]](%rax), %eax
; CHECK-NEXT:    xchgl %eax, (%rsp)
; CHECK-NEXT:    movl L___i386_on_x86_64_cs64$non_lazy_ptr-[[PB]](%rax), %eax
; CHECK-NEXT:    movw (%rax), %ax
; CHECK-NEXT:    movw %ax, 4(%rsp)
; CHECK-NEXT:    lcalll *(%rsp)
; CHECK-NEXT:    retq
; CHECK:       [[FOO64]]:
; CHECK:         popq %rax
; CHECK-NEXT:    movq %rax, (%esp)
; CHECK-NEXT:    callq _foo
; CHECK-NEXT:    lretl

; CHECK: .p2align 5, 0x90
; CHECK: .quad _bar-[[PB:.*]]
; CHECK: .quad 8595522607861216050
; CHECK-LABEL: ___i386_on_x86_64_thunk_bar:
; CHECK:         movl %edi, %edi
; CHECK-NEXT:    callq [[PB]]
; CHECK:       [[PB]]:
; CHECK-NEXT:    popl %eax
; CHECK:         pushq %rax
; CHECK-NEXT:    pushq %rax
; CHECK-NEXT:    leal [[BAR64:[^-]*]]-[[PB]](%rax), %eax
; CHECK-NEXT:    xchgl %eax, (%rsp)
; CHECK-NEXT:    movl L___i386_on_x86_64_cs64$non_lazy_ptr-[[PB]](%rax), %eax
; CHECK-NEXT:    movw (%rax), %ax
; CHECK-NEXT:    movw %ax, 4(%rsp)
; CHECK-NEXT:    lcalll *(%rsp)
; CHECK-NEXT:    retq $16
; CHECK:       [[BAR64]]:
; CHECK:         popq %rax
; CHECK-NEXT:    movq %rax, (%esp)
; CHECK-NEXT:    callq _bar
; CHECK-NEXT:    lretl

; Check that thunks *aren't* generated if we already defined them in inline
; assembly.
; CHECK-NOT: ___i386_on_x86_64_thunk_baz:

; CHECK: .p2align 5, 0x90
; CHECK: .quad _quux-[[PB:.*]]
; CHECK: .quad 8595522607861216050
; CHECK-LABEL: ___wine32_thunk_quux:
; CHECK:         movl %edi, %edi
; CHECK-NEXT:    callq [[PB]]
; CHECK:       [[PB]]:
; CHECK-NEXT:    popl %eax
; CHECK:         pushq %rax
; CHECK-NEXT:    pushq %rax
; CHECK-NEXT:    leal [[QUUX64:[^-]*]]-[[PB]](%rax), %eax
; CHECK-NEXT:    xchgl %eax, (%rsp)
; CHECK-NEXT:    movl L___wine32_cs64$non_lazy_ptr-[[PB]](%rax), %eax
; CHECK-NEXT:    movw (%rax), %ax
; CHECK-NEXT:    movw %ax, 4(%rsp)
; CHECK-NEXT:    lcalll *(%rsp)
; CHECK-NEXT:    retq $16
; CHECK:       [[QUUX64]]:
; CHECK:         popq %rax
; CHECK-NEXT:    movq %rax, (%esp)
; CHECK-NEXT:    callq _quux
; CHECK-NEXT:    lretl

attributes #1 = { "thunk-prefix"="__wine32" "thunk-cs64-name"="__wine32_cs64" }
