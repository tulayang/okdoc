# [流，格式化输出](https://www.gnu.org/software/libc/manual/html_node/Formatted-Output.html#Formatted-Output)

本节描述如何通过流格式化输出。比如，你可以使用 `printf()` 函数，指定字符串模板，它进行格式转换后，打印结果。

> 译注：本节例子中，打印结果的 | 只是个范围标记，并不包含在结果值中。比如 
> ```?
|   +1|
```
> 表示长度是 5，值是 +1。

## 从基础开始

调用 `printf()` 函数时，需要指定一个模板字符串参数，以及任意数量的参数。它执行格式化后，把结果打印到标准输出。模板字符串使用包含 % 的占位符，来格式化对应的参数，例子：

```c
int pct = 37;
char filename[] = "foo.txt";
printf ("Processing of `%s' is %d%% finished.\nPlease be patient.\n", filename, pct);
```

上面的例子会打印：

```?
Processing of `foo.txt' is 37% finished.
Please be patient.
```

这个例子演示了使用 `%s` 转换一个字符串参数，`%d` 来转换一个 `int` 参数，`%%` 则打印一个 '%'。

你也可以指定占位符，把整数值打印成八进制（`%o`）、十进制（`%u`）、十六进制（`%x`），或者是一个字符值（`%c`）。

浮点数也可以正确打印，使用 `%f` 或 `%e` 打印定点计数法表示的浮点数。

## 占位符语法

这里描述下 `printf()` 中模板字符串的转换语法的具体细节。

模板字符串的字符，不属于转换语法的，原样输出。此外，多字节字符序列可以出现在模板字符串。

占位符的转换语法如下：

```?
% [ param-no $] flags width [ . precision ] type conversion
```

或

```?
% [ param-no $] flags width . * [ param-no $] type conversion
```

举个例子，`%-10.8ld`，`-` 是 flag，`10` 是 width，`8` 是 precision，`ld` 是 type conversion（`l` 是类型修饰符，`d` 是转换风格）。

## 占位符汇总

这里有一个汇总，详细列出了所有不同的占位符：

* `%d`，`%i` 打印一个整数，以有符号十进制数字表示。用作输出时，`%d` 和 `%i` 是同义，用做输入是则是不同的。

* `%o`、 打印一个整数，以无符号八进制数字表示。

* `%u` 打印一个整数，以无符号十进制数字表示。

* `%x`，`%X` 打印一个整数，以无符号十六进制数字表示。`%X` 用大写 `ABCDEF` 表示，`%x` 用小写表示。

* `%f` 打印一个浮点数，以正常形态表示。

* `%e`、`%E` 打印一个浮点数，以指数形态表示。

* `%g`、`%G` 打印一个浮点数，以正常形态或指数形态表示，由给出的值决定。

* `%a`、`%A` 打印一个浮点数，以十六进制表示。

* `%c` 打印一个字符。

* `%C` 这是 `%lc` 的别名，用于兼容 Unix 标准。

* `%s` 打印一个字符串。

* `%S` 这是 `%lS` 的别名，用于兼容 Unix 标准。

* `%p` 打印一个指针的值。

* `%n` 获取当前打印的字符数。

* `%m` 打印 `errno` 值对应的字符串消息。

* `%%` 打印一个 `'%'` 字符。

如果没有足够的参数以匹配模板字符串参数的占位符，或者参数的类型不正确，那么结果值是不可预料的；如果提供的参数超过了占位符的数量，多余的会被忽略。

## 整数规则

`%d` 和 `%i` 打印 `int` 参数，以有符号十进制数字表示；`%o`、`%u`、`%x` 打印 `int` 参数，以无符号八进制、无符号十进制、无符号十六进制表示。

相关的 flag 有：

* `-` 左对齐结果（取代默认的右对齐）。

* `+` 用于 `%d` 和 `%i`，如果值是正数，结果值使用 + 作为前缀。

* `空格` 用于 `%d` 和 `%i`，如果结果值没有正号或负号前缀，用一个空格作为前缀。

* `#` 用于 `%o`，结果值使用 0 作为前缀。用于 `%x`、`%X`，结果值使用 0x、0X 作为前缀。

* `'` Separate the digits into groups as specified by the locale specified for the LC_NUMERIC category。这是一个 GNU 扩展。

* `0` 使用 0 而不是空格填充空余。

