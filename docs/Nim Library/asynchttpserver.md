[Module asynchttpserver](http://nim-lang.org/docs/asyncnet.html)
========================================================================

This module implements a high performance asynchronous HTTP server.

```
import strtabs, asyncnet, asyncdispatch, parseutils, uri, strutils 
```

Types
------

```
Request = object      ## 客户端
    client*    : AsyncSocket
    reqMethod* : string
    headers*   : StringTableRef
    protocol*  : tuple[orig: string, major, minor: int]
    url*       : Uri
    hostname*  : string
    body*      : string
AsyncHttpServer = ref object 
    socket: AsyncSocket
    reuseAddr: bool
HttpCode = enum 
    Http100 = "100 Continue", Http101 = "101 Switching Protocols", 
    Http200 = "200 OK", Http201 = "201 Created", Http202 = "202 Accepted", 
    Http204 = "204 No Content", Http205 = "205 Reset Content", 
    Http206 = "206 Partial Content", Http300 = "300 Multiple Choices", 
    Http301 = "301 Moved Permanently", Http302 = "302 Found", 
    Http303 = "303 See Other", Http304 = "304 Not Modified", 
    Http305 = "305 Use Proxy", Http307 = "307 Temporary Redirect", 
    Http400 = "400 Bad Request", Http401 = "401 Unauthorized", 
    Http403 = "403 Forbidden", Http404 = "404 Not Found", 
    Http405 = "405 Method Not Allowed", Http406 = "406 Not Acceptable", 
    Http407 = "407 Proxy Authentication Required", 
    Http408 = "408 Request Timeout", Http409 = "409 Conflict", 
    Http410 = "410 Gone", Http411 = "411 Length Required", 
    Http418 = "418 I\'m a teapot", Http500 = "500 Internal Server Error", 
    Http501 = "501 Not Implemented", Http502 = "502 Bad Gateway", 
    Http503 = "503 Service Unavailable", Http504 = "504 Gateway Timeout", 
    Http505 = "505 HTTP Version Not Supported"
HttpVersion = enum 
    HttpVer11, HttpVer10
```

Procs
------

```
proc newAsyncHttpServer(reuseAddr = true): AsyncHttpServer {.raises: [], tags: [].}
     ## 创建一个异步服务器。

proc close(server: AsyncHttpServer) {.raises: [], tags: [].}
     ## 关闭一个异步服务器。

proc sendHeaders(req: Request; headers: StringTableRef): Future[void] 
                {.raises: [], tags: [RootEffect].}
     ## 发送响应头。

proc respond(req: Request; code: HttpCode; content: string; headers: StringTableRef = nil)
            : Future[void] {.raises: [], tags: [RootEffect].}
     ## 发送响应代码、[响应头]、响应体。这个过程不关闭套接字。

proc serve(server: AsyncHttpServer; port: Port; 
           callback: proc (request: Request): Future[void] {.closure, gcsafe.}; 
           address = ""): Future[void] 
           {.raises: [], tags: [WriteIOEffect, ReadIOEffect, RootEffect].}
     ## 使用指定的 address:port 启动一个 HTTP 服务器。当有请求进来时，调用回调函数。
```

<span>

```
proc `==`(protocol: tuple[orig: string, major, minor: int]; ver: HttpVersion): bool 
         {.raises: [], tags: [].}
```

Examples
---------

```
import asynchttpserver, asyncdispatch

var server = newAsyncHttpServer()
proc callback(req: Request) {.async.} =
    await req.respond(Http200, "Hello World")

waitFor server.serve(Port(8080), callback)
```