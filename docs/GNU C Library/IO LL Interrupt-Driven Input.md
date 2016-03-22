# 嗨，有输入或输出到来

如果你对一个文件描述符设置 `O_ASYNC` 标志[→ 文件状态标志](/docs/GNU C 标准库手册/IO LL File Status Flags.md)，当输入或输出到来时，就会发送 `SIGIO` 信号。接收信号的进程或进程组，可以通过 `fcntl()` 函数指定命令 `F_SETOWN` 设置。如果文件描述符是一个套接字，同时还会发送 `SIGURG` 信号[→ 带外数据]()。(SIGURG在任何情况下选择发送报告套接字是一个“特殊情况”。（`SIGURG` is sent in any situation where `select()` would report the socket as having an “exceptional condition”.[→ select 多路复用](/docs/GNU C 标准库手册/IO LL Waiting for Input or Output.md)

如果文件描述符是一个终端设备，那么 `SIGIO` 信号被发送到前台进程组。[→ 参看作业控制]()

## API

###: #include &lt;fcntl.h&gt;

```c
#include <fcntl.h>
```

###: F_GETOWN

```c
int F_GETOWN
```

* Macro

`F_GETOWN` 作为 `fcntl()` 函数的命令项使用，返回当前接收 `SIGIO`、`SIGURG` 信号的进程号码或进程组号码。

`fcntl()` 在使用此命令项时，返回值通常是进程号码或进程组号码，如果是负数，则取绝对值。如果出错返回 `-1` 并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 指定的 `fd` 不是有效的文件描述符。

###: F_SETOWN

```c
int F_SETOWN
```

* Macro

`F_SETOWN` 作为 `fcntl()` 函数的命令项使用，设置接收 `SIGIO`、`SIGURG` 信号的进程号码或进程组号码。使用场景如下：

```c
fcntl(fd, F_SETOWN, pid);
```

`pid` 应该是一个进程号码。你也可以指定一个负数，它的绝对值应该是一个进程号码。

`fcntl()` 使用此命令项，成功时返回一个未指定的值，出错时返回 `-1` 并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 指定的 `fd` 不是有效的文件描述符。

* `ESRCH` 指定的 `pid` 不是有效的进程号码或进程组号码。