// RUN: %clang -fsyntax-only -I%S/Inputs/ilocal_before_I -ilocal %S/Inputs %s -Xclang -verify
// expected-no-diagnostics

#include <test.h>
