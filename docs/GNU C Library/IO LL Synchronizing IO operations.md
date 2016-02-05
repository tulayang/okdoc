# [同步，把脏数据写入磁盘](https://www.gnu.org/software/libc/manual/html_node/Synchronizing-I_002fO.html#Synchronizing-I_002fO)

在大多数现在操作系统，常规 IO 操作不会执行同步---而是存储在内核缓冲区中。也就是说，`write()` 调用成功返回时，数据并没有被立刻写入磁盘，而是写入内核缓冲区---内核过一些时间自动将其写入磁盘。

如果你需要确保数据被立刻写入存储设备，比如磁盘，你可以使用本节描述的函数。

## API

###: #include &lt;unistd.h&gt;

```c
#include <unistd.h>
```

###: sync()

```c
void sync(void);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

执行同步，把内核缓冲区的所有脏数据（包括数据和文件属性）写入到磁盘。直到完全写完，才会返回。

###: fsync()

```c
int fsync(int fd);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

执行同步，把指定的文件描述符在内核缓冲区的脏数据（包括数据和文件属性）写入到磁盘。直到完全写完，才会返回。

> 对于多线程程序，`fsync()` 函数是一个“取消点”。如果线程在 `fsync()` 被调用时，分配了一些资源（比如内存、文件描述符、信号或者其它），有可能会产生问题。如果该线程被取消了，这些资源仍然会继续存在，直到程序结束。要避免这种情况，应该通过取消处理器保护 `fsync()` 调用。

执行成功返回 `0`，出错返回 `-1` 并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 指定的文件描述符无效。

* `EINVAL` 系统不支持该同步操作。

###: fdatasync()

```c
int fdatasync(int fildes);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

执行同步，把指定的文件描述符在内核缓冲区的脏数据（只有数据，不包括文件属性）写入到磁盘。直到完全写完，才会返回。

并非所有系统都实现了 `fdatasync()`。在没有实现这个函数的系统，它被仿真为 `fsync()`。

执行成功返回 `0`，出错返回 `-1` 并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 指定的文件描述符无效。

* `EINVAL` 系统不支持该同步操作。