// RUN: %clang_cc1 -triple i686-windows-gnu -emit-llvm -o - %s \
// RUN:    | FileCheck %s --check-prefix=GNU32
// RUN: %clang_cc1 -triple i686-windows-gnu -emit-llvm -o - %s -mms-bitfields \
// RUN:    | FileCheck %s --check-prefix=GNU32
// RUN: %clang_cc1 -triple x86_64-windows-gnu -emit-llvm -o - %s \
// RUN:    | FileCheck %s --check-prefix=GNU64
// RUN: %clang_cc1 -triple x86_64-windows-msvc -emit-llvm -o - %s \
// RUN:    | FileCheck %s --check-prefix=MSC64

struct {
  char c;
  long double ldb;
} agggregate_LD = {};
// GNU32: %struct.anon = type { i8, x86_fp80 }
// GNU32: @agggregate_LD = dso_local global %struct.anon zeroinitializer, align 4
// GNU64: %struct.anon = type { i8, x86_fp80 }
// GNU64: @agggregate_LD = dso_local global %struct.anon zeroinitializer, align 16
// MSC64: %struct.anon = type { i8, double }
// MSC64: @agggregate_LD = dso_local global %struct.anon zeroinitializer, align 8

long double dataLD = 1.0L;
// GNU32: @dataLD = dso_local global x86_fp80 0xK3FFF8000000000000000, align 4
// GNU64: @dataLD = dso_local global x86_fp80 0xK3FFF8000000000000000, align 16
// MSC64: @dataLD = dso_local global double 1.000000e+00, align 8

long double _Complex dataLDC = {1.0L, 1.0L};
// GNU32: @dataLDC = dso_local global { x86_fp80, x86_fp80 } { x86_fp80 0xK3FFF8000000000000000, x86_fp80 0xK3FFF8000000000000000 }, align 4
// GNU64: @dataLDC = dso_local global { x86_fp80, x86_fp80 } { x86_fp80 0xK3FFF8000000000000000, x86_fp80 0xK3FFF8000000000000000 }, align 16
// MSC64: @dataLDC = dso_local global { double, double } { double 1.000000e+00, double 1.000000e+00 }, align 8

long double TestLD(long double x) {
  return x * x;
}
// GNU32: define dso_local x86_fp80 @TestLD(x86_fp80 %x)
// GNU64: define dso_local void @TestLD(x86_fp80* noalias sret %agg.result, x86_fp80*)
// MSC64: define dso_local double @TestLD(double %x)

long double _Complex TestLDC(long double _Complex x) {
  return x * x;
}
// GNU32: define dso_local void @TestLDC({ x86_fp80, x86_fp80 }* noalias sret %agg.result, { x86_fp80, x86_fp80 }* byval align 4 %x)
// GNU64: define dso_local void @TestLDC({ x86_fp80, x86_fp80 }* noalias sret %agg.result, { x86_fp80, x86_fp80 }* %x)
// MSC64: define dso_local void @TestLDC({ double, double }* noalias sret %agg.result, { double, double }* %x)

// GNU32: declare dso_local void @__mulxc3
// GNU64: declare dso_local void @__mulxc3
// MSC64: declare dso_local void @__muldc3

long double TestLDVA(long double x, ...) {
  __builtin_va_list ap;
  __builtin_va_start(ap, x);
  long double y = __builtin_va_arg(ap, long double);
  __builtin_va_end(ap);
  return x * y;
}
// GNU32-LABEL: define dso_local x86_fp80 @TestLDVA(x86_fp80 %x, ...)
// GNU64-LABEL: define dso_local void @TestLDVA(x86_fp80* noalias sret %agg.result, x86_fp80*, ...)
// GNU64: %[[AP:.*]] = alloca i8*
// GNU64: call void @llvm.va_start
// GNU64: %[[AP_CUR:.*]] = load i8*, i8** %[[AP]]
// GNU64-NEXT: %[[AP_NEXT:.*]] = getelementptr inbounds i8, i8* %[[AP_CUR]], i64 8
// GNU64-NEXT: store i8* %[[AP_NEXT]], i8** %[[AP]]
// GNU64-NEXT: %[[CUR:.*]] = bitcast i8* %[[AP_CUR]] to x86_fp80**
// GNU64-NEXT: load x86_fp80*, x86_fp80** %[[CUR]]
// MSC64-LABEL: define dso_local double @TestLDVA(double %x, ...)
