# [因特网命名空间](https://www.gnu.org/software/libc/manual/html_node/Internet-Namespace.html#Internet-Namespace)

本节聊聊因特网命名空间，谈谈它已经实现的协议族，以及采用的套接字地址。

最初，因特网命名空间只使用 IP version 4 （IPv4）。随着网络主机的增长，我们需要更大的地址空间：IP version 6 (IPv6)。IPv4 采用 32-bit 地址，而 IPv6 采用 128-bit 地址，并加入一些新的特性，在未来将取代 IPv4。

因特网命名空间的套接字地址，包含下列两项：

* 主机地址
* 主机端口号

## 命名空间

调用 `socket()` 或 `socketpair()` 时，指定 `PF_INET` 则创建 IPv4 因特网命名空间的套接字，指定 `PF_INET6` 则创建 IPv6 因特网命名空间的套接字。

###: #include &lt;sys/socket.h&gt;

```c
#include <sys/socket.h>
```

###: PF_INET

```c
int PF_INET
```

* Macro

`PF_INET` 指定 IPv4 因特网命名空间和相关协议族。

###: PF_INET6

```c
int PF_INET6
```

* Macro

`PF_INET6` 指定 IPv6 因特网命名空间和相关协议族。 

###

## 套接字地址

在因特网命名空间中，IPv4 （`AF_INET`） 和 IPv6 （`AF_INET6`） 套接字地址由主机地址和主机端口号组成。此外，指定的协议也作为套接字地址的一部分，因为端口号是和协议对应的---特定的端口号，使用特定的协议。

###: #include &lt;netinet/in.h&gt;

```c
#include <netinet/in.h>
```

###: struct sockaddr_in

```c
struct sockaddr_in
```

* Data Type

`struct sockaddr_in` 用来表示 IPv4 因特网命名空间的套接字地址。它有下列成员：

* `sa_family_t sin_family;` 标识是什么样的套接字地址。应该置为 `AF_INET`。

* `struct in_addr sin_addr;` 主机地址。

* `unsigned short int sin_port;` 主机端口号。

> 当调用 `bind()` 或 `getsockname()`，你应该指定 `sizeof(struct sockaddr_in)` 作为 `length` 参数。

###: struct sockaddr_in6

```c
struct sockaddr_in6
```

* Data Type

`struct sockaddr_in6` 用来表示 IPv6 因特网命名空间的套接字地址。它有下列成员：

* `sa_family_t sin6_family;` 标识是什么样的套接字地址。应该置为 `AF_INET6`。

* `struct in6_addr sin6_addr;` 主机地址。

* `uint32_t sin6_flowinfo;` 当前未启用该字段。

* `unsigned short int sin_port;` 主机端口号。

> 当调用 `bind()` 或 `getsockname()`，你应该指定 `sizeof(struct sockaddr_in6)` 作为 `length` 参数。      

###

## 主机地址

每台机器有一个或多个主机地址---因特网地址，这些地址由数字组成。IPv4 主机地址由 `.` 分隔，比如 `128.52.46.32`。IPv6 主机地址由 `:` 分隔，比如 `5f03:1200:836f:c100::1`。

早期，IPv4 主机地址是基于分类的地址，由两部分组成：网络号和本网号。在 20 世纪 90 年代中期引入了无类地址，从而改变了这种形式。由于历史原因，一些函数内部依赖旧的地址，在这里，我们首先描述分类地址，然后描述无类地址。IPv 6 主机地址只使用无类地址。

每台机器也有一个或多个主机名，由字符串组成，以 `.` 分隔，比如 `www.gnu.org`。通常，程序要求用户指定主机地址或主机名。打开一个连接只能用主机地址，这时候必须把主机名转换成主机地址。

### IPv4 分类地址

IPv 4 基于分类的主机地址，包含 `32bit` 数据，其网络号由一个、二个或三个字节组成，剩下的字节是本网号。网络号由网络信息中心（NIC）注册，并且划分为三类---A、B、C。本网号由机器的管理员自行注册。

