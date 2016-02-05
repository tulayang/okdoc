# [输入输出原语](https://www.gnu.org/software/libc/manual/html_node/I_002fO-Primitives.html#I_002fO-Primitives)

本节描述了执行原始的输入和输出操作的函数，它们基于文件描述符：`read()`、`write()`、`lseek()`。

## API

###: #include &lt;unistd.h&gt;

```c
#include <unistd.h>
```

###: ssize_t

```c
ssize_t
```

这个数据类型，用来表示读或写操作的块大小。它类似 `size_t`，但是是有符号类型。

###: read()

```c
ssize_t read(int fd, void *buffer, size_t size);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

`read()` 函数，从指定文件读取 `size` 个字节，保存到缓冲区 `buffer`。（读取的不一定是字符串，也不会添加 null 终止符）。

返回值是实际读取的字节数。可能会少于 `size`；比如，文件没有更多的字节，或者没有立刻出现更多的字节。确切的行为，依赖文件的类型。注意：读取的字节数少于 `size` 不是一个错误。

返回值是 `0`，表示到达文件尾端（除了 `size` 设定为 `0` 的情况）。这不是一个错误。如果你在到达文件尾端一直调用 `read()`，它会一直返回 `0` 并且什么也不做。

如果 `read()` 返回了至少一个字节，你无法确定是否已经到达文件尾端。但是，如果你确实到达了文件尾端，再次调用 `read()` 一定返回 `0`。

当出现错误时，`read()` 返回 `-1` 并设置 `errno` 值。相关的 `errnor` 值如下所示：

* `EAGAIN` 通常，当没有输入可以立刻获得，`read()` 会等待直到输入到来。但是，如果文件的标志位被设定了 `O_NONBLOCK`，`read()` 会立刻返回，并且报告这个错误。

  兼容性注意：许多 BSD 版本的 Unix 系统，使用 `EWOULDBLOCK` 来表示这个错误代码。在 GNU C 库，`EWOULDBLOCK` 是 `EAGAIN` 的别名，因此它不影响你的使用。

  在一些系统，从一个字符特殊文件读取大量数据，如果内核发现没有足够的物理内存在锁定用户的页，也会发生 `EAGAIN` 错误。对设备来讲，直接访问用户内存是受限的，终端则不会，它们在内核中使用独立的缓冲区。在 GNU/Hurd 系统，不会发生这个问题。

  任何可以触发 `EAGAIN` 的条件，都可能导致 `read()` 实际读取的字节数少于 `size`。当出现 `EAGAIN` 错误时，记得再次调用 `read()` 以读取剩余的字节。

* `EBADF` 参数 `fd` 不是有效的文件描述符，或者不是读打开的。

* `EINTR` 当 `read()` 在等待输入到来时，被一个信号打断。当出现 `EINTR` 错误时，记得再次调用 `read()` 以读取剩余的字节。

* `EIO` 用于许多设备和磁盘文件，表示一个硬件错误。

  当后台进程尝试读取控制终端时，也会发生 `EIO` 错误（停止进程的常用行为是，给它发送一个 `SIGTTIN` 信号，但是对后台进程无效）。如果信号被阻塞或者忽略，或者因为进程组长已经退出，就可能发生这个错误[→ 作业控制]() [→ 信号处理]()。  

* `EINVAL` 在一些系统，读一个字符设备或块设备时，位置和偏移必须对齐特定块的大小。这个错误表示：偏移没有被正确对齐。

> 对于多线程程序，`read()` 函数是一个“取消点”。如果线程在 `read()` 被调用时，分配了一些资源（比如内存、文件描述符、信号或者其它），有可能会产生问题。如果该线程被取消了，这些资源仍然会继续存在，直到程序结束。要避免这种情况，应该通过取消处理器保护 `read()` 调用。

流的所有读操作函数，都是基于 `read()`，比如 `fgetc()`。

请注意，没有 `read64()` 函数。这是不需要的，因为读操作不直接修改或者处理文件位置。内核会处理文件状态，所以，`read()` 函数可以被用于所有的情况（32 位，64 位）。

###: pread()

```c
ssize_t pread(int fd, void *buffer, size_t size, off_t offset);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

