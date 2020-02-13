; RUN: llc < %s | FileCheck %s
target datalayout = "e-m:o-p32:32:32-A32-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0-wine32"

; Function Attrs: noinline nounwind optnone ssp uwtable
define void @baz() addrspace(32) #0 {
entry:
  %thunk.storage = alloca { [6 x i64] }, align 8, addrspace(32)
  call x86_stdcallcc void addrspacecast (void ({ [6 x i64] } addrspace(32)*, i32) addrspace(32)* @bar to void ({ [6 x i64] } addrspace(32)*, i32)*)({ [6 x i64] } addrspace(32)* thunkdata %thunk.storage, i32 ptrtoint (void ({ [6 x i64] } addrspace(32)*) addrspace(32)* @foo to i32))
; CHECK: movl ___i386_on_x86_64_thunk_foo@GOTPCREL(%rip), %[[REG:.*]]
; CHECK: movl %[[REG]], 12(%{{.*}})
  ret void
}

declare x86_stdcallcc void @bar({ [6 x i64] } addrspace(32)* thunkdata, i32) addrspace(32) #1

declare x86_stdcallcc void @foo({ [6 x i64] } addrspace(32)* thunkdata) addrspace(32) #1

attributes #0 = { noinline nounwind optnone ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 8.0.0 (cdavis@foghorn:~ken/repos/clang.git 11119e8ab36ed65c8ac5bb9d08c1f1679c856f18) (cdavis@foghorn:~ken/repos/llvm.git 53f07fa72e304cc9f8d19126dab9f01143854d31)"}