A 类地址的网络号是一个单字节数字，范围是 0 ~ 127。A 类网络号虽然范围很小，但是却能支撑大量的主机。B 类地址的网络号是一个两字节数字，第一个字节的范围是 128 ~ 191。C 类地址的网络号是一个三字节数字，第一个字节的范围是 192 ~ 255。

A 类地址 `0` 是保留地址，用于广播到全网。In addition, the host number 0 within each network is reserved for broadcast to all hosts in that network. These uses are obsolete now but for compatibility reasons you shouldn’t use network 0 and host number 0. 

A 类地址 `127` 是保留地址，用于环回。你可以使用 `127.0.0.1` 来引用主机。

机器可以是多个网络的成员，因此，机器可以有多个因特网主机地址。然而，不存在多个主机有相同的主机地址。

有四种方式表示因特网地址：

* `a.b.c.d` 单独指定四个字节，是常用的表示方法。

* `a.b.c` 最后一个 `c` 作为两个字节。指定 B 类地址比较方便。

* `a.b` 最后一个 `b` 作为三个字节。指定 A 类地址比较方便。

* `a` 直接指定地址数字。

在主机地址的每个部分，都可以基于进制计数。也就是说，以 `0x` 或 `0X` 开头表示十六进制，以 `0` 开头表示八进制，其他则是十进制。

### IPv4 无类地址

IPv4 主机地址现在是无类地址，A、B、C 类地址的区别被忽略。代替的是，IPv 4 主机地址由 `32bit` 地址和 `32bit` 掩码组成。掩码包括：设定位，表示网络部分；清除位，表示主机部分。网络部分从左开始，剩余的是主机部分。根据这个规则，只需要设定掩码的设定位。A、B、C 类地址可以非常容易的适用这个规则。比如，对于 A 类地址，其掩码可以是 `255.0.0.0` （只要设定前 8 位就可以）。

Classless IPv4 network addresses are written in numbers-and-dots notation with the prefix length appended and a slash as separator. For example the class A network 10 is written as `10.0.0.0/8`. 

### IPv6 无类地址

IPv6 主机地址包含 `128bit` 数据。通常写作八个 `16bit` 十六进制数字，以 `:` 分隔。`::` 是缩写，表示连续的 `0`。比如，IPv6 环回地址 `0:0:0:0:0:0:0:1` 可以写作 `::1`。

###: #include &lt;netinet/in.h&gt;

```c
#include <netinet/in.h>
```

###: struct in_addr

```c
struct in_addr 
```

* Data Type

`struct in_addr` 用来表示 IPv4 主机地址。它有下列成员：

* `uint32_t s_addr;` 存储主机地址（二进制数字）。

###: INADDR_LOOPBACK

```c
uint32_t INADDR_LOOPBACK
```

* Macro

`INADDR_LOOPBACK` 表示 IPv4 主机地址 `127.0.0.1`，通常也称为 “localhost”，即环回地址。This special constant saves you the trouble of looking up the address of your own machine. Also, the system usually implements `INADDR_LOOPBACK` specially, avoiding any network traffic for the case of one machine talking to itself. 

###: INADDR_ANY

```c
uint32_t INADDR_ANY
```

* Macro

`INADDR_ANY` 表示 IPv4 主机地址 `0.0.0.0`，即未指明的地址。You can use this constant to stand for “any incoming address” when binding to an address. 当你想要接受因特网连接时，将它指定为 `struct sockaddr_in` 成员 `sin_addr` 的主机地址---这是一个很常用的方法。

###: INADDR_BROADCAST

```c
uint32_t INADDR_BROADCAST
```

* Macro

`INADDR_BROADCAST` 用来广播消息。

###: INADDR_NONE

```c
uint32_t INADDR_NONE
```

* Macro

`INADDR_NONE` 用来在某些函数中返回，表示一个错误。

###: struct in6_addr

```c
struct in6_addr 
```

* Data Type

`struct in6_addr` 用来表示 IPv6 主机地址。它有下列成员：

* `uint8_t s6_addr[16];` 存储主机地址（二进制数字）。

###: in6addr_loopback

```c
struct in6_addr in6addr_loopback
```

* Macro

`in6addr_loopback` 表示 IPv6 主机地址 `::1`，即环回地址。参看上面的描述。

###: in6addr_any

```c
struct in6_addr in6addr_any
```

