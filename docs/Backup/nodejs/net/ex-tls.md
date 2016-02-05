Tls Server
-----------

```
import Tls from 'tls';
import Fs  from 'fs';

var server = Tls.createServer({
    key                : Fs.readFileSync('./ca-key.pem'),   // 服务器密钥
    cert               : Fs.readFileSync('./ca-cert.pem'),  // 服务器签名证书
    handshakeTimeout   : 120,                               // 握手超时时间，default=120s
    ca                 : [],                                // 有效证书认证机构
    passphrase         : '123456',                          // 服务器密钥解析密码
    requestCert        : true,                              // 客户端需要发送签名证书
    rejectUnauthorized : true                               // 客户端发送的证书必须是有效认证机构签名
    // ciphers          : '',                               // 加密组件
    // ECDHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA256:AES128-GCM-SHA256:RC4:HIGH:!MD5:!aNULL
    // secureProtocol : secureProtocol,                     // 强制使用版本的安全协议
    // secureOptions  : secureOptions                       // 安全方法配置 
});
server.listen(10010);
server.on('secureConnection', (socket) => {
    console.log('Authorized: ',         socket.authorized);            // 客户端签名证书是 CA 签名？
    console.log('AuthorizationError: ', socket.authorizationError);    // 验证错误原因
    console.log('Certificate: ',        socket.getPeerCertificate());  // 客户端签名证书信息
    console.log('Cipher: ',             socket.getCipher());           // 当前加密组件的信息

    socket.setEncoding('utf8');
    socket.on('data', (data) => {
        console.log('Data: %j', data);
    });
    socket.on('end', () => {
        console.log('End');
    });

    process.stdin.pipe(socket);
    process.stdin.resume();
});
server.on('newSession', (sessionId, sessionData) => {
    console.log('SessionId',            sessionId);
    console.log('SessionData',          sessionData);
});
```

Tls Client
------------

```
import Tls from 'tls';
import Fs  from 'fs';

var socket = Tls.connect({
    port               : 10010,
    key                : Fs.readFileSync('./ca-key.pem'),   // 客户端密钥
    cert               : Fs.readFileSync('./ca-cert.pem'),  // 客户端签名证书
    ca                 : [],                                // 有效证书认证机构
    passphrase         : '123456',                          // 客户端密钥解析密码    
    rejectUnauthorized : true                               // 服务器发送的证书必须是有效认证机构签名
    // secureProtocol   : ''                                // 安全协议
}, function() {
    console.log('client connected', socket.authorized ? 'authorized' : 'unauthorized');
    process.stdin.pipe(socket);
    process.stdin.resume();
});
socket.setEncoding('utf8');
socket.on('data', function(data) {
    console.log('Data: %j', data);
});
socket.on('end', function() {
    console.log('End');
    socket.end();
});
socket.on('error', function(err) {
    console.log('Error: ', err);
});
```