# [数据报套接字](https://www.gnu.org/software/libc/manual/html_node/Datagrams.html#Datagrams)

本节聊聊无连接通信方式---数据报套接字（通信方式是 `SOCK_DGRAM` 和 `SOCK_RDM`）。在这种通信方式，数据被打包，并且每个包传输是一个独立的通信。你需要为每个包单独地指定目的地。

每个包被单独地发送，它可能会到达目的地，也可能不会，各个包到达的顺序也是混乱的。

`listen()` 和 `accept()` 不能用在无连接通信方式。

## 发送数据报消息

通常，数据报套接字发送数据需要使用 `sendto()` 函数，声明在头文件 `<sys/socket.h>`。

你可以调用 `connect()` 函数连接一个数据报套接字，但是这样只会为后续的包指定默认的目的地。当套接字有默认的目的地时，你可以调用 `send()` 或 `write()` 发送包。你可以在调用 `connect()` 时指定 `AF_UNSPEC` 格式的套接字地址，以取消默认目的地。 

###: #include &lt;sys/socket.h&gt;

```c
#include <sys/socket.h>
```

###: sendto()

```c
ssize_t sendto(int socket, const void *buffer, size_t size, int flags, struct sockaddr *addr, socklen_t length);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`sendto()` 函数通过套接字 `socket`， 把 `buffer` 存储的数据，发送到套接字地址 `addr`。`size` 指定 `buffer` 的长度。`flags` 指定发送模式 [→ 传输数据](/docs/GNU C 标准库手册/Sockets Using Sockets with Connections.md#user-content-13)。`length` 指定 `addr` 的长度。

返回值和错误条件与 `send()` 相同，但是，你不能依赖系统来检查错误。大多数常见错误，是包丢失或者指定的地址没有接收它，操作系统通常不会知道这些细节。

调用 `sendto()` 产生的错误，也有可能是前一个 `sendto()` 调用引起的。

> 对于多线程程序，`sendto()` 函数是一个“取消点”。如果线程在 `sendto()` 被调用时，分配了一些资源（比如内存、文件描述符、信号或者其它），有可能会产生问题。如果该线程被取消了，这些资源仍然会继续存在，直到程序结束。要避免这种情况，应该通过取消处理器保护 `sendto()` 调用。

###

## 接收数据报消息

调用 `recvfrom()` 函数从一个套接字读取包，同时能获知是哪里发送的。


###: #include &lt;sys/socket.h&gt;

```c
#include <sys/socket.h>
```

###: recvfrom()

```c
ssize_t recvfrom(int socket, void *buffer, size_t size, int flags, struct sockaddr *addr, socklen_t *length-ptr);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`recvfrom()` 函数通过套接字 `socket` 接收一个包，存储到 `buffer`，把目标套接字地址存储到 `addr`，把目标套接字地址的长度存储到 `length-ptr`。`size` 指定 `buffer` 的长度---读取的最大值。`flags` 指定接收模式 [→ 传输数据](/docs/GNU C 标准库手册/Sockets Using Sockets with Connections.md#user-content-13)。

如果包比指定的 `size` 大，那么你得到包的前面字节，剩余的字节被丢掉。没有其他办法可以读剩下的字节。因此，你必须确保自己知道包的长度。

对于本机命名空间，请把 `addr` 置为一个空指针---目标套接字地址没有意义。

返回值和错误条件与 `recvfrom()` 相同。

如果你不关心包是哪里发的，可以使用 `recv()`、`read()` 代替 `recvfrom()`。

> 对于多线程程序，`recvfrom()` 函数是一个“取消点”。如果线程在 `recvfrom()` 被调用时，分配了一些资源（比如内存、文件描述符、信号或者其它），有可能会产生问题。如果该线程被取消了，这些资源仍然会继续存在，直到程序结束。要避免这种情况，应该通过取消处理器保护 `recvfrom()` 调用。

###

## 例子 __ 服务器

这儿有个例子，演示了如果通过本机命名空间的数据报套接字发送消息，它用到了 `make_named_socket()` 函数 [→ 本机命名空间](/docs/GNU C 标准库手册/Sockets The Local Namespace.md#user-content-10)。

```c
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <sys/un.h>

#define SERVER  "/tmp/serversocket"
#define MAXMSG  512

int main (void) {
    int sock;
    char message[MAXMSG];
    struct sockaddr_un name;
    size_t size;
    int nbytes;

    /*  先删除文件名，如果调用失败，没有关系  */
    unlink(SERVER);

    /*  创建套接字，然后开始循环  */
    sock = make_named_socket(SERVER);
    for (;;) {
        /*  等待数据报到达  */
        size = sizeof(name);
        nbytes = recvfrom(sock, message, MAXMSG, 0,
                          (struct sockaddr *)&name, &size);
        if (nbytes < 0) {
            perror("recfrom(server)");
            exit(EXIT_FAILURE);
        }

        /*  打印收到的消息  */
        fprintf(stderr, "Server: got message: %s\n", message);

        /*  把消息返回给发送者  */
        nbytes = sendto(sock, message, nbytes, 0,
                        (struct sockaddr *)&name, size);
        if (nbytes < 0) {
            perror("sendto (server)");
            exit(EXIT_FAILURE);
        }
    }
}
```

## 例子 __ 客户端

这儿有个例子，演示了客户端如何通过数据报套接字收发消息：

```c
#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <sys/un.h>

#define SERVER  "/tmp/serversocket"
#define CLIENT  "/tmp/mysocket"
#define MAXMSG  512
#define MESSAGE "Yow!!! Are we having fun yet?!?"

int main (void) {
    extern int make_named_socket(const char *name);
    int sock;
    char message[MAXMSG];
    struct sockaddr_un name;
    size_t size;
    int nbytes;

    /*  创建套接字  */
    sock = make_named_socket(CLIENT);

    /*  初始化服务器套接字地址  */
    name.sun_family = AF_LOCAL;
    strcpy(name.sun_path, SERVER);
    size = strlen(name.sun_path) + sizeof(name.sun_family);

    /*  发送消息  */
    nbytes = sendto(sock, MESSAGE, strlen(MESSAGE) + 1, 0,
                    (struct sockaddr *)&name, size);
    if (nbytes < 0) {
        perror("sendto (client)");
        exit(EXIT_FAILURE);
    }

    /*  等待响应  */
    nbytes = recvfrom(sock, message, MAXMSG, 0, NULL, 0);
    if (nbytes < 0) {
        perror("recfrom (client)");
        exit(EXIT_FAILURE);
    }

    /*  打印收到的消息 */
    fprintf(stderr, "Client: got message: %s\n", message);

    /*  大扫除  */
    remove(CLIENT);
    close(sock);
}
```

记住，数据报套接字的通信是不可靠的。在这个例子，客户端无法确定消息是否到达服务器，还是服务器收到了却没有做出响应。更好的解决方案是用 `select()` 设定一个超时时间，当超时的时候重新发送数据或者关闭套接字。

