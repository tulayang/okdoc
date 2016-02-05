# [文件状态标志](https://www.gnu.org/software/libc/manual/html_node/File-Status-Flags.html#File-Status-Flags)

文件状态标志，用来指定一个打开文件的属性。和文件描述符标志不同，当你复制文件描述符时，文件描述符之间共享文件状态标志。主要分为以下三种：

* 访问标志
* 打开标志
* 输入输出标志

## 访问标志

访问标志，指定文件描述符可读、可写，或者兼而有之。（在 GNU/Hurd 系统，还可以指定可执行）。访问标志在文件被打开时指定，并且不能修改。

###: #include &lt;fcntl.h&gt;

```c
#include <fcntl.h>
```

###: O_RDONLY

```c
int O_RDONLY
```

* Macro

打开的文件可读。

###: O_WRONLY

```c
int O_WRONLY
```

* Macro

打开的文件可写。

###: O_RDONLY

```c
int O_RDWR
```

* Macro

打开的文件可读可写。

###: O_ACCMODE

```c
int O_ACCMODE
```

* Macro

因为历史原因，`O_RDONLY`、`O_WRONLY`、`O_RDWR` 并不是各占 1 位（分别是 `0` `1` `2`），没法直接用二进制 `&` 判断当前的模式，而必须使用 `O_ACCMODE` 加以转换后，再进行比较。例子：

```c
int val = fcntl(fd, F_GETFL);
if (val == -1)
    errExit("fcntl");
switch (val & O_ACCMODE) { 
case O_RDONLY:
    printf("read only");
    break;
case O_WRONLY:
    printf("write only");
    break;
case O_RDWR:
    printf("read write");
    break;
default:
    errExit("unknown access mode");
}

if (val & O_APPEND)
    printf("append");
if (val & O_NONBLOCK)
    printf("nonblocking");
if (val & O_SYNC)
    printf("synchronous writes");

// 使用功能测试宏 _POSIX_C_SOURCE，排除 POSIX，测试 FreeBSD 和 Mac OS X
#if !defined(_POSIX_C_SOURCE) && defined(O_FSYNC) && (O_FSYNC != O_SYNC) 
    if (val & O_FSYNC)
        printf("synchronous writes");
#endif
```

###

## 打开标志

打开标志，指定打开文件时的行为。

###: #include &lt;fcntl.h&gt;

```c
#include <fcntl.h>
```

###: O_CREAT

```c
int O_CREAT
```

* Macro

如果文件不存在，则创建它。

###: O_EXCL

```c
int O_EXCL
```

* Macro

如果同时指定 `O_CREAT` 和 `O_EXCL`，当文件已经存在的时候，`open()` 会失败。这个选项确保不覆盖一个已经存在的文件。

###: O_NONBLOCK

```c
int O_NONBLOCK
```

* Macro

这个选项避免 `open()` 打开文件时阻塞一段时间。它只对一些特定类型的文件有意义，通常是串口设备；当它无意义时，它不会造成负面影响。通常，打开一个调制解调器时，会一直等待，直到载波检测完毕；如果指定了 `O_NONBLOCK`，则会立刻返回而不等待检测。

注意：打开文件时指定 `O_NONBLOCK`，同时会使该文件的后续 IO 变成非阻塞的。如果你想要阻塞 IO，则在调用 `open()` （指定 `O_NONBLOCK`）后调用 `fcntl()` 关闭非阻塞。

###: O_NOCTTY

```c
int O_NOCTTY
```

* Macro

如果指定的文件是一个设备，不要把它作为当前进程的控制终端。[→ 作业控制]()

###: O_TRUNC

```c
int O_TRUNC
```

* Macro

把文件的长度截断为 `0`。这个选项只对普通文件有效，对于管道、FIFO 等设备无效。

POSIX.1 要求 `O_TRUNC` 打开的文件应该是可写模式。在 BSD 和 GNU，你必须对文件有写访问权限，但是不需要打开的文件是可写模式。

使用 `open()` 截断文件不是个好主意，代替的，使用 `ftruncate()` 截断文件。`O_TRUNC` 比 `ftruncate()` 出现的要早，现在的主要目的是为了向后兼容。

###: O_SHLOCK

```c
int O_SHLOCK
```

* Macro

