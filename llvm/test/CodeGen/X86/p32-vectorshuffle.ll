; RUN: llc -mtriple=x86_64-apple-macosx10.13.0-wine32 < %s | FileCheck %s
; RUN: llc -mtriple=x86_64-apple-macosx10.13.0-wine32sp64 < %s | FileCheck %s

; Function Attrs: nounwind ssp uwtable
define dso_local fastcc void @foo() unnamed_addr {
entry:
  br i1 undef, label %exit, label %if.end.i14

if.end.i14:                                       ; preds = %entry
  %0 = load <2 x i32>, <2 x i32> addrspace(32)* undef, align 8
  %shuffle = shufflevector <2 x i32> %0, <2 x i32> undef, <4 x i32> <i32 0, i32 1, i32 0, i32 1>
  %1 = sub <4 x i32> zeroinitializer, %shuffle
  store <4 x i32> %1, <4 x i32>* undef, align 16
  unreachable

exit:                                             ; preds = %entry
  ret void
}

; CHECK-LABEL: _foo:
; CHECK: movq	(%{{e?}}[[PTR:.*]]{{d?}}), %[[MM0:xmm[0-9]+]]
; CHECK: pshufd	$68, %[[MM0]], %[[MM0]]
; CHECK: pxor	%[[MM1:xmm[0-9]+]], %[[MM1]]
; CHECK: psubd	%[[MM0]], %[[MM1]]
; CHECK: movdqa	%[[MM1]], (%{{r?}}[[PTR]])

