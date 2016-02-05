[Module net](http://nim-lang.org/docs/net.html)
================================================================

This module implements a high-level cross-platform sockets interface.

```
import rawsockets, os, strutils, unsigned, parseutils, times 
```

Types
------

```
SocketImpl = object                     ## 套接字类型
    fd: SocketHandle
    case isBuffered: bool
    of true: 
        buffer: array[0 .. BufferSize, char]
        currPos: int
        bufLen: int
    of false: 
        nil
    when defined(ssl): 
        case isSsl: bool
        of true: 
            sslHandle: SSLPtr
            sslContext: SSLContext
            sslNoHandshake: bool
            sslHasPeekChar: bool
            sslPeekChar: char
        of false: 
            nil
    lastError: OSErrorCode                 ## stores the last error on this socket
Socket = ref SocketImpl
SOBool = enum                           ## 套接字配置
    OptAcceptConn, OptBroadcast, OptDebug, OptDontRoute, 
    OptKeepAlive, OptOOBInline, OptReuseAddr
ReadLineResult = enum                   ## result for readLineAsync
    ReadFullLine, ReadPartialLine, ReadDisconnected, ReadNone
TimeoutError = object of Exception
SocketFlag   = enum                     ## 确保断开连接的异常（ECONNRESET, EPIPE etc）不被抛出
    Peek, SafeDisconn
IpAddressFamily = enum                  ## IP 地址的类型描述
    IPv6,                                  ## IPv6 address
    IPv4                                   ## IPv4 address
TIpAddress = object                     ## 存储 IP 地址
    case family: IpAddressFamily           ## the type of the IP address (IPv4 or IPv6)
    of IpAddressFamily.IPv6: 
        address_v6: array[0 .. 15, uint8]  ## Contains the IP address in bytes in case of IPv6
    of IpAddressFamily.IPv4: 
        address_v4: array[0 .. 3, uint8]   ## Contains the IP address in bytes in case of IPv4
```

Consts
---------

```
BufferSize: int = 4000                  ## 套接字缓冲区大小
```

Procs
----------

```
proc newSocket(domain: Domain = AF_INET; typ: SockType = SOCK_STREAM; 
               protocol: Protocol = IPPROTO_TCP; buffered = true): Socket 
              {.raises: [OSError], tags: [].}
proc newSocket(domain, typ, protocol: cint; buffered = true): Socket 
              {.raises: [OSError], tags: [].}
     ## 创建一个新的套接字。如果失败，抛出 OSError 。

proc close(socket: Socket) {.raises: [], tags: [].}
     ## 关闭一个套接字。
```

<span>

```
proc bindAddr(socket: Socket; port = Port(0); address = "") 
             {.tags: [ReadIOEffect], raises: [OSError].}
     ## 绑定 address:port 到套接字。如果地址是""，绑定 ADDR_ANY 。

proc listen(socket: Socket; backlog = SOMAXCONN) {.tags: [ReadIOEffect], raises: [OSError].}
     ## 标记套接字作为监听连接端，backlog 指定最大连接排队数量。

proc acceptAddr(server: Socket; client: var Socket; address: var string; flags = {SafeDisconn}) 
               {.tags: [ReadIOEffect], gcsafe, locks: 0, raises: [OSError].}
     ## 阻塞，直到有连接进入。当连接进入时，client 会被修改为客户端套接字，address 会被修改为客户端地址。
     ## 如果失败，抛出 OSError 。产生的客户端会继承服务器套接字的属性。例如：套接字是缓冲或者非缓冲。
     ## 
     ## 注意：客户端必须初始化（使用 new），这个过程不会负责初始化。
     ## 
     ## 如果连接套接字在 accept 期间断开，可能会产生一个错误。如果指定了 SafeDisconn，这个错误不会抛出，而是
     ## 再次 accept 。

proc accept(server: Socket; client: var Socket; flags = {SafeDisconn}) 
           {.tags: [ReadIOEffect], raises: [OSError].}
     ## 等同 acceptAddr ，但是不返回客户端地址，只返回客户端套接字。
     ##
     ## 注意：客户端必须初始化（使用 new），这个过程不会负责初始化。
     ## 
     ## 如果连接套接字在 accept 期间断开，可能会产生一个错误。如果指定了 SafeDisconn，这个错误不会抛出，而是
     ## 再次 accept 。

proc connect(socket: Socket; address: string; port = Port(0); af: Domain = AF_INET) 
            {.tags: [ReadIOEffect], raises: [OSError].}
     ## 使用套接字连接到 address:port 。地址可以是 IP 地址，或者主机名。如果是主机名，过程会尝试该主机名的每
     ## 一个 IP 地址。port 已经在内存 htons 了，所以你不需要手动转换。
     ##
     ## 如果套接字是 SSL 连接，会自动进行握手。 

proc connect(socket: Socket; address: string; port = Port(0); timeout: int; af: Domain = AF_INET)
            {.tags: [ReadIOEffect, WriteIOEffect], raises: [OSError, TimeoutError].}
     ## 通过 address:port 连接指定的服务器。可以指定毫秒超时时间。
```

<span>

```
proc getSockOpt(socket: Socket; opt: SOBool; level = SOL_SOCKET): bool 
               {.tags: [ReadIOEffect], raises: [OSError].}
     ## 返回套接字配置。

proc setSockOpt(socket: Socket; opt: SOBool; value: bool; level = SOL_SOCKET) 
               {.tags: [WriteIOEffect], raises: [OSError].}
     ## 设置套接字配置。
```

<span>

```
proc isDisconnectionError(flags: set[SocketFlag]; lastError: OSErrorCode): bool 
                         {.raises: [], tags: [].}
     ## 确认 lastError 是断开连接引起的错误。只有当配置标记包含 SafeDisconn 才工作。

proc getSocketError(socket: Socket): OSErrorCode {.raises: [OSError], tags: [].}
     ## 检查 osLastError ， 找到套接字错误。

proc socketError(socket: Socket; err: int = - 1; async = false; 
                 lastError = -1.OSErrorCode) {.raises: [OSError], tags: [].}
     ## Raises an OSError based on the error code returned by SSLGetError (for SSL sockets) 
     ## and osLastError otherwise.
     ##
     ## If async is true no error will be thrown in the case when the error was caused by no 
     ## data being available to be read.
     ## 
     ## If err is not lower than 0 no exception will be raised.
```

<span>

```
proc toOSFlags(socketFlags: set[SocketFlag]): cint {.raises: [], tags: [].}
     ## 转换配置标记为系统 cint 类型。
     
proc toCInt(opt: SOBool): cint {.raises: [], tags: [].}
     ## 转换套接字配置为系统 cint 类型。
```

<span>

```
proc recv(socket: Socket; data: pointer; size: int): int {.tags: [ReadIOEffect], raises: [].}
proc recv(socket: Socket; data: pointer; size: int; timeout: int): int 
         {.tags: [ReadIOEffect, TimeEffect], raises: [TimeoutError, OSError].}
     ## 从套接字接收数据。注意：这是一个低阶过程，你可能对高阶 recv 感兴趣。

proc recv(socket: Socket; data: var string; size: int; timeout = - 1; flags = {SafeDisconn}): int
         {.raises: [TimeoutError, OSError], tags: [ReadIOEffect, TimeEffect].}
     ## 高阶版本。返回 0， 表示套接字连接已经关闭。如果出错，抛出 OSError 。永远不会返回 <0 的值。可以指定
     ## 毫秒超时时间，如果在指定时间没有接收足够的数据，抛出 TimeoutError 。
     ##
     ## 注意：data 必须初始化。警告：当前只支持 SafeDisconn 配置标记。

proc readLine(socket: Socket; line: var TaintedString; timeout = - 1; flags = {SafeDisconn}) 
             {.tags: [ReadIOEffect, TimeEffect], raises: [TimeoutError, OSError].}
     ## 从套接字读取一行数据。If a full line is read \r\L is not added to line, however if solely 
     ## \r\L is read then line will be set to it. 如果套接字断开连接，line 会修改为"" 。如果套接字出错，
     ## 抛出 EOS。可以指定毫秒超时时间，如果在指定时间没有接收到数据，抛出 TimeoutError 。
     ##
     ## 注意：line 必须初始化。警告：当前只支持 SafeDisconn 配置标记。

proc recvFrom(socket: Socket; data: var string; length: int; 
              address: var string; port: var Port; flags = 0'i32): int  
             {.tags: [ReadIOEffect], raises: [OSError].}
     ## 从套接字接收数据。这个过程通常用于无连接套接字（UDP）。如果出错，抛出 OSError 。警告：这个过程没有
     ## 实现缓冲，所以套接字是无缓冲的。Therefore if socket contains something in its buffer this 
     ## function will make no effort to return it.

proc skip(socket: Socket; size: int; timeout = - 1) 
         {.raises: [Exception, TimeoutError, OSError], tags: [TimeEffect, ReadIOEffect].}
     ## 跳过指定字节的数据。

proc send(socket: Socket; data: pointer; size: int): int 
         {.tags: [WriteIOEffect], raises: [].}
     ## 通过套接字发送数据。注意：这个是一个低阶版本。

proc send(socket: Socket; data: string; flags = {SafeDisconn}) 
         {.tags: [WriteIOEffect], raises: [OSError].}
     ## 高阶版本。

proc trySend(socket: Socket; data: string): bool {.tags: [WriteIOEffect], raises: [].}
     ## send 二选一的安全版本。如果出现错误，不抛出异常，而是返回 false。

proc sendTo(socket: Socket; address: string; port: Port; data: pointer; 
            size: int; af: Domain = AF_INET; flags = 0'i32): int 
           {.tags: [WriteIOEffect], raises: [OSError].}
     ## 发送数据给制定的 address:port 。地址可以是 IP 或者主机名，如果是主机名，尝试每一个 IP 地址。
     ## 注意：这是一个低阶版本，并且对 SSL 套接字无效。

proc sendTo(socket: Socket; address: string; port: Port; data: string): int 
           {.tags: [WriteIOEffect], raises: [OSError].}
     ## 高阶版本。
```

<span>

```
proc hasDataBuffered(s: Socket): bool {.raises: [], tags: [].}
     ## 套接字有数据缓冲？

proc isSsl(socket: Socket): bool {.raises: [], tags: [].}
     ## SSL 套接字？

proc getFd(socket: Socket): SocketHandle {.raises: [], tags: [].}
     ## 返回套接字描述符。

proc IPv4_any(): TIpAddress {.raises: [], tags: [].}
     ## 返回一个 IPv4 地址，可以用于有效的网络监听地址

proc IPv4_loopback(): TIpAddress {.raises: [], tags: [].}
     ## 返回 IPv4 巡回地址 （127.0.0.1）。

proc IPv4_broadcast(): TIpAddress {.raises: [], tags: [].}
     ## 返回 IPv4 广播地址 （255.255.255.255）。

proc IPv6_any(): TIpAddress {.raises: [], tags: [].}
     ## 返回一个 IPv6 地址（::0），可以用于有效的网络监听地址

proc IPv6_loopback(): TIpAddress {.raises: [], tags: [].}
     ## 返回 IPv6 巡回地址 （::1）。

proc `==`(lhs, rhs: TIpAddress): bool {.raises: [], tags: [].}
     ## 比较两个 IP 地址。

proc `$`(address: TIpAddress): string {.raises: [], tags: [].}
     ## 转换 IP 地址为字符串。

proc parseIpAddress(address_str: string): TIpAddress {.raises: [ValueError], tags: [].}
     ## 转换 IP 字符串为地址对象。如果出错，抛出 ValueError 。

proc isIpAddress(address_str: string): bool {.tags: [], raises: [].}
     ## IP 地址？
```