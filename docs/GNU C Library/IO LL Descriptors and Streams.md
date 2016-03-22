# [文件描述符和流的那点事](https://www.gnu.org/software/libc/manual/html_node/Descriptors-and-Streams.html#Descriptors-and-Streams)

给定一个打开的文件描述符，你可以通过 `fdopen()` 函数创建一个流。你可以通过 `fileno()` 函数，从一个流获取底层的文件描述符。这些函数声明在头文件 `<stdio.h>`。

## API

###: #include &lt;stdio.h&gt;

```c
#include <stdio.h>
```

###: fdopen()

```c
FILE *fdopen(int fd, const char *opentype);
```

* Preliminary: | MT-Safe | AS-Unsafe heap lock | AC-Unsafe mem lock |

`fdopen()` 函数通过一个文件描述符返回一个新的流。

`opentype` 参数与 `fopen()` 函数中的同名参数相同[→ 打开流]()，除了禁用 `b` 选项外---因为 GNU 系统对文本文件和二进制文件是无差别对待。

如果不能创建新的流（比如没有足够的访问权限），返回一个空指针。

在一些系统，`fdopen()` 在失败时会检查文件描述符是否满足 `opentype` 指定的访问权限。GNU 系统总是这么做。

[→ 创建管道，详细了解 fdopen() 的用例]()

###: fileno

```c
int fileno(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

`fileno()` 函数通过一个流返回底层的文件描述符。

如果出现错误（比如，流是无效的），返回 `-1`。

###: fileno_unlocked()

```c
int fileno_unlocked(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

`fileno_unlocked()` 函数等价于 `fileno()` 函数，除了一个例外：如果状态是 `FSETLOCKING_INTERNAL`，`fileno_unlocked()` 函数不会隐式地锁定流。

> `fileno_unlocked()` 函数是一个 GNU 扩展。

###: #include &lt;unistd.h&gt;

```c
#include <unistd.h>
```

###: STDIN_FILENO

```c
#define STDIN_FILENO 0
```

这个宏的值是 `0`，表示标准输入流的文件描述符。

###: STDOUT_FILENO

```c
#define STDOUT_FILENO 1
```

这个宏的值是 `1`，表示标准输出流的文件描述符。

###: STDERR_FILENO

```c
#define STDERR_FILENO 2
```

这个宏的值是 `2`，表示标准错误流的文件描述符。