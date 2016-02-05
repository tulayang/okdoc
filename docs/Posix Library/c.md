
> restrict

> `restrict` 是 C语言中的一种类型限定符，是 C99 标准引入的，只可以用于限定和约束指针，用于告诉编译器：所有修改该指针指向内存的操作，都必须通过该指针来修改，而不能通过其它途径(其它变量或指针)修改。好处是，帮助编译器生成更有效率的代码。

```
int anums[10];
int *restrict ptr = (int *)malloc(10 * sizeof(int));
int *bnums = anums;
int i;

for(i = 0; i < 10; i++) {
    bnums[n] += 5;
    ptr[n] += 5;
    anums[n] *= 2;
    bnums[n] += 3;
    ptr[n] += 3;
}
```

> 上例中，`ptr[n] += 5;` 和 `ptr[n] += 3;` 会被编译器合并为 `ptr[n] += 8;`，而 `bnums[n] += 5;` 和 `bnums[n] += 3;` 无法合并，因为 `bnums` 指向的内存可以被 `bnums` 和 `anums` 修改，无法做到保护内存（而 `restrict` 确保了内存只能被一个唯一的指针修改）。
```

## GNU C

> GCC 提供的 C 语言风格也称为 GNU C 。在 20 世纪 90 年代，填补了 C 语言的一些空白，提供如复杂变量、零长度数组、内联函数和命名的初始化器等功能。但是，大约十年之后，C 语言得到全面升级，通过 ISO C99 和 ISO C11 标准后，GNU C 扩展变的不是那么重要尽管如此，GUN C 还是继续提供很多有用的功能，很多 Linux 编程人员依然使用 GNU C 的子集 --- 往往只是一两个扩展 --- 代码可以和 C99 或者 C11 兼容。

<span>

> inline

> 
```
  static inline int foo(int a, int b) { return a == b; }
```

> `static inline` 仅仅是向编译器提供内联建议，是否确实内联，还需要编译器决定。GCC 进一步提供了扩展，告诉编译器对给定的函数“总是”执行内联操作：
>
```
  static inline __attribute__ ((always_inline)) int foo(int a, int b) { return a == b; }
```

<span>

> 纯函数

> 纯函数的返回值只受函数参数或者 `nonvolatile` 全局变量影响。任何参数或者全局访问都值支持“只读模式”：
>
```
  __attribute__ ((pure)) int foo(int a) { return a + 1; }
```

<span>

> 常函数

> 常函数是一种严格的纯函数，不能访问全局变量，参数不能是指针类型：
>
```
  __attribute__ ((const)) int foo(int a) { return a + 1; }
```

<span>

> 没有返回值的函数

> 编译器可以对此进行一些优化：
>
```
  __attribute__ ((noreturn)) void foo(int a) { /* ... */ }
```

<span>

> 分配内存的函数

> 编译器可以对此进行一些优化：
>
```
  __attribute__ ((malloc)) void *foo(void) { return malloc(sizeof(int)); }
```

<span>

> 强制调用方检查返回值的函数
>
```
  __attribute__ ((warn_unused_result)) int foo(void) { /* ... */ }
```

<span>

> 把函数标识为“已废弃”
>
```
  __attribute__ ((deprecated)) int foo(void) { /* ... */ }
```

<span>

> 把函数标识为“已使用”
>
```
  __attribute__ ((used)) int foo(void) { /* ... */ }
```

<span>

> 把函数或参数标识为“未使用的”
>
```
  __attribute__ ((unused)) int foo(void) { /* ... */ }
```

<span>

> 对结构体进行紧凑存储

> 结构体的字段往往需要内存地址对齐，并使用字节填充技术。开启紧凑存储后，将不会进行字节填充，从而不会内存地址对齐，以消耗更少的内存。
>
```
  struct __attribute__ ((packed)) foo { char a; int b; }  // 8B => 5B
```

<span>

> 获取表达式类型
>
```
  #define max(a, b) ({         \
          typeof (a) _a = (a); \
          typeof (b) _b = (b); \
          _a > _b ? _a : _b;   \
  })
