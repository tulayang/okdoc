# [流，读到尾部？还是出错？](https://www.gnu.org/software/libc/manual/html_node/EOF-and-Errors.html#EOF-and-Errors)

流的许多函数，当读到尾部或者出错都会返回宏 `EOF` 的值。为了区分到底是尾部还是错误，你可以使用 `feof()` 检查是否尾部，使用 `ferror()` 检查是否出错。流的这些状态是在内部存储的，每个 IO 操作都可能会修改它。



###: #include &lt;stdio.h&gt;

```c
#include <stdio.h>
```

###: EOF

```c
int EOF
```

* Macro

`EOF` 宏是一个整数常量，表示 end-of-file 或者出错。在 GNU C 库，它的值是 `-1`。在其他库，它的值可能是其他负数。

###: WEOF

```c
int WEOF
```

* Macro

`WEOF` 宏是一个整数常量，表示 end-of-file 或者出错，它用于宽字符流。在 GNU C 库，它的值是 `-1`。在其他库，它的值可能是其他负数。

`WEOF` 声明在头文件 `<wchar.h>`。

###: feof()

```c
int feof(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Unsafe lock |
* Function

`feof()` 函数检查流的 end-of-file 状态。如果是 end-of-file，返回 `非 0`；否则，返回 `0`。

###: feof_unlocked()

```c
int feof_unlocked(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Unsafe lock |
* Function

`feof_unlocked()` 函数类似 `feof()` 函数，但是不再内部锁定流。

> `feof_unlocked()` 函数是一个 GNU 扩展。

###: ferror()

```c
int ferror(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Unsafe lock |
* Function

`ferror()` 函数检查流的错误状态。如果出现错误，返回 `非 0`；否则，返回 `0`。

###: ferror_unlocked()

```c
int ferror_unlocked(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Unsafe lock |
* Function

`ferror_unlocked()` 函数类似 `ferror()` 函数，但是不再内部锁定流。

> `feof_unlocked()` 函数是一个 GNU 扩展。


