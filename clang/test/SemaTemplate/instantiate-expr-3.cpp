// RUN: %clang_cc1 -triple x86_64-unknown-unknown-wine32 -fsyntax-only -verify %s

// ---------------------------------------------------------------------
// Imaginary literals
// ---------------------------------------------------------------------
template<typename T>
struct ImaginaryLiteral0 {
  void f(T &x) {
    x = 3.0I; // expected-error{{incompatible type}}
  }
};

template struct ImaginaryLiteral0<_Complex float>;
template struct ImaginaryLiteral0<int*>; // expected-note{{instantiation}}

// ---------------------------------------------------------------------
// Compound assignment operator
// ---------------------------------------------------------------------
namespace N1 {
  struct X { };

  int& operator+=(X&, int); // expected-note{{candidate}}
}

namespace N2 {
  long& operator+=(N1::X&, long); // expected-note{{candidate}}

  template<typename T, typename U, typename Result>
  struct PlusEquals0 {
    void f(T t, U u) {
      Result r = t += u; // expected-error{{ambiguous}}
    }
  };
}

namespace N3 {
  struct Y : public N1::X {
    short& operator+=(long); // expected-note{{candidate}}
  };
}

template struct N2::PlusEquals0<N1::X, int, int&>;
template struct N2::PlusEquals0<N1::X, long, long&>;
template struct N2::PlusEquals0<N3::Y, long, short&>;
template struct N2::PlusEquals0<int, int, int&>;
template struct N2::PlusEquals0<N3::Y, int, short&>; // expected-note{{instantiation}}

// ---------------------------------------------------------------------
// Conditional operator
// ---------------------------------------------------------------------
template<typename T, typename U, typename Result>
struct Conditional0 {
  void f(T t, U u) {
    Result result = t? : u;
  }
};

template struct Conditional0<int, int, int>;

// ---------------------------------------------------------------------
// Statement expressions
// ---------------------------------------------------------------------
template<typename T>
struct StatementExpr0 {
  void f(T t) {
    (void)({
        if (t) // expected-error{{contextually convertible}}
          t = t + 17;
        t + 12; // expected-error{{invalid operands}}
      });
  }
};

template struct StatementExpr0<int>;
template struct StatementExpr0<N1::X>; // expected-note{{instantiation}}

// ---------------------------------------------------------------------
// __builtin_choose_expr
// ---------------------------------------------------------------------
template<bool Cond, typename T, typename U, typename Result>
struct Choose0 {
  void f(T t, U u) {
    Result r = __builtin_choose_expr(Cond, t, u); // expected-error{{lvalue}}
  }
};

template struct Choose0<true, int, float, int&>;
template struct Choose0<false, int, float, float&>;
template struct Choose0<true, int, float, float&>; // expected-note{{instantiation}}

// ---------------------------------------------------------------------
// __builtin_va_arg
// ---------------------------------------------------------------------
template<typename ArgType>
struct VaArg0 {
  void f(int n, ...) {
    __builtin_va_list va;
    __builtin_va_start(va, n);
    for (int i = 0; i != n; ++i)
      (void)__builtin_va_arg(va, ArgType);
    __builtin_va_end(va);
  }
};

template struct VaArg0<int>;

template<typename VaList, typename ArgType>
struct VaArg1 {
  void f(int n, ...) {
    VaList va;
    __builtin_va_start(va, n); // expected-error{{int}} expected-error{{char *}} expected-error{{__va_list32 *}}
    for (int i = 0; i != n; ++i)
      (void)__builtin_va_arg(va, ArgType); // expected-error{{int}}
    __builtin_va_end(va); // expected-error{{int}} expected-error{{char *}} expected-error{{__va_list32 *}}
  }
};

template struct VaArg1<__builtin_va_list, int>;
template struct VaArg1<__builtin_ms_va_list, int>; // expected-note{{instantiation}}
template struct VaArg1<__builtin_va_list32, int>; // expected-note{{instantiation}}
template struct VaArg1<int, int>; // expected-note{{instantiation}}

template<typename ArgType>
struct VaArg2 {
  void __attribute__((ms_abi)) f(int n, ...) {
    __builtin_ms_va_list va;
    __builtin_ms_va_start(va, n);
    for (int i = 0; i != n; ++i)
      (void)__builtin_va_arg(va, ArgType);
    __builtin_ms_va_end(va);
  }
};

template struct VaArg2<int>;

template<typename VaList, typename ArgType>
struct VaArg3 {
  void __attribute__((ms_abi)) f(int n, ...) {
    VaList va;
    __builtin_ms_va_start(va, n); // expected-error{{int}} expected-error{{__va_list_tag}} expected-error{{__va_list32 *}}
    for (int i = 0; i != n; ++i)
      (void)__builtin_va_arg(va, ArgType); // expected-error{{int}}
    __builtin_ms_va_end(va); // expected-error{{int}} expected-error{{__va_list_tag}} expected-error{{__va_list32 *}}
  }
};

template struct VaArg3<__builtin_ms_va_list, int>;
template struct VaArg3<__builtin_va_list, int>; // expected-note{{instantiation}}
template struct VaArg3<__builtin_va_list32, int>; // expected-note{{instantiation}}
template struct VaArg3<int, int>; // expected-note{{instantiation}}

template<typename ArgType>
struct VaArg4 {
  void __attribute__((cdecl32)) f(int n, ...) {
    __builtin_va_list32 va;
    __builtin_va_start32(va, n);
    for (int i = 0; i != n; ++i)
      (void)__builtin_va_arg(va, ArgType);
    __builtin_va_end32(va);
  }
};

template struct VaArg4<int>;

template<typename VaList, typename ArgType>
struct VaArg5 {
  void __attribute__((cdecl32)) f(int n, ...) {
    VaList va;
    __builtin_va_start32(va, n); // expected-error{{int}} expected-error{{__va_list_tag}} expected-error{{char *}}
    for (int i = 0; i != n; ++i)
      (void)__builtin_va_arg(va, ArgType); // expected-error{{int}}
    __builtin_va_end32(va); // expected-error{{int}} expected-error{{__va_list_tag}} expected-error{{char *}}
  }
};

template struct VaArg5<__builtin_va_list32, int>;
template struct VaArg5<__builtin_va_list, int>; // expected-note{{instantiation}}
template struct VaArg5<__builtin_ms_va_list, int>; // expected-note{{instantiation}}
template struct VaArg5<int, int>; // expected-note{{instantiation}}
