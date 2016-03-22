# [基础指南](https://www.feistyduck.com/library/openssl-cookbook/online/ch-openssl.html)

OpenSSL 是一个开源软件，由加密库和 SSL/TLS 工具包组成。官方网站是这样描述的：

> OpenSSL 是一个多人合作产生开源软件包，实现了健壮的、企业级别的、全功能的安全套接字层协议 （SSL） 和传输层安全协议 （TLS），旨在成为一个通用加密库。这个项目由许多义务工作者维护着，他/她们使用因特网联系、设计、开发 OpenSSL 工具包和相关文档。

OpenSSL 已经有很长历史。最开始是来自 1995 年一个称为 SSLeay 的项目，由 Eric A. Young 和 Tim J. Hudson 开发。1998 年，Eric 和 Tim 停止了 SSLeay 的工作，转而开发一个企业 SSL/TLS 工具包 --- 称为 BSAFE SSL-C。

今天，OpenSSL 遍布服务器和客户端工具。命令行工具也常常选择它作为密钥和证书管理器。有趣的是，浏览器在过去使用其它加密库，Google 在自己的 Chrome 中使用了 OpenSSL 的分支  BoringSSL。

OpenSSL is dual-licensed under OpenSSL and SSLeay licenses. Both are BSD-like, with an advertising clause. The license has been a source of contention for a very long time, because neither of the licenses is considered compatible with the GPL family of licenses. For that reason, you will often find that GPL-licensed programs favor GnuTLS.

## 楔子

如果你使用 Unix-like 平台，使用 OpenSSL 是非常简单的；实际上，你的系统往往已经自带了 OpenSSL。你要面对的唯一问题是：该自带 OpenSSL 是否是最新的版本。

Windows？　不想翻译　...

### 确定 OpenSSL 版本和配置

在你开始之前，你应该知道所使用的 OpenSSL 版本。比如，我在这里列出了一个 Ubuntu 12.04 LTS 上面的 OpenSSL 版本：

```sh
$ openssl version 
OpenSSL 1.0.1 14 Mar 2012
```

在写这篇文章之时，OpenSSL 正从 0.9.x 过渡到 1.0.x。1.0.x 是特别重要的，因为它是第一个支持 TLS 1.1 和 1.2 的版本。支持这个新的协议是全球趋势，过渡会为此持续一段时间。在此期间，一些互操作问题也时有发生。

> 注意：一些操作系统常常修改 OpenSSL 代码，以修复一些已知 BUG。然而，其名字和版本号会继续保留不变，没有什么“资料”可以帮助你知道该 OpenSSL 代码是否改变了。比如，Ubuntu 12.04 LTS 自带的  OpenSSL 是基于 OpenSSL 1.0.1c。在写这篇文章之时，这个包的全名是 openssl 1.0.1-4ubuntu5.16，包含了一些后续发布的补丁。

要得到完整的版本信息:

```sh
$ openssl version -a
OpenSSL 1.0.1f 6 Jan 2014
built on: Mon Feb 29 18:11:15 UTC 2016
platform: debian-amd64
options:  bn(64,64) rc4(16x,int) des(idx,cisc,16,int) blowfish(idx) 
compiler: cc -fPIC -DOPENSSL_PIC -DOPENSSL_THREADS -D_REENTRANT -DDSO_DLFCN -DHAVE_DLFCN_H -m64 -DL_ENDIAN -DTERMIO -g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2 -Wl,-Bsymbolic-functions -Wl,-z,relro -Wa,--noexecstack -Wall -DMD32_REG_T=int -DOPENSSL_IA32_SSE2 -DOPENSSL_BN_ASM_MONT -DOPENSSL_BN_ASM_MONT5 -DOPENSSL_BN_ASM_GF2m -DSHA1_ASM -DSHA256_ASM -DSHA512_ASM -DMD5_ASM -DAES_ASM -DVPAES_ASM -DBSAES_ASM -DWHIRLPOOL_ASM -DGHASH_ASM
OPENSSLDIR: "/usr/lib/ssl"
```

最后一行特别有意思，它告诉你 OpenSSL 从哪里查找配置和证书。在我的系统上，这些文件是 */etc/ssl* 的链接：

```sh
$ ls -l /usr/lib/ssl
lrwxrwxrwx  1 root root   14 Apr 19 09:28 certs -> /etc/ssl/certs
drwxr-xr-x  2 root root 4096 May 28 06:04 misc
lrwxrwxrwx  1 root root   20 May 22 17:07 openssl.cnf -> /etc/ssl/openssl.cnf
lrwxrwxrwx  1 root root   16 Apr 19 09:28 private -> /etc/ssl/private
```