这个函数类似 `read()` 函数。前三个参数完全相同，返回值和错误代码也完全相同。

不同的是第四个参数 `offset`。不是从当前的文件位置读取数据块，而是从 `offset` 开始。文件描述符自身的文件位置，不会受到影响，值和调用之前相同。

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，`pread()` 函数实质上是 `pread64()` 函数，并且 `off_t` 实质上是 `off64_t`，这使得可以处理 <code>2<sup>63</sup>bytes</code> 长度的文件。

当出现错误时，`pread()` 和 `read()` 是相同的，还有另外附加的 `errno` 值：

* `EINVAL` 参数 `offset` 的值是负数。

* `ESPIPE` 文件描述符是和一个管道或 FIFO 相关的，而设备是不允许定位的。

> `pread()` 函数是 Unix Single Specification V2 定义的扩展。 

###: pread64()

```c
ssize_t pread64(int fd, void *buffer, size_t size, off64_t offset);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

> 这个函数类似 `pread()`。唯一的不同是：在 32 位系统，打开的文件使用“大文件模式”。也就是说，文件长度和文件偏移可以超过 31 位。文件描述符 `fd` 必须是用 `open64()` 打开的，否则会发生错误。

<span>

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，`pread()` 函数实质上执行 `pread64()` 函数。也就是说，扩展 API 使用 64 位文件长度和文件偏移，透明地替换掉旧的 API。   

###: write

```c
ssize_t write(int fd, const void *buffer, size_t size);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

`write()` 函数，从指定文件写入 `size` 个字节，写入的字节来自缓冲区 `buffer`。（写入的不一定是字符串，也不会添加 null 终止符）。 

返回值是实际写入的字节数。可能会少于 `size`。你的程序应该总是在循环调用 `write()`，直到所有的数据被写入。

一旦 `write()` 返回，这些按照顺序写入的数据，可以被立刻读取。不过，没必要立刻把它们写入到持久存储。内核持有读写缓冲区，它把这些写入的数据暂存到缓冲区，过一些时间再一起写入到持久存储，比如磁盘文件。如果你需要，你可以调用 `fsync()` 要求内核立刻把数据写入到持久存储。（由内核缓冲区暂存数据，再一起写入到持久存储，性能更好，也更方便。通常，1 分钟后会写入到磁盘）。现代操作系统还提供了另一个函数 `fdatasync()`，它也要求内核立刻把数据写入到持久存储，但是只包括文件数据，不包括文件属性，因此更快一些。你也可以使用 `O_FSYNC` 打开文件，`write()` 的时候总是以同步的方式写入到持久存储。

当出现错误时，`write()` 返回 `-1` 并设置 `errno` 值。相关的 `errnor` 值如下所示：

* `EAGAIN` 通常，如果 `write()` 不能立刻完成，它会阻塞直到完成。但是，如果文件的标志位被设定了 `O_NONBLOCK`，`write()` 会立刻返回，并且报告这个错误。

  兼容性注意：许多 BSD 版本的 Unix 系统，使用 `EWOULDBLOCK` 来表示这个错误代码。在 GNU C 库，`EWOULDBLOCK` 是 `EAGAIN` 的别名，因此它不影响你的使用。

  在一些系统，从一个字符特殊文件写入大量数据，如果内核发现没有足够的物理内存在锁定用户的页，也会发生 `EAGAIN` 错误。对设备来讲，直接访问用户内存是受限的，终端则不会，它们在内核中使用独立的缓冲区。在 GNU/Hurd 系统，不会发生这个问题。

  任何可以触发 `EAGAIN` 的条件，都可能导致 `write()` 实际写入的字节数少于 `size`。当出现 `EAGAIN` 错误时，记得再次调用 `write()` 以写入剩余的字节。

