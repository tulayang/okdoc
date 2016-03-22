# [使用套接字连接](https://www.gnu.org/software/libc/manual/html_node/Connections.html#Connections)

最常见的通信是用套接字连接到另一个套接字，然后通过套接字交换数据。连接过程是不对称的，一边（客户端）请求连接，另一边（服务器）等待请求连接。

## 以客户端之名连接

客户端只能连接一个正在等待并接受连接的服务器。客户端可以调用 `connect()` 函数进行连接。

###: #include &lt;sys/socket.h&gt;

```c
#include <sys/socket.h>
```

###: connect()

```c
int connect(int socket, struct sockaddr *addr, socklen_t length);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`connect()` 函数使用套接字 `socket` 启动一个连接，连接的套接字地址是 `addr`。`length` 指定 `addr` 的长度。

通常，`connect()` 会等待，直到服务器响应了连接请求。你可以使用 `fcntl()` 设置套接字 `socket` 为非阻塞模式，不等待直接返回。

执行成功返回 `0`；出错返回 `-1`，并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 指定的 `socket` 不是有效的文件描述符。

* `ENOTSOCK` 指定的 `socket` 不是套接字。

* `EADDRNOTAVAIL` 指定的 `addr` 无法连接到远程机器。

* `EAFNOSUPPORT` 指定的 `addr` 不受 `socket` 的命名空间支持。

* `EISCONN` 指定的 `socket` 已经连接。

* `ETIMEDOUT` 连接超时。

* `ECONNREFUSED` 服务器拒绝连接。

* `ENETUNREACH` The network of the given `addr` isn’t reachable from this host。

* `EADDRINUSE` 指定的 `addr` 已经被占用。

* `EINPROGRESS` 指定的 `socket` 是非阻塞，并且连接不能被立刻建立。你可以使用 `select()` 检查连接是否完全建立。在连接完全建立前，再次 `connect()` 同一个套接字，会失败，错误码是 `EALREADY`。

* `EALREADY` 指定的 `socket` 是非阻塞，并且已经有一个连接。

> 对于多线程程序，`connect()` 函数是一个“取消点”。如果线程在 `connect()` 被调用时，分配了一些资源（比如内存、文件描述符、信号或者其它），有可能会产生问题。如果该线程被取消了，这些资源仍然会继续存在，直到程序结束。要避免这种情况，应该通过取消处理器保护 `connect()` 调用。    

###

## 监听连接

现在让我们来看看服务器如何接受客户端连接。首先，它必须调用 `listen()` 函数启动监听，然后调用 `accept()` 函数等待连接的到来。一旦启动监听，当套接字有连接准备好可以接受的时候，`select()` 函数就会发出通知。

在因特网命名空间，没有特殊的保护机制可以限制对端口的访问；任何机器的任何进程都能连接你的服务器。如果你想限制对服务器的访问，验证请求连接的地址、或实现其他握手规则、或进行协议认证。

在本机命名空间，普通文件的权限位控制着谁可以访问该套接字。

###: #include &lt;sys/socket.h&gt;

```c
#include <sys/socket.h>
```

###: listen()

```c
int listen(int socket, int n);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe fd |
* Function

`listen()` 函数启动套接字 `socket` 监听，以接受连接，这使它成为一个服务器。

`n` 指定等待队列的长度。当队列满的时候，新连接的客户端会收到 `ECONNREFUSED` 失败。服务器调用 `accept()` 时会从队列中移除一个。

执行成功返回 `0`；出错返回 `-1`，并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 指定的 `socket` 不是有效的文件描述符。

* `ENOTSOCK` 指定的 `socket` 不是套接字。

* `EOPNOTSUPP` 指定的 `socket` 不支持监听操作。

> `listen()` 不能用于无连接通信方式。 

###

## 接受连接

当服务器收到客户端连接请求时，使用 `accept()` 接受请求。

已经通过套接字启动监听的服务器，可以接受多个客户端的连接请求。服务器的套接字不会成为连接的一部分，`accept()` 会为连接生成一个新的套接字，以表示客户端。而服务器的套接字仍然继续监听其他连接请求。

