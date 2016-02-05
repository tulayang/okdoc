[Module rawsockets](http://nim-lang.org/docs/rawsockets.html)
================================================================

This module implements a low-level cross-platform sockets interface. Look at the net module for the higher-level version.

```
import unsigned, os, winlean 
```

Types
------

```
Port   = distinct uint16    ## 端口类型 
Domain = enum               ## 域名，用来指定套接字的协议家族。
    AF_UNIX,                   ## for local socket (using a file). Unsupported on Windows.
    AF_INET  = 2,              ## for network protocol IPv4 or
    AF_INET6 = 23              ## for network protocol IPv6.
SockType = enum             ## socket 过程的第二个参数，传输类型
    SOCK_STREAM    = 1,        ## reliable stream-oriented service or Stream Sockets （可靠流）
    SOCK_DGRAM     = 2,        ## datagram service or Datagram Sockets               （用户数据报）
    SOCK_RAW       = 3,        ## raw protocols atop the network layer.              （atop）
    SOCK_SEQPACKET = 5         ## reliable sequenced packet service                  （可靠序列包）
Protocol = enum             ## socket 过程的第三个参数，协议类型
    IPPROTO_TCP = 6,           ## Transmission control protocol. 
    IPPROTO_UDP = 17,          ## User datagram protocol.
    IPPROTO_IP,                ## Internet protocol. Unsupported on Windows.
    IPPROTO_IPV6,              ## Internet Protocol Version 6. Unsupported on Windows.
    IPPROTO_RAW,               ## Raw IP Packets Protocol. Unsupported on Windows.
    IPPROTO_ICMP               ## Control message protocol. Unsupported on Windows.
Servent = object            ## 一个服务的信息
    name     : string
    aliases  : seq[string]
    port     : Port
    proto    : string
Hostent = object            ## 一个给定主机的信息
    name     : string
    aliases  : seq[string]
    addrtype : Domain
    length   : int
    addrList : seq[string]
```

Lets
---------

```
osInvalidSocket = INVALID_SOCKET
```

Consts
---------

```
IOCPARM_MASK = 127
IOC_IN       = -2147483648
FIONBIO      = -2147195266
```

Procs
----------

```
proc ioctlsocket(s: SocketHandle; cmd: clong; argptr: ptr clong): cint 
                {.stdcall, importc: "ioctlsocket", dynlib: "ws2_32.dll".}

proc `==`(a, b: Port): bool {.borrow.}

proc `$`(p: Port): string {.borrow.}
     ## 返回端口号的字符串形式

proc toInt(domain: Domain): cint {.raises: [], tags: [].}
     ## 转换域名为系统依赖的 cint 类型

proc toInt(typ: SockType): cint {.raises: [], tags: [].}
     ## 转换传输类型为系统依赖的 cint 类型

proc toInt(p: Protocol): cint {.raises: [], tags: [].}
     ## 转换协议类型为系统依赖的 cint 类型
```

<span>

```
proc ntohl(x: int32): int32 {.raises: [], tags: [].}
     ## 转换一个 32 位网络序地址为主机序地址。

proc ntohs(x: int16): int16 {.raises: [], tags: [].}
     ## 转换一个 16 位网络序地址为主机序地址。

proc htonl(x: int32): int32 {.raises: [], tags: [].}
     ## 转换一个 32 位主机序地址为网络序地址。

proc htons(x: int16): int16 {.raises: [], tags: [].}
     ## 转换一个 16 位主机序地址为网络序地址。
```

<span>

```
proc newRawSocket(domain: Domain = AF_INET; typ: SockType = SOCK_STREAM; 
                  protocol: Protocol = IPPROTO_TCP): SocketHandle {.raises: [], tags: [].}
     ## 创建一个新的套接字。如果失败，返回 InvalidSocket 。

proc newRawSocket(domain: cint; typ: cint; protocol: cint): SocketHandle {.raises: [], tags: [].}
     ## 创建一个新的套接字。如果失败，返回 InvalidSocket 。当指定的枚举中没有你需要的类型时，使用此过程重载。

proc close(socket: SocketHandle) {.raises: [], tags: [].} 
     ## 关闭一个套接字

proc bindAddr(socket: SocketHandle; name: ptr SockAddr; namelen: SockLen): cint 
             {.raises: [], tags: [].}

proc listen(socket: SocketHandle; backlog = SOMAXCONN): cint {.tags: [ReadIOEffect], raises: [].}
     ## 标记套接字作为监听连接端，backlog 指定最大连接排队数量。

proc getAddrInfo(address: string; port: Port; af: Domain = AF_INET; 
                 typ: SockType = SOCK_STREAM; prot: Protocol = IPPROTO_TCP): ptr AddrInfo 
                {.raises: [OSError], tags: [].}
     ## 警告：返回值 ptr TAddrInfo 必须用 dealloc 释放内存。

proc dealloc(ai: ptr AddrInfo) {.raises: [], tags: [].}
```

<span>

```
proc setBlocking(s: SocketHandle; blocking: bool) {.raises: [OSError], tags: [].}
     ## 设置套接字阻塞模式。如果失败，抛出 OSError 。

proc select(readfds: var seq[SocketHandle]; timeout = 500): int {.raises: [], tags: [].}
     
proc selectWrite(writefds: var seq[SocketHandle]; timeout = 500): int 
                {.tags: [ReadIOEffect], raises: [].}
```

<span>

```
proc getServByName(name, proto: string): Servent {.tags: [ReadIOEffect], raises: [OSError].}
     ## Searches the database from the beginning and finds the first entry for which the service
     ## name specified by name matches the s_name member and the protocol name specified by 
     ## proto matches the s_proto member.
     ##
     ## On posix this will search through the /etc/services file.

proc getServByPort(port: Port; proto: string): Servent 
                  {.tags: [ReadIOEffect], raises: [OSError].}
     ## Searches the database from the beginning and finds the first entry for which the port 
     ## specified by port matches the s_port member and the protocol name specified by proto 
     ## matches the s_proto member.
     ## 
     ## On posix this will search through the /etc/services file.

proc getHostByAddr(ip: string): Hostent {.tags: [ReadIOEffect], raises: [OSError].}
     ## 查找 IP 地址对应的主机名。

proc getHostByName(name: string): Hostent {.tags: [ReadIOEffect], raises: [OSError].}
     ## 查找主机名对应的 IP 地址。

proc getSockName(socket: SocketHandle): Port {.raises: [OSError], tags: [].}
     ## 返回套接字的端口。

proc getSockOptInt(socket: SocketHandle; level, optname: int): int 
                  {.tags: [ReadIOEffect], raises: [OSError].}
     ## getsockopt for integer options.

proc setSockOptInt(socket: SocketHandle; level, optname, optval: int) 
                  {.tags: [WriteIOEffect], raises: [OSError].}
     ## setsockopt for integer options. 
```

