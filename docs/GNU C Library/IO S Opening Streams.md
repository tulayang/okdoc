# [打开流](https://www.gnu.org/software/libc/manual/html_node/Opening-Streams.html#Opening-Streams)

本节描述了如何打开流、重定向流，以及如何判断流是可读还是可写。所有描述的内容，声明在头文件 `<stdio.h>` 和 `<stdio_ext.h>`。

## 如何打开流

调用 `fopen()` 函数，会打开一个文件，创建一个新流，并且在文件和流之间建立连接。这个过程可能会创建一个新文件。

###: #include &lt;stdio.h&gt;

```c
#include <stdio.h>
```

###: fopen()

```c
FILE *fopen(const char *filename, const char *opentype);
```

* Preliminary: | MT-Safe | AS-Unsafe heap lock | AC-Unsafe mem fd lock |
* Function

`fopen()` 函数打开指定的文件 `filename`， 创建一个新流，返回流指针。

`opentype` 是一个字符串，控制文件如何被打开，以及指定流的属性。它必须是下列字符串之一：

* `"r"` 以可读方式打开。

* `"w"` 以可写方式打开。如果文件已经存在，长度被截断为 `0`；否则，创建一个新文件。

* `"a"` 以追加方式打开，总是在文件尾端写入。如果文件已经存在，原先的内容保持不变，后来的数据写入到尾部；否则，创建一个新文件。

* `"r+"` 以可读可写方式打开，文件必须已经存在。原先的内容保持不变，初始文件位置位于文件开始。

* `"w+"` 以可读可写方式打开。如果文件已经存在，长度被截断为 `0`；否则，创建一个新文件。

* `"a+"` 以可读追加方式打开，总是在文件尾端写入。如果文件已经存在，原先的内容保持不变，后来的数据写入到尾部；否则，创建一个新文件。读的时候，初始文件位置位于文件开始。

如你所见，使用 `+` 创建的流既可以输入也可以输出。当你使用这样的流，并且从读切换到写时，必须调用 `fflush()` 清空流，或者调用 `fseek()` 定位文件位置，反之亦然。否则，流内部的缓冲区会产生混乱。

GNU C 库为 `opentype` 增加了几个额外的选项：

* `"c"` The file is opened with cancellation in the I/O functions disabled. 

* `"e"` 当你调用 `exec()` 生成子进程时，关闭流内部的文件描述符。相当于为文件描述符设置 `FD_CLOEXEC`。

* `"m"` 打开文件，使用 `mmap()` 访问。只能用来读。

* `"x"` 如果 `filename` 已存在，则以失败返回。相当于为文件描述符设置 `O_EXCL`。`"x"` 属于 ISO C11 标准。

* `"ccs=ENCODING"` 你可以在 `opentype` 指定编码字符集（UTF-8、UTF-16LE 或 UNICODE，如果需要 ANSI 编码，请不要指定此字符集）：`"rw,ccs=ENCODING"`，比如 `fopen(filename, "rw,ccs=UTF-8")`。这个时候流函数会做一些转换，采用宽字符。当不指定编码时，新创建的流是无定向的，后续的第一个流操作将决定流的定向。如果第一个流操作是一个宽字符操作，流会被标记为宽定向，同时其转换函数也会采用当前字符编码。之后不再改变，也不能改变。

* `"b"` 指定是二进制流。

在 `opentype` 的其他字符都会被忽略。

如果执行失败，返回一个空指针。

> 当源代码通过 `-D_FILE_OFFSET_BITS=64` 或 `#define FILE_OFFSET_BITS 64` 在 32 位机器编译时，`fopen()` 函数实质上是 `fopen64()` 函数。也就是说，LFS 接口（使用 64 位文件长度和文件偏移）透明地替换掉旧的接口。   

###: fopen64()

```c
FILE *fopen64(const char *filename, const char *opentype);
```

* Preliminary: | MT-Safe | AS-Unsafe heap lock | AC-Unsafe mem fd lock |
* Function

