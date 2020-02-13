; RUN: opt -S -instcombine -o - %s | FileCheck %s

target datalayout = "e-m:o-p32:32:32-A32-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.13.0-wine32"

@.str = private unnamed_addr constant [2 x i8] c"y\00", align 1

define i8* @foo(i8 addrspace(32)* %a) {
  %1 = call i8* @strstr(i8 addrspace(32)* %a, i8* getelementptr inbounds ([2 x i8], [2 x i8]* @.str, i64 0, i64 0))
  ret i8* %1
}

; CHECK-LABEL: define i8* @foo(i8 addrspace(32)* %a
; CHECK: %[[CSTR_AS:.*]] = addrspacecast i8 addrspace(32)* %a to i8*
; CHECK: call i8* @strchr(i8* %[[CSTR_AS]], i32 121)

; This is deliberate. Clang generates a signature like this for the built-in
; (i.e. known) function, strstr(3), when called with a 32-bit pointer.
declare i8* @strstr(i8 addrspace(32)*, i8*)
