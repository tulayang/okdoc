# [新手指南](http://nginx.org/en/docs/beginners_guide.html)

本节介绍 **nginx** 的基本知识，以及一些简单的任务。我们假定你的机器已经安装了 **nginx**。如果没有，赶快先装上吧。我们这里讲讲怎么启动、停止 **nginx**、重新加载配置、解析配置文件的结构、提供静态文件服务、连接到 FastCGI 应用程序。

**nginx** 有一个主进程（管理），多个子进程（工作）。主进程的作用是读取和评估配置，维持工作进程的运转。工作进程负责实际的请求处理。**nginx** 使用事件驱动模式（具体实现方式，依赖系统）来高效地把请求分配给工作进程。工作进程号，可以定义在配置文件，也可以通过 CPU 内核计数来得到。

配置文件决定 **nginx** 和它的模块怎么工作。默认，配置文件名是 *nginx.conf*，并且位于 */usr/local/nginx/conf*、*/etc/nginx*、或 */usr/local/etc/nginx* 目录。

## 启动、停止、 重新加载

运行可执行文件，启动 **nginx**。启动之后，可以使用以下语法控制 **nginx**：

```sh
$ nginx -s signal
```

`signal` 可以是下列之一：

* `stop` 快速关闭

* `quit` 正常关闭

* `reload` 重新加载配置文件

* `reopen` 重新打开日志文件

举个例子，等候工作进程完成当前处理的请求，然后关闭 **nginx** 进程：

```sh
$ nginx -s quit
```

修改配置文件后，只有重新加载 **nginx** 或者重启动，才能应用新配置。重新加载：

```sh
$ nginx -s reload
```

一旦主进程收到信号---要求重新加载配置，它检查新配置文件的语法，然后尝试应用新的配置。如果成功，主进程启动新的工作进程，并且向旧的工作进程发送信号，要求它们关闭。否则，主进程回退，继续使用旧的配置工作。

旧的工作进程，当收到信号，要求关闭时，它们停止接受新的连接，继续处理当前请求，直到所有请求处理完成。然后，旧的工作进程退出。

**nginx** 进程收到的信号，也可能是通过 Unix 工具（比如 `kill` 工具）发送的。这种情况下，信号被直接发送给一个进程（通过进程号）。**nginx** 主进程的进程号，保存在 *nginx.pid* 文件中，默认位于 */usr/local/nginx/logs*、或 */var/run* 目录。比如，如果主进程的进程号是 `1628`，发送一个 `QUIT` 信号，使 **nginx** 进程正常关闭：

```sh
$ kill -s QUIT 1628
```

查看所有运行的 **nginx** 进程，可以使用 `ps` 工具，比如：

```sh
$ ps -ax | grep nginx
```

