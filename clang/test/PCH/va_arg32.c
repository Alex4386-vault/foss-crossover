// Test this without pch.
// RUN: %clang_cc1 -triple=x86_64-unknown-freebsd7.0-wine32 -include %S/va_arg32.h %s -emit-llvm-only
// REQUIRES: x86-registered-target

// Test with pch.
// RUN: %clang_cc1 -triple=x86_64-unknown-freebsd7.0-wine32 -emit-pch -o %t %S/va_arg32.h
// RUN: %clang_cc1 -triple=x86_64-unknown-freebsd7.0-wine32 -include-pch %t %s -emit-llvm-only

char *g0(char** argv, int argc) { return argv[argc]; }

char *g(char **argv) {
  f(g0, argv, 1, 2, 3);
}

char *i0(char **argv, int argc) { return argv[argc]; }

char *i(char **argv) {
  h(i0, argv, 1, 2, 3);
}

char *k0(char **argv, int argc) { return argv[argc]; }

char *k(char **argv) {
  j(k0, argv, 1, 2, 3);
}
