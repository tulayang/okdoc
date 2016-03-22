# [打开套接字，关闭套接字](https://www.gnu.org/software/libc/manual/html_node/Open_002fClose-Sockets.html#Open_002fClose-Sockets)

好了，现在我们来聊聊打开套接字、关闭套接字的函数。它们可以使用所有的命名空间和通信方式，来完成任务。

## 如何打开套接字

创建套接字的原语是 `socket()` 函数，声明在头文件 `<sys/socket.h>`。

###: #include &lt;sys/socket.h&gt;

```c
#include <sys/socket.h>
```

###: socket()

```c
int socket(int namespace, int style, int protocol);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe fd |
* Function

`socket()` 函数创建一个套接字，指定命名空间 `namespace`、通信方式 `style`、协议 `protocol` --- 置`0` 表示使用默认协议。

执行成功返回新建套接字的文件描述符；出错返回 `-1`，并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EPROTONOSUPPORT` 指定的 `namespace` 不支持 `style` 或 `protocol` 。

* `EMFILE` 进程已达打开文件描述符上限。

* `ENFILE` 系统已达打开文件描述符上限。

* `EACCES` 进城没有特权创建指定 `stype` 或 `protocol` 的套接字。

* `ENOBUFS` 系统耗尽内部缓冲区空间。

返回的文件描述符支持读写操作，然而，和管道一样，套接字不支持文件定位操作。

###

## 关闭套接字

当你用完套接字，你应该使用 `close()` 关闭它的文件描述符。如果此时仍有数据等待着被传输（在内部缓冲区中），`close()` 通常尝试完成这次传输。你可以设置套接字选项 `SO_LINGER` 指定一个超时时间，以控制其行为---如果到时间还没有完成，就强行关闭。

你也可以使用 `shutdown()` 只停止接收或发送。

###: #include &lt;sys/socket.h&gt;

```c
#include <sys/socket.h>
```

###: shutdown()

```c
int shutdown(int socket, int how);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`shutdown()` 函数停止套接字 `socket` 的连接。`how` 指定具体行为：

* `0` 停止从套接字接收数据。如果远程数据到达，丢弃它。

* `1` 停止从套接字发送数据。丢弃任何正在等待发送的数据。停止搜寻已发送数据的确认包；如果已发送的数据丢失，不再重新发送。

* `2` 同时停止接收和发送。

执行成功返回 `0`；出错返回 `-1`，并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 指定的 `socket` 不是有效的文件描述符。

* `ENOTSOCK` 指定的 `socket` 不是套接字。

* `ENOTCONN` 指定的 `socket` 没有连接。

###

## 套接字对

套接字对由一对连接的套接字组成（但是是无名的---没有套接字地址）。它非常类似管道，并且使用的目的也很相似；和管道不同的是，套接字对是双向的，而管道则是单向的---一端输入一端输出。使用 `socketpair()` 创建套接字对。

###: #include &lt;sys/socket.h&gt;

```c
#include <sys/socket.h>
```

###: socketpair()

```c
int socketpair(int namespace, int style, int protocol, int fds[2]);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe fd |
* Function

`socketpair()` 函数创建一个套接字对，返回的文件描述符存储到 `fds`。`namespace` 指定命名空间---必须是 `PF_LOCAL`，`style` 指定通信方式，`protocol` 指定协议---`0` 是唯一有意义的值。

套接字对是全双工通信通道，因此，每个文件描述符都可以执行读写操作。

如果 `style` 指定了无连接通信方式，那么得到的两个套接字不是连接的，但是它们知道如何找到对方，因此，仍然可以相互发包。

执行成功返回 `0`；出错返回 `-1`，并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EAFNOSUPPORT` 指定的 `namespace` 不受支持。

* `EPROTONOSUPPORT` 指定的 `protocol` 不受支持。

* `EMFILE` 进程已达打开文件描述符上限。

* `EOPNOTSUPP` 指定的 `protocol` 不支持创建套接字对。

###   

