; RUN: llc < %s -mtriple=x86_64-linux-wine32 | FileCheck %s
; RUN: llc < %s -mtriple=x86_64-linux-wine32sp64 | FileCheck %s
; CHECK:      mov
; CHECK:      movb %ah, (%esi)
; CHECK:      mov
; CHECK:      movb %ah, (%esi)
; CHECK:      mov
; CHECK:      movb %ah, (%esi)
; CHECK-NOT:  mov

; Use h-register extract and store.

define void @foo16(i16 inreg %p, i8 addrspace(32)* inreg %z) nounwind {
  %q = lshr i16 %p, 8
  %t = trunc i16 %q to i8
  store i8 %t, i8 addrspace(32)* %z
  ret void
}
define void @foo32(i32 inreg %p, i8 addrspace(32)* inreg %z) nounwind {
  %q = lshr i32 %p, 8
  %t = trunc i32 %q to i8
  store i8 %t, i8 addrspace(32)* %z
  ret void
}
define void @foo64(i64 inreg %p, i8 addrspace(32)* inreg %z) nounwind {
  %q = lshr i64 %p, 8
  %t = trunc i64 %q to i8
  store i8 %t, i8 addrspace(32)* %z
  ret void
}
