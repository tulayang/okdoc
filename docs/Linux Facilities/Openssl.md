    * libcrypto  通用加密库
    * libssl     TLS/SSL 的实现
    * openssl    命令行工具

加密算法
--------

* 对称加密 

      AES(128) | DES(64) | Blowfish(64) | CAST(64) | IDEA(64) | RC2(64) | RC5(64)

* 非对称加密
  
      DH | RSA | DSA | EC

* 信息摘要

      MD2 | MD5 | MDC2 | SHA | RIPEMD | DSS

安装
-------

    $ ./configure
    $ make
    $ make install

    or

    $ aptitude install openssl
    $ aptitude install libssl-dev

命令
------

    $ openssl s_client -connect 127.0.0.1:8000          // 连接服务器

    $ openssl version -a                                // 显示版本和编译参数
    $ openssl ?                                         // 显示支持的子命令
    $ openssl ciphers                                    // 显示 SSL 密码组合列表

    $ openssl speed [name]                               // 测试算法速度

    $ openssl enc -e -rc4 -in ./file1 -out ./file2       // 加密文件
    $ openssl enc -d -rc4 -in ./file2 -out ./file1       // 解密文件

    $ openssl sha1 < ./file1                             // 计算 hash 值 

    $ openssl genrsa -out ./a.key 1024                   // 生成 RSA 密钥对
    $ openssl rsa    -in  ./a.key -pubout -out ./a.pub   // 从密钥中提取公钥

      密钥位数 : 1024 | 2048 | 4096

    
CA 密钥公钥
------------

配置 /etc/ssl/openssl.cnf

    [ CA_default ]

    dir           = /etc/pki/CA                // 工作目录
    certs         = $dir/certs                 // 客户端证书保存目录
    crl_dir       = $dir/crl                   // 证书吊销列表的位置
    database      = $dir/index.txt             // 证书发证记录数据库
    new_certs_dir = $dir/newcerts              // 新生成证书存放目录
    certificate   = $dir/cacert.pem            // CA的证书文件
    serial        = $dir/serial                // 签发证书的序列号，一般从01开始
    crlnumber     = $dir/crlnumber             // 帧数吊销列表的序列号
    crl           = $dir/crl.pem               // 证书吊销列表文件
    private_key   = $dir/private/cakey.pem     // CA的私钥文件
    RANDFILE      = $dir/private/.rand         // 随机数生产文件，会自动创建
    default_days  = 365                        // 默认签发有效期

1. 创建密钥

       $ openssl genrsa -out ./ca-key.pem 2048

2. 生成证书签发申请
        
       $ openssl req -new                       \
                     -key    ./ca-key.pem       \
                     -out    ./ca-csr.pem       \
                     -config ./ca.cnf

3. 生成自签名证书 | 证书认证机构签名 (发送CSR)

       $ openssl x509 -req                      \
                      -days    9999             \
                      -signkey ./ca-key.pem     \
                      -in      ./ca-csr.pem     \
                      -out     ./ca-cert.pem

   or 一步完成密钥、自签名证书

       $ openssl req -new                       \
                     -x509                      \
                     -days   9999               \
                     -keyout ./ca-key.pem       \
                     -out    ./ca-cert.pem      \
                     -config ./ca.cnf

4. 验证签名证书

       $ openssl verify -CAfile ca-cert.pem ca-cert.pem

example

```
// CA 证书机构签名
$ openssl req -new                       \
              -x509                      \
              -days   9999               \
              -keyout ./ca-key.pem       \
              -out    ./ca-cert.pem      \
              -config ./ca.cnf

// 使用 CA 证书签名 CSR
$ openssl genrsa -out agent-key.pem 1024
$ openssl req    -new                      \
                 -key    ./agent-key.pem   \
                 -out    ./agent-csr.pem   \
                 -config ./agent.cnf
$ openssl x509   -req                      \
                 -days 9999                \
                 -passin "pass:password"   \
                 -in      ./agent-csr.pem  \
                 -CA      ./ca-cert.pem    \
                 -CAkey   ./ca-key.pem     \
                 -CAcreateserial           \
                 -out     ./agent-cert.pem

// 验证签名
$ openssl verify -CAfile ./ca-cert.pem ./agent-cert.pem
```