// RUN: %clang_cc1 -triple x86_64-apple-macosx10.13.0-wine32 -std=c11 -fsyntax-only -verify %s

#pragma clang ptr32_thunk_prefix("__foo")
#pragma clang ptr32_thunk_prefix("")

#pragma clang ptr32_thunk_prefix(goto)  // expected-warning{{expected string literal}}

#pragma clang ptr32_thunk_prefix(foo)  // expected-warning{{expected string literal}}

#pragma clang ptr32_thunk_prefix "__bar"  // expected-warning{{missing '(' after}}
#pragma clang ptr32_thunk_prefix("__baz"  // expected-warning{{missing ')' after}}
#pragma clang ptr32_thunk_prefix(  // expected-warning{{expected string literal}}

#pragma clang ptr32_thunk_prefix("__quux") foo  // expected-warning{{extra tokens at end}}

#pragma clang ptr32_cs32_name("__foo")
#pragma clang ptr32_cs32_name("")

#pragma clang ptr32_cs32_name(goto)  // expected-warning{{expected string literal}}

#pragma clang ptr32_cs32_name(foo)  // expected-warning{{expected string literal}}

#pragma clang ptr32_cs32_name "__bar"  // expected-warning{{missing '(' after}}
#pragma clang ptr32_cs32_name("__baz"  // expected-warning{{missing ')' after}}
#pragma clang ptr32_cs32_name(  // expected-warning{{expected string literal}}

#pragma clang ptr32_cs32_name("__quux") foo  // expected-warning{{extra tokens at end}}

#pragma clang ptr32_cs64_name("__foo")
#pragma clang ptr32_cs64_name("")

#pragma clang ptr32_cs64_name(goto)  // expected-warning{{expected string literal}}

#pragma clang ptr32_cs64_name(foo)  // expected-warning{{expected string literal}}

#pragma clang ptr32_cs64_name "__bar"  // expected-warning{{missing '(' after}}
#pragma clang ptr32_cs64_name("__baz"  // expected-warning{{missing ')' after}}
#pragma clang ptr32_cs64_name(  // expected-warning{{expected string literal}}

#pragma clang ptr32_cs64_name("__quux") foo  // expected-warning{{extra tokens at end}}
