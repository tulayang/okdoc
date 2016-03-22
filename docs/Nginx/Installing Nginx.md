# [在 Linux 中安装 nginx](http://nginx.org/en/linux_packages.html)

当前，**nginx** 包支持以下版本的系统：

* RHEL/CentOS: 

  * 5.x x86_64, i386
  * 6.x x86_64, i386
  * 7.x x86_64

* Debian

  * 7.x （wheezy） x86_64, i386
  * 8.x （jessie） x86_64, i386

* Ubuntu

  * 12.04 （precise） x86_64, i386
  * 14.04 （trusty） x86_64, i386, aarch64/arm64
  * 15.04 （vivid） x86_64, i386
  * 15.10 （wily） x86_64, i386

* SLES

  * 12 x86_64

配置 RHEL/CentOS 发布版的 **yum** 库、Debian/Ubuntu 发布版的 **apt** 库、SLES 发布版的 **zypper** 库，以得到最新的 **nginx** 包。

## 安装稳定版

### RHEL/CentOS 的 yum 库

要配置 RHEL/CentOS 的 **yum** 库，按照下面的内容创建 */etc/yum.repos.d/nginx.repo* 文件：

```?
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/OS/OSRELEASE/$basearch/
gpgcheck=0
enabled=1
```

用 `rhel` 或 `centos` 替换 `OS` --- 依赖你用的系统，用 `5`、`6`、或 `7` 替换 `OSRELEASE` --- 分别表示 5.x、6.x、7.x。

### Debian/Ubuntu 的 apt 库

