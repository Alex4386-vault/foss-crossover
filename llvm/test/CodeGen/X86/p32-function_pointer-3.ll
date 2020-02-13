; RUN: llc < %s -mtriple=x86_64-linux-wine32 | FileCheck %s
; RUN: llc < %s -mtriple=x86_64-linux-wine32 -fast-isel | FileCheck %s

; Test calling function pointer passed in struct

;    The function argument `h' in

;    struct foo {
;      void (* __ptr32 f) (void);
;      int i;
;    };
;    void
;    bar (struct foo h)
;    {
;      h.f ();
;    }

;    is passed in the 64-bit %rdi register.  The `f' field is in the lower 32
;    bits of %rdi register and the `i' field is in the upper 32 bits of %rdi
;    register.

%foo = type { [6 x i64] }

define void @bar(i64 %h.coerce) #1 {
entry:
  %td = alloca %foo, align 8, addrspace(32)
  %h.sroa.0.0.extract.trunc = trunc i64 %h.coerce to i32
  %0 = inttoptr i32 %h.sroa.0.0.extract.trunc to void (%foo addrspace(32)*)*
  tail call x86_64_c32cc addrspace(32) void %0(%foo addrspace(32)* thunkdata %td) nounwind
; CHECK-LABEL: bar:
; CHECK: movq	%rdi, 8(%eax)
; CHECK: callq	__wine32_invoke32_0
  ret void
}

; CHECK-LABEL: __wine32_invoke32_0:
; CHECK: cmpw __wine32_cs64, %r8w
; CHECK: movw __wine32_cs32, %r9w
; CHECK: callq *8(%rbx)

attributes #1 = { nounwind "thunk-prefix"="__wine32" "thunk-cs32-name"="__wine32_cs32" "thunk-cs64-name"="__wine32_cs64" }
