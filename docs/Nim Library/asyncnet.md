[Module asyncnet](http://nim-lang.org/docs/asyncnet.html)
=====================================================================

This module implements a high-level asynchronous sockets API based on the asynchronous dispatcher defined in the asyncdispatch module.

SSL ---

SSL can be enabled by compiling with the -d:ssl flag.

You must create a new SSL context with the newContext function defined in the net module. You may then call wrapSocket on your socket using the newly created SSL context to get an SSL socket.

```
import asyncdispatch, rawsockets, net, os 
```

Types
-------

```
AsyncSocketDesc  = object
    fd: SocketHandle
    closed: bool ## determines whether this socket has been closed
    case isBuffered: bool ## determines whether this socket is buffered.
    of true:
        buffer: array[0..BufferSize, char]
        currPos: int # current index in buffer
        bufLen: int # current length of buffer
    of false: nil
    case isSsl: bool
    of true:
        when defined(ssl):
            sslHandle: SslPtr
            sslContext: SslContext
            bioIn: BIO
            bioOut: BIO
    of false: nil
AsyncSocket* = ref AsyncSocketDesc
```

Procs
------

```
proc newAsyncSocket(fd: TAsyncFD; isBuff: bool): AsyncSocket {.raises: [], tags: [].}
     ## 创建一个新的异步套接字。

proc newAsyncSocket(domain: Domain = AF_INET; typ: SockType = SOCK_STREAM; 
                    protocol: Protocol = IPPROTO_TCP; buffered = true): AsyncSocket 
                   {.raises: [OSError], tags: [].}
proc newAsyncSocket(domain, typ, protocol: cint; buffered = true): AsyncSocket 
                   {.raises: [OSError], tags: [].}
     ## 创建一个新的异步套接字。同时会为该套接字创建一个文件描述符。

proc close(socket: AsyncSocket) {.raises: [], tags: [].}
     ## 关闭一个新的异步套接字。
```

<span>

```
proc bindAddr(socket: AsyncSocket; port = Port(0); address = "") 
             {.tags: [ReadIOEffect], raises: [OSError].}
     ## 绑定 address:port 到异步套接字。

proc listen(socket: AsyncSocket; backlog = SOMAXCONN) {.tags: [ReadIOEffect], raises: [OSError].}
     ## 标记异步套接字用于接收连接，指定最大连接排队数量。

proc acceptAddr(socket: AsyncSocket; flags = {SafeDisconn})
               : Future[tuple[address: string, client: AsyncSocket]] 
               {.raises: [ValueError, OSError, Exception], tags: [RootEffect].}
     ## 接收一个新的连接。返回一个保存客户端异步套接字和远程地址的 future。当连接成功接收时，完成 future 。
     ## 结果客户端套接字，自动注册到调读器。套接字接收期间可能会返回错误。如果指定 SafeDisconn，这个错误不会
     ## 抛出，而是重新调用接收。 

proc accept(socket: AsyncSocket; flags = {SafeDisconn}): Future[AsyncSocket] 
           {.raises: [ValueError, OSError, Exception], tags: [RootEffect].}
     ## 接收一个新的连接。返回一个保存客户端异步套接字的 future。当连接成功接收时，完成 future 。

proc connect(socket: AsyncSocket; address: string; port: Port; af = AF_INET): Future[void]
            {.raises: [], tags: [RootEffect].}
     ## 通过异步套接字连接到服务器 address:port 。当连接成功或者错误时，返回一个完成的 future 。
```

<span>

```
proc getSockOpt(socket: AsyncSocket; opt: SOBool; level = SOL_SOCKET): bool 
               {.tags: [ReadIOEffect], raises: [OSError].}
     ## 返回异步套接字配置。

proc setSockOpt(socket: AsyncSocket; opt: SOBool; value: bool; level = SOL_SOCKET)
               {.tags: [WriteIOEffect], raises: [OSError].}
     ## 设置异步套接字配置。
```

<span>

```
proc recv(socket: AsyncSocket; size: int; flags = {SafeDisconn}): Future[string] 
         {.raises: [], tags: [RootEffect].}
     ## 通过异步套接字读取 size 字节。缓冲套接字会试图读取所有的请求数据，以 BufferSize 数据块逐个读取。
     ## 非缓冲套接字并不尝试读取所有的请求数据，只会返回操作系统当时提供的数据。期间套接字连接如果断开，返回
     ## 一个部分数据的完成的 future 。如果套接字连接断开时没有读取有效数据，future 的值是 ""。

proc recvLineInto(socket: AsyncSocket; resString: ptr string; 
                  flags = {SafeDisconn}): Future[void] {.raises: [], tags: [RootEffect].}
     ## 通过异步套接字读取一行。一旦读取完一整行或者出错，完成 future 。警告：peek 套接字配置标记还未实现。
     ## 警告：非缓冲套接字假定协议使用 \r\l 作为换行符。警告：当前使用一个原始的字符串指针（高性能目的）。

proc recvLine(socket: AsyncSocket; flags = {SafeDisconn}): Future[string] 
             {.raises: [], tags: [RootEffect].}
     ## 通过异步套接字读取一行。一旦读取完一整行或者出错，完成 future 。警告：peek 套接字配置标记还未实现。
     ## 警告：非缓冲套接字假定协议使用 \r\l 作为换行符。

proc send(socket: AsyncSocket; data: string; flags = {SafeDisconn}): Future[void] 
         {.raises: [], tags: [RootEffect].}
     ## 通过异步套接字发送数据。一旦数据发送完成，返回一个完成的 future 。
```

<span>

```
proc isSsl(socket: AsyncSocket): bool {.raises: [], tags: [].}
     ## ssl 连接？

proc getFd(socket: AsyncSocket): SocketHandle {.raises: [], tags: [].}
     ## 返回异步套接字的文件描述符。

proc isClosed(socket: AsyncSocket): bool {.raises: [], tags: [].}
     ## 异步套接字已经关闭？
```