```
import Http from 'http';
```

<span>

```
Http.STATUS_CODES                              // 获取 HTTP 响应状态码的集合和简短描述

Http.createServer([listener()])                // 创建一个 HTTP 服务器
Http.request(options, callback)                // 连接一个远程服务器

     • options {
           host           : String  // 请求发送到的服务器的域名或IP地址。默认为'localhost'。
           hostname       : String  // 用于支持url.parse()。hostname比host更好一些
           port           : Number  // 远程服务器的端口。默认值为80。
           localAddress   : String  // 用于绑定网络连接的本地接口。
           socketPath     : String  // Unix域套接字（使用host:port或socketPath）
           method         : String  // 指定HTTP请求方法的字符串。默认为'GET'。
           path           : String  // 请求路径。默认为'/'。如果有查询字符串，则需要包含。例如'/index.html?page=12'。请求路径包含非法字符时抛出异常。目前，只否决空格，不过在未来可能改变。
           headers        : Object  // 包含请求头的对象。
           auth           : String  // 用于计算认证头的基本认证，即'user:password'
           agent          : Agent   // 控制Agent的行为。当使用了一个Agent的时候，请求将默认为Connection: keep-alive。可能的值为 : 
                                       ∘ undefined（默认） // 在这个主机和端口上使用[全局Agent][]。
                                       ∘ Agent对象        // 在Agent中显式使用passed。
                                       ∘ false           // 在对Agent进行资源池的时候，选择停用连接，默认请求为 : Connection: close。
           keepAlive      : Boolean // 保持资源池周围的套接字在未来被用于其它请求。默认值为false
           keepAliveMsecs : Number  // 当使用HTTP KeepAlive的时候，通过正在保持活动的套接字发送TCP KeepAlive包的频繁程度。默认值为1000。仅当keepAlive被设置为true时才相关。
       }

Http.get(options, callback)                   // 连接一个远程服务器
```

Http.Server  (HTTP 服务器)
--------------------------------

```
• 'request'       (req, res)                  // 收到一个请求时触发，
                                              // 每个连接可能有多个请求(在keep-alive的连接中)
• 'connection'    (socket)                    // 新连接被创建时触发
• 'checkContinue' (req, res)                  // 收到Expect: 100-continue的请求时触发
• 'upgrade'       (req, socket, head)         // 客户端请求http升级时触发
• 'close'         ()                          // 服务器被关闭时触发
• 'clientError'   (error, socket)             // 客户端连接错误时触发
• 'error'         (error)                     // 服务器发生错误时触发
 
server.listen(port, [host], [backlog], [callback(e)])   // 在指定端口 port 和主机 host 上开始接受连接
                                                        // 如果省略 host，接受来自所有 IPv4 地址
                                                        // （INADDR_ANY）的连接
                                                        // port 为 0， 则会使用分随机分配的端口
        
       • backlog : Number // 连接等待队列的最大长度，
                          // 由操作系统通过 sysctl 设置决定， 
                          // (Linux : tcp_max_syn_backlog 和 somaxconn)
                          // default=511

server.listen(path, [callback(e)])           // 通过 path 启动一个 UNIX 套接字服务器开始接受连接
server.listen(handle, [callback(e)])         // 通过一个触发器启动服务器开始接受连接

server.close([callback(error)])              // 停止服务器接受新连接，但保持已存在的连接 
                                             // 服务器将在所有的连接都结束后关闭
                                             // 触发 'close' 事件

server.maxHeadersCount                       // 设置最大请求头数量，default=1000

server.timeout                               // 设置闲置超时时间
socket.setTimeout(msecs, [callback()])       // 设置闲置超时时间，
                                             // 默认情况，服务器的超时时间是2分钟，
                                             // 超时后套接字会自动销毁
```

Http.ServerResponse (服务器响应)
---------------------------------

```
• 'close' ()                                 

res.statusCode                                  // 设置获取响应状态码
res.headersSent                                 // 响应头发送完毕？
res.sendDate                                    // 设置为 true 时，响应头自动设置 Date

res.writeContinue()                             // 发送一个 HTTP/1.1 100 Continue 消息至客户端，
                                                // 表明请求体可以被发送
res.setHeader(name, value)                      // 设置响应头
res.getHeader(name)                             // 获取还未发送的响应头
res.removeHeader(name)                          // 获取还未发送的响应头
res.writeHead(statusCode, [reason], [headers])  // 发送响应头
res.write(chunk, [encoding])                    // 发送响应体
res.addTrailers(headers)                        // 添加 HTT P尾随 headers （一个在消息末尾的header）
                                                // 给响应
res.end([data], [encoding])                     // 发送 FIN 包

res.setTimeout(msecs, callback())               // 设置套接字超时时间   
```

Http.IncomingMessage (客户端)
---------------------------------

```
• 'close' ()                                 

req.httpVersion                                 // 获取 HTTP 版本
req.method                                      // 获取请求方法
req.url                                         // 获取请求路径
req.headers                                     // 获取请求头
req.rawHeaders                                  // 获取原始请求头/响应头字段列表
req.trailers                                    // 获取尾部对象
req.rawTrailers                                 // 获取尾部键和值
req.statusCode                                  // 获取请求状态码

req.socket                                      // 套接字

req.setTimeout(msecs, callback())               // 设置套接字超时时间   
```

Http.Agent (连接远程服务器的套接字池)
----------------------------------

```
new Agent([options])

    • options {
          keepAlive      : Boolean // 保持在资源池周围套接未来字被其它请求使用。默认值为false
          keepAliveMsecs : Number  // 当使用HTTP KeepAlive时, 通过正在被保持活跃的套接字来发送
                                   // TCP KeepAlive包的频繁程度。默认值为1000。
                                   // 仅当keepAlive设置为true时有效。
          maxSockets     : Number  // 每台主机允许的套接字的数目的最大值。默认值为Infinity。
          //在空闲状态下还依然开启的套接字的最大值。仅当keepAlive设置为true的时候有效。默认值为256。
      }                                

agent.maxSockets                                // 设置并发套接字的打开的数量，default=Infinity
agent.maxFreeSockets                            // 设置支持HTTP KeepAlive的Agent，default=256
agent.sockets                                   // 获取代理的套接字组
agent.freeSockets                               // 获取代理的空闲套接字组
agent.requests                                  // 获取代理的套接字请求队列
agent.destroy()                                 // 销毁代理的套接字组

agent.getName(options)                          // 获取配置

Http.globalAgent                                // 获取全局套接字代理
```

Http.ClientRequest (远程连接)
---------------------------------

```
• 'response' (res)                                // 远程服务器发送响应时触发     
• 'socket'   (socket)                             // 套接字可用时触发
• 'connect'  (res, socket, head)                  // 服务器使用 CONNECT 方法响应一个请求时被触发
• 'upgrade'  (res, socket, head)                  // 服务器返回 upgrade 响应时触发
• 'continue' ()                                   // 服务器返回100 Continue响应时触发

req.write(chunk, [encoding])                      // 发送数据
req.end([data], [encoding])                       // 发送 FIN 包
req.abort()                                       // 终止请求

req.setNoDelay([noDelay])                         // 禁用纳格算法
req.setSocketKeepAlive([enable], [initialDelay])  // 设置长连接 
req.setTimeout(msecs, callback())                 // 设置套接字超时时间   
```
