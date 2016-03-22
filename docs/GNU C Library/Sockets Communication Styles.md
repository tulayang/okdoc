# [通信方式](https://www.gnu.org/software/libc/manual/html_node/Communication-Styles.html#Communication-Styles)

GNU C 库支持几个不同的通信方式，本节描述了它们的细节。

###: #include &lt;sys/socket.h&gt;

```c
#include <sys/socket.h>
```

###: SOCK_STREAM

```c
int SOCK_STREAM
```

* Macro

`SOCK_STREAM` 类似管道，连接一个远程的套接字，然后使用字节流可靠地传输数据。

###: SOCK_DGRAM

```c
int SOCK_DGRAM
```

* Macro

`SOCK_DGRAM` 用来向单一地址发送包，它是不可靠的。它和 `SOCK_STREAM` 正好相反。

每次把数据写到套接字，这些数据被打包。因为 `SOCK_DGRAM` 是无连接的，你必须为每个包指定接收地址。

唯一能保证的是，系统会尽可能的把你请求的数据交付到目标。第七个包可能比第六个包早到达，也可能到达两次第六个包。

只有在以下情况时使用 `SOCK_DGRAM`：当发现一定时间没有响应时，只需要简单重发。

###: SOCK_RAW

```c
int SOCK_RAW
```

`SOCK_RAW` 用来访问底层网络协议和接口。普通用户程序通常不需要使用它。