> BSD 扩展，只存在部分系统中。

获取一把共享锁，类似 `flock` [→ 文件锁](/docs/GNU C 标准库手册/IO LL File Locks.md)。如果指定了 `O_CREAT`，创建文件然后获取锁是原子操作。

###: O_EXLOCK

```c
int O_EXLOCK
```

* Macro

> BSD 扩展，只存在部分系统中。

获取一独占锁，类似 `flock` [→ 文件锁](/docs/GNU C 标准库手册/IO LL File Locks.md)。如果指定了 `O_CREAT`，创建文件然后获取锁是原子操作。   

###

## 输入输出标志

输入输出标志，指定输入输出如何操作。这些标志通过 `open()` 设置，可以通过 `fcntl()` 修改。

###: #include &lt;fcntl.h&gt;

```c
#include <fcntl.h>
```

###: O_APPEND

```c
int O_APPEND
```

* Macro

对文件启用追加模式。所有的写操作都会把数据写入文件的尾部，而不管当前的文件位置。它对于追加文件数据非常可靠，总能保证写入的数据在文件尾部。

###: O_NONBLOCK

```c
int O_NONBLOCK
```

* Macro

对文件启用非阻塞模式。当调用 `read()` 时，如果没有可用的输入，不会阻塞，而是立刻返回一个失败状态。同样的，当调用 `write()` 时，如果输出不能立刻完成，不会阻塞，而是立刻返回一个失败状态。

###: O_NDELAY

```c
int O_NDELAY
```

* Macro

这是一个废弃的宏，和 `O_NONBLOCK` 作用相同，主要是为了和 BSD 兼容。POSIX.1 并没有定义它。

###: O_ASYNC

```c
int O_ASYNC
```

* Macro

> BSD 扩展，只存在部分系统中。

对文件启用异步输入模式。当文件可读时，触发 `SIGIO` 信号。

###: O_FSYNC

```c
int O_FSYNC
```

* Macro

> BSD 扩展，只存在部分系统中。

对文件启用同步模式。每次调用 `write()`，都确保数据被写到磁盘，然后才返回。

###: O_SYNC

```c
int O_SYNC
```

* Macro

> BSD 扩展，只存在部分系统中。

`O_FSYNC` 的别名。

###: O_NOATIME

```c
int O_NOATIME
```

* Macro

> GNU 扩展，只存在部分系统中。

当调用 `read()` 时，会更新文件的访问时间。   

###

## 获取和设置文件状态标志

`fcntl()` 函数可以获取和设置文件状态标志。

###: #include &lt;fcntl.h&gt;

```c
#include <fcntl.h>
```

###: F_GETFL

```c
int F_GETFL
```

* Macro

`F_GETFL` 作为 `fcntl()` 函数的命令项使用，返回文件状态标志。

`fcntl()` 在使用此命令项时，返回值通常是非负数。如果出错返回 `-1` 并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 指定的 `fd` 不是有效的文件描述符。

###: F_SETFL

```c
int F_SETFL
```

* Macro

`F_SETFL` 作为 `fcntl()` 函数的命令项使用，设置文件状态标志---指定第三个参数作为新的标志。使用场景如下：

```c
fcntl(fd, F_SETFL, new_flags);
```

`fcntl()` 使用此命令项，成功时返回一个未指定的值，出错时返回 `-1` 并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 指定的 `fd` 不是有效的文件描述符。

如果你想修改文件状态标志，应该先使用 `F_GETFL` 获取当前标志，然后使用 `F_SETFL` 修改标志。例子：

```c
/* Set the O_NONBLOCK flag of desc if value is nonzero,
     or clear the flag if value is 0.
     Return 0 on success, or -1 on error with errno set. */

int set_nonblock_flag(int desc, int value) {
    int oldflags = fcntl(desc, F_GETFL, 0);
    /* 如果读取标志失败，立刻返回错误代码 */
    if (oldflags == -1)
        return -1;
    /* 添加 O_NONBLOCK */
    if (value != 0)
        oldflags |= O_NONBLOCK;
    /* 删除 O_NONBLOCK */
    else
        oldflags &= ~O_NONBLOCK;
    /* 保存修改后的标志 */
    return fcntl(desc, F_SETFL, oldflags);
}
```

###