* Macro

`in6addr_any` 表示 IPv6 主机地址 `::`，即未指明的地址。参看上面的描述。

###: #include &lt;arpa/inet.h&gt;

```c
#include <arpa/inet.h>
```

###: inet_aton()

```c
int inet_aton(const char *name, struct in_addr *addr);
```

* Preliminary: | MT-Safe locale | AS-Safe | AC-Safe |
* Function

`inet_aton()` 函数把字符串 `name` 转换为 IPv4 主机地址（网络字节序），存储到 `addr`。如果地址无效，返回 `非 0`；否则，返回 `0`。

###: inet_ntoa()

```c
char *inet_ntoa(struct in_addr addr);
```

* Preliminary: | MT-Safe locale | AS-Safe | AC-Safe |
* Function

`inet_ntoa()` 函数把 `addr` 存储的 IPv4 主机地址（网络字节序）转换为字符串，并返回。返回值是一个指针，指向一个静态分配的缓冲区。后续调用会重写这个缓冲区，所以，如果需要保存的话，你应该复制这个字符串。

在多线程，每个线程有自己的静态分配缓冲区。同一线程的后续调用会重写缓冲区。

推荐使用下面的 `inet_ntop()` 函数，因为 `inet_ntop()` 可以同时处理 IPv4 和 IPv6 主机地址。

###: inet_makeaddr()

```c
struct in_addr inet_makeaddr(uint32_t net, uint32_t local);
```

* Preliminary: | MT-Safe locale | AS-Safe | AC-Safe |
* Function

`inet_makeaddr()` 函数通过网络号（主机字节序）和本网号（主机字节序），构造一个 IPv4 主机地址（网络字节序）。

###: inet_pton()

```c
int inet_pton(int af, const char *cp, void *buf);
```

* Preliminary: | MT-Safe locale | AS-Safe | AC-Safe |
* Function

`inet_pton()` 函数把字符串 `cp` 转换为 IPv4 或 IPv6 主机地址（网络字节序），存储到 `buf` （`struct in_addr *` 或 `struct in6_addr *`）。`af` 指定 `AF_INET` 或 `AF_INET6`。调用者应该确保 `buf` 的长度足够大。如果地址无效，返回 `非 0`；否则，返回 `0`。

###: inet_ntop()

```c
const char *inet_ntop(int af, const void *cp, char *buf, socklen_t len);
```

* Preliminary: | MT-Safe locale | AS-Safe | AC-Safe |
* Function

`inet_ntop()` 函数把 `cp` （`struct in_addr *` 或 `struct in6_addr *`） 存储的 IPv4 或 IPv6 主机地址（网络字节序）转换为字符串，存储到 `buf`。`af` 指定 `AF_INET` 或 `AF_INET6`。`len` 指定 `buf` 的长度。如果地址无效，返回一个空指针；否则，返回 `buf`。

###: --- 下列函数是过时的 ---

###: inet_addr()

```c
uint32_t inet_addr(const char *name);
```

* Preliminary: | MT-Safe locale | AS-Safe | AC-Safe |
* Function

`inet_addr()` 函数把字符串 `name` 转换为 IPv4 主机地址（网络字节序），并返回。如果地址无效，返回 `INADDR_NONE`。这个函数是过时的，请使用上面的 `inet_aton()`。

`INADDR_NONE` 的值通常是 `-1`，表示 `255.255.255.255`。现在 `255.255.255.255` 是一个有效的主机地址，`INADDR_NONE` 不再适用，所以 `inet_addr()` 已经过时。

###: inet_network()

```c
uint32_t inet_network(const char *name);
```

* Preliminary: | MT-Safe locale | AS-Safe | AC-Safe |
* Function

`inet_network()` 函数提取 IPv4 主机地址 `name` 的网络号（主机字节序）。如果地址无效，返回 `-1`。这个函数只对分类 IPv4 地址有效，对无类地址无效，不应该再使用了。

###: inet_netof()

```c
uint32_t inet_netof(struct in_addr addr);
```

* Preliminary: | MT-Safe locale | AS-Safe | AC-Safe |
* Function

