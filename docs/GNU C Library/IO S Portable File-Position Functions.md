# [流，文件位置，可移植](https://www.gnu.org/software/libc/manual/html_node/Portable-Positioning.html#Portable-Positioning)

在 GNU C 系统，文件位置是一个字符计数。然而，一些 ISO C 系统不用这种方式表示。

在这些系统，文本流和二进制流是完全不同的，无法用字符计数表示文本流的文件位置。比如，某些系统可能会编码文件偏移量，以计算文件位置。

如果你想编写可移植的程序，那么必须遵循下列规则：

* 对于文本流，调用 `ftell()` 返回值不能可靠地表示已经读了多少字符。你只应该把它作为后续 `fseek()` 或 `fseeko()` 的参数，移动到该文件位置。

* 对于文本流，如果调用 `fseek()` 或 `fseeko()`，那么 `offset` 必须是 `0`，或者 `whence` 必须是 `SEEK_SET` 并且 `offset` 必须是之前 `ftell()` 返回的值。

* 对于文本流，当调用 `ungetc()` 压回字符，该字符被读走或丢弃时，其文件位置是不可知的。

不过，就算你遵守了这些规则，遇到大文件时，你可能还是会碰到麻烦---由于 `ftell()` 和 `fseek()` 使用 `long int` 表示文件位置的原因。使用 `fseek()` 或 `fseeko()` 可以帮助你解决这个问题，因为 `off_t` 可以容纳所有文件位置值，但是对于文件位置的附加信息则帮不上什么忙。

因此，如果你想支持这些对文件位置采用特殊编码的系统，最好使用 `fgetpos()` 和 `fsetpos()` 函数。这些函数使用 `fpos_t` 表示文件位置，它在不同的系统上是不同的。

###: #include &lt;stdio.h&gt;

```c
#include <stdio.h>
```

###: fpos_t

```c
fpos_t
```

* Data Type

`fpos_t` 是一个对象类型，可以编码流的文件位置，用于 `fgetpos()` 和 `fsetpos()` 函数。

在 GNU C 库，`fpos_t` 包含了表示文件偏移和转换状态的信息。在其他系统，`fpos_t` 可能有不同的内容。

> 当源代码通过 `-D_FILE_OFFSET_BITS=64` 或 `#define FILE_OFFSET_BITS 64` 在 32 位机器编译时，`fpos_t` 实质上是 `fpos64_t`。也就是说，LFS 接口透明地替换掉旧的接口。 

###: fpos64_t()

```c
fpos64_t
```

* Data Type

`fpos64_t` 是一个对象类型，可以编码流的文件位置，用于 `fgetpos64()` 和 `fsetpos64()` 函数。

在 GNU C 库，`fpos64_t` 包含了表示文件偏移和转换状态的信息。在其他系统，`fpos64_t` 可能有不同的内容。

<span>

> 当源代码通过 `-D_FILE_OFFSET_BITS=64` 或 `#define FILE_OFFSET_BITS 64` 在 32 位机器编译时，`fpos_t` 实质上是 `fpos64_t`。也就是说，LFS 接口透明地替换掉旧的接口。  

###: fgetpos()

```c
int fgetpos(FILE *stream, fpos_t *position);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

`fgetpos()` 函数返回流 `stream` 的当前文件位置，将其存储到 `position`。

执行成功返回 `0`；出错返回 `非 0` 并设置 `errno` 值。

> 当源代码通过 `-D_FILE_OFFSET_BITS=64` 或 `#define FILE_OFFSET_BITS 64` 在 32 位机器编译时，`fgetpos()` 函数实质上是 `fgetpos64()` 函数。也就是说，LFS 接口透明地替换掉旧的接口。 

###: fgetpos64()

```c
int fgetpos64(FILE *stream, fpos64_t *position);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

`fgetpos64()` 函数类似 `fgetpos` 函数，但是使用 `fpos64_t` 类型存储文件位置。

> 当源代码通过 `-D_FILE_OFFSET_BITS=64` 或 `#define FILE_OFFSET_BITS 64` 在 32 位机器编译时，`fgetpos()` 函数实质上是 `fgetpos64()` 函数。也就是说，LFS 接口透明地替换掉旧的接口。

###: fsetpos()

```c
int fsetpos(FILE *stream, const fpos_t *position);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

`fsetpos()` 函数设置流 `stream` 的文件位置，该文件位置必须是之前通过 `fgetpos()` 返回的。

执行成功返回 `0`，清除 end-of-file 标志，丢弃 `ungetc()` 压回的字符（如果有的话）；出错返回 `非 0` 并设置 `errno` 值。

> 当源代码通过 `-D_FILE_OFFSET_BITS=64` 或 `#define FILE_OFFSET_BITS 64` 在 32 位机器编译时，`fsetpos()` 函数实质上是 `fsetpos64()` 函数。也就是说，LFS 接口透明地替换掉旧的接口。 

###: fsetpos64()

```c
int fsetpos64(FILE *stream, const fpos64_t *position);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

`fsetpos64()` 函数类似 `fsetpos` 函数，但是使用 `fpos64_t` 类型存储文件位置。

> 当源代码通过 `-D_FILE_OFFSET_BITS=64` 或 `#define FILE_OFFSET_BITS 64` 在 32 位机器编译时，`fsetpos()` 函数实质上是 `fsetpos64()` 函数。也就是说，LFS 接口透明地替换掉旧的接口。

