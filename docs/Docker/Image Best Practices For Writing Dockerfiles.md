# [编写 Dockerfile 的最佳实践](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/)

Docker 能使用 Dockerfile 文件自动化编译镜像。Dockerfile 是一个文本文件，由指令集组成。

## 一般准则和建议

### 容器应该是短暂的

Dockerfile 产生的容器，应该是尽可能短暂的。“短暂”，意味着可以停止、销毁、重新制作一个新的。

### 使用一个 .dockerfile 文件

大多数情况下，你都应该有一个 .dockerfile 文件，它非常类似 `.gitignore` 文件。

### 避免安装不必要的包

为了减少复杂度、依赖性、文件大小和创建时间，你应该避免安装额外的或不必要的软件包。比如，不需要在一个数据镜像中安装一个文本编辑器。

### 每个容器只运行一个进程

大多数情况下，你应该在一个容器中只运行一个进程。在多个容器中解耦，可以更容易的水平伸缩和重用容器。

### 最小化层数

你需要在可读性和最小化层数之间作出平衡。在战略上要小心镜像的层数。

### 让指令更漂亮

可能的话，把长的指令分成多行：

```dockerfile
RUN apt-get update && apt-get install -y \
  bzr \
  cvs \
  git \
  mercurial \
  subversion
```

### 编译缓存

编译的过程中，Docker 会按照 Dockerfile 文件的指令一步一步的前进。每一条指令，Docker 都会先查找一下当前缓存中有没有已有的镜像，而不是创建一个新镜像。如果你不想使用缓存，`docker build` 时指定 `--no-cache=true`   。

如果允许 Docker 使用镜像缓存，那么理解编译过程是非常重要的：

* 从基础镜像开始后，下一条指令会检查当前缓存中是否有使用同一个基础镜像的，如果有就用该层镜像。如果没有，缓存被视为无效。

* 大多数情况下，比较 Dockerfile 的指令足够。然而，一些特定指令需要额外的解释。

* `ADD` 和 `COPY` 指令，会为每个文件计算校验和。最后修改时间和最后访问时间不被计入比较之内。在整个查找过程，校验和会和已有文件的校验和进行比较。如果没有匹配的文件，那么缓存被视为无效。

* 除了 `ADD` 和 `COPY` 指令，缓存检查不会比较文件。比如：`RUN apt-get -y update` 不会比较文件是否相当，而只是比较指令是否相同。

一旦缓存被视为无效，所有后续的指令都会生成新的镜像。

###

## 指令集

### FROM

