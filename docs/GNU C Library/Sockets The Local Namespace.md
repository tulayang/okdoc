# [本机命名空间](https://www.gnu.org/software/libc/manual/html_node/Local-Namespace.html#Local-Namespace)

本节聊聊本机命名空间，它的符号名是 `PF_LOCAL` （创建套接字时需要）。本机命名空间也称为 “Unix domain sockets”。另一个称谓是 “文件命名空间”---因为它的套接字是基于文件实现的。

本机命名空间，它的套接字地址存储的是文件名。你可以指定任何文件名作为套接字地址，但是必须拥有父目录的写权限。根据国际惯例，通常使用 */tmp* 目录来放置这些文件。

本机命名空间的一个特点是：名字只能在打开连接的时候使用；一旦地址无效就不再存在。

另一个特点是：你不能从其他机器连接到这样的套接字---就算其他机器和套接字所在的机器共享文件系统，也不行。你能在目录列表中看到这个套接字，但是无法连接。一些程序可能利用这个特性，比如要求客户端发送它自己的进程号，然后使用这个进程号来区分客户端。然而，我们建议你不要这么用，因为有天我们可能会把它实现为可以与其他机器连接。

一旦你关闭了本机命名空间的套接字，你应该从文件系统删除文件名。使用 `unlink()` 或 `remove()` 即可。

对于本机命名空间，不管采用何种通信方式，只支持通信方式的一个协议。请将协议设为 `0`。

## 命名空间

调用 socket() 或 socketpair() 时，指定 `PF_LOCAL`、`PF_UNIX` 或 `PF_FILE` 则创建本机命名空间的套接字。

###: #include &lt;sys/socket.h&gt;

```c
#include <sys/socket.h>
```

###: PF_LOCAL

```c
int PF_LOCAL
```

* Macro

`PF_LOCAL` 指定本机命名空间。它是 POSIX.1g 制定的。

###: PF_UNIX

```c
int PF_UNIX
```

* Macro

`PF_UNIX` 是 `PF_LOCAL` 的同义。它用来兼容其他系统。 

###: PF_FILE

```c
int PF_FILE
```

* Macro

`PF_FILE` 是 `PF_LOCAL` 的同义。它用来兼容其他系统。 

###

## 套接字地址

###: #include &lt;sys/un.h&gt;

```c
#include <sys/un.h>
```

###: struct sockaddr_un

```c
struct sockaddr_un;
```

* Data Type

`struct sockaddr_un` 用来表示本机命名空间的套接字地址。它的成员如下：

* `short int sun_family;` 标识是什么样的套接字地址。应该置为 `AF_LOCAL`。

* `char sun_path[108];` 使用的文件名。

  备注：为什么是 108？  RMS 建议把它设成 0 长度的数组，并使用 `alloca()` 调整它的长度。

> 你应该计算 `sun_family` 和 文件名的字符串长度（不是分配的长度）占用的总空间，以便于创建套接字。调用 `SUN_LEN()` 可完成该任务。

###: SUN_LEN()

```c
int SUN_LEN(struct sockaddr_un *ptr);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Macro

`SUN_LEN()` 宏计算套接字地址 `ptr` 的长度。

###

## 来看个例子

```c
#include <stddef.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>

int make_named_socket(const char *filename) {
    struct sockaddr_un name;
    int sock;
    size_t size;

    /*  创建套接字  */
    sock = socket(PF_LOCAL, SOCK_DGRAM, 0);
    if (sock < 0) {
        perror("socket");
        exit(EXIT_FAILURE);
    }

    /*  设定套接字地址  */
    name.sun_family = AF_LOCAL;
    strncpy(name.sun_path, filename, sizeof(name.sun_path));
    name.sun_path[sizeof(name.sun_path) - 1] = '\0';

    /*  
        占用的空间是：
            size = 文件名偏移量 + 文件名长度（不包括终止符）
        也可以用我们的宏计算：
            size = SUN_LEN(&name);
   */
    size = (offsetof(struct sockaddr_un, sun_path) + strlen(name.sun_path));

    if (bind(sock, (struct sockaddr *)&name, size) < 0) {
        perror("bind");
        exit(EXIT_FAILURE);
    }

    return sock;
}
```