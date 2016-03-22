# [守护进程 inetd](https://www.gnu.org/software/libc/manual/html_node/Inetd.html#Inetd)

我们已经聊了一大堆关于服务器的东西，怎么启动监听，怎么接受，怎么传输。

另外一种通过因特网端口提供服务的方法，是让守护进程 **inetd** 进行监听。**inetd** 是一个守护进程，它会一直运行，并且等待一个指定的端口集合（使用 `select()`）。当它收到消息时，它接受连接（如果套接字是该类型的话），然后 `fork` 一个子进程，来运行相应的服务器程序。你可以在 */etc/inetd.conf* 文件指定端口号集合。

## inetd 服务器

写一个基于 **inetd** 的服务器程序非常简单。每当有人请求连接到对应端口，就开始一个新服务器进程。在服务器进程中，套接字作为标准输入描述符和标准输出描述符。通常，程序只需要普通的 IO 设施。

你也可以把 **inetd** 用于无连接的通信方式。这时候，**inetd** 不接受连接。它只会启动服务器程序，该程序可以通过文件描述符 `0` 读取数据报消息。服务器程序可以处理完一次请求就退出；也可以保持读多个请求，直到没有更多的消息到达，然后退出。当你配置 **inetd** 时，你必须指定用哪一种。

## 配置 inetd

配置文件 */etc/inetd.conf* 告诉 **inetd** 监听哪些端口，运行什么样的服务器程序。通常，每一个配置是一行，但是你可以分成多行---后面的每一行以空格开始。以 `#` 开始的行是注释。

看看这个例子：

```?
ftp   stream  tcp  nowait  root  /libexec/ftpd   ftpd
talk  dgram   udp  wait    root  /libexec/talkd  talkd
```

每一项的格式是这样的：

```?
service  style  protocol  wait  username  program  arguments
```

`service` 指定这个程序提供哪种服务。它应该是定义在 */etc/services* 文件的服务名。**inetd** 使用服务名决定监听哪个端口。

`style` 和 `protocol` 为套接字分别指定通信方式和协议。`style` 要写作小写形式，并且删除开头的 `SOCK_`，比如 `stream`、`dgram`。`protocol` 应该是定义在 */etc/protocols* 文件的协议名，字节流的协议名是 `tcp`，数据报的协议名是 `udp`。

`wait` 应该是 `wait` 或 `nowait`。指定 `wait` 时，如果 `style` 是无连接通信方式，当连接请求到来时，服务器程序只启动一次，并处理多个连接请求。指定 `nowait` 时，每当连接请求到来时，启动一个新的进程。如果 `style` 是连接通信方式，`wait` 必须是 `nowait`。

`username` 指定服务器运行的用户名。**inetd** 以超级用户运行，所以它可以设置子进程的用户号。最好不要把 `username` 设定成 `root`。不过，一些服务器，像 Telnet、FTP，它们会要求输入用户名和密码，这些服务器需要 `root`，以确保可以让用户通过口令登录。

`program` 和 `arguments` 指定运行服务器的命令。`program` 应该是一个绝对文件名，表示要运行的可执行文件。`arguments` 由空白分隔的参数组成，表示程序执行时的参数。第一个参数应该是程序名---按照程序执行规则。

当你编辑了 */etc/inetd.conf*，可以通过向 **inetd** 进程发送 `SIGHUP` 信号，告诉 **inted** 重读这个文件并且以新的规则运作。当然了，你首先得用 `ps` 命令来确定 **inetd** 进程的进程号。
 