[TLS/SSL zhn](http://nodeapi.ucdok.com/api/tls.html#tls_tls_server_1026)<br />
[TLS/SSL en](https://nodejs.org/api/tls.html)<br />
`采用 OPENSSL 加密`

```
import Tls from 'tls'; 
```

<span>

```
Tls.getCiphers()                                       // 获取支持的的SSL加密器的名字列表

Tls.createServer(options, [secureConnectionListener])  // 创建一个 TLS 加密服务器

Tls.connect(options, [callback])
Tls.connect(port, [host], [options], [callback])       // 连接一个 TLS 加密服务器
```

Tls.Server extend Net.Server (TLS 加密服务器)
---------------------------------------------

```
• 'secureConnection' (socket)                   // 握手成功时触发
• 'newSession'       (sessionId, sessionData)   // 会话建立时触发
• 'resumeSession'    (sessionId, callback)      // 重新打开会话时触发 
• 'clientError'      (error, socket)            // 客户端连接错误时触发

server.addContext(hostname, credentials)        // 为服务器添加安全环境

       • credentials : {key, cert, ca}
```

Tls.TLSSocket extend Net.Socket (安全套接字)
-------------------------------------------

```
• 'secureConnect'                               // 握手成功时触发

tlsSocket.authorized                            // Boolean，对端证书是否 CA 签名
tlsSocket.authorizationError                    // Object，验证出错的原因

tlsSocket.getPeerCertificate()                  // Object | null，获取对端的签名证书信息
tlsSocket.getCipher()                           // Object，获取当前连接的加密方式与SSL/TLS协议版本
                                                // {name: 'AES256-SHA', version: 'TLSv1/SSLv3'} 
tlsSocket.renegotiate(options, callback)        // 启动TLS协商过程
```