> `fopen64()` 函数类似 `fopen()` 函数。唯一的不同是：在 32 位系统，打开的文件使用“大文件模式”。在该模式下，文件的最大长度是 <code>2<sup>63</sup>bytes</code>，文件的偏移范围是 <code>-2<sup>63</sup></code> 到 <code>2<sup>63</sup></code>。

<span>

> 当源代码通过 `-D_FILE_OFFSET_BITS=64` 或 `#define FILE_OFFSET_BITS 64` 在 32 位机器编译时，`fopen()` 函数实质上是 `fopen64()` 函数。也就是说，LFS 接口（使用 64 位文件长度和文件偏移）透明地替换掉旧的接口。   

###: FOPEN_MAX

```c
int FOPEN_MAX
```

* Macro

`FOPEN_MAX` 是一个整数常量，表示系统允许同时打开的流上限，值至少是 `8`，包括 `stdin`、`stdout`、`stderr`。

> 在 POSIX.1 标准，这个值是由 `OPEN_MAX` 确定的；在 BSD 和 GNU，这个值是由资源限制 `RLIMIT_NOFILE` 确定的。

###: freopen()

```c
FILE *freopen(const char *filename, const char *opentype, FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe corrupt fd |
* Function

`freopen()` 函数如同 `fopen()` 和 `fclose()` 的组合。它首先关闭流 `stream`，忽略进程检测到的任何错误，然后打开指定的文件 `filename`，指定打开模式 `opentype`，创建新的流。

执行成功返回流；失败返回一个空指针。

`freopen` 常用于将标准流（比如 `stdin`）重定向到你自己的文件。

> 当源代码通过 `-D_FILE_OFFSET_BITS=64` 或 `#define FILE_OFFSET_BITS 64` 在 32 位机器编译时，`freopen()` 函数实质上是 `freopen64()` 函数。也就是说，LFS 接口（使用 64 位文件长度和文件偏移）透明地替换掉旧的接口。 

###: freopen64()

```c
FILE *freopen64(const char *filename, const char *opentype, FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe heap lock | AC-Unsafe mem fd lock |
* Function

> `freopen64()` 函数类似 `freopen()` 函数。唯一的不同是：在 32 位系统，打开的文件使用“大文件模式”。在该模式下，文件的最大长度是 <code>2<sup>63</sup>bytes</code>，文件的偏移范围是 <code>-2<sup>63</sup></code> 到 <code>2<sup>63</sup></code>。

<span>

> 当源代码通过 `-D_FILE_OFFSET_BITS=64` 或 `#define FILE_OFFSET_BITS 64` 在 32 位机器编译时，`freopen()` 函数实质上是 `freopen64()` 函数。也就是说，LFS 接口（使用 64 位文件长度和文件偏移）透明地替换掉旧的接口。
  
###
  
## 流可读？ 流可写？

判断流是可读还是可写，是非常有用的。Solaris 为此提供了一些函数，可以获取流的读写信息，GNU C 库也提供了这些函数。

###: #include &lt;stdio_ext.h&gt;

```c
#include <stdio_ext.h>
```

###: __freadable()

```c
int __freadable(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`__freadable()` 函数判断指定的流 `stream` 是否可读。如果是，返回 `非 0`；否则，返回 `0`。

###: __fwritable()

```c
int __fwritable(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`__fwritable()` 函数判断指定的流 `stream` 是否可写。如果是，返回 `非 0`；否则，返回 `0`。

###: __freading()

```c
int __freading(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`__freading()` function determines whether the stream `stream` was last read from or whether it is opened read-only. In this case the return value is nonzero, otherwise it is zero. Determining whether a stream opened for reading and writing was last used for writing allows to draw conclusions about the content about the buffer, among other things. 

###: __fwriting()

```c
int __fwriting(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`__fwriting()` function determines whether the stream `stream` was last written to or whether it is opened write-only. In this case the return value is nonzero, otherwise it is zero. 

###
