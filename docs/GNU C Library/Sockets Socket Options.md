# [套接字选项](https://www.gnu.org/software/libc/manual/html_node/Socket-Options.html#Socket-Options)

本节聊聊如何获取和设置套接字选项，套接字选项可以修改套接字的行为和底层的通信协议。

###: #include &lt;sys/socket.h&gt;

```c
#include <sys/socket.h>
```

###: SOL_SOCKET

```c
int SOL_SOCKET
```

* Macro

`SOL_SOCKET` 常量表示 socket-level，将其作为 `getsockopt()` 和 `setsockopt()` 函数的 `level` 参数，操纵下面描述的选项。

下面是一个选项表，基于 socket-level：

* `SO_DEBUG` 启用协议支持的调试记录。选项值是 `int` 类型，`非 0` 表示启用。

* `SO_REUSEADDR` 允许 `bind()` 为套接字绑定的本地地址重用。如果启用此选项，本质上，两个套接字可以有相同的因特网端口号；但是系统并不会允许你这样做，这会混淆网络。启用此选项的原因，是一些高级别的因特网协议，包括 FTP，需要你不断地重复使用相同的端口号。

  选项值是 `int` 类型，`非 0` 表示启用。

* `SO_KEEPALIVE` 周期性地在已连接的套接字上发送消息---以保持长连接。如果对端未能对这些消息作出响应，可以认为连接已经坏掉。选项值是 `int` 类型，`非 0` 表示启用。

* `SO_DONTROUTE` 发送消息时绕过常规的消息路由设施。如果设置，则直接发送消息到网络接口。选项值是 `int` 类型，`非 0` 表示启用。 

* `SO_LINGER` 对于可靠连接的套接字，当关闭套接字时，如果还有未发送的数据，则推迟关闭。选项值是 `struct linger` 类型。

  ```c
  struct linger；

  /*  成员  */
  int l_onoff;   // 如果 `非 0`，`close()` 阻塞直到数据被发送，或者直到下面的超时时间。
  int l_linger;  // 指定超时时间，以秒为单位。
  ```

* `SO_BROADCAST` 通过数据报套接字广播。选项值是 `int` 类型，`非 0` 表示启用。

* `SO_OOBINLINE` 将收到的带外数据放置在常规输入队列。这样的话，可以通过 `read()`、`recv()` 读取，但不用指定 `MSG_OOB`。选项值是 `int` 类型，`非 0` 表示启用。

* `SO_SNDBUF` 获取或设置输出缓冲区大小。选项值是 `size_t` 类型，以字节为单位。

* `SO_RCVBUF` 获取或设置输入缓冲区大小。选项值是 `size_t` 类型，以字节为单位。

* `SO_STYLE`、`SO_TYPE` 只能用于 `getsockopt()`。获取套接字的通信方式。`SO_TYPE` 已经是历史，`SO_STYLE` 是 GNU 首选的名字。选项值是 `int` 类型，它的值表示通信方式。

* `SO_ERROR` 只能用于 `getsockopt()`。重置套接字的错误状态。选项值是 `size_t` 类型，它的值表示之前的错误状态。  

###: getsockopt()

```c
int getsockopt(int socket, int level, int optname, void *optval, socklen_t *optlen-ptr);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`getsockopt()` 函数返回套接字 `socket` 的选项 `optname` 的值，将其存储到 `optval`，将其长度存储到 `optlen-ptr`。`level` 指定等级。

大多数返回的信息是一个 `int` 值。

执行成功时返回 `0`；出错时返回 `-1` 并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 指定的 `socket` 不是有效的文件描述符。

* `ENOTSOCK` 指定的 `socket` 不是套接字。

* `ENOPROTOOPT` 指定的 `optname` 在 `level` 内没有意义。

###: setsockopt()

```c
int setsockopt(int socket, int level, int optname, const void *optval, socklen_t optlen);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`setsockopt()` 函数设置套接字 `socket` 的选项 `optname` 的值为 `optval`。`level` 指定等级。`optlen` 指定 `optval` 缓冲区的长度。
