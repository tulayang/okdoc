# [套接字地址](https://www.gnu.org/software/libc/manual/html_node/Socket-Addresses.html#Socket-Addresses)

套接字的名字通常称为套接字地址。

调用 `socket()` 创建新的套接字时，套接字还没有地址。想要与其他进程通信，需要调用 `bind()` 为它绑定地址，这样别的进程才能找到它。

你可以为另外的套接字绑定相同的地址，但是这样做通常没什么意义。当你第一次发送数据，或者开始一个连接，所使用的套接字被自动作为系统认定的套接字。

偶尔，客户端需要绑定一个地址（通常不需要），因为服务器要求辨别它们的地址。比如，the rsh and rlogin protocols look at the client’s socket address and only bypass password checking if it is less than `IPPORT_RESERVED`。

套接字地址的结构非常依赖所指定的命名空间。

## 套接字地址格式

`bind()` 和 `getsockname()` 函数使用通用数据类型 `struct sockaddr *`，表示一个指针，指向套接字地址。你无法直接使用此数据类型来解释或构造一个套接字地址，必须使用命名空间对应的数据类型。在调用 `bind()` 或 `getsockname()` 时，将实际套接字地址转换为 `struct sockaddr *`。

###: #include &lt;sys/socket.h&gt;

```c
#include <sys/socket.h>
```

###: struct sockaddr

```c
struct sockaddr
```

* Data Type

`struct sockaddr` 有以下成员：

* `short int sa_family` 地址格式，标识何种套接字地址。

* `char sa_data[14]` 套接字地址的实际数据。它的长度依赖 `sa_family`，可能大于 14。`sa_data` 的长度 `14` 是随意表示一下。

每一个地址格式有一个符号名，以 AF\_ 开头。它们和以 PF\_ 开头的命名空间一一对应。下面是地址格式的汇总：

* `AF_LOCAL` 地址格式属于本地命名空间。（`PF_LOCAL` 是其命名空间）。

* `AF_UNIX` 是 `AF_LOCAL` 的同义词。`AF_LOCAL` 是 POSIX.1 制定的，`AF_UNIX` 兼容更多的系统，来自 BSD，甚至 POSIX 也支持，而且纳入 Unix98 规范。（`AF_UNIX` 是其命名空间）。

* `AF_FILE` 是 `AF_LOCAL` 的同义词，主要为了兼容。（`PF_FILE` 是其命名空间）。

* `AF_INET` 地址格式属于 IPv4 因特网命名空间。（`PF_INET` 是其命名空间）。

* `AF_INET6` 地址格式属于 IPv6 因特网命名空间。（`PF_INET6` 是其命名空间）。

* `AF_UNSPEC` 没有特定地址格式。它只在很少情况下使用，比如清除一个数据包套接字的默认接收地址。（`PF_UNSPEC` 是其对应的命名空间，但是仅仅为了保持完整，不要在程序中使用）。

如果你看看 GNU C 库的 `<sys/socket.h>` 文件，会看到很多 AF_ 开头的符号，其中许多都未实现。我们在文档中只描述那些能工作的。   

###

## 绑定套接字地址

调用 `bind()` 函数为一个套接字绑定地址。

###: #include &lt;sys/socket.h&gt;

```c
#include <sys/socket.h>
```

###: bind()

```c
int bind(int socket, struct sockaddr *addr, socklen_t length);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`bind()` 函数为套接字 `socket` 绑定套接字地址 `addr`。`length` 指定 `addr` 的长度。套接字地址的格式，依赖套接字的命名空间。

执行成功返回 `0`；出错返回 `-1` 并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 指定的 `socket` 不是有效的文件描述符。

* `ENOTSOCK` 指定的 `socket` 不是套接字。

* `EADDRNOTAVAIL` 指定的 `addr` 在本机器上不可用。

* `EADDRINUSE` 其他套接字已经使用了这个地址。

* `EINVAL` 指定的 `socket` 已经绑定了地址。

* `EACCES` 没有足够的权限访问请求的地址。（对于因特网域，只有超级用户允许指定 `0 ~ IPPORT_RESERVED-1` 的端口号）。         

###

## 读取套接字地址

调用 `getsockname()` 函数可以解释一个因特网套接字的地址。

###: #include &lt;sys/socket.h&gt;  

```c
#include <sys/socket.h>
```

###: getsockname()

```c
int getsockname(int socket, struct sockaddr *addr, socklen_t *length-ptr);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe mem/hurd |
* Function

`getsockname()` 函数返回套接字地址的信息，将其存储到 `addr`，信息长度存储到 `length-ptr`。注意：`length-ptr` 是一个指针，你应该初始化它，以便于调用修改它。

地址信息的格式依赖套接字的命名空间。信息长度通常是固定的，与命名空间对应。因此，通常你可以明确的知道需要分配多少空间。分配空间，明智的做法是：使用与命名空间对应的地址数据类型，然后将其转换为 `struct sockaddr *` 传递给 `getsockname()`。

执行成功返回 `0`；出错返回 `-1` 并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 指定的 `socket` 不是有效的文件描述符。

* `ENOTSOCK` 指定的 `socket` 不是套接字。

* `ENOBUFS` 没有足够的内部缓冲区执行操作。

> You can’t read the address of a socket in the file namespace. This is consistent with the rest of the system; in general, there’s no way to find a file’s name from a descriptor for that file. 

###

