# [流，缓冲区](https://www.gnu.org/software/libc/manual/html_node/Stream-Buffering.html#Stream-Buffering)

写入流的字符，通常是逐渐的累积，然后异步地传送给文件（内核缓冲区）---而不是立刻传送。同样的，流读取也是以块的方式进行，而不是一个字符一个字符。这被称为“缓冲”。

如果你使用流编写输入输出程序，那么你应该了解流的缓冲是如何工作的。否则，你可能会发现，输入输出并不是按你设想的那样工作。

## 缓冲概念

有三种不同的缓冲策略：

* 不采用缓冲，流会尽可能快的（立刻）传送数据

* 采用行缓冲，每当遇到换行符或缓冲区填满，才传送数据

* 采用全缓冲，每当缓冲区填满，才传送数据

新打开的流，通常是全缓冲，但是有一种情况除外：这个流连接到交互式设备（比如终端），则是行缓冲。通常，打开流时，采用自动选择缓冲，可以给你最方便的缓冲类型。

交互式设备使用行缓冲，这说明一旦输出的消息有换行符，就立刻传送---通常大家都喜欢这样。如果消息没有换行符，则可能立刻传送（缓冲区满了），也可能不会；如果你想立刻传送，使用 `fflush()` 冲洗缓冲区。

> 译注：在翻译的文档里，我们也把“冲洗缓冲区”叫做“清空缓冲区”。

## 冲洗缓冲区

冲洗缓冲区，意味着立刻传送缓冲区积累的所有字符。有许多情况会使流自动冲洗缓冲区：

* 当你做输出时，缓冲区被填满了

* 当流被关闭时

* 当调用 `exit()` 终止程序时

* 当流是行缓冲，写入换行符时

* 每当流执行输入操作，实际从文件读取数据时

如果你想自己冲洗缓冲区，调用 `fflush()`。

###: #include &lt;stdio.h&gt;

```c
#include <stdio.h>
```

###: fflush()

```c
int fflush(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

`fflush()` 函数冲洗流 `stream` 的缓冲区，使缓冲区的数据立刻传送到文件。如果 `stream` 是一个空指针，则冲洗所有打开的流。

执行成功返回 `0`；出错返回 `EOF`。

###: fflush_unlocked()

```c
int fflush_unlocked(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

`fflush_unlocked()` 函数类似 `fflush()` 函数，但是不在内部锁定流。

###: _flushlbf()

```c
void _flushlbf(void);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

`_flushlbf()` 函数冲洗所有打开的行缓冲区的流。

> `__flbf()` 是非标准函数，声明在头文件 `<stdio_ext.h>`，由 Solaris 引入，在 GNU C 库可用。

###: __fpurge()

```c
void __fpurge(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

`__fpurge()` 函数将流 `stream` 的缓冲区置空。如果流当前是读模式，则所有缓冲的数据都丢弃；如果流当前是写模式，则缓冲的数据不会写到文件，缓冲区被置为空的。

> `__flbf()` 是非标准函数，声明在头文件 `<stdio_ext.h>`，由 Solaris 引入，在 GNU C 库可用。


###
 
## 控制缓冲类型

打开流之后（还没有对流执行其他操作之前），你可以使用 `setvbuf()` 显式地指定流的缓冲类型。

###: #include &lt;stdio.h&gt;

```c
#include <stdio.h>
```

###: _IOFBF

```c
int _IOFBF
```

* Macro

`_IOFBF` 常量指定流是全缓冲。

###: _IOLBF

```c
int _IOLBF
```

* Macro

`_IOFBF` 常量指定流是行缓冲。

###: _IONBF

```c
int _IONBF
```

* Macro

`_IOFBF` 常量指定流是无缓冲。

###: BUFSIZ

```c
int BUFSIZ
```

* Macro

`BUFSIZ` 常量可以帮助你指定缓冲区的长度，它的值至少是 `256`---这一点可以保证。

每个系统都设定了 `BUFSIZ`，其取值可以保证流的 IO 效率较佳。因此，使用 `BUFSIZ` 作为你的缓冲区长度是一个好主意。

事实上，你可以使用 `fstat()` 获取最佳缓冲区长度---返回文件属性的 `st_blksize` 字段，即表示最佳缓冲区长度。

###: setvbuf()

```c
int setvbuf(FILE *stream, char *buf, int mode, size_t size);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

`setvbuf()` 函数指定流 `stream` 的缓冲模式 `mode`---可以是 `_IOFBF` （全缓冲）、`_IOLBF` （行缓冲）、`_IONBF` （无缓冲）。

如果指定 `buf` 是一个空指针，那么 `setvbuf()` 在内部通过 `malloc()` 分配缓冲区。当你关闭流时，内部分配的缓冲区会被释放。

否则，`buf` 应该是一个字符数组，至少 `size` 长度。只要流仍在打开，`buf` 就会作为其缓冲区，千万不要提前释放 `buf` 的空间。你可以静态分配、也可以调用 `malloc()` 动态分配缓冲区的空间。不过，尽量避免使用栈内数组，当离开栈时数组自动销毁，有可能破坏流的使用。
 
执行成功返回 `0`；出错返回 `非 0`。

###: setbuf()

```c
void setbuf(FILE *stream, char *buf);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

如果 `buf` 是一个空指针，则等价于 `setvbuf(stream, NULL, _IONBF, 0)`；否则，等价于 `setvbuf(stream, buf, _IOFBF, BUFSIZ)`。

> `setbuf()` 函数用来兼容旧的代码，请使用 `setvbuf()`。

###: setbuffer()

```c
void setbuffer(FILE *stream, char *buf, size_t size);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

如果 `buf` 是一个空指针，则等价于 `setvbuf(stream, NULL, _IONBF, 0)`；否则，等价于 `setvbuf(stream, buf, _IOFBF, size)`。

> `setbuffer()` 函数用来兼容旧的 BSD 代码，请使用 `setvbuf()`。

###: setlinebuf()

```c
void setlinebuf(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

`setlinebuf()` 指定流 `stream` 是行缓冲。

> `setbuffer()` 函数用来兼容旧的 BSD 代码，请使用 `setvbuf()`。

###: __flbf()

```c
int __flbf(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe | 
* Function

`__flbf()` 函数检查流 `stream` 是否是行缓冲。如果是，返回 `非 0`；否则，返回 `0`。

> `__flbf()` 是非标准函数，声明在头文件 `<stdio_ext.h>`，由 Solaris 引入，在 GNU C 库可用。

###: __fbufsize()

```c
int __fbufsize(FILE *stream);
```

* Preliminary: | MT-Safe race:stream | AS-Unsafe corrupt | AC-Safe |
* Function

`__fbufsize()` 函数返回流 `stream` 的缓冲区长度。

> `__fbufsize()` 是非标准函数，声明在头文件 `<stdio_ext.h>`，由 Solaris 引入，在 GNU C 库可用。

###: __fpending()

```c
int __fpending(FILE *stream);
```

* Preliminary: | MT-Safe race:stream | AS-Unsafe corrupt | AC-Safe |
* Function

`__fpending()` 函数返回流 `stream` 当前已缓冲的字节数。对于宽定向流，测量单位是宽字符。不要对读模式的流或打开只读的流使用 `__fpending()`。

> `__fpending()` 是非标准函数，声明在头文件 `<stdio_ext.h>`，由 Solaris 引入，在 GNU C 库可用。v    

###