可能的话，使用当前官方仓库提供的镜像。我们推荐 [Debian image](https://registry.hub.docker.com/_/debian/)，因为它非常轻量（当前 `100MB`），并且长期处于维护中。

### RUN

总是使 Dockerfile 更可读，更易于维护。把长的指令分成多行。

### apt-get

最常用的安装命令可能就是 `apt-get` 了。

避免 `RUN apt-get upgrade` 或 `dist-upgrade`，因为许多包不会在非特权容器中升级。如果想要升级一个包，使用 `RUN apt-get update && apt-get install -y foo` 自动更新。

总是把 `RUN apt-get update` 和 `apt-get install` 写在一条 `RUN` 指令，这样能确保不会因为缓存导致不进行 `update` 而 `install`：

```dockerfile
RUN apt-get update && apt-get install -y \
    package-bar \
    package-baz \
    package-foo
```

指定一个包的版本，可以强制编译忽略此处的缓存：

```dockerfile
RUN apt-get update && apt-get install -y \
    package-bar \
    package-baz \
    package-foo=1.3.*
```

下面是一个非常良好的 `RUN` 示范：

```sh
RUN apt-get update && apt-get install -y \
    aufs-tools \
    automake \
    build-essential \
    curl \
    dpkg-sig \
    libcap-dev \
    libsqlite3-dev \
    mercurial \
    reprepro \
    ruby1.9.1 \
    ruby1.9.1-dev \
    s3cmd=1.1.* \
 && rm -rf /var/lib/apt/lists/*
```

### `CMD`

`CMD` 应该用来运行镜像中的软件。尽可能使用这种格式：`CMD [“executable”, “param1”, “param2”…]`。比如 `CMD ["apache2","-DFOREGROUND"]`。

大多数情况下，`CMD` 应该给出一个内部 Shell （bash、python、perl、...）。比如 `CMD ["perl", "-de0"]`、`CMD ["python"]`。

### `EXPOSE`

`EXPOSE` 指令标示容器想要监听的端口。因此，你应该为你的应用程序使用通用的、传统的端口。比如，一个镜像，内含一个 Apache Web Server，会需要使用 `EXPOSE 80`；一个基于 MongoDB 的镜像则需要 `EXPOSE 27017`。

### `ENV`

为了使新软件更容易运行，你可以使用 `ENV` 更新容器内的 `PATH` 环境变量。比如 `ENV PATH /usr/local/nginx/bin:$PATH` 可以确保 `CMD [“nginx”]` 工作。

`ENV` 对于容器提供的服务也很有帮助，比如 Postgres 所需要的 `PGDATA` 环境变量。

最后，`ENV` 也能用来设定通用的版本号：

```sh
ENV PG_MAJOR 9.3
ENV PG_VERSION 9.3.4
RUN curl -SL http://example.com/postgres-$PG_VERSION.tar.xz | tar -xJC /usr/src/postgress && …
ENV PATH /usr/local/postgres-$PG_MAJOR/bin:$PATH
```

### `ADD` `COPY`

尽管 `ADD`、`COPY` 功能非常相似，仍然推荐首先 `COPY` --- 它比 `ADD` 更透明。`COPY` 只会拷贝文件，`ADD` 则有一些额外功能（比如 tar 包解压缩、远程 URL 支持）。使用 `ADD` 最常用的情况是解压 tar 包：`ADD rootfs.tar.xz /`。

如果 Dockerfile 需要多个不同文件，分开 `COPY` 它们，而不是一次性 `COPY`。这能利用编译缓存节省空间：

```dockerfile
COPY requirements.txt /tmp/
RUN  pip install --requirement /tmp/requirements.txt
COPY . /tmp/
```

因为镜像尺寸的问题，使用 `ADD` 请求远程 URL 非常受挫。你应该使用 `curl` 或 `wget` 来完成这个任务，而不是用 `ADD`。比如下面的例子非常不推荐：

```dockerfile
ADD http://example.com/big.tar.xz /usr/src/things/
RUN tar -xJf /usr/src/things/big.tar.xz -C /usr/src/things
RUN make -C /usr/src/things all
```
应该使用下面的方法：

```dockerfile
RUN  mkdir -p /usr/src/things \
  && curl -SL http://example.com/big.tar.xz \
  |  tar -xJC /usr/src/things \
  && make -C /usr/src/things all
```

### `ENTRYPOINT`

`ENTRYPOINT` 最好用来设置镜像的主命令。

下面这个例子运行一个 `s3cmd` 工具：

```dockerfile
ENTRYPOINT ["s3cmd"]
CMD ["--help"]
```

现在，可以这样运行容器：

```sh
$ docker run s3cmd
```

也可以这样运行：

```sh
$ docker run s3cmd ls s3://mybucket
```

`ENTRYPOINT` 也能用来组合一个帮助脚本。比如 [Postgres Official Image](https://registry.hub.docker.com/_/postgres/) 使用了下面的脚本：

```sh
#!/bin/bash
set -e

if [ "$1" = 'postgres' ]; then
    chown -R postgres "$PGDATA"

    if [ -z "$(ls -A "$PGDATA")" ]; then
        gosu postgres initdb
    fi

    exec gosu postgres "$@"
fi

exec "$@"
```

帮助脚本被拷贝进容器，然后通过 `ENTRYPOINT` 运行：

```dockerfile
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
```

这条脚本允许用户和 Postgres 交互。

### `VOLUME`

`VOLUME` 指令应该用来暴露数据存储、配置存储、或者容器创建的文件。非常鼓励在用户服务中使用 `VOLUME`。

### `USER`

如果要让一个服务以非特权运行，使用 `USER` 改变为一个非 root 用户。创建一个用户和组：

```dockerfile
RUN groupadd -r postgres && useradd -r -g postgres postgres
```

> 镜像中的 UID 和 GID 是不确定的。如果需要的话，应该在创建用户和组时明确指定 UID、GID。 

应该避免安装或使用 `sudo`，因为存在信号转发的问题，可能引起不可知的问题。如果你确实需要这么做，使用 `gosu` 代替。

### `WORKDIR`

为了可读性，应该总是用绝对路径指定 `WORKDIR`。避免 `RUN cd … && do-something` 这样的指令。

### `ONBUILD`

`ONBUILD` 指令在 Dockerfile 文件编译完成后触发。

###