Debian/Ubuntu，为了认证 **nginx** 库的签名，以及消除安装过程中缺少 PGP 秘钥的问题，需要把秘钥和库添加到 **apt** 程序。请下载 [this key](http://nginx.org/keys/nginx_signing.key)，然后把它添加到 **apt** 程序：

```sh
$ sudo apt-key add nginx_signing.key
```

Debian，请将下面两行（用对应的代号替换掉 `codename`，比如 `wheezy`），添加到 */etc/apt/sources.list* 文件末尾： 

```?
deb http://nginx.org/packages/debian/ codename nginx
deb-src http://nginx.org/packages/debian/ codename nginx
```

Ubuntu，请将下面两行（用对应的代号替换掉 `codename`，比如 `wheezy`），添加到 */etc/apt/sources.list* 文件末尾： 

```?
deb http://nginx.org/packages/ubuntu/ codename nginx
deb-src http://nginx.org/packages/ubuntu/ codename nginx
```

Debian/Ubuntu，然后执行下列命令：

```sh
$ apt-get update
$ apt-get install nginx
```

### SLES 的 zypper 库 

SLES，执行下列命令：

```sh
$ zypper addrepo -G -t yum -c 'http://nginx.org/packages/sles/12' nginx
```

###

## 安装主线版

### RHEL/CentOS 的 yum 库

要配置 RHEL/CentOS 的 **yum** 库，按照下面的内容创建 */etc/yum.repos.d/nginx.repo* 文件：

```?
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/OS/OSRELEASE/$basearch/
gpgcheck=0
enabled=1
```

用 `rhel` 或 `centos` 替换 `OS` --- 依赖你用的系统，用 `5`、`6`、或 `7` 替换 `OSRELEASE` --- 分别表示 5.x、6.x、7.x。

### Debian/Ubuntu 的 apt 库

Debian/Ubuntu，为了认证 **nginx** 库的签名，以及消除安装过程中缺少 PGP 秘钥的问题，需要把秘钥和库添加到 **apt** 程序。请下载 [this key](http://nginx.org/keys/nginx_signing.key)，然后把它添加到 **apt** 程序：

```sh
$ sudo apt-key add nginx_signing.key
```

Debian，请将下面两行（用对应的代号替换掉 `codename`，比如 `wheezy`），添加到 */etc/apt/sources.list* 文件末尾： 

```?
deb http://nginx.org/packages/mainline/debian/ codename nginx
deb-src http://nginx.org/packages/mainline/debian/ codename nginx
```

Ubuntu，请将下面两行（用对应的代号替换掉 `codename`，比如 `wheezy`），添加到 */etc/apt/sources.list* 文件末尾： 

```?
deb http://nginx.org/packages/mainline/ubuntu/ codename nginx
deb-src http://nginx.org/packages/mainline/ubuntu/ codename nginx
```

Debian/Ubuntu，然后执行下列命令：

```sh
$ apt-get update
$ apt-get install nginx
```

### SLES 的 zypper 库 

SLES，执行下列命令：

```sh
$ zypper addrepo -G -t yum -c 'http://nginx.org/packages/mainline/sles/12' nginx
```

###

## Configure 参数

### 稳定版

为稳定版本 Configure 参数：

```sh
--prefix=/etc/nginx                                        # 安装目录
--sbin-path=/usr/sbin/nginx                                # 可执行文件
--conf-path=/etc/nginx/nginx.conf                          # 配置文件
--error-log-path=/var/log/nginx/error.log                  # 错误日志
--http-log-path=/var/log/nginx/access.log                  # HTTP 服务日志
--pid-path=/var/run/nginx.pid                              # 进程号文件
--lock-path=/var/run/nginx.lock                            # 锁文件
--http-client-body-temp-path=/var/cache/nginx/client_temp  # 上传文件的临时目录
--http-proxy-temp-path=/var/cache/nginx/proxy_temp         # 代理缓存的临时目录
--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp     # fastcgi 缓存的临时目录
--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp         # uwsgi 缓存的临时目录 
--http-scgi-temp-path=/var/cache/nginx/scgi_temp           # scgi 缓存的临时目录
--user=nginx                                               # 属主
--group=nginx                                              # 组
--with-http_ssl_module                                     # HTTP SSL 模块
--with-http_realip_module                                  # 真实 IP 模块
--with-http_addition_module                                # 流量中追加内容模块
--with-http_sub_module                                     # 过滤器模块
--with-http_dav_module                                     # 
--with-http_flv_module                                     # flv 媒体模块
--with-http_mp4_module                                     # mp4 媒体模块
--with-http_gunzip_module                                  # 对不支持 gzip 的流量提供解压模块 
--with-http_gzip_static_module                             # 静态资源压缩模块
--with-http_random_index_module                            # 随即主页模块
--with-http_secure_link_module                             # 安全校验模块
--with-http_stub_status_module                             # 监控模块
--with-http_auth_request_module                            # 要求请求认证模块
--with-mail                                                # 邮件模块
--with-mail_ssl_module                                     # 邮件 SSL 模块
--with-file-aio                                            # 异步文件 IO 模块 
--with-http_spdy_module                                    # 提供 SPDY 支持模块
--with-ipv6                                                # 提供 IPv6 支持模块
```

主线版本还增加了 Configure 参数：

```sh
--with-threads                                             # 提供线程支持模块
--with-stream                                              # 提供流支持模块
--with-stream_ssl_module                                   # 流 SSL 模块
--with-http_slice_module                                   # 
```

和

```sh
--with-http_v2_module  # 请用它替换掉 --with-http_spdy_module
```

包加入这些模块时，不需要另外安装库---避免依赖。

###

## 关于签名的一些解释

RPM 包和 Debian/Ubuntu 库使用数字签名，以验证下载的包的完整和来源。为了检查签名，需要下载 [nginx signing key](http://nginx.org/keys/nginx_signing.key)，然后导入到 **rpm** 或 **apt** 程序的秘钥包：

* RHEL/CentOS：

  ```sh
  $ sudo rpm --import nginx_signing.key
  ```

* Debian/Ubuntu：

  ```sh
  $ sudo apt-key add nginx_signing.key
  ```

* SLES：

  ```sh
  $ sudo rpm --import nginx_signing.key
  ```

Debian/Ubuntu/SLES 默认检查秘钥，但是 RHEL/CentOS 需要在 */etc/yum.repos.d/nginx.repo* 文件设置：

```sh
gpgcheck=1
```

我们的 [PGP keys](http://nginx.org/en/pgp_keys.html) 和包在同一个服务器，因此你可以信任它们。非常建议你验证下载的 PGP 秘钥的真实性。PGP has the “Web of Trust” concept, when a key is signed by someone else’s key, that in turn is signed by another key and so on. It often makes possible to build a chain from an arbitrary key to someone’s key who you know and trust personally, thus verify the authenticity of the first key in a chain. [GPG Mini Howto](http://www.dewinter.com/gnupg_howto/english/GPGMiniHowto-1.html)更详细地解释了这个概念。我们的秘钥签名很完整，检查它们的真实性非常容易。