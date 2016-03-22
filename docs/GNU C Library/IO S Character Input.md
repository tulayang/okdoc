# [流，输入一个字符](https://www.gnu.org/software/libc/manual/html_node/Character-Input.html#Character-Input)

本节描述输入一个字符的函数。普通字符的函数声明在头文件 `<stdio.h>`，宽字符的函数声明在头文件 `<wchar.h>`。

普通字符函数返回 `int` 值，宽字符函数返回 `wint_t` 值，分别对应输入的普通字符、宽字符，或者 `EOF`、`WEOF` （通常是 `-1`）。对于普通字符函数，使用 `int` 而不是 `char` 存储结果很重要。在 `char` 中存储 `EOF`，`(char)-1`，会导致值被截断，导致无法正确的识别 。因此，总是使用 `int` 保存返回值，一旦你验证结果不是 `EOF`，你就可以确定返回值是 `char` 了。

例子：

```c
int y_or_n_p(const char *question) {
    fputs(question, stdout);
    while (1) {
        int c, answer;
        /* Write a space to separate answer from question. */
        fputc(' ', stdout);
        /* Read the first character of the line.
           This should be the answer character, but might not be. */
        c = tolower(fgetc(stdin));
        answer = c;
        /* Discard rest of input line. */
        while(c != '\n' && c != EOF)
            c = fgetc(stdin);
        /* Obey the answer if it was valid. */
        if (answer == 'y')
            return 1;
        if (answer == 'n')
            return 0;
        /* Answer was invalid: ask for valid answer. */
        fputs("Please answer y or n:", stdout);
    }
}
```

###: #include &lt;stdio.h&gt; #include &lt;wchar.h&gt;

```c
#include <stdio.h>
#include <wchar.h>
```

###: fgetc()

```c
int fgetc(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

`fgetc()` 函数通过流 `stream` 读取下一个普通字符，并把它转换为 `unsigned char`，然后将其返回。如果出错或 end-of-file 返回 `EOF`。

###: fgetc_unlocked()

```c
int fgetc_unlocked(FILE *stream);
```

* Preliminary: | MT-Safe race:stream | AS-Unsafe corrupt | AC-Unsafe corrupt |
* Function

`fgetc_unlocked()` 函数类似 `fgetc()` 函数，但是不会在内部锁定流。

###: fgetwc()

```c
wint_t fgetwc(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe corrupt lock |
* Function

`fgetwc()` 函数通过流 `stream` 读取下一个宽字符，然后将其返回。如果出错或 end-of-file 返回 `WEOF`。

###: fgetwc_unlocked()

```c
wint_t fgetwc_unlocked(wchar_t wc, FILE *stream);
```

* Preliminary: | MT-Safe race:stream | AS-Unsafe corrupt | AC-Unsafe corrupt |
* Function

`fgetwc_unlocked()` 函数类似 `fgetwc()` 函数，但是不会在内部锁定流。

> `fgetwc_unlocked()` 函数是一个 GNU 扩展。

###: getc()

```c
int getc(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe corrupt lock |
* Macro

`getc()` 函数类似 `fgetc()` 函数，大部分系统将它实现为宏，使它更快。一个后果是，它的参数不能带副作用。读单个普通字符时，`getc()` 通常是最好的选择。

###: getc_unlocked()

```c
int getc_unlocked(FILE *stream);
```

* Preliminary: | MT-Safe race:stream | AS-Unsafe corrupt | AC-Unsafe corrupt |
* Macro

`getc_unlocked()` 函数类似 `getc()` 函数，但是不会在内部锁定流。

###: getwc()

```c
wint_t getwc(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe corrupt lock |
* Macro

`getwc()` 函数类似 `fgetwc()` 函数，大部分系统将它实现为宏，使它更快。一个后果是，它的参数不能带副作用。写单个宽字符时，`getwc()` 是最好的选择。

###: getwc_unlocked()

```c
wint_t getwc_unlocked(FILE *stream);
```

* Preliminary: | MT-Safe race:stream | AS-Unsafe corrupt | AC-Unsafe corrupt |
* Macro

`getwc_unlocked()` 函数类似 `getwc()` 函数，但是不会在内部锁定流。

> `getwc_unlocked()` 函数是一个 GNU 扩展。

###: getchar()

```c
int getchar(void);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe corrupt lock |
* Macro

`getchar()` 函数类似 `getc()` 函数，指定 `stdin` 作为流。

###: getchar_unlocked()

```c
int getchar_unlocked(void);
```

* Preliminary: | MT-Safe race:stream | AS-Unsafe corrupt | AC-Unsafe corrupt |
* Macro

`getchar_unlocked()` 函数类似 `getchar()` 函数，但是不会在内部锁定流。

###: getwchar()

```c
wint_t getwchar(void);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe corrupt lock |
* Macro

`putwchar()` 函数类似 `putwc()` 函数，指定 `stdin` 作为流。

###: getwchar_unlocked()

```c
wint_t getwchar_unlocked();
```

* Preliminary: | MT-Safe race:stream | AS-Unsafe corrupt | AC-Unsafe corrupt |
* Macro

`getwchar_unlocked()` 函数类似 `getwchar()` 函数，但是不会在内部锁定流。

> `getwchar_unlocked()` 函数是一个 GNU 扩展。

###: getw()

```c
int getw(FILE *stream);
```

* Preliminary: | MT-Safe race:stream | AS-Unsafe corrupt | AC-Unsafe corrupt |
* Macro

`getw()` 函数通过流 `stream` 读取一个单词。它是为了向后兼容 SVID，请使用 `fread()` 代替。

