# [编译源代码](http://nginx.org/en/docs/configure.html)

编译时，使用 `configure` 命令配置选项。它会定义系统的相关配置，然后生成一个 Makefile。`configure` 命令支持如下参数：

* `--prefix=path` 定义存放服务器文件的目录。这会作为 **nginx** 相关设施的相对目录。默认是 */usr/local/nginx*。

* `--sbin-path=path` 设置可执行文件的文件名。默认是 *${prefix}/sbin/nginx*。

* `--conf-path=path` 设置配置文件。如果需要的话，在你启动 **nginx** 时，命令项中指定 `-c path`，则会使用一个不同的配置文件。默认是 *${prefix}/conf/nginx.conf*。

* `--pid-path=path` 设置存储主进程进程号的文件。安装完成后，这个文件可以通过 *nginx.conf* 配置文件，指定 `pid path;` 修改。默认是 *${prefix}/logs/nginx.pid*。

* `--error-log-path=path` 设置存储主错误、警告、诊断消息的日志文件。安装完成后，这个文件可以通过 *nginx.conf* 配置文件，指定 `error_log path;` 修改。默认是 *${prefix}/logs/error.log*。

* `--http-log-path=path` 设置存储 HTTP 服务器主要请求的日志文件。安装完成后，这个文件可以通过 *nginx.conf* 配置文件，指定 `access_log path;` 修改。默认是 *${prefix}/logs/access.log*。

* `--user=username` 设置非特权用户，其证书会被工作进程使用。安装完成后，这个文件可以通过 *nginx.conf* 配置文件，指定 `user username [groupname];` 修改。默认是 `nobody`。

* `--group=name` 设置组，其证书会被工作进程使用。安装完成后，这个文件可以通过 *nginx.conf* 配置文件，指定 `user username [groupname];` 修改。默认是非特权用户名。

* `--with-select_module` `--without-select_module` 启用或禁止编译一个模块---允许服务器使用 `select()` 工作。如果系统不支持更得当的方法，比如 kqueue、epoll、或 /dev/poll，会自动编译进去。

* `--with-poll_module` `--without-poll_module` 启用或禁止编译一个模块---它允许服务器使用 `poll()` 工作。如果系统不支持更得当的方法，比如 kqueue、epoll、或 /dev/poll，会自动编译进去。

* `--without-http_gzip_module` 禁止编译一个模块---压缩 HTTP 服务的响应。运行这个模块需要 zlib 库。

* `--without-http_rewrite_module` 禁止编译一个模块---允许 HTTP 服务跳转请求，以及改变资源位置。运行这个模块需要 PCRE 库。

* `--without-http_proxy_module` 禁止编译一个模块---HTTP 服务代理。

* `--with-http_ssl_module` 启用编译一个模块---使 HTTP 服务支持 HTTPS 协议。默认不会编译这个模块。运行这个模块需要 OpenSSL 库。

* `--with-pcre=path` 设置 PCRE 库的路径。你需要从 [PCRE 网站](http://www.pcre.org/)下载这个库（4.4 ～ 8.32 版本）并提取。这个库用于解析 `location` 的正则表达式，以及 [ngx_http_rewrite_module](http://nginx.org/en/docs/http/ngx_http_rewrite_module.html)。 

* `--with-pcre-jit` 提供即时编译支持来编译 PCRE 库。你需要从 [zlib 网站](http://zlib.net/)下载这个库（1.1.3 ～ 1.2.7 版本）并提取。剩下的工作通过 **nginx** 的 `./configure` 和 `make` 完成。[ngx_http_gzip_module](http://nginx.org/en/docs/http/ngx_http_gzip_module.html) 需要这个库。

* `--with-cc-opt=parameters` 为 `CFLAGS` 变量添加附加参数。当在 FreeBSD 使用 PCRE 库时，应该指定 `--with-cc-opt="-I /usr/local/include"`。If the number of files supported by select() needs to be increased it can also be specified here such as this: `--with-cc-opt="-D FD_SETSIZE=2048"`. 

* `--with-ld-opt=parameters` 为链接器添加附加参数。当在 FreeBSD 使用 PCRE 库时，应该指定 `--with-ld-opt="-L /usr/local/lib"`。

例子（下面的内容必须在一行）：

```sh
./configure
    --sbin-path=/usr/local/nginx/nginx
    --conf-path=/usr/local/nginx/nginx.conf
    --pid-path=/usr/local/nginx/nginx.pid
    --with-http_ssl_module
    --with-pcre=../pcre-4.4
    --with-zlib=../zlib-1.1.3
```

执行 `configure` 之后，使用 `make`、`make install` 编译和安装 **nginx**。