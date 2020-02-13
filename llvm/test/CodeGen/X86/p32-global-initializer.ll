; RUN: llc -mtriple=x86_64-apple-macosx10.13.0-wine32 < %s | FileCheck %s
; RUN: llc -mtriple=x86_64-apple-macosx10.13.0-wine32sp64 < %s | FileCheck %s

@output_makefile_name = internal unnamed_addr addrspace(32) global i8* addrspacecast (i8 addrspace(32)* getelementptr inbounds ([9 x i8], [9 x i8] addrspace(32)* @.str.46, i32 0, i32 0) to i8*), align 8
@.str.46 = private unnamed_addr addrspace(32) constant [9 x i8] c"Makefile\00", align 1

; CHECK: _output_makefile_name:
; CHECK: .quad	[[STR:.*]]
; CHECK: [[STR]]:
; CHECK: .asciz	"Makefile"