* `EBADF` 参数 `fd` 不是有效的文件描述符，或者不是写打开的。

* `EFBIG` 文件的长度会变长，超过系统可支持的长度。

* `EINTR` 当 `write()` 在阻塞时，被一个信号打断。当出现 `EINTR` 错误时，记得再次调用 `write()` 以写入剩余的字节。

* `EIO` 用于许多设备和磁盘文件，表示一个硬件错误。

  当后台进程尝试读取控制终端时，也会发生 `EIO` 错误（停止进程的常用行为是，给它发送一个 `SIGTTIN` 信号，但是对后台进程无效）。如果信号被阻塞或者忽略，或者因为进程组长已经退出，就可能发生这个错误[→ 作业控制]() [→ 信号处理]()。    

* `ENOSPC` 包含文件的设备已经满了。

* `EPIPE` 当尝试写入一个管道或 FIFO 时，没有消费者（读）。导致缓冲区填满。当发生这个错误时，一个 `SIGPIPE` 信号也被发送给进程[→ 信号处理]()。

* `EINVAL` 在一些系统，写一个字符设备或块设备时，位置和偏移必须对齐特定块的大小。这个错误表示：偏移没有被正确对齐。

除非你预先做了安排可以防止 `EINTR` 错误，否则，你应该在每次 `write()` 失败时检查 `errno`，如果错误是 `EINTR`，你应该简单的重新调用 `write()`。[→ 中断原语]()。有一个简单的方法是用宏 `TEMP_FAILURE_RETRY`：

```c
nbytes = TEMP_FAILURE_RETRY(write(desc, buffer, count));
```

> 对于多线程程序，`write()` 函数是一个“取消点”。如果线程在 `write()` 被调用时，分配了一些资源（比如内存、文件描述符、信号或者其它），有可能会产生问题。如果该线程被取消了，这些资源仍然会继续存在，直到程序结束。要避免这种情况，应该通过取消处理器保护 `write()` 调用。

流的所有写操作函数，都是基于 `write()`，比如 `fputc()`。

请注意，没有 `write64()` 函数。这是不需要的，因为写操作不直接修改或者处理文件位置。内核会处理文件状态，所以，`write()` 函数可以被用于所有的情况（32 位，64 位）。

###: pwrite()

```c
ssize_t pwrite(int fd, const void *buffer, size_t size, off_t offset);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

这个函数类似 `write()` 函数。前三个参数完全相同，返回值和错误代码也完全相同。

不同的是第四个参数 `offset`。不是从当前的文件位置写入数据块，而是从 `offset` 开始。文件描述符自身的文件位置，不会受到影响，值和调用之前相同。

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，`pwrite()` 函数实质上是 `pwrite64()` 函数，并且 `off_t` 实质上是 `off64_t`，这使得可以处理 <code>2<sup>63</sup>bytes</code> 长度的文件。

当出现错误时，`pwrite()` 和 `write()` 是相同的，还有另外附加的 `errno` 值：

* `EINVAL` 参数 `offset` 的值是负数。

* `ESPIPE` 文件描述符是和一个管道或 FIFO 相关的，而设备是不允许定位的。 

> `pwrite()` 函数是 Unix Single Specification V2 定义的扩展。

###: pwrite64()

```c
ssize_t pwrite64(int fd, const void *buffer, size_t size, off64_t offset);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

> 这个函数类似 `pwrite()`。唯一的不同是：在 32 位系统，打开的文件使用“大文件模式”。在该模式下，文件的最大长度是 <code>2<sup>63</sup>bytes</code>，文件的偏移范围是 <code>-2<sup>63</sup></code> 到 <code>2<sup>63</sup></code>。文件描述符 `fd` 必须是用 `open64()` 打开的，否则会发生错误。

<span>

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，`pwrite()` 函数实质上执行 `pwrite64()` 函数。也就是说，扩展 API 使用 64 位文件长度和文件偏移，透明地替换掉旧的 API。   