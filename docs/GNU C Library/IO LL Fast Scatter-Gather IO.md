# [分散-聚集](https://www.gnu.org/software/libc/manual/html_node/Scatter_002dGather.html#Scatter_002dGather)

一些应用程序可能需要把数据读写到多个缓冲区，这些缓冲区在内存中是独立的。虽然可以通过多个调用 `read()` 和 `write()` 轻松完成，但是这样比较低效，因为会制造更多的系统调用，而系统调用的开销也很客观。 

取而代之的是，很多平台都提供了特殊的高性能原语，通过一次系统调用完成这些操作。如果你所用的系统缺乏这些原语，GNU C 库会提供一个仿真，因此可移植性不是问题。它们被定义在头文件 `<sys/uio.h>`。

这些函数主要是控制数据结构 `struct iovec`，它描述了每个缓冲区的地址和尺寸。

## API

###: #include &lt;sys/uio.h.h&gt;

```c
#include <sys/uio.h>
```

###: struct iovec

```c
struct iovec {
    void   *iov_base;  // 缓冲区的地址 
    size_t  iov_len;   // 缓冲区的长度
};
```

`struct iovec` 描述了缓冲区的相关信息。

###: readv()

```c
ssize_t readv(int fd, const struct iovec *vector, int count);
```

* Preliminary: | MT-Safe | AS-Unsafe heap | AC-Unsafe mem |

`readv()` 函数通过指定的文件描述符读取数据，并把数据分散到 `vector`。`count` 指定 `vector` 的数量。当其中一个缓冲区被填满，就填入下一个缓冲区。

注意：`readv()` 不能保证填满所有的缓冲区。它可能会在任何一个点停止，原因和 `read()` 相同。

读取成功时，返回值是实际读取的字节数，如果是 `0`，则表示文件尾部。当出现错误时，返回 `-1` 并设置 `errno` 值，相关的 `errno` 值和 `read()` 相同。

###: writev()

```c
ssize_t writev(int fd, const struct iovec *vector, int count);
```

* Preliminary: | MT-Safe | AS-Unsafe heap | AC-Unsafe mem |

`writev()` 函数把 `vector` 描述的缓冲区的数据，写入到指定的文件描述符。`count` 指定 `vector` 的数量。当其中一个缓冲区被写完，就写下一个缓冲区。

注意：`writev()` 不能保证写完所有的缓冲区。它可能会在任何一个点停止，原因和 `write()` 相同。

写入成功时，返回值是实际写入的字节数。当出现错误时，返回 `-1` 并设置 `errno` 值，相关的 `errno` 值和 `write()` 相同。

注意：如果缓冲区比较小（小于 `1KB`），采用流要比用这里的函数更方便。然而，当缓冲区比较大的时候，`readv()` 和 `writev()` 可以提供更高的性能。