如果指定了精度，则包含小数位后最小的数量。如果不指定精度，则打印尽可能需要的精度。

当没有类型修饰符时，其参数被认为是 `int` 或 `unsigned int`，如果你传入的是 `char` 或 `short`，会自动转换为 `int`。你可以使用如下的修饰符：

* `hh` 指定参数是 `signed char` 或 `unsigned char`，由具体值决定。默认情况下，`char` 参数被转换为 `int` 或 `unsigned int`，但是 `hh` 可以将其再次转换为 `char`。这个修饰符由 ISO C99 引入。

* `h` 指定参数是 `short int` 或 `unsigned short int`，由具体值决定。默认情况下，`short` 参数被转换为 `int` 或 `unsigned int`，但是 `h` 可以将其再次转换为 `short`。

* `j` 指定参数是 `intmax_t` 或 `uintmax_t`，由具体值决定。这个修饰符由 ISO C99 引入。

* `l` 指定参数是 `long int` 或 `unsigned long int`，由具体值决定。这个修饰符由 ISO C90 修订稿 引入。

* `L`、`ll`、`q` 指定参数是 `long long int`（这个类型是 GNU C 编译器的扩展，对于不支持的系统，它等同于 `long int`）。`q` 来自于 4.4 BSD。

* `t` 指定参数是 `ptrdiff_t`。这个修饰符由 ISO C99 引入。

* `z`、`Z` 指定参数是 `size_t`。`z` 由 ISO C99 引入。`Z` 是 GNU 早期的扩展，你不应该在你新的代码中继续使用。

这儿有个例子，演示如何使用模板字符串打印整数：

```c
"|%5d|%-5d|%+5d|%+-5d|% 5d|%05d|%5.0d|%5.2d|%d|\n"
```

其输出结果类似这样：

```?
|    0|0    |   +0|+0   |    0|00000|     |   00|0|
|    1|1    |   +1|+1   |    1|00001|    1|   01|1|
|   -1|-1   |   -1|-1   |   -1|-0001|   -1|  -01|-1|
|100000|100000|+100000|+100000| 100000|100000|100000|100000|100000|
```

这儿有个例子，演示无符号整数的打印：

```c
"|%5u|%5o|%5x|%5X|%#5o|%#5x|%#5X|%#10.8x|\n"
```

其输出结果类似这样：

```?
|    0|    0|    0|    0|    0|    0|    0|  00000000|
|    1|    1|    1|    1|   01|  0x1|  0X1|0x00000001|
|100000|303240|186a0|186A0|0303240|0x186a0|0X186A0|0x000186a0|
```

## 浮点数规则

`%f` 打印浮点数，以点数形态表示，输出结果类似 [-]ddd.ddd 。

`%e` 打印浮点数，以指数形态表示，输出结果类似 [-]d.ddd<sub>e</sub>[+|-]dd 。

`%g`、`%G` 打印一个浮点数，以正常形态或指数形态表示，由给出的值决定。

`%a`、`%A` 打印一个浮点数，以十六进制表示。

相关的 flag 有：

* `-` 左对齐结果（取代默认的右对齐）。

* `+` 总是在结果包含 + 或 - 前缀。

* `空格` 如果结果值没有正号或负号前缀，用一个空格作为前缀。

* `#` Specifies that the result should always include a decimal point, even if no digits follow it. For the `%g` and `%G` conversions, this also forces trailing zeros after the decimal point to be left in place where they would otherwise be removed. 

* `'` Separate the digits of the integer part of the result into groups as specified by the locale specified for the LC_NUMERIC category。这是一个 GNU 扩展。

* `0` 使用 0 而不是空格填充空余。

当没有类型修饰符时，其参数被认为是 `double`（任何传入的 `float` 参数，会自动转换为 `double`）。你可以使用如下的修饰符：

* `L` 指定参数是 `long double`。

这儿有个例子，演示如何使用模板字符串打印浮点数：

```c
"|%13.4a|%13.4f|%13.4e|%13.4g|\n"
```

其输出结果类似这样：

```?
|  0x0.0000p+0|       0.0000|   0.0000e+00|            0|
|  0x1.0000p-1|       0.5000|   5.0000e-01|          0.5|
|  0x1.0000p+0|       1.0000|   1.0000e+00|            1|
| -0x1.0000p+0|      -1.0000|  -1.0000e+00|           -1|
|  0x1.9000p+6|     100.0000|   1.0000e+02|          100|
|  0x1.f400p+9|    1000.0000|   1.0000e+03|         1000|
| 0x1.3880p+13|   10000.0000|   1.0000e+04|        1e+04|
| 0x1.81c8p+13|   12345.0000|   1.2345e+04|    1.234e+04|
| 0x1.86a0p+16|  100000.0000|   1.0000e+05|        1e+05|
| 0x1.e240p+16|  123456.0000|   1.2346e+05|    1.235e+05| 
```

## 其他规则

`%c` 打印一个字符。如果传入 `int` 参数，会转换为 `unsigned char`。当使用宽字符流时，也会转换为相应的宽字符。`-` 可以指定结果值是左对齐的。此外，没有其他的 flag，不能指定精度，也没有类型修饰符可用。例子：

```c
printf ("%c%c%c%c%c", 'h', 'e', 'l', 'l', 'o');
```

打印 

```?
|hello|
```

`%lc` 打印一个宽字符，它期望参数是 `wint_t`。

`%s` 打印一个字符串。如果没有 `l` 修饰符，则参数必须是 `char *` 或 `const char *`。当使用宽字符流时，也会转换为相应的宽字符串。可以指定精度，表明写入的最大字符数；否则，写入所有的字符，但是不包括终止符。`-` 可以指定结果值左对齐。没有其他的 flag 或类型修饰符可用。例子：

```c
printf ("%3s%-6s", "no", "where");
```

打印 

```?
|nowhere |
```

`%lS` 打印一个宽字符串，它期望参数是 `wchar_t *` 或 `const wchar_t *`。

如果你对 `%s` 传入一个空指针，GNU C 库会打印为 (null)。我们觉得比让程序崩溃更有意义。但是，故意传入空指针，可不是优秀程序员该干的事。

`%m` 打印一个 `errno` 值对应的字符串信息。例子：

```c
fprintf(stderr, "can't open `%s': %m\n", filename);
```

等价于    

```c
fprintf(stderr, "can't open `%s': %s\n", filename, strerror (errno));
```

> `%m` 是一个 GNU 扩展。

`%p` 打印一个指针值。对应的参数必须是 `void *` 类型。事实上，你可以用任意类型的指针。

在 GNU C 库，非空指针打印为无符号整数，空指针打印为 (nil)。（在其他系统，可能会有不同）。例子：

```c
printf("%p", "testing");
```

打印一个 0x 为前缀的十六进制数字--- 字符串常量 `"testing"` 的地址。

你可以指定 `-` 使结果值左对齐。没有其他的 flag、精度或类型修饰符可用。

`%n` 和其他占位符不同，它要求对应的参数必须是 `int *` 指针，不会打印参数，而是把当前已经打印的字符数存储到指针。`h` 和 `l` 类型修饰符可以指定 `shor int *`、`long int *`。没有其他的 flag、精度或类型修饰符可用。例子：          

```c
int n;
printf("%d %s%n\n", 3, "bears", &n);
``` 

打印

```?
|3 bears|
```

并且修改 `n` 为 `7`。

`%%` 打印一个 `%` 字符，不需要对应参数。没有其他的 flag、精度或类型修饰符可用。

## 格式化输出

###: #include &lt;stdio.h&gt;

```c
#include <stdio.h>
```

###: printf()

```c
int printf(const char *template, …);
```

* Preliminary: | MT-Safe locale | AS-Unsafe corrupt heap | AC-Unsafe mem lock corrupt |
* Function

`printf()` 函数通过流 `stdout` 打印模板字符串 `template` 及其后面的参数。

执行成功返回打印的字符数；出错返回一个负数。

###: wprintf()

```c
int wprintf(const wchar_t *template, …);
```

* Preliminary: | MT-Safe locale | AS-Unsafe corrupt heap | AC-Unsafe mem lock corrupt |
* Function

`wprintf()` 函数通过流 `stdout` 打印模板字符串 `template` 及其后面的参数。

执行成功返回打印的宽字符数；出错返回一个负数。

###: fprintf()

```c
int fprintf(FILE *stream, const char *template, …);
```

* Preliminary: | MT-Safe locale | AS-Unsafe corrupt heap | AC-Unsafe mem lock corrupt |
* Function

`fprintf()` 函数通过流 `stream` 打印模板字符串 `template` 及其后面的参数。

执行成功返回打印的字符数；出错返回一个负数。

###: fwprintf()

```c
int fwprintf(FILE *stream, const wchar_t *template, …);
```

* Preliminary: | MT-Safe locale | AS-Unsafe corrupt heap | AC-Unsafe mem lock corrupt |
* Function

`fwprintf()` 函数通过流 `stdout` 打印模板字符串 `template` 及其后面的参数。

执行成功返回打印的宽字符数；出错返回一个负数。

###: sprintf()

```c
int sprintf(char *s, const char *template, …);
```

* Preliminary: | MT-Safe locale | AS-Unsafe heap | AC-Unsafe mem |
* Function

`sprintf()` 函数把模板字符串 `template` 及其后面的参数，存储到 `s`，最后添加一个终止符。

执行成功返回存储的字符数，不包含终止符；出错返回一个负数。

如果复制的对象之间存在重叠，其结果是不可知的。比如，`s` 也作为要打印的参数：`sprintf(s, "hello %s", s)`。

> 警告：当你使用 `sprintf()` 函数必须规避风险，它可能会输出比 `s` 的内存空间还要多的字符。为避免这个问题，你可以使用下面描述的 `snprintf()` 或
 `asprintf()`。

###: swprintf()

```c
int swprintf(wchar_t *ws, size_t size, const wchar_t *template, …);
```

* Preliminary: | MT-Safe locale | AS-Unsafe heap | AC-Unsafe mem | 
* Function

`swprintf()` 函数把模板字符串 `template` 及其后面的参数，存储到 `ws`。最后添加一个宽终止符。`size` 指定结果字符数量上限。尾部终止符会被计算在内，因此，你应该为 `ws` 分配至少 `size` 个宽字符。

执行成功返回生成的字符数，不包含终止符，如果大于等于 `size`，那么不是所有的宽字符都被存储到 `s`，你应该换用大一点的宽字符串缓冲区；出错返回一个负数。

###: snprintf()

```c
int snprintf(char *s, size_t size, const char *template, …);
```

* Preliminary: | MT-Safe locale | AS-Unsafe heap | AC-Unsafe mem | 
* Function

`snprintf()` 函数把模板字符串 `template` 及其后面的参数，存储到 `s`，最后添加一个终止符。`size` 指定结果字符数量上限。尾部终止符会被计算在内，因此，你应该为 `s` 分配至少 `size` 个字符。如果 `size = 0`，则什么也不做。

执行成功返回生成的字符数，不包含终止符，如果大于等于 `size`，那么不是所有的字符都被存储到 `s`，你应该换用大一点的字符串缓冲区；出错返回一个负数。

```c
/* 构建一条消息，包含 name 和 value */
char *make_message(char *name, char *value) {
    /* 我猜我们最多需要 100 个字符空间 */
    int size = 100;
    char *buffer = (char *)xmalloc(size);
    int nchars;

    if (buffer == NULL)
        return NULL;

    /* 试着打印存储空间 */
    nchars = snprintf(buffer, size, "value of %s is %s", name, value);

    if (nchars >= size) {
        /* 重新分配缓冲区，我们需要更大的空间 */
        size = nchars + 1;
        buffer = (char *) xrealloc(buffer, size);

        if (buffer != NULL)
            /* 再试一次 */
            snprintf(buffer, size, "value of %s is %s", name, value);
    }
    /* 返回结果 */
    return buffer;
}
```

> 注意：在 2.1 版本之前的 GNU C 库，`snprintf()` 的返回值是存储的字符数，不包含终止符。如果 `s` 的空间不足以容纳所有的字符，返回 `-1`。现在已经改变，以符合 ISO C99 标准。

###

## 动态分配格式化输出

###: #include &lt;stdio.h&gt;

```c
#include <stdio.h>
```

###: asprintf()

```c
int asprintf(char **ptr, const char *template, …);
```

* Preliminary: | MT-Safe locale | AS-Unsafe heap | AC-Unsafe mem |
* Function

`asprintf()` 函数动态分配一个字符串，把模板字符串 `template` 及其后面的参数存储到该字符串。`ptr` 应该是一个 `char *` 对象，执行成功时存储分配的字符串的地址。

执行成功返回存储在缓冲区的字符数；出错返回一个负数---通常是因为无法分配缓冲区。

这儿有个例子，使用了 `asprintf()`，它比 `snprintf()` 更方便：

```c
/* 构建一条消息，包含 name 和 value */
char *make_message(char *name, char *value) {
    char *result;
    if (asprintf(&result, "value of %s is %s", name, value) < 0) {
        return NULL;
    }
    return result;
}
```

###: obstack_printf()

```c
int obstack_printf(struct obstack *obstack, const char *template, …);
```

* Preliminary: | MT-Safe race:obstack locale | AS-Unsafe corrupt heap | AC-Unsafe corrupt mem | 
* Function

`obstack_printf()` 函数类似 `asprintf()` 函数，只不过它使用了 obstack 来分配空间。

###

## 可变参数格式化输出

... 待补充 ... 

例子：

```c
#include <stdio.h>
#include <stdarg.h>

void eprintf(const char *template, ...) {
    va_list ap;
    extern char *program_invocation_short_name;

    fprintf(stderr, "%s: ", program_invocation_short_name);
    va_start(ap, template);
    vfprintf(stderr, template, ap);
    va_end(ap);
}
```

可以这样调用：

```c
eprintf("file `%s' does not exist\n", filename);
```

在 GNU C，这是一个特殊的结构，你可以通知编译器：你使用了一个 printf-style 的函数。之后，编译器会在每次调用该函数时，检查参数的个数和类型，并且在参数不匹配时发出警告。比如，这样声明 `eprintf()` 函数：

```c
void eprintf(const char *template, ...) __attribute__ ((format(printf, 1, 2)));
```

###: #include &lt;stdio.h&gt;

```c
#include <stdio.h>
```

###: vprintf()

```c
int vprintf(const char *template, va_list ap);
```

* Preliminary: | MT-Safe locale | AS-Unsafe corrupt heap | AC-Unsafe mem lock corrupt |
* Function

`vprintf()` 函数类似 `printf()` 函数，但是参数使用列表指针 `ap`。

###: vwprintf()

```c
int vwprintf(const wchar_t *template, va_list ap);
```

* Preliminary: | MT-Safe locale | AS-Unsafe corrupt heap | AC-Unsafe mem lock corrupt |
* Function

`vwprintf()` 函数类似 `wprintf()` 函数，但是参数使用列表指针 `ap`。

###: vfprintf()

```c
int vfprintf(FILE *stream, const char *template, va_list ap);
```

* Preliminary: | MT-Safe locale | AS-Unsafe corrupt heap | AC-Unsafe mem lock corrupt |
* Function

`vfprintf()` 函数类似 `fprintf()` 函数，但是参数使用列表指针 `ap`。

###: vfwprintf()

```c
int vfwprintf(FILE *stream, const wchar_t *template, va_list ap);
```

* Preliminary: | MT-Safe locale | AS-Unsafe corrupt heap | AC-Unsafe mem lock corrupt |
* Function

`vfwprintf()` 函数类似 `fwprintf()` 函数，但是参数使用列表指针 `ap`。

###: vsprintf()

```c
int vsprintf(char *s, const char *template, va_list ap);
```

* Preliminary: | MT-Safe locale | AS-Unsafe heap | AC-Unsafe mem |
* Function

`vsprintf()` 函数类似 `sprintf()` 函数，但是参数使用列表指针 `ap`。

###: vswprintf()

```c
int vswprintf(wchar_t *s, size_t size, const wchar_t *template, va_list ap);
```

* Preliminary: | MT-Safe locale | AS-Unsafe heap | AC-Unsafe mem |
* Function

`vswprintf()` 函数类似 `swprintf()` 函数，但是参数使用列表指针 `ap`。

###: vsnprintf()

```c
int vsnprintf(char *s, size_t size, const char *template, va_list ap);
```

* Preliminary: | MT-Safe locale | AS-Unsafe heap | AC-Unsafe mem |
* Function

`vsnprintf()` 函数类似 `snprintf()` 函数，但是参数使用列表指针 `ap`。

###: vasprintf()

```c
int vasprintf(char **ptr, const char *template, va_list ap);
```

* Preliminary: | MT-Safe locale | AS-Unsafe heap | AC-Unsafe mem |
* Function

`vasprintf()` 函数类似 `asprintf()` 函数，但是参数使用列表指针 `ap`。

###: obstack_vprintf()

```c
int obstack_vprintf(struct obstack *obstack, const char *template, va_list ap);
```

* Preliminary: | MT-Safe race:obstack locale | AS-Unsafe corrupt heap | AC-Unsafe corrupt mem | 
* Function

`obstack_vprintf()` 函数类似 `obstack_printf()` 函数，但是参数使用列表指针 `ap`。 

###

## 解析模版字符串

例子：

```c
/*  Test whether the nargs specified objects
    in the vector args are valid
    for the format string format:
    if so, return 1.
    If not, return 0 after printing an error message.  */