*misc/* 目录包含了一些功能脚本，其中最有意思的就是能让你实现私有证书签发（CA）。

### 编译 OpenSSL

大多数情况下，你只需要使用系统自带的 OpenSSL 就够了，但是有时候还是升级的好。比如，你的系统可能是 OpenSSL 0.9.x，这个版本不支持 TLS 协议。此外，就算是你的系统 OpenSSL 支持 TLS，也可能缺少需要的某些功能。比如，Ubuntu 12.04 LTS 不支持 SSL 2 的 `s_client` 命令。下面我们介绍一下如何下载并编译最新版本的 OpenSSL。

首先，到官方网站下载 OpenSSL 最新版本：

```sh
wget http://www.openssl.org/source/openssl-1.0.1p.tar.gz
``` 

然后，配置 OpenSSL：

```sh
$ ./config --prefix=/opt/openssl \
           --openssldir=/opt/openssl \
           enable-ec_nistp_64_gcc_128
```

`enable-ec_nistp_64_gcc_128` 为某些经常使用的项启用优化。这些优化依赖于你的编译器。

接下来：

```sh
$ make depend
$ make
$ sudo make install
```

你会在 */opt/openssl* 得到下面文件：

```sh
$ ls -l /opt/openssl
drwxr-xr-x 2 root root  4096 Jun  3 08:49 bin
drwxr-xr-x 2 root root  4096 Jun  3 08:49 certs
drwxr-xr-x 3 root root  4096 Jun  3 08:49 include
drwxr-xr-x 4 root root  4096 Jun  3 08:49 lib
drwxr-xr-x 6 root root  4096 Jun  3 08:48 man
drwxr-xr-x 2 root root  4096 Jun  3 08:49 misc
-rw-r--r-- 1 root root 10835 Jun  3 08:49 openssl.cnf
drwxr-xr-x 2 root root  4096 Jun  3 08:49 private
```

