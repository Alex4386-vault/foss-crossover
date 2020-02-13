; RUN: llc < %s | FileCheck %s
target datalayout = "e-m:o-p32:32:32-A32-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.13.0-wine32"

%struct.anon.6 = type { %struct.dds_pixel_format, i32, i32, i32, i32, i32, i32, %struct.anon.7 }
%struct.dds_pixel_format = type { i32, i32, i32, i32, i32, i32, i32, i32 }
%struct.anon.7 = type { i32, i32 }
%struct._D3DXIMAGE_INFO = type { i32, i32, i32, i32, i32, i32, i32 }

@.str.2 = external dso_local unnamed_addr constant [42 x i8], align 1
@noimage = external dso_local constant [4 x i8], align 1
@.str.15 = external dso_local unnamed_addr constant [61 x i8], align 1
@test_dds_header_handling.tests = external dso_local unnamed_addr constant [62 x %struct.anon.6], align 16
@.str.38 = external dso_local unnamed_addr constant [65 x i8], align 1
@.str.39 = external dso_local unnamed_addr constant [35 x i8], align 1

; Function Attrs: nounwind ssp uwtable
define void @func_surface() local_unnamed_addr #0 {
entry:
  %tests.i.i = alloca [62 x %struct.anon.6], align 16, addrspace(32)
  call void @winetest_set_location(i8* getelementptr inbounds ([42 x i8], [42 x i8]* @.str.2, i64 0, i64 0), i32 458) #3
  %call137.i = call win64cc i32 @D3DXGetImageInfoFromFileInMemory(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @noimage, i64 0, i64 0), i32 4, %struct._D3DXIMAGE_INFO* undef) #3
  call void (i32, i8*, ...) @winetest_ok(i32 undef, i8* getelementptr inbounds ([61 x i8], [61 x i8]* @.str.15, i64 0, i64 0), i32 %call137.i, i32 -2005529767) #3
  %call171.i = call win64cc i32 @D3DXGetImageInfoFromFileInMemory(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @noimage, i64 0, i64 0), i32 0, %struct._D3DXIMAGE_INFO* undef) #3
  call void @winetest_set_location(i8* getelementptr inbounds ([42 x i8], [42 x i8]* @.str.2, i64 0, i64 0), i32 586) #3
  call void @llvm.memcpy.p32i8.p0i8.i64(i8 addrspace(32)* align 16 undef, i8* align 16 bitcast ([62 x %struct.anon.6]* @test_dds_header_handling.tests to i8*), i64 3968, i1 false) #3
  br i1 undef, label %if.then.i688.i, label %for.cond.preheader.i.i

for.cond.preheader.i.i:                           ; preds = %entry
  br label %for.body.i.i

if.then.i688.i:                                   ; preds = %entry
  unreachable

for.body.i.i:                                     ; preds = %for.body.i.i, %for.cond.preheader.i.i
  %indvars.iv.i.i = phi i64 [ 0, %for.cond.preheader.i.i ], [ %indvars.iv.next.i.i, %for.body.i.i ]
  %i.0106.i.i = phi i32 [ 0, %for.cond.preheader.i.i ], [ %inc.i.i, %for.body.i.i ]
  %0 = getelementptr inbounds [62 x %struct.anon.6], [62 x %struct.anon.6] addrspace(32)* %tests.i.i, i32 0, i32 %i.0106.i.i
  %1 = bitcast %struct.anon.6 addrspace(32)* %0 to i8 addrspace(32)*
  call void @llvm.memcpy.p0i8.p32i8.i64(i8* nonnull align 4 undef, i8 addrspace(32)* align 16 %1, i64 32, i1 false) #3
  %call36.i.i = call win64cc i32 @D3DXGetImageInfoFromFileInMemory(i8* nonnull undef, i32 undef, %struct._D3DXIMAGE_INFO* undef) #3
  call void @winetest_set_location(i8* getelementptr inbounds ([42 x i8], [42 x i8]* @.str.2, i64 0, i64 0), i32 416) #3
  %hr41.i.i = getelementptr [62 x %struct.anon.6], [62 x %struct.anon.6]* @test_dds_header_handling.tests, i64 0, i64 %indvars.iv.i.i, i32 7, i32 0
  %2 = load i32, i32* %hr41.i.i, align 8
  %3 = trunc i64 %indvars.iv.i.i to i32
  call void (i32, i8*, ...) @winetest_ok(i32 undef, i8* getelementptr inbounds ([65 x i8], [65 x i8]* @.str.38, i64 0, i64 0), i32 %3, i32 %call36.i.i, i32 %2) #3
  call void (i32, i8*, ...) @winetest_ok(i32 undef, i8* getelementptr inbounds ([35 x i8], [35 x i8]* @.str.39, i64 0, i64 0), i32 %3, i32 undef, i32 undef) #3
  %indvars.iv.next.i.i = add nuw nsw i64 %indvars.iv.i.i, 1
  %inc.i.i = add nuw nsw i32 %i.0106.i.i, 1
  %cmp.i689.i = icmp ult i64 %indvars.iv.next.i.i, 62
  br label %for.body.i.i
}

; CHECK:     movq	-56(%ebp), %{{r?}}[[PTR:[a-z0-9]*]]
; CHECK:     movq	24(%{{e?}}[[PTR]]{{d?}},%[[IDX:.*]]), %[[TMP:.*]]
; CHECK:     movq	%[[TMP]], {{.*}}
; CHECK:     movq	16(%{{e?}}[[PTR]]{{d?}},%[[IDX]]), %[[TMP:.*]]
; CHECK:     movq	%[[TMP]], {{.*}}
; CHECK-DAG: movq	(%{{e?}}[[PTR]]{{d?}},%[[IDX]]), %[[TMP:.*]]
; CHECK-DAG: movq	8(%{{e?}}[[PTR]]{{d?}},%[[IDX]]), %[[TMP2:.*]]
; CHECK-DAG: movq	%[[TMP]], {{.*}}
; CHECK-DAG: movq	%[[TMP2]], {{.*}}
; CHECK:     callq	_D3DXGetImageInfoFromFileInMemory
; CHECK:     addq	$64, %r13

declare void @winetest_set_location(i8*, i32) local_unnamed_addr #1

declare void @winetest_ok(i32, i8*, ...) local_unnamed_addr #1

declare win64cc i32 @D3DXGetImageInfoFromFileInMemory(i8*, i32, %struct._D3DXIMAGE_INFO*) local_unnamed_addr #1

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p32i8.p0i8.i64(i8 addrspace(32)* nocapture writeonly, i8* nocapture readonly, i64, i1) #2

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p32i8.i64(i8* nocapture writeonly, i8 addrspace(32)* nocapture readonly, i64, i1) #2

attributes #0 = { nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { argmemonly nounwind }
attributes #3 = { nounwind }