`inet_netof()` 函数返回 `addr` 存储的 IPv4 主机地址（网络字节序）的网络号（主机字节序）。这个函数只对分类 IPv4 地址有效，对无类地址无效，不应该再使用了。

###: inet_lnaof()

```c
uint32_t inet_lnaof(struct in_addr addr);
```

* Preliminary: | MT-Safe locale | AS-Safe | AC-Safe |
* Function

`inet_lnaof()` 函数返回 `addr` 存储的 IPv4 主机地址（网络字节序）的本网号（主机字节序）。这个函数只对分类 IPv4 地址有效，对无类地址无效，不应该再使用了。

###: ----------------------

###

## 主机数据库

主机名的优点是更方便记忆。比如，GNU 服务器的主机地址是 `158.121.106.19`，主机名是 `alpha.gnu.org`。

在系统内部，使用一个数据库来记录主机名和主机地址的映射关系。这个数据库，通常存储在 */et/hosts* 文件，或者由一个命名服务器提供。声明在头文件 `<netdb.h>` 的许多函数和符号，可以访问这个数据库。

###: #include &lt;netdb.h&gt;

```c
#include <netdb.h>
```

###: struct hostent

```c
struct hostent;
```

* Data Tye

`struct hostent` 用来表示主机数据库的一条记录。它有下列成员：

* `char *h_name;` 正式的主机名字。

* `char **h_aliases` 备选的主机名字，一个字符串矢量。这个矢量有一个终止符。

* `int h_addrtype` 主机地址的分类，这个值总是 `AF_INET` 或 `AF_INET6`。技术上，这个值可以是其他分类的地址。

* `int h_length;` 每个主机地址的字节长度。

* `char **h_addr_list;` 主机地址列表，一个字符串矢量。（一台主机可能连接多个网络，每个对应不同的主机地址）。这个矢量有一个终止符。

* `char *h_addr` 是 `h_addr_list[0]` 的同义词，即第一个主机地址。

对主机数据库而言，每个地址存储在 `h_length` 字节的内存空间。但是，你可以把 IPv4 地址转换为 `struct in_addr` 或 `uint32_t`。`struct hostent` 存储的主机地址，总是网络字节序。

你可以下面的函数获取数据库记录，返回的记录存储在一个静态分配的缓冲区，如果需要保存信息，你必须复制它。

###: gethostbyname()

```c
struct hostent *gethostbyname(const char *name);
```

* Preliminary: | MT-Unsafe race:hostbyname env locale | AS-Unsafe dlopen plugin corrupt heap lock | AC-Unsafe lock corrupt mem fd |
* Function

`gethostbyname()` 函数返回主机名 `name` 的一条记录。如果查找失败，返回一个空指针。

> `gethostbyname()` 函数是不可重入的。

###: gethostbyname2()

```c
struct hostent *gethostbyname2(const char *name, int af);
```

* Preliminary: | MT-Unsafe race:hostbyname2 env locale | AS-Unsafe dlopen plugin corrupt heap lock | AC-Unsafe lock corrupt mem fd |
* Function

`gethostbyname2()` 函数类似 `gethostbyname()`，但是允许指定 `af` 是 `AF_INE` 或 `AF_INET6`。

> `gethostbyname2()` 函数是不可重入的。

###: gethostbyaddr()

```c
struct hostent *gethostbyaddr(const void *addr, socklen_t length, int format);
```

* Preliminary: | MT-Unsafe race:hostbyaddr env locale | AS-Unsafe dlopen plugin corrupt heap lock | AC-Unsafe lock corrupt mem fd |
* Function

`gethostbyaddr()` 函数返回主机地址 `addr` （`struct in_addr *` 或 `struct in6_addr *`） 的一条记录。`length` 指定 `addr` 的长度。`format` 指定 `AF_INE` 或 `AF_INET6`。

如果查找失败，返回一个空指针。

如果 `gethostbyname()` 或 `gethostbyaddr()` 查找失败，你可以通过查看 `h_errno` 变量的值找到原因。相关的 `h_errno` 值如下所示：

* `HOST_NOT_FOUND` 数据库中没有这个主机。

* `TRY_AGAIN` 当服务器无法联系时发生。如果你稍后再次尝试，可能会成功。

