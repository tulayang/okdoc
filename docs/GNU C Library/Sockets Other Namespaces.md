# [其他命名空间](https://www.gnu.org/software/libc/manual/html_node/Misc-Namespaces.html#Misc-Namespaces)

我们还实现了一些其它的命名空间，但是没有在本文档里介绍，因为很少用到它们。`PF_NS` 是施乐网络软件协议。` PF_ISO` 用于开源系统互联。`PF_CCITT` 则是涉及 CCITT 的协议。`<sys/socket.h>` 定义了这些符号名，以及一些尚未实现的协议名。

`PF_IMPLINK` 用来在主机和因特网消息处理器通信。`PF_ROUTE` 是一个本地区域路由协议，偶尔才会用那么一次。如果你想深入了解，可以看看 GNU Hurd 的文档介绍。