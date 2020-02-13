; RUN: opt -S -instcombine %s | FileCheck %s
target datalayout = "e-m:o-p32:32:32-A32-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.13.0-wine32"

; Test that this doesn't crash.

@.str.12 = external dso_local unnamed_addr addrspace(32) constant [5 x i8], align 1

; Function Attrs: nounwind ssp uwtable
define internal fastcc i8* @next_dll_path() unnamed_addr #0 {
entry:
  switch i32 undef, label %sw.default [
    i32 0, label %sw.bb
    i32 1, label %sw.bb13
  ]

sw.bb:                                            ; preds = %entry
  %call = call i32 @memcmp(i8* undef, i8 addrspace(32)* getelementptr inbounds ([5 x i8], [5 x i8] addrspace(32)* @.str.12, i32 0, i32 0), i64 4)
  %tobool = icmp ne i32 %call, 0
  br i1 %tobool, label %if.end, label %if.then

; CHECK:      sw.bb:
; CHECK-NEXT:   %call = call i32 @memcmp(i8* undef, i8 addrspace(32)* getelementptr inbounds ([5 x i8], [5 x i8] addrspace(32)* @.str.12, i32 0, i32 0), i64 4)
; CHECK-NEXT:   %tobool = icmp eq i32 %call, 0
; CHECK-NEXT:   br i1 %tobool, label %if.then, label %if.end

if.then:
  br label %if.end

if.end:
  unreachable

sw.bb13:
  unreachable

sw.default:
  unreachable
}

; Function Attrs: nounwind readonly
declare i32 @memcmp(i8* nocapture, i8 addrspace(32)* nocapture, i64) local_unnamed_addr #1

attributes #0 = { nounwind ssp }
attributes #1 = { nounwind readonly }