* `NO_RECOVERY` 出现不可恢复的错误。

* `NO_ADDRESS` 数据库包含该主机名的一条记录，但是它没有关联主机地址。

> `gethostbyaddr()` 函数是不可重入的。

###: gethostbyname_r()

```c
int gethostbyname_r(const char *restrict name, struct hostent *restrict result_buf, char *restrict buf, size_t buflen, struct hostent **restrict result, int *restrict h_errnop);
```

* Preliminary: | MT-Safe env locale | AS-Unsafe dlopen plugin corrupt heap lock | AC-Unsafe lock corrupt mem fd |
* Function

`gethostbyname_r()` 函数返回主机名 `name` 的一条记录，存储到 `result_buf`。`buf` 是临时缓冲区，`buflen` 指定 `buf` 的长度。`h_errnop` 存储查找过程的错误码。

当执行成功时，记录被存储，`*result` 会存储缓冲区的指针。如果出现错误或没有找到记录，`*result` 是空指针。执行成功时返回 `0`；失败返回错误码。如果错误码是 `ERANGE`，表示缓冲区空间太小，你应该重调大小再次调用。 例子：

```c
struct hostent *gethostname(char *host) {
      struct hostent *hostbuf, *hp;
      size_t hstbuflen;
      char *tmphstbuf;
      int res;
      int herr;

      hostbuf = malloc(sizeof(struct hostent));
      hstbuflen = 1024;
      tmphstbuf = malloc(hstbuflen);

      while ((res = gethostbyname_r(host, hostbuf, tmphstbuf, hstbuflen,
                                    &hp, &herr)) == ERANGE) {
          /* Enlarge the buffer.  */
          hstbuflen *= 2;
          tmphstbuf = realloc(tmphstbuf, hstbuflen);
      }

      free(tmphstbuf);
      /*  Check for errors.  */
      if (res || hp == NULL) {
            return NULL;
      }
      return hp;
}
```

> `gethostbyname_r()` 函数是可重入的。

###: gethostbyname2_r()

```c
int gethostbyname2_r(const char *name, int af, struct hostent *restrict result_buf, char *restrict buf, size_t buflen, struct hostent **restrict result, int *restrict h_errnop);
```

* Preliminary: | MT-Safe env locale | AS-Unsafe dlopen plugin corrupt heap lock | AC-Unsafe lock corrupt mem fd |
* Function

`gethostbyname2_r()` 函数类似 `gethostbyname_r()` 函数，但是允许指定 `af` 是 `AF_INE` 或 `AF_INET6`。

> `gethostbyname2_r()` 函数是可重入的。

###: gethostbyaddr_r()

```c
int gethostbyaddr_r(const void *addr, socklen_t length, int format, struct hostent *restrict result_buf, char *restrict buf, size_t buflen, struct hostent **restrict result, int *restrict h_errnop);
```

* Preliminary: | MT-Safe env locale | AS-Unsafe dlopen plugin corrupt heap lock | AC-Unsafe lock corrupt mem fd | 
* Function

`gethostbyaddr_r()` 函数返回主机地址 `addr` （`struct in_addr *` 或 `struct in6_addr *`） 的一条记录，存储到 `result_buf`。`buf` 是临时缓冲区，`buflen` 指定 `buf` 的长度。`format` 指定 `AF_INE` 或 `AF_INET6`。`h_errnop` 存储查找过程的错误码。

调用过程类似 `gethostbyname_r()` 函数。

> `gethostbyaddr_r()` 函数是可重入的。

###: sethostent()

```c
void sethostent(int stayopen);
```

* Preliminary: | MT-Unsafe race:hostent env locale | AS-Unsafe dlopen plugin heap lock | AC-Unsafe corrupt lock fd mem |
* Function

`sethostent()` 函数打开主机数据库，准备扫描。你可以调用 `gethostent()` 读取一条记录。

如果 `stayopen` 是 `非 0`，会设定一个标志，后续调用 `gethostbyname()` 或 `gethostbyaddr()` 等函数不会关闭数据库（通常它们会关闭数据库）。如果你多次调用这些函数，这个标志可以避免关闭再打开。

