; RUN: llc < %s -mtriple=x86_64-apple-darwin17-wine32sp64 | FileCheck %s -check-prefixes=CHECK,CHECK-SDAG
; RUN: llc < %s -mtriple=x86_64-apple-darwin17-wine32sp64 -fast-isel | FileCheck %s -check-prefixes=CHECK,CHECK-FAST

%struct.__thunk_data = type { i64, i64, i64 }

define x86_64_c32cc i64 @foo(%struct.__thunk_data addrspace(32)* thunkdata %td, i32 %a, i64 %b, i8 addrspace(32)* %c, ...) {
; CHECK-LABEL: _foo:
  %1 = load i8, i8 addrspace(32)* %c
; CHECK: movl 32(%rsp), %eax
  %2 = zext i8 %1 to i32
; CHECK-NEXT: movzbl (%eax), %eax
  %3 = add i32 %2, %a
; CHECK-NEXT: addl 20(%rsp), %eax
  %4 = sext i32 %3 to i64
; CHECK-NEXT: cltq
  %5 = sub i64 %4, %b
; CHECK-NEXT: subq 24(%rsp), %rax
  ret i64 %5
; CHECK-NEXT: movq %rax, %rdx
; CHECK-NEXT: shrq $32, %rdx
; CHECK: retq{{$}}
}

define i64 @call_foo() {
; CHECK-LABEL: _call_foo:
  %td = alloca %struct.__thunk_data, align 8
; CHECK: subq $56, %rsp
  %td.0 = addrspacecast %struct.__thunk_data* %td to %struct.__thunk_data addrspace(32)*
  %1 = call x86_64_c32cc i64 (%struct.__thunk_data addrspace(32)*, i32, i64, i8 addrspace(32)*, ...) @foo(%struct.__thunk_data addrspace(32)* %td.0, i32 0, i64 0, i8 addrspace(32)* null)
; CHECK-NOT: movb $0, %al
; CHECK-DAG: movl $0, 12(%rsp)
; CHECK-DAG: movq $0, 16(%rsp)
; CHECK-DAG: movl $0, 24(%rsp)
; CHECK-DAG: leaq 32(%rsp), %rax
; CHECK-NOT: movb $0, %al
; CHECK: callq _foo
  %2 = add i64 %1, 10
; CHECK: shlq $32, %rdx
; CHECK-SDAG: leaq 10(%rax,%rdx), %rax
; CHECK-FAST: orq %rdx, %rax
; CHECK-FAST: addq $10, %rax
  ret i64 %2
; CHECK: addq $56, %rsp
; CHECK: retq
}

define x86_stdcallcc i64 @bar(%struct.__thunk_data addrspace(32)* thunkdata %td, i32 %a, i64 %b, i8 addrspace(32)* %c) {
; CHECK-LABEL: _bar:
  %1 = load i8, i8 addrspace(32)* %c
; CHECK: movl 32(%rsp), %eax
  %2 = zext i8 %1 to i32
; CHECK-NEXT: movzbl (%eax), %eax
  %3 = add i32 %2, %a
; CHECK-NEXT: addl 20(%rsp), %eax
  %4 = sext i32 %3 to i64
; CHECK-NEXT: cltq
  %5 = sub i64 %4, %b
; CHECK-NEXT: subq 24(%rsp), %rax
  ret i64 %5
; CHECK-NEXT: movq %rax, %rdx
; CHECK-NEXT: shrq $32, %rdx
; CHECK: retq{{$}}
}

define void @call_bar() {
; CHECK-LABEL: _call_bar:
  %td = alloca %struct.__thunk_data, align 8
; CHECK: subq $56, %rsp
  %td.0 = addrspacecast %struct.__thunk_data* %td to %struct.__thunk_data addrspace(32)*
  %1 = call x86_stdcallcc i64 @bar(%struct.__thunk_data addrspace(32)* %td.0, i32 0, i64 0, i8 addrspace(32)* null)
; CHECK-DAG: movl $0, 12(%rsp)
; CHECK-DAG: movq $0, 16(%rsp)
; CHECK-DAG: movl $0, 24(%rsp)
; CHECK-DAG: leaq 32(%rsp), %rax
; CHECK: callq _bar
; CHECK: addq $56, %rsp
; CHECK: retq
  ret void
}

define x86_fastcallcc i64 @baz(%struct.__thunk_data addrspace(32)* thunkdata %td, i32 inreg %a, i64 inreg %b, i8 addrspace(32)* %c) {
; CHECK-LABEL: _baz:
  %1 = load i8, i8 addrspace(32)* %c
; CHECK: movl 28(%rsp), %eax
  %2 = zext i8 %1 to i32
; CHECK-NEXT: movzbl (%eax), %eax
  %3 = add i32 %2, %a
; CHECK-NEXT: addl %ecx, %eax
  %4 = sext i32 %3 to i64
; CHECK-NEXT: cltq
  %5 = sub i64 %4, %b
; CHECK-NEXT: subq 20(%rsp), %rax
  ret i64 %5
; CHECK-NEXT: movq %rax, %rdx
; CHECK-NEXT: shrq $32, %rdx
; CHECK: retq{{$}}
}

