# [fcntl 控制输入输出的行为](https://www.gnu.org/software/libc/manual/html_node/Control-Operations.html#Control-Operations)

本节描述了如何对文件描述符执行各种有趣的操作，比如获取文件属性、操控记录锁，等等。所有这些操作，都是通过 `fcntl()` 执行的。

`fcntl()` 函数的第二个参数是一个命令，指定要执行什么操作。

## API

###: #include &lt;fcnlt.h&gt;

```c
#include <fcnlt.h>
```

###: fcntl()

```c
int fcntl(int fd, int command, …);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

`fcntl()` 函数对文件描述符 `fd` 执行 `command` 指定的操作。有些命令需要提供附加的参数。这些附加参数及其对应的返回值和错误，与 `command` 相关。

`command` 的常用命令如下：

* `F_DUPFD` 复制文件描述符号码（返回另一个文件描述符，指向同一个文件）。[→ 复制文件描述符](/docs/GNU C 标准库手册/IO LL Duplicating Descriptors.md)

* `F_DUPFD_CLOEXEC` 复制文件描述符号码（返回另一个文件描述符，指向同一个文件），同时设置 close-on-exec 标志。[→ 复制文件描述符](/docs/GNU C 标准库手册/IO LL Duplicating Descriptors.md)

* `F_GETFD` 返回文件描述符标志。当前只定义了一个文件描述符标志： `FD_CLOEXEC` （close-on-exec）。[→ 文件描述符标志](/docs/GNU C 标准库手册/IO LL File descriptor flags.md)

* `F_SETFD` 设置文件描述符标志。[→ 文件描述符标志](/docs/GNU C 标准库手册/IO LL File descriptor flags.md)

* `F_GETFL` 返回打开文件的状态标志。[→ 文件状态标志](/docs/GNU C 标准库手册/IO LL File Status Flags.md)

  因为历史原因，`O_RDONLY` `O_WRONLY` `O_RDWR` `O_EXEC O_SEARCH` 并不是各占 1 位（前 3 个分别是 0 1 2），没法直接用二进制 `&` 比较，需要用 `& O_ACCMODE` 取得访问方式位，再进行比较。

* `F_SETFL` 设置打开文件的状态标志。[→ 文件状态标志](/docs/GNU C 标准库手册/IO LL File Status Flags.md)

* `F_GETOWN` 返回当前接收 `SIGIO` `SIGURG` 信号的进程号码或进程组号码。

* `F_SETOWN` 设置接收 `SIGIO` `SIGURG` 信号的进程号码或进程组号码。

* `F_GETLK` 测试一把文件锁。[→ 文件锁](/docs/GNU C 标准库手册/IO LL File Locks.md)

* `F_SETLK` 设置或清除一把文件锁。[→ 文件锁](/docs/GNU C 标准库手册/IO LL File Locks.md)

* `F_SETLKW` 类似 `F_SETLK`，但是会阻塞直到完成。[→ 文件锁](/docs/GNU C 标准库手册/IO LL File Locks.md)

* `F_OFD_GETLK` 测试一把打开文件描述锁。**Linux 专有**。[→ 打开文件描述锁]()

* `F_OFD_SETLK` 设置或清除一把打开文件描述锁。**Linux 专有**。[→ 打开文件描述锁]()

* `F_OFD_SETLKW` 类似 `F_OFD_SETLK`，但是会阻塞直到完成。**Linux 专有**。[→ 打开文件描述锁]()

> 对于多线程程序，`fcntl()` 函数是一个“取消点”。如果线程在 `fcntl()` 被调用时，分配了一些资源（比如内存、文件描述符、信号或者其它），有可能会产生问题。如果该线程被取消了，这些资源仍然会继续存在，直到程序结束。要避免这种情况，应该通过取消处理器保护 `fcntl()` 调用。