> `gethostbyaddr_r()` 函数是不可重入的。

###: gethostent()

```c
struct hostent *gethostent(void);
```

* Preliminary: | MT-Unsafe race:hostent race:hostentbuf env locale | AS-Unsafe dlopen plugin heap lock | AC-Unsafe corrupt lock fd mem |
* Function

`gethostent()` 函数返回主机数据库的下一条记录。如果没有更多记录，返回一个空指针。

> `gethostbyaddr_r()` 函数是不可重入的。

###: endhostent()

```c
void endhostent(void);
```

* Preliminary: | MT-Unsafe race:hostent env locale | AS-Unsafe dlopen plugin heap lock | AC-Unsafe corrupt lock fd mem |
* Function

`endhostent()` 关闭主机数据库。

> `gethostbyaddr_r()` 函数是不可重入的。

###

## 主机端口号

套接字地址的主机端口号，用来区分机器的套接字。端口号的范围是 `0 ~ 65535`。

小于 `IPPORT_RESERVED` 的端口号作为保留，用于标准服务器，比如 **finger** 和 **telnet**。有一个数据库负责记录，你可以调用 `getservbyname()` 把服务名映射到端口号。

如果你在写一个服务器，而它并非定义在数据库的标准服务，那么你必须为它选定一个端口号---挑选一个大于 `IPPORT_USERRESERVED` 的号码。当你挑选的时候，注意与其他服务发生冲突---不要用它们正在使用的端口号。

对于因特网，从技术上来讲，两个不同的套接字可以拥有相同的端口号，只要它们不同时和同一个套接字地址通信。

想要重用一个端口号，必须设定套接字选项 `SO_REUSEADDR`---当套接字关闭后，该端口号可被其他套接字使用。

###: #include &lt;netinet/in.h&gt;

```c
#include <netinet/in.h>
```

###: IPPORT_RESERVED

```c
int IPPORT_RESERVED
```

* Macro

小于 `IPPORT_RESERVED` 的端口号作为标准服务使用。

###: IPPORT_USERRESERVED

```c
int IPPORT_USERRESERVED
```

* Macro

大于等于 `IPPORT_USERRESERVED` 的端口号作为其他用途，系统不会自动分配。

###

## 服务数据库

服务数据库记录标准的服务，通常存储在 */etc/services* 文件，或者由一个命名服务器提供。你可以使用 `<netdb.h>` 的工具，访问服务数据库。

###: #include &lt;netdb.h&gt;

```c
#include <netdb.h>
```

###: struct servent

```c
struct servent;
```

* Data Type

`struct servent` 用来存储服务数据库的一条记录。它有以下成员：

* `char *s_name;` 正式的服务名字。

* `char **s_aliases;` 备选的服务名字，一个字符串矢量。这个矢量有一个终止符。

* `int s_port;` 服务的端口号。以网络字节序表示。

* `char *s_proto;` 服务使用的协议名字。

你可以下面的函数获取数据库记录，返回的记录存储在一个静态分配的缓冲区，如果需要保存信息，你必须复制它。

###: getservbyname()

```c
struct servent *getservbyname(const char *name, const char *proto);
```

* Preliminary: | MT-Unsafe race:servbyname locale | AS-Unsafe dlopen plugin heap lock | AC-Unsafe corrupt lock fd mem |
* Function

`getservbyname()` 函数返回服务名 `name` 的一条记录。如果查找失败，返回一个空指针。

你可以使用这个函数确定服务器所监听的端口号。

> `getservbyname()` 函数是不可重入的。

###: getservbyport()

```c
struct servent *getservbyport(int port, const char *proto);
```

* Preliminary: | MT-Unsafe race:servbyport locale | AS-Unsafe dlopen plugin heap lock | AC-Unsafe corrupt lock fd mem |
* Function

`getservbyport()` 函数返回服务的端口号 `port` 的一条记录。`proto` 指定协议名。如果查找失败，返回一个空指针。

> `getservbyport()` 函数是不可重入的。

###: setservent()

```c
void setservent(int stayopen);
```

* Preliminary: | MT-Unsafe race:servent locale | AS-Unsafe dlopen plugin heap lock | AC-Unsafe corrupt lock fd mem |
* Function

