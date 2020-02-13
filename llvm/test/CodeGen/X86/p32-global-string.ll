; RUN: llc -mtriple=x86_64-apple-macosx10.13.0-wine32 < %s | FileCheck %s
; RUN: llc -mtriple=x86_64-apple-macosx10.13.0-wine32sp64 < %s | FileCheck %s

@.str = private unnamed_addr addrspace(32) constant [4 x i8] c"foo\00", align 1

; Function Attrs: nounwind ssp uwtable
define i32 @main() local_unnamed_addr #0 {
  %call1 = tail call i32 @res_9_query(i8* addrspacecast (i8 addrspace(32)* getelementptr inbounds ([4 x i8], [4 x i8] addrspace(32)* @.str, i32 0, i32 0) to i8*), i32 1, i32 0, i8* null, i32 0) #2
  ret i32 0
}

; CHECK-LABEL: _main:
; CHECK: leal	[[STR:.*]](%rip), %edi
; CHECK: callq	_res_9_query

; CHECK: [[STR]]:
; CHECK:   .asciz "foo"

declare i32 @res_9_query(i8*, i32, i32, i8*, i32) local_unnamed_addr #1

attributes #0 = { nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }

