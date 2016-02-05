# [流，输出一个字符，输出一行](https://www.gnu.org/software/libc/manual/html_node/Simple-Output.html#Simple-Output)

本节描述执行输出一个字符和一行的函数。普通字符的函数声明在头文件 `<stdio.h>`，宽字符的函数声明在头文件 `<wchar.h>`。

###: #include &lt;stdio.h&gt; #include &lt;wchar.h&gt;

```c
#include <stdio.h>
#include <wchar.h>
```

###: fputc()

```c
int fputc(int c, FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe corrupt lock |
* Function

`fputc()` 函数把字符 `c` 转换为 `unsigned char` 类型，然后通过流 `stream` 写入。执行成功返回字符 `c`；出错返回 `EOF`。

###: fputc_unlocked()

```c
int fputc_unlocked(int c, FILE *stream);
```

* Preliminary: | MT-Safe race:stream | AS-Unsafe corrupt | AC-Unsafe corrupt |
* Function

`fputc_unlocked()` 函数类似 `fputc()` 函数，但是不会在内部锁定流。

###: fputwc()

```c
wint_t fputwc(wchar_t wc, FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe corrupt lock |
* Function

`fputwc()` 函数把宽字符 `wc` 通过流 `stream` 写入。执行成功返回宽字符 `wc`；出错返回 `WEOF`。

###: fputwc_unlocked()

```c
wint_t fputwc_unlocked(wchar_t wc, FILE *stream);
```

* Preliminary: | MT-Safe race:stream | AS-Unsafe corrupt | AC-Unsafe corrupt |
* Function

`fputwc_unlocked()` 函数类似 `fputwc()` 函数，但是不会在内部锁定流。

> `fputwc_unlocked()` 函数是一个 GNU 扩展。

###: putc()

```c
int putc(int c, FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe corrupt lock |
* Macro

`putc()` 函数类似 `fputc()` 函数，大部分系统将它实现为宏，使它更快。一个后果是，它的参数不能带副作用。写单个普通字符时，`putc()` 是最好的选择。

###: putc_unlocked()

```c
int putc_unlocked(int c, FILE *stream);
```

* Preliminary: | MT-Safe race:stream | AS-Unsafe corrupt | AC-Unsafe corrupt |
* Macro

`putc_unlocked()` 函数类似 `putc()` 函数，但是不会在内部锁定流。

###: putwc()

```c
wint_t putwc(wchar_t wc, FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe corrupt lock |
* Macro

`putwc()` 函数类似 `fputwc()` 函数，大部分系统将它实现为宏，使它更快。一个后果是，它的参数不能带副作用。写单个宽字符时，`putwc()` 是最好的选择。

###: putwc_unlocked()

```c
wint_t putwc_unlocked(wchar_t wc, FILE *stream);
```

* Preliminary: | MT-Safe race:stream | AS-Unsafe corrupt | AC-Unsafe corrupt |
* Macro

`putwc_unlocked()` 函数类似 `putwc()` 函数，但是不会在内部锁定流。

> `fputwc_unlocked()` 函数是一个 GNU 扩展。

###: putchar()

```c
int putchar(int c);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe corrupt lock |
* Macro

`putchar()` 函数类似 `putc()` 函数，指定 `stdout` 作为流。

###: putchar_unlocked()

```c
int putchar_unlocked(int c);
```

* Preliminary: | MT-Safe race:stream | AS-Unsafe corrupt | AC-Unsafe corrupt |
* Macro

`putchar_unlocked()` 函数类似 `putchar()` 函数，但是不会在内部锁定流。

###: putwchar()

```c
wint_t putwchar(wchar_t wc);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe corrupt lock |
* Macro

`putwchar()` 函数类似 `putwc()` 函数，指定 `stdout` 作为流。

###: putwchar_unlocked()

```c
wint_t putwchar_unlocked(wchar_t wc);
```

* Preliminary: | MT-Safe race:stream | AS-Unsafe corrupt | AC-Unsafe corrupt |
* Macro

`putwchar_unlocked()` 函数类似 `putwchar()` 函数，但是不会在内部锁定流。

> `fputwc_unlocked()` 函数是一个 GNU 扩展。





###: fputs()

```c
int fputs(const char *s, FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe corrupt lock |
* Function

`fputs()` 函数把普通字符串 `s` 通过流 `stream` 写入。终止符不会被写入，也不添加换行符。执行成功返回 `非负数`；出错返回 `EOF`。

例子：

```c
fputs("Are ", stdout);
fputs("you ", stdout);
fputs("hungry?\n", stdout);
```

输出文本 "Are you hungry?\n"。

###: fputs_unlocked()

```c
int fputs_unlocked(const char *s, FILE *stream);
```

* Preliminary: | MT-Safe race:stream | AS-Unsafe corrupt | AC-Unsafe corrupt |
* Function

`fputs_unlocked()` 函数类似 `fputs()` 函数，但是不会在内部锁定流。

> `fputs_unlocked()` 函数是一个 GNU 扩展。

###: fputws()

```c
int fputws(const wchar_t *ws, FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe corrupt lock |
* Function

`fputws()` 函数把宽字符串 `ws` 通过流 `stream` 写入。终止符不会被写入，也不添加换行符。执行成功返回 `非负数`；出错返回 `WEOF`。

###: fputws_unlocked()

```c
int fputws_unlocked(const wchar_t *ws, FILE *stream);
```

* Preliminary: | MT-Safe race:stream | AS-Unsafe corrupt | AC-Unsafe corrupt |
* Function

`fputws_unlocked()` 函数类似 `fputws()` 函数，但是不会在内部锁定流。

> `fputws_unlocked()` 函数是一个 GNU 扩展。

###: puts()

```c
int putchar(const char *s);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe corrupt lock |
* Macro

`puts()` 函数把普通字符串 `s` 通过流 `stdout` 写入。终止符不会被写入，但是添加换行符。执行成功返回 `非负数`；出错返回 `EOF`。

打印单行消息时，`puts()` 是最方便的： `puts("This is a message.");`。

###: putw()

```c
int putw(int w, FILE *stream);
```

* Preliminary: | MT-Safe race:stream | AS-Unsafe corrupt | AC-Unsafe corrupt |
* Macro

`putw()` 函数把单词 `w` 通过流 `stream` 写入。它是为了向后兼容 BSD，请使用 `fwrite()` 代替。

