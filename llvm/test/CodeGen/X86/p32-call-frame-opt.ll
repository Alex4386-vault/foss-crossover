; RUN: llc -mtriple=x86_64-apple-macosx10.12.0-wine32 < %s | FileCheck -check-prefixes=CHECK,CHECK32 %s
; RUN: llc -mtriple=x86_64-apple-macosx10.12.0-wine32sp64 < %s | FileCheck -check-prefixes=CHECK,CHECK64 %s

; Test that call frame optimization doesn't crash on this input.

@DXTraceW.format.5 = external dso_local constant [31 x i16], align 16

; Function Attrs: nounwind ssp uwtable
define x86_stdcallcc i32 @DXTraceW(i8* %strFile, i32 %dwLine, i32 returned %hr, i16* %strMsg) local_unnamed_addr #0 {
entry:
  call x86_64_c32cc void ({ [6 x i64] } addrspace(32)*, i16*, i16*, ...) @wsprintfW({ [6 x i64] } addrspace(32)* thunkdata undef, i16* undef, i16* getelementptr inbounds ([31 x i16], [31 x i16]* @DXTraceW.format.5, i64 0, i64 0), i8* %strFile, i32 %dwLine, i16* %strMsg, i16* undef, i32 %hr) #2
  ; CHECK32: movq    28(%ebp), %[[STRMSG:.*]]
  ; CHECK64: movq    28(%rbp), %[[STRMSG:.*]]
  ; CHECK32: movl    36(%ebp), %[[HR:.*]]
  ; CHECK64: movl    36(%rbp), %[[HR:.*]]
  ; CHECK32: movq    44(%ebp), %[[STRFILE:.*]]
  ; CHECK64: movq    44(%rbp), %[[STRFILE:.*]]
  ; CHECK32: movl    40(%ebp), %[[DWLINE:.*]]
  ; CHECK64: movl    40(%rbp), %[[DWLINE:.*]]
  ; CHECK32: movl    %[[DWLINE]], 56(%esp)
  ; CHECK64: movl    %[[DWLINE]], 56(%rsp)
  ; CHECK32: movq    %[[STRFILE]], 40(%esp)
  ; CHECK64: movq    %[[STRFILE]], 40(%rsp)
  ; CHECK32: movl    %[[HR]], 36(%esp)
  ; CHECK64: movl    %[[HR]], 36(%rsp)
  ; CHECK32: movq    %[[STRMSG]], 28(%esp)
  ; CHECK64: movq    %[[STRMSG]], 28(%rsp)
  ; CHECK:   leaq    _DXTraceW.format.5(%rip), %[[FORMAT:.*]]
  ; CHECK32: movq    %[[FORMAT]], 20(%esp)
  ; CHECK64: movq    %[[FORMAT]], 20(%rsp)
  ; CHECK:   callq   _wsprintfW
  unreachable
}

declare hidden x86_64_c32cc void @wsprintfW({ [6 x i64] } addrspace(32)* thunkdata, i16*, i16*, ...) local_unnamed_addr
; CHECK-NOT: _winethunk_wsprintfW
; CHECK-NOT: ___i386_on_x86_64_thunk_wsprintfW
; CHECK-NOT: ___i386_on_x86_64_cs64

attributes #0 = { nounwind ssp uwtable "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "stack-protector-buffer-size"="8" "thunk-cs32-name"="wine_32on64_cs32" "thunk-cs64-name"="wine_32on64_cs64" "thunk-prefix"="wine" }
attributes #2 = { nounwind }