```


<span>

> 获取类型的对齐方式
>
```
  __alignof(int);  // 返回值依赖硬件架构，很可能是 4
```


<span>

> 结构体中成员变量的偏移

> GCC 提供内置的关键字，可以获取结构体成员变量的偏移。文件 `<stddef.h>` 中定义的宏 `offsetof()`，是 ISO C 标准的一部分。绝大多数定义很糟糕，涉及粗俗的指针算式算法，不适用于其他少数情况。GCC 扩展更简单，而且往往更快：
>
```
  #include <stddef.h>
  #define offsetof(type, member)  __builtin_offsetof(type, member
  )
```

> 在 Linux 系统中，`offset()` 宏应该通过 GCC 关键字来定义，而且不需要重新定义。

<span>

> 让代码可移植并且更优雅

```

// gnuc.h

#if __GNU_ _ >= 3
# undef  inline
# define inline         inline __attribute__ ((always_inline))
# define __noinline     __attribute__ ((noinline))
# define __pure         __attribute__ ((pure))
# define __const        __attribute__ ((const))
# define __noreturn     __attribute__ ((noreturn))
# define __malloc       __attribute__ ((malloc))
# define __must_check   __attribute__ ((warn_unused_result))
# define __deprecated   __attribute__ ((deprecated))
# define __used         __attribute__ ((used))
# define __unused       __attribute__ ((unused))
# define __packed       __attribute__ ((packed))
# define __align        __attribute__ ((aligned(x)))
# define __align_max    __attribute__ ((aligned))
# define likely(x)      __builtin_expect (!!(x), 1)
# define unlikely(x)    __builtin_expect (!!(x), 0)
#else
# define __noinline     /* no noinline */
# define __pure         /* no pure */
# define __const        /* no const */
# define __noreturn     /* no noreturn */
# define __malloc       /* no malloc */
# define __must_check   /* no warn_unused_result */
# define __deprecated   /* no deprecated */
# define __used         /* no used */
# define __unused       /* no unused */
# define __packed       /* no packed */
# define __align        /* no aligned */
# define __align_max    /* no align_max */
# define likely(x)      (x)
# define unlikely(x)    (x)
#endif
``` 

## 二进制操作

> 机器数值

> 数值在计算机中的二进制表示形式，称为这个数的“机器数值”。“机器数值”分为有符号和无符号两种。有符号的“机器数值”，其最高位用来存放正负符号，正数为 `0`，负数为 `1`。

> 比如，十进制数 +3，其“机器数值”是 00000011；十进制数 -3，其“机器数值”是 10000011。

<br />

> 原码

> 原码是“机器数值”的原始表示。

> 反码
>
```?
00000011原  =>  00000011反    # 正数的反码是其本身
10000011原  =>  11111100反    # 负数的反码是符号位不变，其它位取反
```

> 补码
>
```?
00000011原  =>  00000011反  =>  00000011补  # 正数的补码是其本身
10000011原  =>  11111100反  =>  11111101补  # 负数的反码是符号位不变，其它位取反，然后 + 1
```

> 二进制运算
>
```?
# 当符号位参与计算时，会得到错误的结果
1 - 1 = 0 
      = 1          + (-1) 
      = 00000001原 + 10000001原 
      = 10000010原 
      = -2
>
# 因此，需要（对负数）使用反码
# 但是会得到 00000000 和 10000000 两种 0
1 - 1 = 0 
      = 1          + (-1) 
      = 00000001原 + 10000001原 
      = 00000001反 + 11111110反 
      = 11111111反 
      = 10000000原 
      = -0
>
# 为此，进一步使用补码，解决 0 的符号问题
1 - 1 = 0 
      = 1          + (-1) 
      = 00000001原 + 10000001原 
      = 00000001反 + 11111110反
      = 00000001补 + 11111111补 
      = 00000000补
      = 00000000原
      = 0
>
# 00000000 作为 0    表示
# 10000000 作为 -128 表示
```

> 在计算机中，负数是用补码表示的。因此 
>
```c
int x = -20;  # 100...10100原 => 111..101011 反 => 111..101100补
int y = ~x;   # => 000...10011反 => 000...10011原 => 19
```