*private/* 目录是空的，这是正常的 --- 你还没有任何密钥。此外，*certs/* 目录也应该是空的，OpenSSL 不包含任何根证书 --- maintaining a trust store is considered outside the scope of the project。

> When compiling software, it’s important to be familiar with the default configuration of your compiler. System-provided packages are usually compiled using all the available hardening options, but if you compile some software yourself there is no guarantee that the same options will be used.

### 列出可用命令

OpenSSL 是一个加密工具包，由许多不同工具组成。我数了下我的版本有 46 个工具。尽管你只需要其中部分常用工具，但是熟悉其它的工具，能让你在将来知道选取哪一个工具最佳。

```?
$ openssl help
openssl:Error: 'help' is an invalid command.

Standard commands
asn1parse         ca                ciphers           cms
crl               crl2pkcs7         dgst              dh
dhparam           dsa               dsaparam          ec
ecparam           enc               engine            errstr
gendh             gendsa            genpkey           genrsa
nseq              ocsp              passwd            pkcs12
pkcs7             pkcs8             pkey              pkeyparam
pkeyutl           prime             rand              req
rsa               rsautl            s_client          s_server
s_time            sess_id           smime             speed
spkac             srp               ts                verify
version           x509
```

第一部分显示所有可用的工具。要得到该工具的具体信息，使用 `man` 命令查看 --- 比如 `man ciphers`。

第二部分显示消息摘要命令：

```?
Message Digest commands (see the `dgst' command for more details)
md4               md5               rmd160            sha
sha1
```

第三部分，显示所有加密命令：

```?
Cipher commands (see the `enc' command for more details)
aes-128-cbc       aes-128-ecb       aes-192-cbc       aes-192-ecb       
aes-256-cbc       aes-256-ecb       base64            bf                
bf-cbc            bf-cfb            bf-ecb            bf-ofb            
camellia-128-cbc  camellia-128-ecb  camellia-192-cbc  camellia-192-ecb  
camellia-256-cbc  camellia-256-ecb  cast              cast-cbc          
cast5-cbc         cast5-cfb         cast5-ecb         cast5-ofb         
des               des-cbc           des-cfb           des-ecb           
des-ede           des-ede-cbc       des-ede-cfb       des-ede-ofb       
des-ede3          des-ede3-cbc      des-ede3-cfb      des-ede3-ofb      
des-ofb           des3              desx              rc2               
rc2-40-cbc        rc2-64-cbc        rc2-cbc           rc2-cfb           
rc2-ecb           rc2-ofb           rc4               rc4-40            
seed              seed-cbc          seed-cfb          seed-ecb          
seed-ofb          
```

### 

## 编译一个可信任存储

OpenSSL 不提供任何可信任的根证书（also known as a trust store），因此你不得不自己从其它地方找一个来安装。一个可行方案是把可信任存储内置到你的操作系统，但是很有可能无法保持更新。另一个更好的选择是，使用 Mozilla 提供的可信任存储 --- 开源的，Mozilla 负责维护其源代码：

```sh
https://hg.mozilla.org/mozilla-central/raw-file/tip/security/nss/lib/ckfw/builtins/certdata.txt
```

然而，Mozilla 提供的证书集是一个专有格式，很多情况下不符合我们的格式要求。如果你不介意使用第三方提供的证书集，Curl project 提供了一个 Privacy-Enhanced Mail (PEM) 格式的，你能直接使用：

```sh
http://curl.haxx.se/docs/caextract.html
```

如果你打算使用 Mozilla 提供的，你不得不写一个脚本来转换它。好在已经提供了一些这样的脚本，以下是一个 Perl 脚本：

```sh
https://raw.github.com/bagder/curl/master/lib/mk-ca-bundle.pl
```

下载之后，运行它，它会找到 Mozilla 的证书数据并转换为 PEM 格式：

```sh
$ ./mk-ca-bundle.pl
Downloading 'certdata.txt' ...
Processing  'certdata.txt' ...
Done (156 CA certs processed, 19 untrusted skipped).
```

如果之前你已经下载了证书数据，这个脚本会检查是否有更新变化。

## 密钥和证书

大多数用户使用 OpenSSL 是因为可以为自己的 web 服务器提供 SSL 支持。这个过程由三部组成：

1. 生成一个密钥

2. 创建一个证书签名请求 （CSR），发送到一个 CA 机构

3. 在 web 服务器安装 CA 提供的证书

### 创建密钥

在生成密钥之前，你需要知道：

* 密钥算法

  OpenSSL 支持 RSA、DSA、ECDSA 密钥算法，但是不是所有这些算法都能应对你的需要。比如，web 服务器会使用 RSA，因为 DSA 密钥被限制在 1024 位之内 （IE 不再支持）；ECDSA 也被 CAs 广泛支持。对于 SSH，更常用 RSA 和 DSA，而某些客户端可能不支持  ECDSA 。

* 密钥位数

  默认的密钥位数可能是不安全的，你应该总是明确指定密钥位数。比如，RSA 密钥默认是 512 位，在今天这很容易被蛮力攻击破解。请在你的网站上使用 2048 位。Aim 使用 2048 位 DSA 密钥和至少 256 位 ECDSA 密钥。

* 加密口令

  加密口令是可选的，但是强烈推荐。这样，密钥可以安全的存储、传输和备份。另一方面，这样是不方便的，每次重启服务器你都需要重新输出加密口令。此外，加密口令并不能增加安全。因为，加密口令是保存在程序内存中的，恶意攻击者侵入系统后可以用一些手段从内存中获取到加密口令。因此，加密口令仅仅在密钥没有安装在产品系统时提供保护（防止他人读取）。

要生成一个 RSA 密钥，使用 `genrsa` 命令：

```sh
$ openssl genrsa -aes128 -out fd.key 2048
Generating RSA private key, 2048 bit long modulus
....+++
...................................................................................+++
e is 65537 (0x10001)
Enter pass phrase for fd.key: ****************
Verifying - Enter pass phrase for fd.key: ****************
```

这里，指定密钥算法是 `AES-128`。你也可以指定 `AES-192` 或 `AES-256`，但是最好远离 `DES`、`3DES`、` SEED` 等算法。

> 警告：上面显示的 `e` 的值关系到公共 exponent --- 默认是 `65537`。这被称为 short public exponent，能为 RSA 验证提供更快的性能。使用 `-3`，可以选择为 `3` 使得验证性能更快。但是，`3` 可能存在一些潜在问题，仍然推荐使用默认的 `65537`。

密钥以 PEM 格式存储：

```sh
$ cat fd.key
-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: AES-128-CBC,01EC21976A463CE36E9DB59FF6AF689A

vERmFJzsLeAEDqWdXX4rNwogJp+y95uTnw+bOjWRw1+O1qgGqxQXPtH3LWDUz1Ym
mkpxmIwlSidVSUuUrrUzIL+V21EJ1W9iQ71SJoPOyzX7dYX5GCAwQm9Tsb40FhV/
[21 lines removed...]
4phGTprEnEwrffRnYrt7khQwrJhNsw6TTtthMhx/UCJdpQdaLW/TuylaJMWL1JRW
i321s5me5ej6Pr4fGccNOe7lZK+563d7v5znAx+Wo1C+F7YgF+g8LOQ8emC+6AVV
-----END RSA PRIVATE KEY-----
```

略微一瞥，密钥好像是一些随机数据。你可以使用 `rsa` 看一下它的结构信息：

```sh
$ openssl rsa -text -in fd.key
Enter pass phrase for fd.key: ****************
Private-Key: (2048 bit)
modulus:
    00:9e:57:1c:c1:0f:45:47:22:58:1c:cf:2c:14:db:
    [...]
publicExponent: 65537 (0x10001)
privateExponent:
    1a:12:ee:41:3c:6a:84:14:3b:be:42:bf:57:8f:dc:
    [...]
prime1:
    00:c9:7e:82:e4:74:69:20:ab:80:15:99:7d:5e:49:
    [...]
prime2:
    00:c9:2c:30:95:3e:cc:a4:07:88:33:32:a5:b1:d7:
    [...]
exponent1:
    68:f4:5e:07:d3:df:42:a6:32:84:8d:bb:f0:d6:36:
    [...]
exponent2:
    5e:b8:00:b3:f4:9a:93:cc:bc:13:27:10:9e:f8:7e:
    [...]
coefficient:
    34:28:cf:72:e5:3f:52:b2:dd:44:56:84:ac:19:00:
    [...]
writing RSA key
-----BEGIN RSA PRIVATE KEY-----
[...]
-----END RSA PRIVATE KEY-----
```

如果你需要生成公钥，这样做：

```sh
$ openssl rsa -in fd.key -pubout -out fd-public.key
Enter pass phrase for fd.key: ****************
```

如果你查看新生成的文件，你会看到:

```sh
$ cat fd-public.key
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnlccwQ9FRyJYHM8sFNsY
PUHJHJzhJdwcS7kBptutf/L6OvoEAzCVHi/m0qAA4QM5BziZgnvv+FNnE3sgE5pz
iovEHJ3C959mNQmpvnedXwfcOIlbrNqdISJiP0js6mDCzYjSO1NCQoy3UpYwvwj7
0ryR1F+abARehlts/Xs/PtX3VamrljiJN6JNgFICy3ZvEhLZEKxR7oob7TnyZDrj
IHxBbqPNzeiqLCFLFPGgJPa0cH8DdovBTesvu7wr/ecsf8CYyUCdEwGkZh9DKtdU
HFa9H8tWW2mX6uwYeHCnf2HTw0E8vjtOb8oYQxlQxtL7dpFyMgrpPOoOVkZZW/P0
NQIDAQAB
-----END PUBLIC KEY-----
```

在输出中验证你所期望的内容是一个最佳实践。比如，如果你忘记指定 `-pubout`，输出会包含密钥而不是公钥。

DSA 密钥生成分为两步：创建 DSA 参数和创建密钥。以下命令将它们合并为一行：

```sh
$ openssl dsaparam -genkey 2048 | openssl dsa -out dsa.key -aes128
Generating DSA parameters, 2048 bit long prime
This could take some time
[...]
read DSA key
writing DSA key
Enter PEM pass phrase: ****************
Verifying - Enter PEM pass phrase: ****************
```

这样生成一个密钥，并且没有临时文件留在磁盘。

ECDSA 密钥和上面这些过程类似，除了不能指定密钥位数。你需要指定一个命名 curve，来控制密钥位数。下面使用 `secp256r1` curve 创建一个 256 位的 ECSDA 密钥：

```sh
$ openssl ecparam -genkey -name secp256r1 | openssl ec -out ec.key -aes128
using curve name prime256v1 instead of secp256r1
read EC key
writing EC key
Enter PEM pass phrase: ****************
Verifying - Enter PEM pass phrase: ****************
```
 
OpenSSL 支持许多命名 curve （你能通过 `-list_curves` 获取所有项）。对于 web 服务器，只支持两个：`secp256r1`（OpenSSL 也使用 `prime256v1` 这个名字） 和 `secp384r1`。

> 如果你使用 OpenSSL 1.0.2，可以直接使用 `genpkey` 命令生成密钥以节省时间。

### 创建密钥签名请求

一旦你有了密钥，就需要创建一个密钥签名请求 （CSR）。之后，把这个请求提交给 CA 机构进行签名，你会获得一个包含了公钥和其他信息的签名证书。

CSR 的创建过程通常是交互式的，你需要提供一些成员信息。如果你想要某个字段是空的，那么必须键入 `.` 而不要直接输入回车。If you do the latter, OpenSSL will populate the corresponding CSR field with the default value. (This behavior doesn’t make any sense when used with the default OpenSSL configuration, which is what virtually everyone does. It does make sense once you realize you can actually change the defaults, either by modifying the OpenSSL configuration or by providing your own configuration files.) 

```sh
$ openssl req -new -key fd.key -out fd.csr
Enter pass phrase for fd.key: ****************
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:GB
State or Province Name (full name) [Some-State]:.
Locality Name (eg, city) []:London
Organization Name (eg, company) [Internet Widgits Pty Ltd]:Feisty Duck Ltd
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []:www.feistyduck.com
Email Address []:webmaster@feistyduck.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

CSR 生成之后，自己进行签名或者发给一个公共 CA 请求其签名。后面都这两种情况进行了描述。但是，在此之前，有必要检查以下 CSR 的正确性：

```sh
$ openssl req -text -in fd.csr -noout
Certificate Request:
    Data:
        Version: 0 (0x0)
        Subject: C=GB, L=London, O=Feisty Duck Ltd, CN=www.feistyduck.com/emailAddress=webmaster@feistyduck.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:b7:fc:ca:1c:a6:c8:56:bb:a3:26:d1:df:e4:e3:
                    [16 more lines...]
                    d1:57
                Exponent: 65537 (0x10001)
        Attributes:
            a0:00
    Signature Algorithm: sha1WithRSAEncryption
         a7:43:56:b2:cf:ed:c7:24:3e:36:0f:6b:88:e9:49:03:a6:91:
         [13 more lines...]
         47:8b:e3:28
```

### 使用已有的证书创建密钥签名请求

如果你打算新建了一个证书，并且使用已有的证书而且不进行任何改变，那么可以这样做：

```sh
$ openssl x509 -x509toreq -in fd.crt -out fd.csr -signkey fd.key
```

> 通常，最佳实践是每次都创建一个新的证书。密钥生成很快，而且不贵。

### 非交互式创建密钥签名请求

CSR 创建并不一定需要交互。使用一个自定义的 OpenSSL 配置文件，你可以自动生成一个密钥签名请求。

比如，假设我们想自动为 www.feistyduck.com 生成一个 CSR，我们需要创建一个 *fd.cnf* 文件，输入以下内容：

```?
[req]
prompt             = no
distinguished_name = dn
req_extensions     = ext
input_password     = PASSPHRASE

[dn]
CN                 = www.feistyduck.com
emailAddress       = webmaster@feistyduck.com
O                  = Feisty Duck Ltd
L                  = London
C                  = GB

[ext]
subjectAltName     = DNS:www.feistyduck.com,DNS:feistyduck.com
```

现在，直接从命令行创建 CSR：

```sh
$ openssl req -new -config fd.cnf -key fd.key -out fd.csr
```

### 自己签名证书

如果你架设了一个 TLS 服务器，并且打算自己使用，那么你可能不想要 CA 来签名一个公共证书。最快的方式是生成一个自签名证书。

使用下面命令创建自签名证书：

```sh
$ openssl x509 -req -days 365 -in fd.csr -signkey fd.key -out fd.crt
Signature ok
subject=/CN=www.feistyduck.com/emailAddress=webmaster@feistyduck.com/O=Feisty Duck Ltd↩
/L=London/C=GB
Getting Private key
Enter pass phrase for fd.key: ****************
```

实际上，对于自签名证书，不需要分开一步一步地创建。你可以一步搞定：

```sh
$ openssl req -new -x509 -days 365 -key fd.key -out fd.crt
```

如果你不想询问任何问题，使用 `-subj` 提供证书主题信息：

```sh
$ openssl req -new -x509 -days 365 -key fd.key -out fd.crt \
              -subj "/C=GB/L=London/O=Feisty Duck Ltd/CN=www.feistyduck.com"
```

### 为多个主机创建证书

默认情况下，OpenSSL 生成的证书只有一个名字，而且只对一个主机名有效。因此，你的每个网站，都需要一个单独的证书。

有两种方法可以使一个证书支持多个主机名。第一个是使用 X.509 扩展 Subject Alternative Name （SAN） 列出所有期望的主机名；第二个是用通配符。你也能混合使用它们。在实际中，你可以指定一个域名和一些子域名的通配符（`feistyduck.com` 和 `*.feistyduck.com`）。

现在，在一个文本文件 *fd.txt* 写入扩展信息，指定 `subjectAltName` 列出期望的主机名：

```?
subjectAltName = DNS:*.feistyduck.com, DNS:feistyduck.com
```

然后，使用 `X509` 命令生成一个证书，指定 `-extfile` 为该文件：

```sh
$ openssl x509 -req -days 365 \
               -in fd.csr -signkey fd.key -out fd.crt \
               -extfile fd.ext
```

剩下的内容和之前的没有多大区别，但是当你查看生成的证书时，你能看到 SAN 扩展：

```sh
X509v3 extensions:
    X509v3 Subject Alternative Name:
        DNS:*.feistyduck.com, DNS:feistyduck.com
```

### 检查证书

证书看起来像是一些随机数据，但是它们包含了许多有用的信息。使用 ` x509` 命令可以查看证书的详细信息。

在下面的命令，指定 `-text` 打印证书内容、`-noout` 不打印编码证书本身：

```sh
$ openssl x509 -text -in fd.crt -noout
Certificate:
    Data:
        Version: 1 (0x0)
        Serial Number: 13073330765974645413 (0xb56dcd10f11aaaa5)
    Signature Algorithm: sha1WithRSAEncryption
        Issuer: CN=www.feistyduck.com/emailAddress=webmaster@feistyduck.com, O=Feisty Duck Ltd, L=London, C=GB
        Validity
            Not Before: Jun  4 17:57:34 2012 GMT
            Not After : Jun  4 17:57:34 2013 GMT
        Subject: CN=www.feistyduck.com/emailAddress=webmaster@feistyduck.com, O=Feisty Duck Ltd, L=London, C=GB
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:b7:fc:ca:1c:a6:c8:56:bb:a3:26:d1:df:e4:e3:
                    [16 more lines...]
                    d1:57
                Exponent: 65537 (0x10001)
    Signature Algorithm: sha1WithRSAEncryption
         49:70:70:41:6a:03:0f:88:1a:14:69:24:03:6a:49:10:83:20:
         [13 more lines...]
         74:a1:11:86
``` 

自签名证书通常包含最基础的证书数据，就像上面看到的。相比较之下，CA 签名的证书包含了更多的字段 （通过 X.509 扩展），现在，我们来快速介绍一下：

* `Basic Constraints`

  标识该证书属于一个 CA，可以用来签名其它证书。非 CA 证书会省略这一项或者置为 `FALSE`。

  ```sh
  X509v3 Basic Constraints: critical
      CA:FALSE
  ```

* `Key Usage (KU)` 和 `Extended Key Usage (EKU)`

  限制证书可以使用的范围。如果这一项存在，那么会列出限制的范围；如果不存在，表示可以用于任何范围。

  ```sh
  X509v3 Key Usage: critical
      Digital Signature, Key Encipherment
  X509v3 Extended Key Usage:
      TLS Web Server Authentication, TLS Web Client Authentication
  ```

* `CRL Distribution Points`

  列出地址，在那里可以找到 CA 的 Certificate Revocation List (CRL) 信息。

  ```sh
  X509v3 CRL Distribution Points:
      Full Name:
          URI:http://crl.starfieldtech.com/sfs3-20.crl
  ```

* `Certificate Policies`

  标识证书策略。

  ```sh
  X509v3 Certificate Policies:
      Policy: 2.16.840.1.114414.1.7.23.3
      CPS: http://certificates.starfieldtech.com/repository/
  ```

* `Authority Information Access (AIA)`

  通常用来包含两个重要信息。第一，列出 CA 的 Online Certificate Status Protocol (OCSP) 应答器 --- 用来实时检查证书撤销。第二，包含证书发行者的链接。

  ```sh
  Authority Information Access:
      OCSP - URI:http://ocsp.starfieldtech.com/
      CA Issuers - URI:http://certificates.starfieldtech.com/repository/sf_intermediate.crt
  ```

* `Subject Key Identifier` 和 `Authority Key Identifier`

  ```sh
  X509v3 Subject Key Identifier:
      4A:AB:1C:C3:D3:4E:F7:5B:2B:59:71:AA:20:63:D6:C9:40:FB:14:F1
  X509v3 Authority Key Identifier:
      keyid:49:4B:52:27:D1:1B:BC:F2:A1:21:6A:62:7B:51:42:7A:8A:D7:D5:56
  ```

* `Subject Alternative Name`

  列出证书支持的所有主机名。通常是可选的，如果不存在客户端会使用 Common Name (CN --- Subject 字段的一部分) 提供的信息。

  ```sh
  X509v3 Subject Alternative Name:
      DNS:www.feistyduck.com, DNS:feistyduck.com
  ```

###

## 创建一个私有证书机构

如果你想架设一个自己的 CA，所需要做的就是持有 OpenSSL。一个 OpenSSL 基础的自建 CA，尽管可能是粗糙的，但是能满足个人或者小团体的需要。比如，在开发环境使用私有 CA 更方便。

### 创建一个 Root CA 的过程

创建一个新的 CA 分为如下几步：配置、创建结构目录、初始化密钥文件、生成根密钥和证书。

### 配置 Root CA

创建一个 CA 之前，必须准备一个配置文件，告诉 OpenSSL 我们打算做什么。

第一部分包括基础的 CA 信息，比如名字、基础 URL 等等：

```?
[default]
name                    = root-ca
domain_suffix           = example.com
aia_url                 = http://$name.$domain_suffix/$name.crt
crl_url                 = http://$name.$domain_suffix/$name.crl
ocsp_url                = http://ocsp.$name.$domain_suffix:9080
default_ca              = ca_default
name_opt                = utf8,esc_ctrl,multiline,lname,align

[ca_dn]
countryName             = "GB"
organizationName        = "Example"
commonName              = "Root CA"
```

第二部分直接控制 CA 的操作。要知道所有设置信息，使用 `man ca` 查看。Because this root CA is going to be used only for the issuance of subordinate CAs, I chose to have the certificates valid for 10 years. For the signature algorithm, the secure SHA256 is used by default.

```?
[ca_default]
home                    = .
database                = $home/db/index
serial                  = $home/db/serial
crlnumber               = $home/db/crlnumber
certificate             = $home/$name.crt
private_key             = $home/private/$name.key
RANDFILE                = $home/private/random
new_certs_dir           = $home/certs
unique_subject          = no
copy_extensions         = none
default_days            = 3650
default_crl_days        = 365
default_md              = sha256
policy                  = policy_c_o_match

[policy_c_o_match]
countryName             = match
stateOrProvinceName     = optional
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional
```

第三部分包含 `req` 命令的配置：

```?
[req]
default_bits            = 4096
encrypt_key             = yes
default_md              = sha256
utf8                    = yes
string_mask             = utf8only
prompt                  = no
distinguished_name      = ca_dn
req_extensions          = ca_ext

[ca_ext]
basicConstraints        = critical,CA:true
keyUsage                = critical,keyCertSign,cRLSign
subjectKeyIdentifier    = hash
```

第四部分：

```?
[sub_ca_ext]
authorityInfoAccess     = @issuer_info
authorityKeyIdentifier  = keyid:always
basicConstraints        = critical,CA:true,pathlen:0
crlDistributionPoints   = @crl_info
extendedKeyUsage        = clientAuth,serverAuth
keyUsage                = critical,keyCertSign,cRLSign
nameConstraints         = @name_constraints
subjectKeyIdentifier    = hash

[crl_info]
URI.0                   = $crl_url

[issuer_info]
caIssuers;URI.0         = $aia_url
OCSP;URI.0              = $ocsp_url

[name_constraints]
permitted;DNS.0=example.com
permitted;DNS.1=example.org
excluded;IP.0=0.0.0.0/0.0.0.0
excluded;IP.1=0:0:0:0:0:0:0:0/0:0:0:0:0:0:0:0
```

第五部分指定 OSCP 扩展：

```?
[ocsp_ext]
authorityKeyIdentifier  = keyid:always
basicConstraints        = critical,CA:false
extendedKeyUsage        = OCSPSigning
keyUsage                = critical,digitalSignature
subjectKeyIdentifier    = hash
```

### Root CA 目录

然后，创建 Root CA 的目录，并且初始化 CA 操作用到的一些文件：

```sh
$ mkdir root-ca
$ cd root-ca
$ mkdir certs db private
$ chmod 700 private
$ touch db/index
$ openssl rand -hex 16  > db/serial
$ echo 1001 > db/crlnumber
```

* certs/
 
  存储证书，新的证书会被放置在这里。

* db/
 
  用于证书数据库（索引），以及存放下一个证书和 URL 的编号。

* private/

  存储密钥，只存储 CA 的密钥和其他 OSCP 应答器。其他用户不能访问它。

### Root CA 证书生成

首先，生成密钥和 CSR，所有需要的信息通过 `-﻿config` 指定配置文件：

```sh
$ openssl req -new \
              -config root-ca.conf \
              -out root-ca.csr \
              -keyout private/root-ca.key
```

然后，创建一个自签名证书，`-extensions` 指向配置文件的 `ca_ext` 块 --- 激活适当的扩展功能：

```sh
$ openssl ca -selfsign \
             -config root-ca.conf \
             -in root-ca.csr \
             -out root-ca.crt \
             -extensions ca_ext
```

### 数据库文件的结构

*db/index* 的数据库是一个纯文本文件，包含证书信息，每个证书一行。Root CA 创建完后，应该只包含一行：

```?
V    240706115345Z        1001    unknown    /C=GB/O=Example/CN=Root CA
```

每一行包含六个项：

1. 状态标志 （`V` 是有效，`R` 是取消，`E` 是过期）

2. 过期时间 （`YYMMDDHHMMSSZ` 格式）

3. 如果未撤销的话，是撤销日期或者是空的

4. 编号 （十六进制数字）

5. 特殊名字

### Root CA 操作

使用新 CA 生成一个 CRL：

```sh
$ openssl ca -gencrl \
             -config root-ca.conf \
             -out root-ca.crl
```

发布一个证书，使用 `ca` 命令，指定 `-extensions` 指向配置文件对应的块：

```sh
$ openssl ca -config root-ca.conf \
             -in sub-ca.csr \
             -out sub-ca.crt \
             -extensions sub_ca_ext
```

撤销一个证书，使用 `ca` 命令，指定 `-revoke`：

```sh
$ openssl ca -config root-ca.conf \
             -revoke certs/1002.pem \
             -crl_reason keyCompromise
```

### 

## 密钥和证书转换

密钥和证书可以存储为多种格式，也因此，你可能需要在不同格式之间进行转换。常用的格式有：

* Binary (DER) certificate

  包含一个 X.509 证书的原始形式，使用 DER ASN.1 编码。

* ASCII (PEM) certificate(s)

  包含一个 base64 编码的 DER 证书，以 `-----BEGIN CERTIFICATE-----` 开头、`-----END CERTIFICATE-----` 结尾。通常每个文件存储一个密钥，但是在一个文件也允许存储多个密钥。

* Binary (DER) key

  包含一个密钥的原始形式，使用 DER ASN.1 编码。

* ASCII (PEM) key

  包含一个 base64 编码的密钥，有时候还有一些其它元数据（比如，使用的算法）。  

* PKCS#7 certificate(s)

  复合格式，用来传输签名或加密的数据，定义在 RFC 2315。通常在 .p7b 和 .p7c 看到。

* PKCS#12 (PFX) key and certificate(s)

  复合格式，用来存储和保护服务器证书链。

### PEM 和 DER 转换 ：

```sh
$ openssl x509 -inform PEM -in fd.pem -outform DER -out fd.der

$ openssl x509 -inform DER -in fd.der -outform PEM -out fd.pem
```

### PEM 和 PKCS#12 (PFX) 转换

以下命令转换一个密钥、证书和中间证书到一个单独的 PKCS#12 文件：

```sh
$ openssl pkcs12 -export \
                 -name "My Certificate" \
                 -out fd.p12 \
                 -inkey fd.key \
                 -in fd.crt \
                 -certfile fd-chain.crt
Enter Export Password: ****************
Verifying - Enter Export Password: ****************
```

反向转换如下：

```sh
$ openssl pkcs12 -in fd.p12 -out fd.pem -nodes
```

现在，你必须打开 *fd.pem* 文件，手动把它拆分到密钥、证书、中间证书三个文件。OpenSSL 提供了工具帮助你拆分到三个文件：

```sh
$ openssl pkcs12 -in fd.p12 -nocerts -out fd.key -nodes
$ openssl pkcs12 -in fd.p12 -nokeys -clcerts -out fd.crt
$ openssl pkcs12 -in fd.p12 -nokeys -cacerts -out fd-chain.crt
```

### PEM 和 PKCS#7 转换：

```sh
$ openssl crl2pkcs7 -nocrl -out fd.p7b -certfile fd.crt -certfile fd-chain.crt

$ openssl pkcs7 -in fd.p7b -print_certs -out fd.pem
```

同样的，你必须手动把 *fd.pem* 拆分到三个文件。


### 

## 配置

这里我想谈论两个关于 TLS 开发的话题。一个是加密套件的配置，指定 TLS 通信的可用套件。另一个是原始加密操作的性能度量。

### 选择加密套件

TLS 服务器常用的配置是选择加密套件。比如 Apache httpd 的加密套件配置如下：

```?
SSLHonorCipherOrder On  
SSLCipherSuite "HIGH:!aNULL:@STRENGTH"
```

第一行控制加密套件的优先度，第二行控制所支持的套件。

配置一个良好的加密套件可能是非常耗时的，有太多需要注意的细节。最好的方法是用 OpenSSL `ciphers` 命令决定启用哪一个加密套件和相关配置。

首先，你应该知道 OpenSSL 支持哪些套件：

```sh
$ openssl ciphers -v 'ALL:COMPLEMENTOFALL'
ECDHE-RSA-AES256-GCM-SHA384    TLSv1.2 Kx=ECDH Au=RSA   Enc=AESGCM(256) Mac=AEAD
ECDHE-ECDSA-AES256-GCM-SHA384  TLSv1.2 Kx=ECDH Au=ECDSA Enc=AESGCM(256) Mac=AEAD
ECDHE-RSA-AES256-SHA384        TLSv1.2 Kx=ECDH Au=RSA   Enc=AES(256)    Mac=SHA384
ECDHE-ECDSA-AES256-SHA384      TLSv1.2 Kx=ECDH Au=ECDSA Enc=AES(256)    Mac=SHA384
ECDHE-RSA-AES256-SHA           SSLv3   Kx=ECDH Au=RSA   Enc=AES(256)    Mac=SHA1
[106 more lines...]
```

> 在 1.0.0 及其后续版本，你也可以使用 `-V` 显示套件。这时会显示套件 ID，能够更方便引用。

在每一行，列出了套件以下信息：

1. 套件名字

2. 请求协议的最小版本

3. 密钥交换算法

4. 身份认证算法

5. 加密算法和强度

6. 暴露的套件表示

也可以只显示特定的套件：

```sh
$ openssl ciphers -v 'RC4'
ECDHE-RSA-RC4-SHA    SSLv3 Kx=ECDH       Au=RSA   Enc=RC4(128) Mac=SHA1
ECDHE-ECDSA-RC4-SHA  SSLv3 Kx=ECDH       Au=ECDSA Enc=RC4(128) Mac=SHA1
AECDH-RC4-SHA        SSLv3 Kx=ECDH       Au=None  Enc=RC4(128) Mac=SHA1
ADH-RC4-MD5          SSLv3 Kx=DH         Au=None  Enc=RC4(128) Mac=MD5
ECDH-RSA-RC4-SHA     SSLv3 Kx=ECDH/RSA   Au=ECDH  Enc=RC4(128) Mac=SHA1
ECDH-ECDSA-RC4-SHA   SSLv3 Kx=ECDH/ECDSA Au=ECDH  Enc=RC4(128) Mac=SHA1
RC4-SHA              SSLv3 Kx=RSA        Au=RSA   Enc=RC4(128) Mac=SHA1
RC4-MD5              SSLv3 Kx=RSA        Au=RSA   Enc=RC4(128) Mac=MD5
PSK-RC4-SHA          SSLv3 Kx=PSK        Au=PSK   Enc=RC4(128) Mac=SHA1
EXP-ADH-RC4-MD5      SSLv3 Kx=DH(512)    Au=None  Enc=RC4(40)  Mac=MD5  export
EXP-RC4-MD5          SSLv3 Kx=RSA(512)   Au=RSA   Enc=RC4(40)  Mac=MD5  export
```

### 关键字

. . .

### 
