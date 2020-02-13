; RUN: llc -mtriple=x86_64-pc-linux-wine32 < %s | FileCheck %s
; RUN: llc -mtriple=x86_64-pc-linux-wine32sp64 < %s | FileCheck %s

define i32 @foo(i32* %a, i32 addrspace(32)* %b) {
  %x = addrspacecast i32* %a to i32 addrspace(32)*
  %y = addrspacecast i32 addrspace(32)* %b to i32*
  %1 = load i32, i32 addrspace(32)* %x
  %2 = load i32, i32* %y
  %3 = add i32 %1, %2
  ret i32 %3
}

; CHECK-LABEL: foo:
; CHECK:         movl %esi, %{{e?}}[[R2:.*]]{{d?}}
; CHECK:         movl (%edi), %eax
; CHECK-NEXT:    addl (%{{r?}}[[R2]]), %eax
; CHECK-NEXT:    retq