`setservent()` 函数打开服务器，准备扫描。

如果 `stayopen` 是 `非 0`，会设定一个标志，后续调用 `getservbyname()` 或 `getservbyport()` 函数不会关闭数据库（通常它们会关闭数据库）。如果你多次调用这些函数，这个标志可以避免关闭再打开。

> `setservent()` 函数是不可重入的。

###: getservent()

```c
struct servent *getservent(void);
```

* Preliminary: | MT-Unsafe race:servent race:serventbuf locale | AS-Unsafe dlopen plugin heap lock | AC-Unsafe corrupt lock fd mem |
* Function

`getservent()` 函数返回数据库的下一条记录。如果没有更多记录，返回一个空指针。

> `setservent()` 函数是不可重入的。

###: endservent()

```c
void endservent(void);
```

* Preliminary: | MT-Unsafe race:servent locale | AS-Unsafe dlopen plugin heap lock | AC-Unsafe corrupt lock fd mem |
* Function

`endservent()` 函数关闭数据库。

> `endservent()` 函数是不可重入的。

###

## 字节序

字节序，指字节的存储顺序。不同的处理器架构可能使用不同的字节序。有些把高位字节存储在字的最开始（低地址），称为 “大端序”；其他则把高位字节存储在字的最后（高地址），称为 “小端序”。这被称为 “主机字节序”。

比如，`int a = 0x12345678;`，12 是高位字节，78 是低位字节，从左到右，由高到低。

因此，当采用不同字节序的机器通信时，因特网协议指定一个统一的字节序，以便于输出传输。这被称为 “网络字节序”。

当建立一个套接字连接，你必须确保套接字地址 `sockaddr_in` 的 `sin_port` 和 `sin_addr` 以网络字节序表示。如果你通过套接字发送编码的整数数据，你也应该将其转换为网络字节序。如果你不这样做，程序可能会出现错误。

当你调用 `getservbyname()`、`gethostbyname()`、`inet_addr()` 获取端口号和主机地址时，返回的值总是网络字节序，你可以直接把它们复制到 `sockaddr_in`。

否则，你必须明确地转换它们的值。调用 `htons()`、`ntohs()`，转换 `sin_port` 值。调用 `htonl()`、`ntohl()`，转换 `sin_addr` 值。（记住，`struct in_addr` 相当于 `uint32_t`）。

###: #include &lt;netinet/in.h&gt;

```c
#include <netinet/in.h>
```

###: htons()

```c
uint16_t htons(uint16_t hostshort);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function 

`htons()` 函数把主机字节序的端口号 `hostshort` 转换为网络字节序。

###: ntohs()

```c
uint16_t ntohs(uint16_t netshort);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function 

`ntohs()` 函数把网络字节序的端口号 `netshort` 转换为主机字节序。

###: htonl()

```c
uint32_t htonl(uint32_t hostlong);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function 

`htonl()` 函数把主机字节序的 IPv4 主机地址 `hostlong` 转换为网络字节序。

###: ntohl()

```c
uint32_t ntohl(uint32_t netlong);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function 

`ntohl()` 函数把网络字节序的 IPv4 主机地址 `hostlong` 转换为主机字节序。

###

## 协议数据库

套接字使用通信协议，决定底层数据如何交换。比如，协议实现传输中的错误校验、路由指示。通常，没有理由让普通用户程序直接操控这些细节。

因特网命名空间默认的通信协议依赖通信方式。对于流式通信方式（`SOCK_STREAM`），默认是 `TCP` （传输控制协议）。对于数据报通信方式（`SOCK_DGRAM`），默认是 `UDP` （用户数据包协议）。对于可靠数据报通信方式（`SOCK_SEQPACKET`），默认是 `RDP`。你应该几乎总是使用默认的协议---置为 `0`。

通常使用一个符号名指定协议。有一个数据库负责记录协议。通常存储在 */etc/protocols* 文件，或者由一个命名服务器提供。你可以使用 `<netdb.h>` 的工具，访问协议数据库。

###: #include &lt;netdb.h&gt;

```c
#include <netdb.h>
```

###: struct protoent

```c
struct protoent;
```

* Data Type

