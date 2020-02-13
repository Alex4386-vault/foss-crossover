// RUN: %clang_cc1 -E -ilocal %S/Inputs %s | FileCheck %s

#include "test.h"
// CHECK: # 1 "{.*}test.h" 1 5
// CHECK: # 4 "{.*}ilocal.c" 2 5

# 32 "foo.c" 1 5
// CHECK: # 32 "foo.c" 1 5

