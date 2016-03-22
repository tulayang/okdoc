# [保护 Docker daemon Sockets](https://docs.docker.com/v1.9/engine/articles/https/)

默认情况下，Docker daemon 监听一个 Unix Domain Socket 。此外，你也可以选择使用 TCP Socket 通信。

如果你想要在 TCP Socket 模式下开启安全模式，指定 `tlsverify` 标志位以启用 TLS 加密，并且指定 `tlscacert` 标志位设定可信任的 CA certificate。

启用安全模式后，客户端连接 Docker daemon 时必须提供这个 CA 签名的证书，否则被拒绝连接。

> 警告：使用 TLS 和管理 CA 是一个高级话题。请先熟悉 OpenSSL、x509、TLS。

<span>

> 警告：这里的 TLS 命令行只会生成工作在 Linux 的证书。Mac OS X 版本的 OpenSSL 生成的证书和这里的不兼容。

## 模拟一个 CA 服务器，创建 OpenSSL 密钥和证书

> 注意：把下面例子的 `$HOST` 替换成你的 Docker daemon 所在主机的 DNS 域名。

首先，生成 CA 密钥和公钥：

```sh
$ openssl genrsa -aes256 -out ca-key.pem 4096
Generating RSA private key, 4096 bit long modulus
............................................................................................................................................................................................++
........++
e is 65537 (0x10001)
Enter pass phrase for ca-key.pem:
Verifying - Enter pass phrase for ca-key.pem:
$ openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem
Enter pass phrase for ca-key.pem:
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:
State or Province Name (full name) [Some-State]:Queensland
Locality Name (eg, city) []:Brisbane
Organization Name (eg, company) [Internet Widgits Pty Ltd]:Docker Inc
Organizational Unit Name (eg, section) []:Sales
Common Name (e.g. server FQDN or YOUR name) []:$HOST
Email Address []:Sven@home.org.au
```

现在，我们有了一个 CA。

接下来，创建一个服务器密钥和证书签名请求：

```sh
$ openssl genrsa -out server-key.pem 4096
Generating RSA private key, 4096 bit long modulus
.....................................................................++
.................................................................................................++
e is 65537 (0x10001)
$ openssl req -subj "/CN=$HOST" -sha256 -new -key server-key.pem -out server.csr
```

然后，使用 CA 进行签名。由于 TLS 连接既可以通过 IP 地址也可以通过 DNS 域名，在创建证书的时候必须指定它们。比如，运行 `10.10.10.20` 和 `127.0.0.1` 连接：

```sh
$ echo subjectAltName = IP:10.10.10.20,IP:127.0.0.1 > extfile.cnf

$ openssl x509 -req -days 365 -sha256 -in server.csr \
               -CA ca.pem                            \
               -CAkey ca-key.pem                     \
               -CAcreateserial                       \
               -out server-cert.pem                  \
               -extfile extfile.cnf
Signature ok
subject=/CN=your.host.com
Getting CA Private Key
Enter pass phrase for ca-key.pem:
```

现在，创建一个客户端密钥和证书签名请求：

```sh
$ openssl genrsa -out key.pem 4096
Generating RSA private key, 4096 bit long modulus
.........................................................++
................++
e is 65537 (0x10001)
$ openssl req -subj '/CN=client' -new -key key.pem -out client.csr
```

然后，使用 CA 进行签名：

```sh
$ echo extendedKeyUsage = clientAuth > extfile.cnf

$ openssl x509 -req -days 365 -sha256 -in client.csr \
               -CA ca.pem                            \
               -CAkey ca-key.pem                     \
               -CAcreateserial                       \
               -out cert.pem                         \
               -extfile extfile.cnf
Signature ok
subject=/CN=client
Getting CA Private Key
Enter pass phrase for ca-key.pem:
```

生成 `cert.pem` 和 `server-cert.pem` 后，你可以删除两个证书签名请求：

```sh
$ rm -v client.csr server.csr
$ rm -v client.csr client.csr
```

当默认 `umask` 是 `022` 时，生成的证书对于用户和所属组是可读、可写的。

为了防止不小心破坏你的证书，你可能会想移除写权限：

```sh
$ chmod -v 0400 ca-key.pem key.pem server-key.pem
```

如果你想给任何人赋予读权限：

```sh
$ chmod -v 0444 ca.pem server-cert.pem cert.pem
```

现在，告诉 Docker daemon 只接受通过我们指定的 CA 签名的证书连接：

```sh
$ docker daemon --tlsverify                \  
                --tlscacert=ca.pem         \
                --tlscert=server-cert.pem  \
                --tlskey=server-key.pem    \  
                -H=0.0.0.0:2376
```

为了和这个 Docker daemon 建立连接，客户端必须提供 CA 签名的证书：

```sh
$ docker --tlsverify         \
         --tlscacert=ca.pem  \ 
         --tlscert=cert.pem  \
         --tlskey=key.pem    \
         -H=$HOST:2376 
         version
```

> 注意：Docker daemon 启用 TLS 时应该监听 `2376` 端口。

<span>

> 警告：在上面的例子，运行 Docker client 不需要 `sudo` 或者 `docker` 组 --- 现在使用证书认证。这意味着，任何人都可以用这些密钥和证书访问你的 Docker daemon，并且获得访问 Docker daemon 的 root 权限。这些密钥证书相当于是 root 密码！

## 默认提供安全连接

如果你想让 Docker client 默认提供安全连接，你可以把客户端的密钥证书移动到 *~/.docker* 目录内，并且指定 `DOCKER_HOST` 和 `DOCKER_TLS_VERIFY`：

```sh
$ mkdir -pv ~/.docker
$ cp -v {ca,cert,key}.pem ~/.docker

$ export DOCKER_HOST=tcp://$HOST:2376 DOCKER_TLS_VERIFY=1
```

现在，Docker client 默认提供安全连接：

```sh
$ docker ps
```

## 其他模式

如果你不想两端认证，还有几种其他认证方式。

### daemon 模式

* `tlsverify`、`tlscacert`、`tlscert`、`tlskey` - 认证客户端
* `tls`、`tlscert`、`tlskey` - 只加密数据，不要认证客户端

### client 模式

* `tls` - 使用基础的公共/默认 CA 池认证服务器
* `tlsverify`、`tlscacert` - 使用指定的 CA 认证服务器
* `tls`、`tlscert`、`tlskey` - 给服务器提供客户端密钥和证书，不要认证服务器
* `tlsverify`、`tlscacert`、`tlscert`、`tlskey` - 给服务器提供客户端密钥和证书，并且使用指定的 CA 认证服务器

如果找到这些密钥和证书的文件，客户端就会把它们发送到服务器 --- 因此，把这些文件移动到 *~/.docker/{ca,cert,key}.pem* 就不用明确指定了（可以省略标志位）。二选一，如果你把这些文件存储在另一个位置，你也可以指定环境变量 `DOCKER_CERT_PATH` 来省略标志位：

```sh
$ export DOCKER_CERT_PATH=~/.docker/zone1/
$ docker --tlsverify ps
```

###

## 使用 curl 连接安全的 Docker daemon

想要使用 curl 利用 Remote API 连接 Docker daemon，你需要指定三个标志位：

```sh
$ curl https://$HOST:2376/images/json \
       --cert ~/.docker/cert.pem      \
       --key ~/.docker/key.pem        \
       --cacert ~/.docker/ca.pem
```