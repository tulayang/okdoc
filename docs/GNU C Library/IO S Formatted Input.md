# [流，格式化输入](https://www.gnu.org/software/libc/manual/html_node/Formatted-Input.html#Formatted-Input)

本节描述如何通过流格式化输入。比如，你可以使用 `scanf()` 函数，指定字符串模板，其工作方式非常类似格式化输出。

## 从基础开始

调用 `scanf()` 函数时，非常类似调用 `printf()` 函数，模板字符串的解析和替换都非常相似。

例子：

```c
void readarray (double *array, int n) {
    int i;
    for (i=0; i<n; i++) {
        if (scanf(" %lf", &(array[i])) != 1) {
            invalid_input_error();
        }
    }
}
```

## 占位符语法

这里描述格式化输出函数（比如 `scanf()`）模板字符串的转换语法的具体细节。

Any whitespace character (as defined by the isspace function; see Classification of Characters) in the template causes any number of whitespace characters in the input stream to be read and discarded. The whitespace characters that are matched need not be exactly the same whitespace characters that appear in the template string. For example, write ‘ , ’ in the template to recognize a comma with optional whitespace before and after. 

Other characters in the template string that are not part of conversion specifications must match characters in the input stream exactly; if this is not the case, a matching failure occurs. 

占位符的转换语法如下：

```?
% flags width type conversion
```

......

> 译注：请自行参看原文。

## 占位符汇总

这里有一个汇总，详细列出了所有不同的占位符：

* `%d` 匹配一个可选的有符号十进制整数。

* `%i` Matches an optionally signed integer in any of the formats that the C language defines for specifying an integer constant.

* `%o` 匹配一个无符号八进制基数。

* `%u` 匹配一个无符号十进制基数。

* `%x`，`%X` 匹配一个无符号十六进制基数。`%X` 用大写 `ABCDEF` 表示，`%x` 用小写表示。

