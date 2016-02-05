[Module asyncdispatch](http://nim-lang.org/docs/asyncdispatch.html)
=====================================================================

```
import os, oids, tables, strutils, macros, times, rawsockets, net, winlean, sets, hashes
```

Types
-------

```
FutureBase = ref object of RootObj    ## Untyped future
    cb: proc () {.closure, gcsafe.}
    finished: bool
    error*: ref Exception                ## Stored exception
    errorStackTrace*: string
    when not false: 
        stackTrace: string               ## For debugging purposes only.
        id: int
        fromProc: string
Future[T] = ref object of FutureBase  ## Typed future
    value: T                             ## Stored value
TCompletionKey = DWORD
TCompletionData = object 
    fd*: TAsyncFD
    cb*: proc (fd: TAsyncFD; bytesTransferred: DWORD; errcode: OSErrorCode) 
              {.closure, gcsafe.}
PDispatcher = ref object of PDispatcherBase
    ioPort: THandle
    handles: HashSet[TAsyncFD]
PCustomOverlapped = ref TCustomOverlapped
TAsyncFD = distinct int               ## 异步文件描述符 
```

Procs
--------

```
proc poll(timeout = 500) 
         {.raises: [ValueError, Exception, OSError], tags: [RootEffect, TimeEffect].}
     ## 等待事件完成，并且发出通知。
```

<span>

```
proc newFuture[T](fromProc: string = "unspecified"): Future[T]
     ## 创建一个新的 future。指定 fromProc 为回调过程的名字，是一个好习惯，能够帮助调试。

proc callback=   (future: FutureBase; cb: proc () {.closure, gcsafe.}) 
                 {.raises: [Exception], tags: [RootEffect].}
proc callback=[T](future: Future[T];  cb: proc (future: Future[T]) 
                 {.closure, gcsafe.})
     ## 设置 future 完成后的回调函数。

proc complete[T](future: Future[T]; val: T)
proc complete   (future: Future[void]) {.raises: [Exception], tags: [RootEffect].}
     ## 完成 future，结果是 void 或者值。

proc fail[T](future: Future[T]; error: ref Exception)
     ## 完成 future，结果是错误。

proc read[T](future: Future[T]): T
     ## 返回 future 的值。future 必须已经完成，否则会抛出 ValueError 。如果 future 的结果是
     ## 一个错误，抛出该错误。

proc readError[T](future: Future[T]): ref Exception
     ## 返回 future 保存的异常。如果指定的 future 没有异常，抛出 ValueError。

proc finished[T](future: Future[T]): bool
     ## future 完成？

proc failed(future: FutureBase): bool {.raises: [], tags: [].}
     ## future 完成，结果是错误？

proc asyncCheck[T](future: Future[T])
     ## 设置一个回调过程，如果 future 完成错误，抛出这个错误。用于代替 discard 。

proc `and`[T, Y](fut1: Future[T]; fut2: Future[Y]): Future[void]
     ## 一旦 fut1，fut2 完成，返回一个完成的 future

proc `or`[T, Y](fut1: Future[T]; fut2: Future[Y]): Future[void]
     ## ## 一旦 fut1，fut2 有一个完成，返回一个完成的 future
```

<span>

```
proc newDispatcher(): PDispatcher {.raises: [], tags: [].}
     ## 创建一个新的调读器

proc getGlobalDispatcher(): PDispatcher {.raises: [], tags: [].}
     ## 返回全局线程内部的调读器

proc runForever() {.raises: [ValueError, Exception, OSError], tags: [RootEffect, TimeEffect].}
     ## 启动一个一直运行的全局调度器。
```

<span>


```
proc newAsyncRawSocket(domain, typ, protocol: cint): TAsyncFD {.raises: [OSError], tags: [].}
proc newAsyncRawSocket(domain: Domain = AF_INET; typ: SockType = SOCK_STREAM; 
                       protocol: Protocol = IPPROTO_TCP): TAsyncFD {.raises: [OSError],tags: [].}
     ## 创建一个新的异步套接字，隐式注册到调读器。

proc closeSocket(socket: TAsyncFD) {.raises: [], tags: [].}
     ## 关闭一个异步套接字，并确保其未注册。

proc register(fd: TAsyncFD) {.raises: [OSError], tags: [].}
     ## 使用调读器注册异步文件描述符。

proc unregister(fd: TAsyncFD) {.raises: [], tags: [].}
     ## 取消注册异步文件描述符。

proc `==`(x: TAsyncFD; y: TAsyncFD): bool {.borrow.}
```

<span>

```
proc connect(socket: TAsyncFD; address: string; port: Port; af = AF_INET): Future[void]
            {.raises: [ValueError, OSError, Exception], tags: [RootEffect].}
     ## 通过异步套接字连接到服务器 address:port 。当连接成功或者错误，返回一个 future 。

proc acceptAddr(socket: TAsyncFD; flags = {SafeDisconn})
               : Future[tuple[address: string, client: TAsyncFD]] 
               {.raises: [ValueError, OSError, Exception], tags: [RootEffect].}
     ## 接收一个新的连接。返回一个保存客户端异步套接字和远程地址的 future。当连接成功接收时，返回 future 。
     ## 结果客户端套接字，自动注册到调读器。套接字接收期间可能会返回错误。如果指定 SafeDisconn，这个错误不会
     ## 抛出。而是重新调用接收。 

proc accept(socket: TAsyncFD; flags = {SafeDisconn}): Future[TAsyncFD] 
           {.raises: [ValueError, OSError, Exception], tags: [RootEffect].}
     ## 接收一个新的连接。返回一个保存客户端异步套接字的 future。当连接成功接收时，返回 future 。

proc sleepAsync(ms: int): Future[void] {.raises: [], tags: [TimeEffect].}
     ## 挂起当前异步过程 ms 毫秒。

proc waitFor[T](fut: Future[T]): T
     ## 阻塞，直到指定的 future 完成。
```

<span>

```
proc recv(socket: TAsyncFD; size: int; flags = {SafeDisconn}): Future[string] 
         {.raises: [ValueError, Exception], tags: [RootEffect].}
     ## 读取最大 size 字节。当所有数据读完、读取部分数据、套接字连接断开（值""），完成 future 。
     ## 警告：peek 套接字配置标记，在 Windows 不支持。

proc recvInto(socket: TAsyncFD; buf: cstring; size: int; flags = {SafeDisconn}): Future[int] 
             {.raises: [ValueError, Exception], tags: [RootEffect].}
     ## 通过异步套接字读取最大 size 字节到 buf。当所有数据读完、读取部分数据、套接字连接断开（值""），完成 
     ## future。警告：peek 套接字配置标记，在 Windows 不支持。 

proc recvLine(socket: TAsyncFD): Future[string] {.raises: [], tags: [RootEffect].}
     ## 通过异步套接字读取一行。一旦读取完一整行或者出错，完成 future 。
     ## 注意：这个过程主要用来测试。你可能应该用 asyncnet.recvLine 代替。 

proc send(socket: TAsyncFD; data: string; flags = {SafeDisconn}): Future[void] 
         {.raises: [ValueError, Exception], tags: [RootEffect].}
     ## 通过异步套接字发送数据。一旦所有数据发送完成，完成 future 。
```

Macros
---------

```
macro async(prc: stmt): stmt {.immediate.}
      ## 通过迭代器和 yield 流程化异步程序。
```

Struct
-----------


```
p: PDispatcher {
	selector: Selector {
		epollFD: cint,
		events: array[64, epoll_event { 
			events, fd 
		}]
        fds: Table[SocketHandle, SelectorKey {
        	fd: SocketHandle
        	events: set[Event],
        	data: PData {
        		fd: TAsyncFD,
				readCBs: seq[TCallback],
				writeCBs: seq[TCallback]
        	}
        }]
	},
	timers: seq[tuple[finishAt: float, fut: Future[void]]]
}

info: tuple[
	key: SelectorKey {
		fd: SocketHandle
		events: set[Event],
		data: PData {
			fd: TAsyncFD,
			readCBs: seq[TCallback],
			writeCBs: seq[TCallback]
		}
	}, 
	events: set[Event]
]
```
