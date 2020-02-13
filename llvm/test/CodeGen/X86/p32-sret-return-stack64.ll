; RUN: llc -mtriple=x86_64-apple-darwin8-wine32sp64 < %s | FileCheck %s
; RUN: llc -mtriple=x86_64-pc-linux-wine32sp64 < %s | FileCheck %s

%struct.foo = type { [4 x i64] }

@baz = external global %struct.foo addrspace(32)*

; CHECK-LABEL: bar:
; CHECK-DAG: movl %esi, -4(%rsp)
; FIXME: Operationally, it doesn't matter, since 32-bit loads and stores are
; zero-extended anyway, but we could make this a byte shorter by emitting a
; 32-bit move.
; CHECK-DAG: movq %rdi, %rax

define void @bar(%struct.foo* noalias sret  %agg.result, %struct.foo addrspace(32)* %d) nounwind  {
entry:
	%d_addr = alloca %struct.foo addrspace(32)*	; <%struct.foo**> [#uses=2]
	%"alloca point" = bitcast i32 0 to i32		; <i32> [#uses=0]
	store %struct.foo addrspace(32)* %d, %struct.foo addrspace(32)** %d_addr
	%tmp = load %struct.foo addrspace(32)*, %struct.foo addrspace(32)** %d_addr, align 4		; <%struct.foo*> [#uses=1]
    %memtmp = load %struct.foo addrspace(32)*, %struct.foo addrspace(32)** @baz, align 4
	%tmp1 = getelementptr %struct.foo, %struct.foo* %agg.result, i32 0, i32 0		; <[4 x i64]*> [#uses=4]
	%tmp2 = getelementptr %struct.foo, %struct.foo addrspace(32)* %tmp, i32 0, i32 0		; <[4 x i64]*> [#uses=4]
	%tmp3 = getelementptr [4 x i64], [4 x i64]* %tmp1, i32 0, i32 0		; <i64*> [#uses=1]
	%tmp4 = getelementptr [4 x i64], [4 x i64] addrspace(32)* %tmp2, i32 0, i32 0		; <i64*> [#uses=1]
	%tmp5 = load i64, i64 addrspace(32)* %tmp4, align 8		; <i64> [#uses=1]
	store i64 %tmp5, i64* %tmp3, align 8
	%tmp6 = getelementptr [4 x i64], [4 x i64]* %tmp1, i32 0, i32 1		; <i64*> [#uses=1]
	%tmp7 = getelementptr [4 x i64], [4 x i64] addrspace(32)* %tmp2, i32 0, i32 1		; <i64*> [#uses=1]
	%tmp8 = load i64, i64 addrspace(32)* %tmp7, align 8		; <i64> [#uses=1]
	store i64 %tmp8, i64* %tmp6, align 8
	%tmp9 = getelementptr [4 x i64], [4 x i64]* %tmp1, i32 0, i32 2		; <i64*> [#uses=1]
	%tmp10 = getelementptr [4 x i64], [4 x i64] addrspace(32)* %tmp2, i32 0, i32 2		; <i64*> [#uses=1]
	%tmp11 = load i64, i64 addrspace(32)* %tmp10, align 8		; <i64> [#uses=1]
	store i64 %tmp11, i64* %tmp9, align 8
	%tmp12 = getelementptr [4 x i64], [4 x i64]* %tmp1, i32 0, i32 3		; <i64*> [#uses=1]
	%tmp13 = getelementptr [4 x i64], [4 x i64] addrspace(32)* %tmp2, i32 0, i32 3		; <i64*> [#uses=1]
	%tmp14 = load i64, i64 addrspace(32)* %tmp13, align 8		; <i64> [#uses=1]
	store i64 %tmp14, i64* %tmp12, align 8
	%tmp15 = getelementptr %struct.foo, %struct.foo addrspace(32)* %memtmp, i32 0, i32 0		; <[4 x i64]*> [#uses=4]
	%tmp16 = getelementptr %struct.foo, %struct.foo* %agg.result, i32 0, i32 0		; <[4 x i64]*> [#uses=4]
	%tmp17 = getelementptr [4 x i64], [4 x i64] addrspace(32)* %tmp15, i32 0, i32 0		; <i64*> [#uses=1]
	%tmp18 = getelementptr [4 x i64], [4 x i64]* %tmp16, i32 0, i32 0		; <i64*> [#uses=1]
	%tmp19 = load i64, i64* %tmp18, align 8		; <i64> [#uses=1]
	store i64 %tmp19, i64 addrspace(32)* %tmp17, align 8
	%tmp20 = getelementptr [4 x i64], [4 x i64] addrspace(32)* %tmp15, i32 0, i32 1		; <i64*> [#uses=1]
	%tmp21 = getelementptr [4 x i64], [4 x i64]* %tmp16, i32 0, i32 1		; <i64*> [#uses=1]
	%tmp22 = load i64, i64* %tmp21, align 8		; <i64> [#uses=1]
	store i64 %tmp22, i64 addrspace(32)* %tmp20, align 8
	%tmp23 = getelementptr [4 x i64], [4 x i64] addrspace(32)* %tmp15, i32 0, i32 2		; <i64*> [#uses=1]
	%tmp24 = getelementptr [4 x i64], [4 x i64]* %tmp16, i32 0, i32 2		; <i64*> [#uses=1]
	%tmp25 = load i64, i64* %tmp24, align 8		; <i64> [#uses=1]
	store i64 %tmp25, i64 addrspace(32)* %tmp23, align 8
	%tmp26 = getelementptr [4 x i64], [4 x i64] addrspace(32)* %tmp15, i32 0, i32 3		; <i64*> [#uses=1]
	%tmp27 = getelementptr [4 x i64], [4 x i64]* %tmp16, i32 0, i32 3		; <i64*> [#uses=1]
	%tmp28 = load i64, i64* %tmp27, align 8		; <i64> [#uses=1]
	store i64 %tmp28, i64 addrspace(32)* %tmp26, align 8
	br label %return

return:		; preds = %entry
	ret void
}

; CHECK-LABEL: foo:
; CHECK: movl %edi, %eax

define void @foo({ i64 } addrspace(32)* noalias nocapture sret %agg.result) nounwind {
  store { i64 } { i64 0 }, { i64 } addrspace(32)* %agg.result
  ret void
}
