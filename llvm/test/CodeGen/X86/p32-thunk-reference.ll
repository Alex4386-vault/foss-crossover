; RUN: llc -O2 < %s | FileCheck %s
target datalayout = "e-m:o-p32:32:32-A32-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.13.0-wine32"

@pbar = common local_unnamed_addr global void ({ [6 x i64] } addrspace(32)*, i32, i32 addrspace(32)*) addrspace(32)* null, align 4
@pbaz = common local_unnamed_addr global void ({ [6 x i64] } addrspace(32)*, i32, i32 addrspace(32)*) addrspace(32)* null, align 4
@pcast = common local_unnamed_addr global void ({ [6 x i64] } addrspace(32)*, i64)* null, align 8

define internal x86_stdcallcc void @baz({ [6 x i64] } addrspace(32)* thunkdata %d, i32 %a, i32 addrspace(32)* %b) addrspace(32) #2 {
; CHECK-LABEL: _baz:
  store i32 %a, i32 addrspace(32)* %b, align 4
  ret void
; CHECK: retq
}

; Function Attrs: norecurse nounwind writeonly
define void @quux() local_unnamed_addr #2 {
; CHECK-LABEL: _quux:
  %a = alloca i32, align 4, addrspace(32)
  %td = alloca { [6 x i64] }, align 8, addrspace(32)
  store void ({ [6 x i64] } addrspace(32)*, i32, i32 addrspace(32)*) addrspace(32)* @bar, void ({ [6 x i64] } addrspace(32)*, i32, i32 addrspace(32)*) addrspace(32)** @pbar, align 4, !tbaa !6
; CHECK: movl ___i386_on_x86_64_thunk_bar@GOTPCREL(%rip), %e[[REG1:.*]]
; CHECK: movq _pbar@GOTPCREL(%rip), %[[DEST:.*]]
; CHECK: movl %e[[REG1]], (%[[DEST]])
  store void ({ [6 x i64] } addrspace(32)*, i32, i32 addrspace(32)*) addrspace(32)* @baz, void ({ [6 x i64] } addrspace(32)*, i32, i32 addrspace(32)*) addrspace(32)** @pbaz, align 4, !tbaa !6
; CHECK: movl ___wine32_thunk_baz@GOTPCREL(%rip), %e[[REG2:.*]]
; CHECK: movq _pbaz@GOTPCREL(%rip), %[[DEST:.*]]
; CHECK: movl %e[[REG2]], (%[[DEST]])
  call x86_stdcallcc void @foo(i32 addrspace(32)* %a, void ({ [6 x i64] } addrspace(32)*, i32, i32 addrspace(32)*) addrspace(32)* @bar)
; CHECK: movl %e[[REG1]], 16(%{{.*}})
; CHECK: callq _foo
; Show that we handle casting OK, too.
  %1 = bitcast void ({ [6 x i64] } addrspace(32)*, i32, i32 addrspace(32)*) addrspace(32)* @bar to void ({ [6 x i64] } addrspace(32)*, i64) addrspace(32)*
  %2 = addrspacecast void ({ [6 x i64] } addrspace(32)*, i64) addrspace(32)* %1 to void ({ [6 x i64] } addrspace(32)*, i64)*
  call x86_stdcallcc addrspace(32) void %1({ [6 x i64] } addrspace(32)* thunkdata %td, i64 0)
; CHECK: callq _bar
  store void ({ [6 x i64] } addrspace(32)*, i64)* %2, void ({ [6 x i64] } addrspace(32)*, i64)** @pcast, align 8
; CHECK: movq _pcast@GOTPCREL(%rip), %[[DEST:.*]]
; CHECK: movq %r[[REG1]], (%[[DEST]])

  call x86_stdcallcc addrspace(32) void bitcast (void ({ [6 x i64] } addrspace(32)*, i32, i32 addrspace(32)*) addrspace(32)* @baz to void ({ [6 x i64] } addrspace(32)*, i64) addrspace(32)*)({ [6 x i64] } addrspace(32)* thunkdata %td, i64 0)
; CHECK: callq _baz
  store void ({ [6 x i64] } addrspace(32)*, i64)* addrspacecast (void ({ [6 x i64] } addrspace(32)*, i64) addrspace(32)* bitcast (void ({ [6 x i64] } addrspace(32)*, i32, i32 addrspace(32)*) addrspace(32)* @baz to void ({ [6 x i64] } addrspace(32)*, i64) addrspace(32)*) to void ({ [6 x i64] } addrspace(32)*, i64)*), void ({ [6 x i64] } addrspace(32)*, i64)** @pcast, align 8
  ret void
; CHECK: movq %r[[REG2]], (%[[DEST]])
}

declare x86_stdcallcc void @foo(i32 addrspace(32)* nocapture readonly %a, void ({ [6 x i64] } addrspace(32)*, i32, i32 addrspace(32)*) addrspace(32)* nocapture %b) #0

declare x86_stdcallcc void @bar({ [6 x i64] } addrspace(32)* thunkdata, i32, i32 addrspace(32)*) addrspace(32) #3

; CHECK-LABEL: ___wine32_thunk_baz:
; CHECK: retq

@array = hidden unnamed_addr constant [3 x void ({ [6 x i64] } addrspace(32)*, i32, i32 addrspace(32)*) addrspace(32)*] [void ({ [6 x i64] } addrspace(32)*, i32, i32 addrspace(32)*) addrspace(32)* @bar, void ({ [6 x i64] } addrspace(32)*, i32, i32 addrspace(32)*) addrspace(32)* @baz, void ({ [6 x i64] } addrspace(32)*, i32, i32 addrspace(32)*) addrspace(32)* @bar], align 4

; CHECK-LABEL: _array:
; CHECK: .long ___i386_on_x86_64_thunk_bar
; CHECK: .long ___wine32_thunk_baz
; CHECK: .long ___i386_on_x86_64_thunk_bar

attributes #0 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-features"="+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { norecurse nounwind writeonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-features"="+mmx,+sse,+sse2,+x87" "thunk-prefix"="__wine32" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-features"="+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind }

!2 = !{!3, !3, i64 0}
!3 = !{!"int", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}
!6 = !{!7, !7, i64 0}
!7 = !{!"any pointer", !4, i64 0}
