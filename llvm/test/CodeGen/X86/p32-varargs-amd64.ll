; RUN: llc < %s | FileCheck %s

target datalayout = "e-m:e-p32:32:32-A32-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-wine32"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }
%struct.__va_list_tag = type { i32, i32, i8*, i8* }

@stderr = external dso_local global %struct._IO_FILE*, align 8
@input_file_name = external hidden global i8*, align 8
@.str.39 = external hidden unnamed_addr constant [4 x i8], align 1
@input_line = external hidden global i32, align 4
@.str.40 = external hidden unnamed_addr constant [4 x i8], align 1
@.str.41 = external hidden unnamed_addr constant [9 x i8], align 1
@.str.42 = external hidden unnamed_addr constant [17 x i8], align 1

declare dso_local i32 @fprintf(%struct._IO_FILE*, i8*, ...) #1

; Function Attrs: noreturn nounwind
declare dso_local void @exit(i32) #2

; Function Attrs: noinline nounwind optnone uwtable
declare hidden i8* @xmalloc(i64) #3

; Function Attrs: noinline nounwind optnone uwtable
define hidden void @fatal_error(i8* %msg, ...) #3 {
; CHECK-LABEL: fatal_error:
entry:
  %msg.addr = alloca i8*, align 8, addrspace(32)
  %valist = alloca [1 x %struct.__va_list_tag], align 16, addrspace(32)
  store i8* %msg, i8* addrspace(32)* %msg.addr, align 8
  %arraydecay = getelementptr inbounds [1 x %struct.__va_list_tag], [1 x %struct.__va_list_tag] addrspace(32)* %valist, i32 0, i32 0
  %0 = addrspacecast %struct.__va_list_tag addrspace(32)* %arraydecay to %struct.__va_list_tag*
  %1 = bitcast %struct.__va_list_tag* %0 to i8*
  call void @llvm.va_start(i8* %1)
; CHECK: leal -32(%rbp), %[[AP:.*]]
; CHECK: leaq -208(%rbp), %[[AP_END:.*]]
; CHECK: movq %[[AP_END]], 16(%[[AP]])
; CHECK: leaq 16(%rbp), %[[ARGS:.*]]
; CHECK: movq %[[ARGS]], 8(%[[AP]])
; CHECK: movl $48, 4(%[[AP]])
; CHECK: movl $8, (%[[AP]])
  %2 = load i8*, i8** @input_file_name, align 8
  %tobool = icmp ne i8* %2, null
  br i1 %tobool, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %3 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8
  %4 = load i8*, i8** @input_file_name, align 8
  %call = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %3, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.39, i32 0, i32 0), i8* %4)
  %5 = load i32, i32* @input_line, align 4
  %tobool1 = icmp ne i32 %5, 0
  br i1 %tobool1, label %if.then2, label %if.end

if.then2:                                         ; preds = %if.then
  %6 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8
  %7 = load i32, i32* @input_line, align 4
  %call3 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %6, i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.40, i32 0, i32 0), i32 %7)
  br label %if.end

if.end:                                           ; preds = %if.then2, %if.then
  %8 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8
  %call4 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %8, i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.41, i32 0, i32 0))
  br label %if.end6

if.else:                                          ; preds = %entry
  %9 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8
  %call5 = call i32 (%struct._IO_FILE*, i8*, ...) @fprintf(%struct._IO_FILE* %9, i8* getelementptr inbounds ([17 x i8], [17 x i8]* @.str.42, i32 0, i32 0))
  br label %if.end6

if.end6:                                          ; preds = %if.else, %if.end
  %10 = load %struct._IO_FILE*, %struct._IO_FILE** @stderr, align 8
  %11 = load i8*, i8* addrspace(32)* %msg.addr, align 8
  %arraydecay7 = getelementptr inbounds [1 x %struct.__va_list_tag], [1 x %struct.__va_list_tag] addrspace(32)* %valist, i32 0, i32 0
  %call8 = call i32 @vfprintf(%struct._IO_FILE* %10, i8* %11, %struct.__va_list_tag addrspace(32)* %arraydecay7)
  %arraydecay9 = getelementptr inbounds [1 x %struct.__va_list_tag], [1 x %struct.__va_list_tag] addrspace(32)* %valist, i32 0, i32 0
  %12 = addrspacecast %struct.__va_list_tag addrspace(32)* %arraydecay9 to %struct.__va_list_tag*
  %13 = bitcast %struct.__va_list_tag* %12 to i8*
  call void @llvm.va_end(i8* %13)
  call void @exit(i32 1) #6
  unreachable

return:                                           ; No predecessors!
  ret void
}

; Function Attrs: nounwind
declare void @llvm.va_start(i8*) #4

declare dso_local i32 @vfprintf(%struct._IO_FILE*, i8*, %struct.__va_list_tag addrspace(32)*) #1

; Function Attrs: nounwind
declare void @llvm.va_end(i8*) #4

