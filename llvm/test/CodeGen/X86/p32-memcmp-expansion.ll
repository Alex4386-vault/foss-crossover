; RUN: llc -O2 -mtriple=x86_64-apple-macosx10.13.0-wine32 < %s | FileCheck %s
; RUN: llc -O2 -mtriple=x86_64-apple-macosx10.13.0-wine32sp64 < %s | FileCheck %s

@.str.47 = private unnamed_addr addrspace(32) constant [4 x i8] c"../\00", align 1
@.str.132 = private unnamed_addr addrspace(32) constant [51 x i8] c"#include directive with relative path not allowed\0A\00", align 1

; Function Attrs: noreturn nounwind ssp uwtable
declare void @fatal_error(i8* nocapture readonly %msg, ...) unnamed_addr #7

; Function Attrs: nounwind ssp uwtable
define internal fastcc void @add_dependency(i8* %name) unnamed_addr #0 {
entry:
  %call = tail call i32 @memcmp(i8* %name, i8 addrspace(32)* getelementptr inbounds ([4 x i8], [4 x i8] addrspace(32)* @.str.47, i32 0, i32 0), i64 3)
  %tobool = icmp eq i32 %call, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  tail call void (i8*, ...) @fatal_error(i8* addrspacecast (i8 addrspace(32)* getelementptr inbounds ([51 x i8], [51 x i8] addrspace(32)* @.str.132, i32 0, i32 0) to i8*))
  unreachable

if.end:                                           ; preds = %entry
  ret void
}

; CHECK-LABEL: _add_dependency:
; CHECK:      movzwl	(%rdi), %e[[A:.*]]
; CHECK-NEXT: xorl		$11822, %e[[A]]
; CHECK-NEXT: movzbl	2(%rdi), %e[[B:.*]]
; CHECK-NEXT: xorl		$47, %e[[B]]
; CHECK-NEXT: orw		%[[A]], %[[B]]
; CHECK-NEXT: je

; Function Attrs: nounwind readonly
declare i32 @memcmp(i8* nocapture, i8 addrspace(32)* nocapture, i64) local_unnamed_addr #3

attributes #0 = { nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { noreturn nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