等待服务器套接字接受连接请求的客户端数量是有上限的。如果连接请求到达，而服务器工作繁忙，来不及接受，并且等待队列已经满了，新来的请求就会被拒绝---客户端会得到 `ECONNREFUSED` 错误。你可以通过 `listen()` 指定等待队列的长度。

###: #include &lt;sys/socket.h&gt;

```c
#include <sys/socket.h>
```

###: accept()

```c
int accept(int socket, struct sockaddr *addr, socklen_t *length_ptr);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe fd |
* Function

`accept()` 函数通过套接字 `socket` 接受一个连接请求。

如果没有连接请求，`accept()` 会一直等待，直到连接请求到达。你可以使用 `fcntl()` 函数设置 `socket` 是非阻塞模式。（你可以使用 `select()` 函数检查一个非阻塞套接字，看看是否有连接请求到达）。

当接受连接请求时，创建一个新的套接字，并返回其文件描述符---表示客户端的连接。同时把连接的套接字地址存储到 `addr`，套接字地址长度存储到 `length_ptr`。

如果出错返回 `-1` 并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 指定的 `socket` 不是有效的文件描述符。

* `ENOTSOCK` 指定的 `socket` 不是套接字。

* `EOPNOTSUPP` 指定的 `socket` 不支持接受操作。

* `EWOULDBLOCK` 指定的 `socket` 是非阻塞模式，并且没有连接请求可以立刻接受。

> `listen()` 不能用于无连接通信方式。

<span>

> 对于多线程程序，`accept()` 函数是一个“取消点”。如果线程在 `accept()` 被调用时，分配了一些资源（比如内存、文件描述符、信号或者其它），有可能会产生问题。如果该线程被取消了，这些资源仍然会继续存在，直到程序结束。要避免这种情况，应该通过取消处理器保护 `accept()` 调用。

###

## 谁在连接？

###: #include &lt;sys/socket.h&gt;

```c
#include <sys/socket.h>
```

###: getpeername()

```c
int getpeername(int socket, struct sockaddr *addr, socklen_t *length-ptr);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`getpeername()` 函数返回连接到套接字 `socket` 的套接字地址，将其存储到 `addr`，将套接字地址长度存储到 `length-ptr`。

在某些操作系统，`getpeername()` 只能在因特网命名空间工作。 

执行成功返回 `0`；出错返回 `-1` 并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 指定的 `socket` 不是有效的文件描述符。

* `ENOTSOCK` 指定的 `socket` 不是套接字。

* `ENOTCONN` 指定的 `socket` 没有连接。

* `ENOBUFS` 没有足够的内部缓冲区空间。

###

## 传输数据

一旦套接字已经建立连接，你可以使用 `read()`、`write()` 传输数据。套接字是双工通信通道，所以可以对任何一端执行读写操作。

有一些专用于套接字操作的 IO 模式。你必须使用 `recv()`、`send()` 代替 `read()`、`write()`，来使用这些专有的模式。比如，你可以指定 `MSG_OOB` 以读写带外数据，指定 `MSG_PEEK` 预览输入，指定 `MSG_DONTROUTE` 控制路由信息。

###: #include &lt;sys/socket.h&gt;

```c
#include <sys/socket.h>
```

###: MSG_OOB

```c
int MSG_OOB
```

* Macro

`MSG_OOB` 指定：发送或接收带外数据。

###: MSG_PEEK

```c
int MSG_PEEK
```

* Macro

`MSG_PEEK` 指定：查看一下输入队列的数据，但是不读走它。只对 `recv()` 有用。

###: MSG_DONTROUTE

```c
int MSG_DONTROUTE
```

* Macro

`MSG_DONTROUTE` 指定：不在消息中包含路由信息。只对 `send()` 有用，通常只用来诊断程序或路由程序。我们不想多做解释。

###: send()

