[HTTPS zhn](nodeapi.ucdok.com/#/api/tls.html) <br />
[HTTPS en](https://nodejs.org/api/https.html)
```
import Https from 'https';
```

<span>

```
Https.createServer(options, [listener()])      // 创建一个 HTTPS 服务器

Https.request(options, callback)               // 连接一个远程 HTTPS 服务器

     • options {
           host               : String  // 发送请求的服务器的域名或 IP 地址，缺省为 'localhost'。
           hostname           : String  // 为了支持 url.parse()，hostname 优先于 host。
           port               : Number  // 远程服务器的端口，缺省为 443。
           method             : String  // 指定 HTTP 请求方法的字符串，缺省为 `'GET'。
           path               : String  // 请求路径，缺省为 '/'。如有查询字串则应包含，比如 '/index.html?page=12'。
           headers            : Object  // 包含请求头的对象。
           auth               : String  // 基本认证，如 'user:password' 来计算 Authorization 头。
           agent              : Agent   // 控制 Agent 行为。当使用 Agent 时请求会缺省为 Connection: keep-alive。可选值有 : 
                                           ∘ undefined（缺省） // 为该主机和端口使用 globalAgent。
                                           ∘ Agent 对象       // 明确使用传入的 Agent。
                                           ∘ false           // 不使用 Agent 连接池，缺省请求 Connection: close。

           pfx                : String  // 证书，SSL 所用的私钥或 CA 证书。缺省为 null。
           key                : String  // SSL 所用私钥。缺省为 null。
           passphrase         : String  // 私钥或 pfx 的口令字符串，缺省为 null。
           cert               : String  // 所用公有 x509 证书，缺省为 null。
           ca                 : Array   // 用于检查远程主机的证书颁发机构或包含一系列证书颁发机构的数组。
           ciphers            : String  // 描述要使用或排除的密码的字符串，格式请参阅 http://www.openssl.org/docs/apps/ciphers.html#CIPHER_LIST_FORMAT。
           rejectUnauthorized : Boolean // 如为 true 则服务器证书会使用所给 CA 列表验证。如果验证失败则会触发 'error' 时间。验证过程发生于连接层，在 HTTP 请求发送之前。缺省为 true。
           secureProtocol     : String  // 所用 SSL 方法，比如 SSLv3_method 强制使用 SSL version 3。可取值取决于您安装的 OpenSSL 并被定义在 SSL_METHODS 常量。
       }

Https.get(options, callback)                  // 连接一个远程 HTTPS 服务器
```

Https.Server (HTTPS 服务器)
--------------------------------


Https.Agent (HTTPS 远程连接代理)
-------------------------------