int validate_args(char *format, int nargs, OBJECT *args) {
    int *argtypes;
    int nwanted;

    /*  Get the information about the arguments.
        Each conversion specification must be at least two characters
        long, so there cannot be more specifications than half the
        length of the string.  */

    argtypes = (int *)alloca(strlen(format) / 2 * sizeof(int));
    nwanted = parse_printf_format(string, nelts, argtypes);

    /*  Check the number of arguments.  */
    if (nwanted > nargs) {
        error("too few arguments(at least %d required)", nwanted);
        return 0;
    }

    /*  Check the C type wanted for each argument
        and see if the object given is suitable.  */
    for (i = 0; i < nwanted; i++) {
        int wanted;

        if (argtypes[i] & PA_FLAG_PTR) {
            wanted = STRUCTURE;
        } else {
            switch (argtypes[i] & ~PA_FLAG_MASK) {
            case PA_INT:
            case PA_FLOAT:
            case PA_DOUBLE:
                wanted = NUMBER;
                break;
            case PA_CHAR:
                wanted = CHAR;
                break;
            case PA_STRING:
                wanted = STRING;
                break;
            case PA_POINTER:
                wanted = STRUCTURE;
                break;
            }
        }
        if (TYPE(args[i]) != wanted) {
            error("type mismatch for arg number %d", i);
            return 0;
        }
    }
    return 1;
}
```

###: #include &lt;printf.h&gt;

```c
#include <printf.h>
```

###: parse_printf_format()

```c
size_t parse_printf_format(const char *template, size_t n, int *argtypes);
```

* Preliminary: | MT-Safe locale | AS-Safe | AC-Safe |
* Function

`parse_printf_format()` 函数返回参数的类型信息，将其存储在 `argtypes`，该数组每个成员描述一个参数。这些信息是以 PA_ 开头的宏编码的。

`n` 指定 `argtypes` 的成员个数，它是 `parse_printf_format()` 返回信息的最大个数。

执行成功返回 `template` 需要的参数总数。如果这个值大于 `n`，那么返回的信息中只有前 n 个。如果你想包含所有的信息，分配一个大点的数组，再次调用 `parse_printf_format()`。

###: PA_FLAG_MASK

```c
int PA_FLAG_MASK
```

* Macro

`PA_FLAG_MASK` 宏是一个位掩码。你可以这样写 `(argtypes[i] & PA_FLAG_MASK)` 来提取参数的 flag，或者 `(argtypes[i] & ~PA_FLAG_MASK)` 来提取参数的基类型编码。

下面的符号常量表示基类型，它们是整数：

* `PA_INT` 基类型是 `int`。

* `PA_CHAR` 基类型是 `int`，转换到 `char`。

* `PA_STRING` 基类型是 `char *`，一个字符串。

* `PA_POINTER` 基类型是 `void *`，一个指针。

* `PA_FLOAT` 基类型是 `float`。

* `PA_DOUBLE` 基类型是 `double`。

* `PA_LAST` 你可以使用 `PA_LAST` 定义你自己的基类型。比如:

  ```c
  #define PA_FOO  PA_LAST
  #define PA_BAR  (PA_LAST + 1)    
  ```

下面是修饰基类型的 flag，它们常常和基类型的编码通过或组合：

* `PA_FLAG_PTR` 表示基类型是一个指针，而不是直接值。比如，`PA_INT|PA_FLAG_PTR` 表示类型 `int *`。

* `PA_FLAG_SHORT` 表示基类型使用 `short` 修饰。

* `PA_FLAG_LONG` 表示基类型使用 `long` 修饰。

* `PA_FLAG_LONG_LONG` 表示基类型使用 `long long` 修饰。

* `PA_FLAG_LONG_DOUBLE` 是 `PA_FLAG_LONG_LONG` 的同义词，used by convention with a base type of `PA_DOUBLE` to indicate a type of `long double`。

###
