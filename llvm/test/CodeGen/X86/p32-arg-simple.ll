; RUN: llc -mtriple=x86_64-pc-linux-wine32 < %s | FileCheck %s
; RUN: llc -mtriple=x86_64-pc-linux-wine32sp64 < %s | FileCheck %s

; CHECK-LABEL: foo
; CHECK: movl %esi, (%edi)

define void @foo(i32 addrspace(32)* nocapture %out, i32 %in) nounwind {
entry:
  store i32 %in, i32 addrspace(32)* %out, align 4
  ret void
}

; CHECK-LABEL: bar
; CHECK: movl (%esi), %eax
; CHECK: movl %eax, (%rdi)

define void @bar(i32* nocapture %pOut, i32 addrspace(32)* nocapture %pIn) nounwind {
entry:
  %0 = load i32, i32 addrspace(32)* %pIn, align 4
  store i32 %0, i32* %pOut, align 4
  ret void
}