define void @call_baz() {
; CHECK-LABEL: _call_baz:
  %td = alloca %struct.__thunk_data, align 8
; CHECK: subq $56, %rsp
  %td.0 = addrspacecast %struct.__thunk_data* %td to %struct.__thunk_data addrspace(32)*
  %1 = call x86_fastcallcc i64 @baz(%struct.__thunk_data addrspace(32)* %td.0, i32 inreg 0, i64 inreg 0, i8 addrspace(32)* null)
; CHECK-DAG: xorl %ecx, %ecx
; CHECK-DAG: movq $0, 12(%rsp)
; CHECK-DAG: movl $0, 20(%rsp)
; CHECK-DAG: leaq 32(%rsp), %rax
; CHECK: callq _baz
; CHECK: addq $56, %rsp
; CHECK: retq
  ret void
}

%s = type { i64 }

define x86_thiscallcc void @quux(%struct.__thunk_data addrspace(32)* thunkdata %td, %s addrspace(32)* sret %sret, i32 inreg %a, i64 %b, i8 addrspace(32)* %c) #1 {
; CHECK-LABEL: _quux:
; CHECK: movl 20(%rsp), %eax
  %1 = load i8, i8 addrspace(32)* %c
; CHECK: movl 32(%rsp), %edx
  %2 = zext i8 %1 to i32
; CHECK: movzbl (%edx), %edx
  %3 = add i32 %2, %a
; CHECK-NEXT: addl %ecx, %edx
  %4 = sext i32 %3 to i64
; CHECK-NEXT: movslq %edx, %rcx
  %5 = sub i64 %4, %b
; CHECK-NEXT: subq 24(%rsp), %rcx
  %6 = getelementptr inbounds %s, %s addrspace(32)* %sret, i32 0, i32 0
  store i64 %5, i64 addrspace(32)* %6
  ret void
; CHECK-NEXT: movq %rcx, (%eax)
; CHECK: retq{{$}}
}

define void @call_quux() {
; CHECK-LABEL: _call_quux:
  %td = alloca %struct.__thunk_data, align 8
  %sr = alloca %s, align 8
; CHECK: subq $72, %rsp
  %td.0 = addrspacecast %struct.__thunk_data* %td to %struct.__thunk_data addrspace(32)*
  %sr.0 = addrspacecast %s* %sr to %s addrspace(32)*
  call x86_thiscallcc void @quux(%struct.__thunk_data addrspace(32)* %td.0, %s addrspace(32)* sret %sr.0, i32 inreg 0, i64 0, i8 addrspace(32)* null)
; CHECK: leaq 48(%rsp), %rax
; CHECK: leaq 40(%rsp), %rcx
; CHECK: movl %ecx, 12(%rsp)
; CHECK-DAG: xorl %ecx, %ecx
; CHECK-DAG: movq $0, 16(%rsp)
; CHECK-DAG: movl $0, 24(%rsp)
; CHECK: callq _quux
; CHECK: addq $72, %rsp
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
; CHECK-NEXT:    leal ___i386_on_x86_64_cs64@GOTPCREL(%rax), %eax
; CHECK-NEXT:  [[TMP:.*]]:
; CHECK:         movl [[TMP]]-[[PB]](%rax), %eax
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
; CHECK-NEXT:    callq [[PB:.*]]
; CHECK:       [[PB]]:
; CHECK-NEXT:    popl %eax
; CHECK:         pushq %rax
; CHECK-NEXT:    pushq %rax
; CHECK-NEXT:    leal [[BAR64:[^-]*]]-[[PB]](%rax), %eax
; CHECK-NEXT:    xchgl %eax, (%rsp)
; CHECK-NEXT:    leal ___i386_on_x86_64_cs64@GOTPCREL(%rax), %eax
; CHECK-NEXT:  [[TMP:.*]]:
; CHECK:         movl [[TMP]]-[[PB]](%rax), %eax
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
; CHECK-NEXT:    callq [[PB:.*]]
; CHECK:       [[PB]]:
; CHECK-NEXT:    popl %eax
; CHECK:         pushq %rax
; CHECK-NEXT:    pushq %rax
; CHECK-NEXT:    leal [[QUUX64:[^-]*]]-[[PB]](%rax), %eax
; CHECK-NEXT:    xchgl %eax, (%rsp)
; CHECK-NEXT:    leal ___wine32_cs64@GOTPCREL(%rax), %eax
; CHECK-NEXT:  [[TMP:.*]]:
; CHECK:         movl [[TMP]]-[[PB]](%rax), %eax
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
