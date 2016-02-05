# [设置文件描述符的文件位置](https://www.gnu.org/software/libc/manual/html_node/File-Position-Primitive.html#File-Position-Primitive)

你可以通过 `fseek()` 设置一个流的文件位置，你也可以通过 `lseek()` 设置一个文件描述符的文件位置。这个指定的文件位置，将是你下一次 `read()` 或 `write()` 的位置[→ 文件位置]()。

想要从一个文件描述符读取当前文件位置的值，使用 `lseek (desc, 0, SEEK_CUR)`。

## 打开多次 & 复制多次

如果你打开同一个文件多次，或者使用 `dup()` 复制文件描述符，那么你可以同时拥有多个文件描述符。通过 `open()` 创建的文件描述符，它们有独立的文件位置，在其中一个调用 `lseek()` 不会影响其他的文件位置。例子： 

```c
{
    int d1, d2;
    char buf[4];

    d1 = open("foo", O_RDONLY);
    d2 = open("foo", O_RDONLY);
    lseek(d1, 1024, SEEK_SET);
    read(d2, buf, 4);
}
```

相比之下，通过复制获得的文件描述符，它们共享相同的文件位置。在其中一个调用 `lseek()` 都会影响其他的文件位置。例子：

```c
{
    int d1, d2, d3;
    char buf1[4], buf2[4];

    d1 = open("foo", O_RDONLY);
    d2 = dup(d1);
    d3 = dup(d2);
    lseek(d3, 1024, SEEK_SET);
    read(d1, buf1, 4);
    read(d2, buf2, 4);
}
```

## API

###: #include &lt;unistd.h&gt;

```c
#include <unistd.h>
```

###: lseek

```c
off_t lseek(int fd, off_t offset, int whence);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

`lseek()` 函数用来修改文件位置，它是基于文件描述符的。

`whence` 参数指定如何计算偏移值，它必须是以下符号之一：

* `SEEK_SET` 指定从文件的开始处计算偏移值。

* `SEEK_CUR` 指定从文件的当前位置计算偏移值。此时 `offset` 可以是负数。

* `SEEK_END` 指定从文件的尾部计算偏移值。此时 `offset` 可以是负数。

`lseek()` 的返回值，通常是新的文件位置---从文件的开始处计算。你可以使用 `SEEK_CUR` 来读取当前的文件位置：`ret = lseek(fd, 0, SEEK_CUR)`。

> 如果你想对文件追加数据，单纯使用 `SEEK_END` 指定文件位置为尾部是不够的！！！在你设定完文件位置，但是还没来得及写入时，另一个进程可能在此期间写入数据---这会破坏你的计划。取而代之的是，使用 `O_APPEND` 标志位执行追加操作[→ IO 操作模式](/docs/GNU C 标准库手册/IO LL File Status Flags.md)。

你可以设置文件位置，使其超过文件的尾部。这么做不会把文件变长---`lseek()` 永远不会改变文件。但是随后的写入会扩充文件，在文件尾部到设定的文件位置之间被二进制 `0` 填充，这被称为“空洞”---实际上，这些二进制 `0` 不在磁盘分配内存，因此文件实际占用的空间比它看上去的要少些，这也被称为“稀疏文件”。

如果文件位置不能被修改，或者这个操作是无效的，`lseek()` 返回 `-1`，并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 参数 `fd` 不是有效的文件描述符。

* `EINVAL` 参数 `whence` 的值无效，或者计算得到的偏移值无效。

* `ESPIPE` 文件描述符是和一个管道或 FIFO 相关的，而设备是不允许定位的。（POSIX.1 对管道和 FIFO 定义这个错误，但是在 GNU 系统，如果目标是不可搜索的，你总是能得到 `ESPIPE` 错误）。

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，`lseek()` 函数实质上是 `lseek64()` 函数，并且 `off_t` 实质上是 `off64_t`，这使得可以处理 <code>2<sup>63</sup>bytes</code> 长度的文件。

<span>

> 对于多线程程序，`lseek()` 函数是一个“取消点”。如果线程在 `lseek()` 被调用时，分配了一些资源（比如内存、文件描述符、信号或者其它），有可能会产生问题。如果该线程被取消了，这些资源仍然会继续存在，直到程序结束。要避免这种情况，应该通过取消处理器保护 `lseek()` 调用。

`lseek()` 函数是 `fseek()`、`fseeko()`、`ftell()`、`ftello()`、`rewind()` 的底层函数，它们用来设置流的文件位置。

###: lseek64()

```c
off64_t lseek64(int filedes, off64_t offset, int whence);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

> `lseek64()` 函数类似 `lseek()` 函数。唯一的不同是：在 32 位系统，打开的文件使用“大文件模式”。在该模式下，文件的最大长度是 <code>2<sup>63</sup>bytes</code>，文件的偏移范围是 <code>-2<sup>63</sup></code> 到 <code>2<sup>63</sup></code>。文件描述符 `fd` 必须是用 `open64()` 打开的，否则会发生错误。

<span>

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，`lseek()` 函数实质上是 `lseek64()` 函数。也就是说，扩展 API 使用 64 位文件长度和文件偏移，透明地替换掉旧的 API。   

###: off_t

```c
off_t
```

这个数据类型，是一个有符号整数。它用来表示文件尺寸。在 GNU C 库，它一定不比 `int` 窄。

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，`off_t` 被透明地替换为 `off_t64`。  

###: off64_t

```c
off64_t
```

> `off64_t` 类似 `off_t`。唯一的不同是：在 32 位系统，`off_t` 有 32 位，`off64_t` 有 64 位---可以表示的值范围是 <code>-2<sup>63</sup></code> 到 <code>2<sup>63</sup></code>。 

<span>

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，`off_t` 实质上是 `off64_t` 。

