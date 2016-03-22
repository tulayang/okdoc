```
import Net from 'net';
```

<span>

```
Net.createServer([options], [listener()])              // 创建一个 TCP | UNIX 服务器

    • options {
          allowHalfOpen : Boolean // 允许半关闭半开放 default=false
                                  // 设置为 true 时，当另一端的套接字发送 FIN 包时
                                  // 套接字不会自动发送 FIN 报文，套接字会变为不可读，
                                  // 但仍然可写，需要用户调用 end() 关闭本端套接字
      }

Net.connect(port, [host], [connectListener])           // 连接服务器，返回一个套接字
Net.createConnection(port, [host], [connectListener])  // 连接服务器，返回一个套接字
Net.connect(path, [connectListener])                   // 连接服务器，返回一个套接字
Net.createConnection(path, [connectListener])          // 连接服务器，返回一个套接字
Net.connect(options, [connectionListener])             // 连接服务器，返回一个套接字
Net.createConnection(options, [connectionListener])    // 连接服务器，返回一个套接字

    • options {
          port         : Number // 客户端连接到的端口（必须）
          host         : String // 客户端连接到的主机，default='localhost'
          localAddress : String // 网络连接绑定的本地地址
          family       : Number // IP 栈版本，default=4
          path         : String // 当 UNIX 套接字时，用于连接路径
      }

Net.isIP(string)                                       // IP 地址？
net.isIPv4(string)                                     // IPv4 地址？
net.isIPv6(string)                                     // IPv6 地址？
```

Net.Server  (TCP | UNIX 服务器)
--------------------------------

```
• 'listening'  (e)                           // server.listen 绑定后触发
• 'connection' (socket)                      // 新连接被创建时触发
• 'close'      ()                            // 服务器被关闭时触发
• 'error'      (error)                       // 服务器发生错误时触发
 
server.listen(port, [host], [backlog], [callback(e)])   // 在指定端口 port 和主机 host 上开始接受连接
                                                        // 如果省略 host，接受来自所有 IPv4 地址
                                                        // （INADDR_ANY）的连接
                                                        // port 为 0， 则会使用分随机分配的端口
        
       • backlog : Number // 连接等待队列的最大长度，
                          // 由操作系统通过 sysctl 设置决定， 
                          // (Linux : tcp_max_syn_backlog 和 somaxconn)
                          // default=511

server.listen(pathname, [callback(e)])       // 通过 pathname 启动一个 UNIX 套接字服务器开始接受连接
server.listen(handle, [callback(e)])         // 通过一个触发器启动服务器开始接受连接
server.listen(options, [callback(e)])        // 通过一个配置启动服务器开始接受连接

       • options {
             port      : Number  // 可选，端口号
             host      : String  // 可选，主机
             backlog   : Number  // 可选，连接等待队列的最大长度
             path      : String  // 可选，套接字地址
             exclusive : Boolean // 可选
         }

server.close([callback(error)])              // 停止服务器接受新连接，但保持已存在的连接 
                                             // 服务器将在所有的连接都结束后关闭
                                             // 触发 'close' 事件

server.address()                             // 获取操作系统绑定的地址，协议族和端口
                                             // { port: 12346, 
                                             //   family: 'IPv4', 
                                             //   address: '127.0.0.1' }

server.getConnections(callback(err, count))  // 异步获取服务器当前活跃的连接数
server.maxConnections                        // 设置最大连接数，超过时拒绝连接

server.unref()                           
server.ref() 
```

Net.Socket (TCP | UNIX 套接字)
-------------------------------

```
// 默认情况下 （allowHalfOpen == false），当套接字完成待写入队列中的任务时，
// 它会 destroy 文件描述符。然而，如果把 allowHalfOpen 设成 true，那么套接字将
// 不会自动调用 end()，使得用户可以随意写入数据，但同时用户需要自己调用end()

new Socket([options])                        
    • options {
          fd            : Number  // default=null
          type          : String  // 'tcp4' | 'tcp6' | 'unix'，default=null
          allowHalfOpen : Boolean // 允许半关闭，default=false
      }

• 'lookup'  (err, address, family)                  // 解析主机名之后，连接主机之前时触发
• 'connect' ()                                      // 连接成功建立时触发
• 'data'    (data)                                  // 收到数据时触发
• 'end'     ()                                      // 对端发送 FIN 包时触发
• 'drain'   ()                                      // 写入缓冲区被清空时触发
• 'timeout' ()                                      // 闲置超时时触发
• 'close'   (bool)                                  // 套接字完全关闭时触发 
• 'error'   (error)                                 // 发生错误时触发

socket.connect(port, [host], [connectListener()])   // 连接服务器
socket.connect(pathname, [connectListener()])       // 连接服务器

socket.bufferSize                                   // 当前缓冲区中等待被写入的字符数
socket.bytesRead                                    // 当前接收的字节数
socket.bytesWritten                                 // 当前发送的字节数

socket.setEncoding([encoding])                      // 设置编码

socket.write(data, [encoding], [callback])          // 写入套接字
                                                    // 如果所有数据被成功刷新到内核缓冲区，则返回true，
                                                    // 如果所有或部分数据在用户内存里还处于队列中，
                                                    // 则返回false，
                                                    // 当缓冲区再次被释放时，'drain'事件会被分发
socket.end([data], [encoding])                      // 半关闭套接字，发送一个 FIN 包 
socket.destroy()                                    // 确保没有I/O活动在这个套接字，
                                                    // 只有在错误发生情况下才需要（处理错误等等）

socket.pause()                                      // 暂停读取数据
socket.resume()                                     // 继续读取数据

socket.setTimeout(timeout, [callback()])            // 设置闲置超时时间，
                                                    // 默认情况下不存在超时
socket.setNoDelay([noDelay])                        // 禁用纳格（Nagle）算法
                                                    // 默认情况下使用纳格算法，noDelay默认为true
socket.setKeepAlive([enable], [initialDelay])       // 设置长连接 

       • initialDelay : Number // 毫秒，收到的最后一个数据包和发送第一个 probe 的延时， 
                               // default=0 保持不变 

socket.address()                                    // 获取 socket 绑定的IP地址，协议类型
                                                    // 以及 端口号 (port)
                                                    // { port: 12346, 
                                                    //   family: 'IPv4', 
                                                    //   address: '127.0.0.1' }

socket.remoteAddress                                // 获取远程 IP 地址
socket.remotePort                                   // 获取远程端口
socket.localAddress                                 // 获取本地 IP 地址
socket.localPort                                    // 获取本地端口

socket.unref()
socket.ref()        
```