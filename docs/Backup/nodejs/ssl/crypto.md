[crypto zhn](http://nodeapi.ucdok.com/#/api/crypto.html)<br />
[crypto en](https://nodejs.org/api/crypto.html)


```
/* 提供 OpenSSL 中的一系列哈希方法，包括 hmac、cipher、decipher、签名和验证等方法的封装 */
import Crypto from 'crypto';  
```

<span>

```
Crypto.getCiphers()                                           // 获取支持的加密算法列表
Crypto.getHashes()                                            // 获取支持的哈希加密算法列表

Crypto.createCredentials(options)                             // 创建一个加密凭证对象
 
       • options {
             pfx        : String | Buffer   // 代表经PFX或者PKCS12编码产生的私钥、证书以及CA证书
             key        : String            // 代表经PEM编码产生的私钥
             passphrase : String            // 私钥或者pfx的密码
             cert       : String            // 代表经PEM编码产生的证书
             ca         : String | [String] // 表示可信任的经PEM编码产生的CA证书列表
             crl        : String | [String] // 表示经PEM编码产生的CRL
             ciphers    : String            // 表示需要使用或者排除的加密算法
         }

Crypto.createHash(algorithm)                                  // 创建一个 Hash    
Crypto.createHmac(algorithm, key)                             // 创建一个 Hmac  
Crypto.createCipher(algorithm, password)                      // 创建一个 Ciper
Crypto.createCipheriv(algorithm, key, iv)                     // 创建一个 Ciper
Crypto.createDecipher(algorithm, password)                    // 创建一个 Decipher
Crypto.createDecipheriv(algorithm, key, iv)                   // 创建一个 Decipher  
Crypto.createSign(algorithm)                                  // 创建一个 Sign
Crypto.createVerify(algorithm)                                // 创建一个 Verify
Crypto.createDiffieHellman(prime_length)                      // 创建一个 DiffieHellman
Crypto.createDiffieHellman(prime, [encoding])                 // 创建一个 DiffieHellman

       • algorithm : String // 加密算法，'sha1' | 'md5' | 'sha256' | 'sha512' ...
                            // openssl list-message-digest-algorithms 会显示可用的摘要算法
       • key       : String | Buffer // 密钥
       • password  : String          // 密码
       • iv        : String | Buffer // 向量
       • prime     : String          // prim

Crypto.getDiffieHellman(group_name)                           // 获取迪菲－赫尔曼密钥交换组
Crypto.pbkdf2(password, salt, iterations, keylen, callback()) // 异步，使用伪随机函数生成密钥 
Crypto.pbkdf2Sync(password, salt, iterations, keylen)         // 同步，使用伪随机函数生成密钥 
Crypto.randomBytes(size, [callback()])                        // 生成密码学强度的伪随机数据
Crypto.pseudoRandomBytes(size, [callback()])                  // 生成非密码学强度的伪随机数据
Crypto.DEFAULT_ENCODING                                       // 设置对于可以接受字符串或buffer对象
                                                              // 的函数的默认编码方式   
```

Crypto.Hash (哈希值，可读可写流)
------------------------------

```
hash.update(string, [input_encoding])                         // 使用数据更新哈希值
hash.digest([encoding])                                       // 计算传入的所有数据的摘要值

     • encoding : 'hex' | 'binary' | 'base64'
```

Crypto.Hmac (加密图谱)
----------------------

```
hmac.update(string)                                           // 使用数据更新图谱值
hmac.digest([encoding])                                       // 计算传入的所有数据的摘要值
```

Crypto.Cipher (加密，可读可写流)
-------------------------------

```
cipher.update(string, [input_encoding], [output_encoding])    // 使用数据更新加密值
         
       • input_encoding  // 输入的编码
       • output_encoding // 输出的编码

cipher.setAutoPadding(auto_padding=true)                      // 禁用自动填充
cipher.final([output_encoding])                               // 返回剩余的加密内容
``` 

Crypto.Decipher (解密，可读可写流)
---------------------------------

```
decipher.update(string, [input_encoding], [output_encoding])  // 使用数据更新解密器
decipher.setAutoPadding(auto_padding=true)                    // 禁用自动填充
decipher.final([output_encoding])                             // 返回剩余的加密内容
```

Crypto.Sign (签名，可写流)
----------------------------

```
sign.update(string)                                           // 使用数据更新签名值
sign.sign(privatekey, [output_encoding])                      // 计算传入的所有数据来生成电子签名   

     • privatekey : String // 密钥                            
```

Crypto.Verify (验证签名，可写流)
-------------------------------

```
verify.update(string)                                         // 使用数据更新验证器
verify.verify(publicKey, signature, [signature_encoding])        // Boolean，验证签名

       • publicKey          : String // 包含了一个被PEM编码的公钥，
                                     // 这个对象可以是RSA公钥，DSA公钥或者X.509 证书
       • signature          : Object // 签名值
       • signature_encoding : String // 签名值编码
```

Crypto.DiffieHellman (迪菲－赫尔曼密钥)
-------------------------------------

```
diffieHellman.generateKeys([encoding])                        // 生成迪菲－赫尔曼(Diffie-Hellman)
                                                              // 算法的公钥和私钥，
                                                              // 并根据指明的编码方式返回公钥
diffieHellman.computeSecret(other_public_key, 
                            [input_encoding], 
                            [output_encoding])                // 使用公钥计算并生成共享秘密

              • other_public_key : String // 公钥

diffieHellman.getPrime([encoding])                            // 获取 prim
diffieHellman.getGenerator([encoding])                        // 获取生成器
diffieHellman.getPublicKey([encoding])                        // 获取公钥
diffieHellman.getPrivateKey([encoding])                       // 获取密钥
diffieHellman.setPublicKey(public_key, [encoding])            // 设置公钥
diffieHellman.setPrivateKey(private_key, [encoding])          // 设置密钥
```