```c
ssize_t send(int socket, const void *buffer, size_t size, int flags);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`send()` 函数类似 `write()` 函数，但是增加了标志位 `flags` --- 控制发送模式，可以使用 `|` 组合。如果 `flags` 置为 `0`，则和 `write()` 一模一样。

如果套接字是非阻塞模式，`send()` （类似 `write()`） 可能发送部分数据并返回。

注意，成功返回只是表示消息已经被正确发送，不表示已经被正确收到。

执行成功返回发送的字节数；出错返回 `-1`，并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 指定的 `socket` 不是有效的文件描述符。

* `ENOTSOCK` 指定的 `socket` 不是套接字。

* `EMSGSIZE` 指定发送是原子的，但是消息太大了，无能满足这种情况。

* `EINTR` 发送操作被一个信号中断。再次发送很可能会成功。

* `EWOULDBLOCK` 指定的 `socket` 是非阻塞模式，发送会导致阻塞。

* `ENOBUFS` 没有足够的内部缓冲区空间

* `ENOTCONN` 指定的 `socket` 没有建立连接。

* `EPIPE` 指定的 `socket` 已经建立连接，但是现在已经破坏连接。在这种情况下，`send()` 生成一个 `SIGPIPE` 信号，如果信号被忽略，则 `send()` 会阻塞；如果设定了信号处理器并返回，则 `send()` 返回错误，错误码 `EPIPE`。

> 对于多线程程序，`send()` 函数是一个“取消点”。如果线程在 `send()` 被调用时，分配了一些资源（比如内存、文件描述符、信号或者其它），有可能会产生问题。如果该线程被取消了，这些资源仍然会继续存在，直到程序结束。要避免这种情况，应该通过取消处理器保护 `send()` 调用。

###: recv()

```c
ssize_t recv(int socket, void *buffer, size_t size, int flags);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`recv()` 函数类似 `read()` 函数，但是增加了标志位 `flags` --- 控制发送模式，可以使用 `|` 组合。如果 `flags` 置为 `0`，则和 `read()` 一模一样。

如果套接字是非阻塞模式，并且没有数据可读，`recv()` （类似 `read()`） 立刻返回错误，而不是等待。

注意，成功返回只是表示消息已经被正确发送，不表示已经被正确收到。

执行成功接收发送的字节数；出错返回 `-1`，并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 指定的 `socket` 不是有效的文件描述符。

* `ENOTSOCK` 指定的 `socket` 不是套接字。

* `EINTR` 发送操作被一个信号中断。再次接收很可能会成功。

* `EWOULDBLOCK` 指定的 `socket` 是非阻塞模式，接收会导致阻塞。

* `ENOTCONN` 指定的 `socket` 没有建立连接。

> 对于多线程程序，`recv()` 函数是一个“取消点”。如果线程在 `recv()` 被调用时，分配了一些资源（比如内存、文件描述符、信号或者其它），有可能会产生问题。如果该线程被取消了，这些资源仍然会继续存在，直到程序结束。要避免这种情况，应该通过取消处理器保护 `recv()` 调用。

###

## 例子 __ 字节流客户端