; Function Attrs: noinline nounwind optnone uwtable
declare hidden i8* @xrealloc(i8*, i64) #3

; Function Attrs: noinline nounwind optnone uwtable
define hidden i8* @strmake(i8* %fmt, ...) #3 {
; CHECK-LABEL: strmake:
entry:
  %fmt.addr = alloca i8*, align 8, addrspace(32)
  %n = alloca i32, align 4, addrspace(32)
  %size = alloca i64, align 8, addrspace(32)
  %ap = alloca [1 x %struct.__va_list_tag], align 16, addrspace(32)
  %p = alloca i8*, align 8, addrspace(32)
  store i8* %fmt, i8* addrspace(32)* %fmt.addr, align 8
  store i64 100, i64 addrspace(32)* %size, align 8
  br label %for.cond

for.cond:                                         ; preds = %if.end12, %entry
  %0 = load i64, i64 addrspace(32)* %size, align 8
  %call = call i8* @xmalloc(i64 %0)
  store i8* %call, i8* addrspace(32)* %p, align 8
  %arraydecay = getelementptr inbounds [1 x %struct.__va_list_tag], [1 x %struct.__va_list_tag] addrspace(32)* %ap, i32 0, i32 0
  %1 = addrspacecast %struct.__va_list_tag addrspace(32)* %arraydecay to %struct.__va_list_tag*
  %2 = bitcast %struct.__va_list_tag* %1 to i8*
  call void @llvm.va_start(i8* %2)
; CHECK: leaq -240(%rbp), %[[AP_END:.*]]
; CHECK: movq %[[AP_END]], -48(%rbp)
; CHECK: leaq 16(%rbp), %[[ARGS:.*]]
; CHECK: movq %[[ARGS]], -56(%rbp)
; CHECK: movl $48, -60(%rbp)
; CHECK: movl $8, -64(%rbp)
  %3 = load i8*, i8* addrspace(32)* %p, align 8
  %4 = load i64, i64 addrspace(32)* %size, align 8
  %5 = load i8*, i8* addrspace(32)* %fmt.addr, align 8
  %arraydecay1 = getelementptr inbounds [1 x %struct.__va_list_tag], [1 x %struct.__va_list_tag] addrspace(32)* %ap, i32 0, i32 0
  %call2 = call i32 @vsnprintf(i8* %3, i64 %4, i8* %5, %struct.__va_list_tag addrspace(32)* %arraydecay1)
  store i32 %call2, i32 addrspace(32)* %n, align 4
  %arraydecay3 = getelementptr inbounds [1 x %struct.__va_list_tag], [1 x %struct.__va_list_tag] addrspace(32)* %ap, i32 0, i32 0
  %6 = addrspacecast %struct.__va_list_tag addrspace(32)* %arraydecay3 to %struct.__va_list_tag*
  %7 = bitcast %struct.__va_list_tag* %6 to i8*
  call void @llvm.va_end(i8* %7)
  %8 = load i32, i32 addrspace(32)* %n, align 4
  %cmp = icmp eq i32 %8, -1
  br i1 %cmp, label %if.then, label %if.else

if.then:                                          ; preds = %for.cond
  %9 = load i64, i64 addrspace(32)* %size, align 8
  %mul = mul i64 %9, 2
  store i64 %mul, i64 addrspace(32)* %size, align 8
  br label %if.end12

if.else:                                          ; preds = %for.cond
  %10 = load i32, i32 addrspace(32)* %n, align 4
  %conv = sext i32 %10 to i64
  %11 = load i64, i64 addrspace(32)* %size, align 8
  %cmp4 = icmp uge i64 %conv, %11
  br i1 %cmp4, label %if.then6, label %if.else8

if.then6:                                         ; preds = %if.else
  %12 = load i32, i32 addrspace(32)* %n, align 4
  %add = add nsw i32 %12, 1
  %conv7 = sext i32 %add to i64
  store i64 %conv7, i64 addrspace(32)* %size, align 8
  br label %if.end

if.else8:                                         ; preds = %if.else
  %13 = load i8*, i8* addrspace(32)* %p, align 8
  %14 = load i32, i32 addrspace(32)* %n, align 4
  %add9 = add nsw i32 %14, 1
  %conv10 = sext i32 %add9 to i64
  %call11 = call i8* @xrealloc(i8* %13, i64 %conv10)
  ret i8* %call11

if.end:                                           ; preds = %if.then6
  br label %if.end12

if.end12:                                         ; preds = %if.end, %if.then
  %15 = load i8*, i8* addrspace(32)* %p, align 8
  call void @free(i8* %15) #4
  br label %for.cond
}

declare dso_local i32 @vsnprintf(i8*, i64, i8*, %struct.__va_list_tag addrspace(32)*) #1

; Function Attrs: nounwind
declare dso_local void @free(i8*) #5

attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind }
attributes #5 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { noreturn nounwind }