`struct protoent` 用来存储协议数据库的一条记录。它有以下成员：

* `char *p_name;` 正式的协议名字。

* `char **p_aliases;` 备选的协议名字，一个字符串数组。最后一个成员是一个终止符。

* `int p_proto;` 协议号。以主机字节序表示。使用这个值作为 `socket()` 的协议参数。

你可以下面的函数获取数据库记录，返回的记录存储在一个静态分配的缓冲区，如果需要保存信息，你必须复制它。

###: getprotobyname()

```c
struct protoent *getprotobyname(const char *name);
```

* Preliminary: | MT-Unsafe race:protobyname locale | AS-Unsafe dlopen plugin heap lock | AC-Unsafe corrupt lock fd mem |
* Function

`getprotobyname()` 函数返回协议名 `name` 的一条记录。如果查找失败，返回一个空指针。

> `getprotobyname()` 函数是不可重入的。

###: getprotobynumber()

```c
struct protoent *getprotobynumber(int protocol);
```

* Preliminary: | MT-Unsafe race:protobynumber locale | AS-Unsafe dlopen plugin heap lock | AC-Unsafe corrupt lock fd mem |
* Function

`getprotobynumber()` 函数返回协议号 `protocol` 的一条记录。如果查找失败，返回一个空指针。

> `getprotobynumber()` 函数是不可重入的。

###: setprotoent()

```c
void setprotoent(int stayopen);
```

* Preliminary: | MT-Unsafe race:protoent locale | AS-Unsafe dlopen plugin heap lock | AC-Unsafe corrupt lock fd mem |
* Function

`setprotoent()` 函数打开数据器，准备扫描。

如果 `stayopen` 是 `非 0`，会设定一个标志，后续调用 `getprotobyname()` 或 `getprotobynumber()` 函数不会关闭数据库（通常它们会关闭数据库）。如果你多次调用这些函数，这个标志可以避免关闭再打开。

> `setprotoent()` 函数是不可重入的。

###: getprotoent()

```c
struct protoent *getprotoent(void);
```

* Preliminary: | MT-Unsafe race:protoent race:protoentbuf locale | AS-Unsafe dlopen plugin heap lock | AC-Unsafe corrupt lock fd mem |
* Function

`getprotoent()` 函数返回数据库的下一条记录。如果没有更多记录，返回一个空指针。

> `getprotoent()` 函数是不可重入的。

###: endprotoent()

```c
void endprotoent(void);
```

* Preliminary: | MT-Unsafe race:protoent locale | AS-Unsafe dlopen plugin heap lock | AC-Unsafe corrupt lock fd mem |
* Function

`endprotoent()` 函数关闭数据库。

> `endprotoent()` 函数是不可重入的。

###

## 因特网套接字例子

这儿有个例子，演示了如何创建因特网命名空间的套接字。这个例子没有查找使用机器的主机地址，而是指定 `INADDR_ANY` 作为主机地址，系统会把它替换为机器实际的地址：

```c
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <netinet/in.h>

int make_socket (uint16_t port) {
    int sock;
    struct sockaddr_in name;

    /* 创建套接字 */
    sock = socket(PF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        perror ("socket");
        exit (EXIT_FAILURE);
    }

    /* 设定套接字地址 */
    name.sin_family = AF_INET;
    name.sin_port = htons(port);
    name.sin_addr.s_addr = htonl(INADDR_ANY);
    if (bind(sock, (struct sockaddr *)&name, sizeof(name)) < 0) {
        perror("bind");
        exit(EXIT_FAILURE);
    }

    return sock;
}
```

这儿有个例子，演示了如何通过主机名和端口号填充 `sockaddr_in` 结构：

```c
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

void init_sockaddr (struct sockaddr_in *name, const char *hostname, uint16_t port) {
    struct hostent *hostinfo;

    name->sin_family = AF_INET;
    name->sin_port = htons(port);
    hostinfo = gethostbyname(hostname);
    if (hostinfo == NULL) {
        fprintf (stderr, "Unknown host %s.\n", hostname);
        exit (EXIT_FAILURE);
    }
    name->sin_addr = *(struct in_addr *)hostinfo->h_addr;
}
``` 