[参看控制 nginx，了解更多关于信号的信息](http://nginx.org/en/docs/control.html)


## 配置文件

配置文件指定了许多信息，以控制 **nginx**。这些配置项分为简单和块。简单的项，通过名字和值组成，以空格隔开，以 `;` 结尾。块项，以 `{}` 包裹子项。有层次的项，以环境（或叫命名空间）关联。

按照约定，最外层的配置项，其环境是 `main`。`events` 和 `http` 位于 `main` 环境，`server` 位于 `http`，`location` 位于 `server`。

每一行 `#` 后面的内容作为注释。

## 架设静态内容服务器

Web 服务器的一个重要任务，是输出文件（比如图片、静态 HTML 页）。客户端通过访问 */data/www*、*/data/images* 之类的路径，来获得文件资源。要提供这样的服务，你需要编辑配置文件，增加 `http` 块、`server` 块、`location` 块。

首先，创建 */data/www* 目录，并且放入一个 *index.html* 文件---随便写点什么文本内容；创建一个 */data/images* 目录，放入一些图片。

然后，编辑配置文件。默认的配置已经包含了一些项，比如 `server` 块、一些注释。现在，去掉注释，完成这样的配置：

```sh
http {
    server {
    }
}
```

通常，配置文件可能包含多个 `server` 块，分别监听不同的服务名和端口。**nginx** 会根据 `server` 来决定当前请求的服务器。

然后，在 `server` 块加入 `location` 块：

```sh
location / {
    root /data/www;
}
```

`location` 块指定 `/`，比较请求的 URI。匹配请求后，URI 把 `root` 项作为前缀---/data/www，然后在本地系统查找文件。如果有多个 `location` 都匹配，则挑选最长的那个。

然后，添加第二个 `location` 块：

```sh
location /images/ {
    root /data;
}
```

它会匹配以 /images/ 开头的 URI （`location /` 也匹配这样的 URI，但是更短）。

最后，`server` 块看起来应该像这样：

```sh
server {
    location / {
        root /data/www;
    }

    location /images/ {
        root /data;
    }
}
```

这会构建一个服务器，监听 `80` 端口，主机地址是 `http://localhost/`。当请求 URI 以 `/images/` 开头时，服务器会发送 */data/images/* 目录的文件。比如，请求 `http://localhost/images/example.png`，**nginx** 会发送 */data/images/example.png* 文件。如果这个文件不存在，发送一个 `404` 错误。请求 URI 不以 `/images/` 开头时，会被映射到 */data/www* 目录。比如，请求 `http://localhost/some/example.html`，**nginx** 会发送 */data/www/some/example.html* 文件。

因为我们修改了配置文件，所以需要重新加载 **nginx**：

```sh
$ nginx -s reload
```

> 如果没有按照上面那样工作，你可能需要看看 *access.log* 和 *error.log* 日志，找找问题出在哪里。

## 架设简单的代理服务器

**nginx** 常常用作代理服务器，接收客户端的请求，然后转发到应用服务器；接收应用服务器的响应，然后转发给客户端。

现在，我们来架设一个代理服务器和---提供图片文件服务，并且把其它请求进行转发。

首先，添加一个 `server` 块定义一个应用服务器：

```sh
server {
    listen 8080;
    root /data/up1;

    location / {
    }
}
```

这是一个简单的服务器，监听 `8080` 端口，主机地址是 `http://localhost/`。此外，把请求映射到本地文件系统的 */data/up1* 目录。创建这个目录，放入一个 *index.html* 文件。注意，`root` 项现在位于 `server` 块。当 `location` 块没有指定 `root` 时，就会使用这个 `root`。

然后，添加另一个 `server` 块定义一个代理服务器。在 `location /` 块设置代理---通过 `proxy_pass` 指定转发地址（协议、域名、端口号）：

```sh
server {
    location / {
        proxy_pass http://localhost:8080;
    }

    location /images/ {
        root /data;
    }
}
```

修改一下第二个 `location` 块，现在它匹配 `/images/`。我们想让它匹配更特殊的 URI 请求：

```sh
location ~ \.(gif|jpg|png)$ {
    root /data/images;
}
```

现在，它的参数是一个正则表达式，匹配以 `.gif`、`.jpg`、`.png` 作为结尾的 URI。正则表达式应该以 `~` 开头。对应的请求，会被映射到 */data/images* 目录。

最后，`server` 块看起来应该像这样：

```sh
server {
    location / {
        proxy_pass http://localhost:8080/;
    }

    location ~ \.(gif|jpg|png)$ {
        root /data/images;
    }
}
```

这个服务器会过滤 `.gif`、`.jpg`、`.png` 结尾的请求，把它们映射到 */data/images* 目录（把 `root` 项添加到 URI 前面）；把其他的请求，转发到另一个服务器。

因为我们修改了配置文件，所以需要重新加载 **nginx**：

```sh
$ nginx -s reload
```

## 架设 FastCGI 代理

**nginx** 也能用来把请求路由到 FastCGI 服务器---比如 PHP 开发的服务器。

使用 `fastcgi_pass` 项设置 FastCGI 服务器，` fastcgi_param` 项设置传送给 FastCGI 服务器的参数。例子：

```sh
server {
    location / {
        fastcgi_pass  localhost:9000;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param QUERY_STRING    $query_string;
    }

    location ~ \.(gif|jpg|png)$ {
        root /data/images;
    }
}
```