* `%e`、`%f`、`%g`、`%E、`%G` 匹配一个有符号浮点数。

* `%a`、`%A` 打印一个浮点数，以十六进制表示。

* `%s` 匹配一个字符串，字符串中不包含空白符。`l` 修饰符匹配一个宽字符串或多字节字符串。

* `%S` 这是 `%ls` 的别名，用于兼容 Unix 标准。

* `%[` 匹配一个字符串集合。`l` 修饰符匹配一个宽字符串集合或多字节字符串集合。

* `%c` Matches a string of one or more characters; the number of characters read is controlled by the maximum field width given for the conversion. 

* `%C` 这是 `%lc` 的别名，用于兼容 Unix 标准。

* `%p` 匹配一个指针。

* `%n` 获取当前读取的字符数。

* `%%` 匹配一个 `'%'` 字符。

如果没有足够的参数以匹配模板字符串参数的占位符，或者参数的类型不正确，那么结果值是不可预料的；如果提供的参数超过了占位符的数量，多余的会被忽略。

......

> 译注：后面的不翻译了，格式化这几篇英文文档，写的实在受不了，请参看 《C 程序设计语言》。

## 格式化输入

例子：

```c
{
    char *variable, *value;

    if (2 > scanf("%a[a-zA-Z0-9] = %a[^\n]\n", &variable, &value)) {
        invalid_input_error();
        return 0;
    }

    …
}
```

###: #include &lt;stdio.h&gt;

```c
#include <stdio.h>
```

###: scanf()

```c
int scanf(const char *template, …);
```

* Preliminary: | MT-Safe locale | AS-Unsafe corrupt heap | AC-Unsafe mem lock corrupt |
* Function

`scanf()` 函数通过流 `stdin` 读取输入。可选的参数应该是指针，用来接收结果值---通过 `template` 提取。

执行成功返回取到的字符数；出错或 end-of-file 返回 `EOF`。

###: wscanf()

```c
int wscanf(const wchar_t *template, …);
```

* Preliminary: | MT-Safe locale | AS-Unsafe corrupt heap | AC-Unsafe mem lock corrupt |
* Function

`wscanf()` 函数通过流 `stdin` 读取输入。可选的参数应该是指针，用来接收结果值---通过 `template` 提取。

执行成功返回取到的字符数；出错或 end-of-file 返回 `WEOF`。

###: fscanf()

```c
int fscanf(FILE *stream, const char *template, …);
```

* Preliminary: | MT-Safe locale | AS-Unsafe corrupt heap | AC-Unsafe mem lock corrupt |
* Function

`fscanf()` 函数通过流 `stream` 读取输入。可选的参数应该是指针，用来接收结果值---通过 `template` 提取。

执行成功返回取到的字符数；出错或 end-of-file 返回 `EOF`。

###: fwscanf()

```c
int fwscanf(FILE *stream, const wchar_t *template, …);
```

* Preliminary: | MT-Safe locale | AS-Unsafe corrupt heap | AC-Unsafe mem lock corrupt |
* Function

`fwscanf()` 函数通过流 `stream` 读取输入。可选的参数应该是指针，用来接收结果值---通过 `template` 提取。

执行成功返回取到的字符数；出错或 end-of-file 返回 `WEOF`。

###: sscanf()

```c
int sscanf(const char *s, const char *template, …);
```

* Preliminary: | MT-Safe locale | AS-Unsafe heap | AC-Unsafe mem |
* Function

`sscanf()` 函数通过字符串 `s` 读取输入。可选的参数应该是指针，用来接收结果值---通过 `template` 提取。

执行成功返回取到的字符数；出错或 end-of-file 返回 `EOF`。

###: swscanf()

```c
int swscanf(const wchar_t *ws, const wchar_t *template, …);
```

* Preliminary: | MT-Safe locale | AS-Unsafe heap | AC-Unsafe mem | 
* Function

`swscanf()` 函数通过字符串 `ws` 读取输入。可选的参数应该是指针，用来接收结果值---通过 `template` 提取。

执行成功返回取到的字符数；出错或 end-of-file 返回 `WEOF`。    

###

## 可变参数格式化输入

> 可移植性注解：这里的函数包含在 ISO C99，之前的系统则采用 GNU C 扩展。

###: #include &lt;stdio.h&gt;

```c
#include <stdio.h>
```

###: vscanf()

```c
int vscanf(const char *template, va_list ap);
```

* Preliminary: | MT-Safe locale | AS-Unsafe corrupt heap | AC-Unsafe mem lock corrupt |
* Function

`vscanf()` 函数类似 `scanf()` 函数，但是参数使用列表指针 `ap`。

###: vwscanf()

```c
int vwscanf(const wchar_t *template, va_list ap);
```

* Preliminary: | MT-Safe locale | AS-Unsafe corrupt heap | AC-Unsafe mem lock corrupt |
* Function

`vwscanf()` 函数类似 `wscanf()` 函数，但是参数使用列表指针 `ap`。

###: vfscanf()

```c
int vfscanf(FILE *stream, const char *template, va_list ap);
```

* Preliminary: | MT-Safe locale | AS-Unsafe corrupt heap | AC-Unsafe mem lock corrupt |
* Function

`vfscanf()` 函数类似 `fscanf()` 函数，但是参数使用列表指针 `ap`。

###: vfwscanf()

```c
int vfwscanf(FILE *stream, const wchar_t *template, va_list ap);
```

* Preliminary: | MT-Safe locale | AS-Unsafe corrupt heap | AC-Unsafe mem lock corrupt |
* Function

`vfwscanf()` 函数类似 `fwscanf()` 函数，但是参数使用列表指针 `ap`。

###: vsscanf()

```c
int vsscanf(char *s, const char *template, va_list ap);
```

* Preliminary: | MT-Safe locale | AS-Unsafe heap | AC-Unsafe mem |
* Function

`vsscanf()` 函数类似 `sscanf()` 函数，但是参数使用列表指针 `ap`。

###: vswscanf()

```c
int vswscanf(wchar_t *s, size_t size, const wchar_t *template, va_list ap);
```

* Preliminary: | MT-Safe locale | AS-Unsafe heap | AC-Unsafe mem |
* Function

`vswscanf()` 函数类似 `swscanf()` 函数，但是参数使用列表指针 `ap`。

###