这儿有个客户端程序的例子，演示了如何构建一个因特网命名空间的字节流套接字，并连接服务器。其中用到了 `init_sockaddr()` 函数，[→ 因特网套接字例子](/docs/GNU C 标准库手册/Sockets The Internet Namespace.md#user-content-72)：

```c
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

#define PORT            5555
#define MESSAGE         "Yow!!! Are we having fun yet?!?"
#define SERVERHOST      "www.gnu.org"

void write_to_server (int filedes) {
    int nbytes;

    nbytes = write(filedes, MESSAGE, strlen(MESSAGE) + 1);
    if (nbytes < 0) {
        perror("write");
        exit(EXIT_FAILURE);
    }
}

int main (void) {
    extern void init_sockaddr(struct sockaddr_in *name, const char *hostname, uint16_t port);
    int sock;
    struct sockaddr_in servername;

    /*  创建套接字  */
    sock = socket(PF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        perror("socket (client)");
        exit(EXIT_FAILURE);
    }

    /*  连接服务器  */
    init_sockaddr(&servername, SERVERHOST, PORT);
    if (0 > connect (sock,(struct sockaddr *)&servername, sizeof(servername))) {
        perror("connect (client)");
        exit(EXIT_FAILURE);
    }

    /*  向服务器发送数据  */
    write_to_server(sock);
    close(sock);
    exit(EXIT_SUCCESS);
}
```

## 例子 __ 字节流服务器

服务器的构建比较复制。因为我们想要在同一时间与多个客户端建立连接---以提高并发效率，单纯地使用 `read()` 或 `recv()` 等待输入是错误的。正确的做法是，使用 `select()` 等待所有打开的套接字。同时还能使服务器处理多个连接请求。

这儿有个服务器程序的例子，演示了如何构建一个因特网命名空间的字节流套接字，并作为服务器接受连接请求。其中用到了 `make_socket()` 函数，[→ 因特网套接字例子](/docs/GNU C 标准库手册/Sockets The Internet Namespace.md#user-content-72)：

```c
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

#define PORT    5555
#define MAXMSG  512

int read_from_client (int filedes) {
    char buffer[MAXMSG];
    int nbytes;

    nbytes = read(filedes, buffer, MAXMSG);
    if (nbytes < 0) {
        /*  读取错误  */
        perror("read");
        exit(EXIT_FAILURE);
    } else if (nbytes == 0) {
        /*  End-of-file.  */
        return -1;
    } else {
        /*  读到数据  */
        fprintf(stderr, "Server: got message: `%s'\n", buffer);
        return 0;
    }
}

int main (void) {
    extern int make_socket(uint16_t port);
    int sock;
    fd_set active_fd_set, read_fd_set;
    int i;
    struct sockaddr_in clientname;
    size_t size;

    /*  创建套接字，并作为服务器接受连接  */
    sock = make_socket(PORT);
    if (listen(sock, 1) < 0) {
        perror("listen");
        exit(EXIT_FAILURE);
    }

    /*  初始化套接字集合  */
    FD_ZERO(&active_fd_set);
    FD_SET(sock, &active_fd_set);

    for (;;) {
        /*  阻塞，直到有套接字的输入到达  */
        read_fd_set = active_fd_set;
        if (select(FD_SETSIZE, &read_fd_set, NULL, NULL, NULL) < 0) {
            perror("select");
            exit(EXIT_FAILURE);
        }

        /*  处理套接字的输入  */
        for (i = 0; i < FD_SETSIZE; ++i) {
            if (FD_ISSET(i, &read_fd_set)) {
                if (i == sock) {
                    /*  这里是连接请求  */
                    int new;
                    size = sizeof(clientname);
                    new = accept(sock, (struct sockaddr *)&clientname, &size);
                    if (new < 0) {
                        perror("accept");
                        exit(EXIT_FAILURE);
                    }
                    fprintf(stderr,
                            "Server: connect from host %s, port %hd.\n",
                            inet_ntoa(clientname.sin_addr),
                            ntohs(clientname.sin_port));
                    FD_SET(new, &active_fd_set);
                } else {
                    /*  这里是已经建连接的套接字发送的数据  */
                    if (read_from_client (i) < 0) {
                        close(i);
                        FD_CLR(i, &active_fd_set);
                    }
                }
            }
        }
    }
}
```

## 带外数据

流式连接可以传输带外数据，带外数据比普通数据有更高的优先处理权。比较典型的用法是，使用带外数据发送一个异常通知。调用 `send()` 指定 `MSG_OOB`即可发送带外数据。

带外数据有更高的接收优先级，是因为接收进程不需要按顺序读。调用 `recv()` 指定 `MSG_OOB` 就可读取下一个可用的带外数据。普通读操作不读带外数据；它们只读普通数据。

当一个套接字发现带外数据时，它向所属的进程或进程组发送一个 `SIGURG` 信号。你可以调用 `fcntl()` 指定 `F_SETOWN` 设置接收 `SIGURG` 信号的进程号或进程组号 [→ 嗨，有输入或输出到来](/docs/GNU C 标准库手册/IO LL Interrupt-Driven Input.md#user-content-4)。你可以为这个信号建立处理器 [→ 信号处理]()，以执行适当的处理，比如，读这个带外数据。

还有一个方法，你可以调用 `select()` 测试带外数据，或者等待带外数据出现。没有输入输出或异常条件活动时，`select()` 会等待（阻塞）；当有套接字的异常条件出现时，`select()` 立刻返回。

发现带外数据（`SIGURG` 或者 `select()`）并不表示它已经到达---紧紧表示收到通知，数据有可能稍后才会真正到达。当你发现带外数据，但是尚未到达，如果尝试读带外数据，`recv()` 会失败，其错误码是 `EWOULDBLOCK`。

发送带外数据时，会自动插入标记，表明“我们从哪儿开始，到哪儿结束”。你可以用下面的方法测试一下，看看在标记前是否有普通数据：

```c
success = ioctl (socket, SIOCATMARK, &atmark);
```

如果通过套接字 `socket` 读取到一个标记，整数变量 `atmark` 会被置为 `非 0`。

这儿有个例子，它会丢弃带外数据前的所有普通数据：

```c
int discard_until_mark (int socket) {
    for (;;) {
        /*  这里设定的缓冲区上限不是绝对的，你可以根据自己的需要设定  */
        char buffer[1024];
        int atmark, success;

        /*  测试一下套接字的输入中是否有标记  */
        success = ioctl(socket, SIOCATMARK, &atmark);
        if (success < 0) {
            perror("ioctl");
        }

        /*  我们找到了标记，返回它  */
        if (result) {
            return;
        }

        /*  没有标记，读取普通数据，并丢弃掉。
            这样可以确保：带外数据前有普通数据时，可以正确读到带外数据。  */
        success = read(socket, buffer, sizeof buffer);
        if (success < 0)
          perror ("read");
    }
}
```

如果你不想丢弃带外数据前的普通数据，那么申请一些空间把它们存放起来。当你尝试读带外数据，却收到 `EWOULDBLOCK` 错误时，你就试试读一些普通数据，以腾出空间---让带外数据进来。例子：

```c
struct buffer {
    char *buf;
    int size;
    struct buffer *next;
};

