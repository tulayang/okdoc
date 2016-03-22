# [打开文件，关闭文件](https://www.gnu.org/software/libc/manual/html_node/Opening-and-Closing-Files.html#Opening-and-Closing-Files)

本节描述了如何通过文件描述符执行底层的输入输出操作。通常，使用流更方便；但是，有时候使用文件描述符也很有必要。比如：

* 把二进制文件读到大的块
* 读取整个文件，并进行语法分析
* 执行数据传输操作只能通过文件描述符
* 把文件描述符传递给子进程
* ...

## API

这里描述了打开文件、关闭文件的基本原语。`open` 和 `creat` 函数声明在头文件 `<fcntl.h>`，而 `close` 函数声明在头文件 `<unistd.h>`。

###: #include &lt;fcntl.h&gt;

```c
#include <fcntl.h>
```

###: open()

```c
int open(const char *filename, int flags, [mode_t mode]);
``` 

* Preliminary: | MT-Safe | AS-Safe | AC-Safe fd |

`open()` 函数通过指定的文件名 `filename` 创建一个新的文件描述符，并把它返回。最开始，文件位置在文件的开始处。只有在创建新文件时，参数 `mode` 才被使用，不过在其他情况下指定 `mode` 也没有关系[→ 访问权限]()。`flags` 控制文件如何被打开，它是个位掩码，由一个或多个标志位按位或组合[→ 文件状态标志](/docs/GNU C 标准库手册/IO LL File Status Flags.md)。

`open()` 函数成功时，返回一个非负整数，它是文件描述符；出错时，返回 `-1`，并设置 `errno` 值。除了通用的文件错误[→ 文件名错误](/docs/GNU C 标准库手册/IO Overview.md)，相关的 `errno` 值如下所示：

* `EACCES` 文件存在，但是不可读或不可写（按照 `flags`）；文件不存在，并且目录不可写，因此无法创建。

* `EEXIST` 标志位 `O_CREAT` 和 `O_EXCL` 同时被指定，但是文件已经存在。

* `EINTR` 打开操作被一个信号中断。

* `EISDIR` 标志位指定写访问，但是文件是一个目录。

* `EMFILE` 进程打开的文件数，已达上限。文件描述符的最大值，由 `RLIMIT_NOFILE` 控制[→ 资源限制]()。

* `ENFILE` 整个系统，或者包含该目录的文件系统，不支持同一时间打开额外的文件。（GNU/Hurd 系统不会发生这个错误）

* `ENOENT` 文件不存在，并且没有指定 `O_CREAT`。

* `ENOSPC` 包含新文件的目录或者文件系统不能被扩充，因为没有磁盘空间了。

* `ENXIO` 标志位 `O_NONBLOCK` 和 `O_WRONLY` 同时被指定，指定的文件名是 FIFO，但是没有进程打开这个文件来读。

* `EROFS` 文件在一个只读文件系统中，至少指定了 `O_WRONLY`、`O_RDWR`、`O_TRUNC` 其中一项，或者指定了 `O_CREAT` 但是文件不存在。

> 如果在 32 位系统上，源代码通过 `_FILE_OFFSET_BITS == 64` 编译，那么 `open()` 函数返回的文件描述符被设定为“大文件模式”。在该模式下，文件的最大长度是 <code>2<sup>63</sup>bytes</code>，文件的偏移范围是 <code>-2<sup>63</sup></code> 到 <code>2<sup>63</sup></code>。这些转换都是对用户透明的，所有底层的文件处理函数，都会被替换为等价的。

<span>

> 对于多线程程序，`open()` 函数是一个“取消点”。如果线程在 `open()` 被调用时，分配了一些资源（比如内存、文件描述符、信号或者其它），有可能会产生问题。如果该线程被取消了，这些资源仍然会继续存在，直到程序结束。要避免这种情况，应该通过取消处理器保护 `open()` 调用。

`open()` 函数是 `fopen()` 和 `freopen()` 的底层函数，它们两个是用来创建流的。

###: open64()

```c
int open64(const char *filename, int flags[, mode_t mode]);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe fd |

> `open64()` 函数类似 `open()` 函数。唯一的不同是：在 32 位系统，打开的文件使用“大文件模式”。在该模式下，文件的最大长度是 <code>2<sup>63</sup>bytes</code>，文件的偏移范围是 <code>-2<sup>63</sup></code> 到 <code>2<sup>63</sup></code>。

<span>

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，`open()` 函数实质上执行 `open64()` 函数。也就是说，扩展 API 使用 64 位文件长度和文件偏移，透明地替换掉旧的 API。

###: creat()

```c
int creat(const char *filename, mode_t mode);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe fd |

> 这个函数已经过时了。`creat(filename, mode)` 等价于 `open (filename, O_WRONLY | O_CREAT | O_TRUNC, mode)`。

<span>

> 如果在 32 位系统上，源代码通过 `_FILE_OFFSET_BITS == 64` 编译，那么 `open()` 函数返回的文件描述符被设定为“大文件模式”。在该模式下，文件的最大长度是 <code>2<sup>63</sup>bytes</code>，文件的偏移范围是 <code>-2<sup>63</sup></code> 到 <code>2<sup>63</sup></code>。这些转换都是对用户透明的，所有底层的文件处理函数，都会被替换为等价的。

###: creat64

```c
int creat64(const char *filename, mode_t mode);
```

> 这个函数类似 `creat()`。唯一的不同是：在 32 位系统，打开的文件使用“大文件模式”。也就是说，文件长度和文件偏移可以超过 31 位。

<span>

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，`open()` 函数实质上执行 `creat64()` 函数。也就是说，扩展 API 使用 64 位文件长度和文件偏移，透明地替换掉旧的 API。

###: #include &lt;unistd.h&gt;

```c
#include <unistd.h>
```

###: close()

```c
int close(int fd);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe fd |

`close()` 函数关闭指定的文件描述符。关闭一个文件有以下影响：

* 文件描述符被释放
* 进程在该文件的任何记录锁，被解锁
* 当一个管道或 FIFO 相关的所有文件描述符被关闭，所有未读取的数据都被丢弃

`close()` 函数成功时，返回 `0`；出错时，返回 `-1`，并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 参数 `fd` 不是一个有效的文件描述符。

* `EINTR` 关闭操作被一个信号中断。这儿有个处理 `EINTR` 的例子： `TEMP_FAILURE_RETRY (close (desc));`。

* `ENOSPC` `EIO` `EDQUOT` 当访问 NFS 文件时，`write()` 发生的错误，有时无法被发现，直到调用 `close()`。

> 对于多线程程序，`close()` 函数是一个“取消点”。如果线程在 `close()` 被调用时，分配了一些资源（比如内存、文件描述符、信号或者其它），有可能会产生问题。如果该线程被取消了，这些资源仍然会继续存在，直到程序结束。要避免这种情况，应该通过取消处理器保护 `close()` 调用。

`close()` 函数是 `fclose()` 的底层函数，它会冲洗所有的缓冲区，并且关闭流。

请注意，没有 `close64()` 函数。