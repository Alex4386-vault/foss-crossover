// RUN: %clang_cc1 -triple x86_64-linux-wine32 -emit-llvm -o - %s | FileCheck %s

void *memcpy(void *dest, const void *src, __SIZE_TYPE__ len);
void *memmove(void *dest, const void *src, __SIZE_TYPE__ len);
void *memset(void *dest, int v, __SIZE_TYPE__ len);

void foo(const char *src) {
  char dest[16];
  char *p;
  // CHECK: %{{.*}} = alloca i8*, align 8, addrspace(32)
  // CHECK: %[[P:.*]] = alloca i8*, align 8, addrspace(32)

  p = memcpy(dest, src, 16);
  // CHECK: call void @llvm.memcpy.p32i8.p0i8.i64(i8 addrspace(32)* align 16 %[[DEST:[^,]*]],
  // CHECK: %[[TMP:[0-9]+]] = addrspacecast i8 addrspace(32)* %[[DEST]] to i8*
  // CHECK: store i8* %[[TMP]], i8* addrspace(32)* %[[P]]
  p = memmove(dest, src, 16);
  // CHECK: call void @llvm.memmove.p32i8.p0i8.i64(i8 addrspace(32)* align 16 %[[DEST:[^,]*]],
  // CHECK: %[[TMP:[0-9]+]] = addrspacecast i8 addrspace(32)* %[[DEST]] to i8*
  // CHECK: store i8* %[[TMP]], i8* addrspace(32)* %[[P]]
  p = memset(dest, 0xcc, 16);
  // CHECK: call void @llvm.memset.p32i8.i64(i8 addrspace(32)* align 16 %[[DEST:[^,]*]],
  // CHECK: %[[TMP:[0-9]+]] = addrspacecast i8 addrspace(32)* %[[DEST]] to i8*
  // CHECK: store i8* %[[TMP]], i8* addrspace(32)* %[[P]]

  p = __builtin___memcpy_chk(dest, src, 16, __builtin_object_size(dest, 0));
  // CHECK: call void @llvm.memcpy.p32i8.p0i8.i64(i8 addrspace(32)* align 16 %[[DEST:[^,]*]],
  // CHECK: %[[TMP:[0-9]+]] = addrspacecast i8 addrspace(32)* %[[DEST]] to i8*
  // CHECK: store i8* %[[TMP]], i8* addrspace(32)* %[[P]]
  p = __builtin___memmove_chk(dest, src, 16, __builtin_object_size(dest, 0));
  // CHECK: call void @llvm.memmove.p32i8.p0i8.i64(i8 addrspace(32)* align 16 %[[DEST:[^,]*]],
  // CHECK: %[[TMP:[0-9]+]] = addrspacecast i8 addrspace(32)* %[[DEST]] to i8*
  // CHECK: store i8* %[[TMP]], i8* addrspace(32)* %[[P]]
  p = __builtin___memset_chk(dest, 0xcc, 16, __builtin_object_size(dest, 0));
  // CHECK: call void @llvm.memset.p32i8.i64(i8 addrspace(32)* align 16 %[[DEST:[^,]*]],
  // CHECK: %[[TMP:[0-9]+]] = addrspacecast i8 addrspace(32)* %[[DEST]] to i8*
  // CHECK: store i8* %[[TMP]], i8* addrspace(32)* %[[P]]
}