/*  从套接字读取带外数据，并存储到 `struct buffer` --- 记录了带外数据
    和数据的长度。

    为了让带外数据到达，可能需要先读走一些普通数据。我们把普通数据保存在一个
    链接的 `struct buffer`，`next` 指向下一条普通数据。 */

struct buffer *read_oob(int socket) {
    struct buffer *tail = 0;
    struct buffer *list = 0;

    for (;;) {
        /*  这里设定的缓冲区上限不是绝对的，你可以根据自己的需要设定  */
#define BUF_SZ 1024
        char *buf = (char *)xmalloc(BUF_SZ);
        int success;
        int atmark;

        /*  尝试读带外数据  */
        success = recv(socket, buf, BUF_SZ, MSG_OOB);
        if (success >= 0) {
            /*  我们拿到了带外数据，返回它  */
            struct buffer *link
                = (struct buffer *)xmalloc(sizeof(struct buffer));
            link->buf = buf;
            link->size = success;
            link->next = list;
            return link;
        }

        /*  如果没能读到带外数据，看看是否有标记  */
        success = ioctl(socket, SIOCATMARK, &atmark);
        if (success < 0) {
            perror ("ioctl");
        }

        if (atmark) {
            /*  有标记，（可能还没到达）但是越过普通数据并没有什么鸟用。
                所以，只好等会了---也许过会就到达了。 */
            sleep(1);
            continue;
        }

        /*  没有标记，读普通数据，并存储它们。
            这样可以确保：带外数据前有普通数据时，可以正确读到带外数据。  */
        success = read(socket, buf, BUF_SZ);
        if (success < 0) {
            perror("read");
        }

        /*  把普通数据保存到 `list`  */
        {
            struct buffer *link
                = (struct buffer *)xmalloc(sizeof(struct buffer));
            link->buf = buf;
            link->size = success;

            /*  Add the new link to the end of the list.  */
            if (tail) {
                tail->next = link; 
            } else {
                list = link;
            }
            tail = link;
        }
    }
}
```