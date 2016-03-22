# [镜像示范](https://docs.docker.com/engine/userguide/containers/dockerimages/)

Docker 镜像是 Docker 容器的基础。每次使用 `docker run` 都要告诉 Docker 要用哪个镜像。当 Docker 发现主机没有该镜像，就会从 [Docker Hub](https://registry.hub.docker.com/) 下载，否则就使用主机已有的镜像。

## 列出主机已有的镜像

使用 `docker images` 命令可以列出主机已有的镜像：

```sh
$ docker images
REPOSITORY         TAG       IMAGE ID        CREATED         SIZE
ubuntu             14.04     1d073211c498    3 days ago      187.9 MB
busybox            latest    2c5ac3f849df    5 days ago      1.113 MB
training/webapp    latest    54bb4e8718e8    5 months ago    348.7 MB
``` 

列出的镜像信息中，有三部分最重要：

* 镜像来自哪个仓库，比如 `ubuntu`
* 镜像的标签，比如 `14.04`
* 镜像的 ID，比如 `1d073211c498`

一个仓库可能会容纳多个镜像。比如，`ubuntu` 镜像可能存在 `10.04`、`12.04`、`12.10`、`14.04` 等等。每一个变体通过标签识别，你能这样引用一个镜像：

```
ubuntu:14.04
```

因此，运行容器时，通过标签引用镜像，像这样：

```sh
$ docker run -t -i ubuntu:14.04 /bin/bash
```

如果没有写明标签，比如 `ubuntu`，Docker 会引用 `ubuntu:latest` 镜像。

> 应该总是指明标签，比如 `ubuntu：14.04`。这样，你能总是确切知道在引用哪个镜像。

## 拉取一个新镜像

正如你所知道的，Docker 发现主机没有镜像时，会从 [Docker Hub](https://registry.hub.docker.com/) 自动下载镜像。可以使用 `docker pull` 命令主动拉取镜像：

```sh
$ docker pull centos
Pulling repository centos
b7de3133ff98: Pulling dependent layers
5cc9e91966f7: Pulling fs layer
511136ea3c5a: Download complete
ef52fb1fe610: Download complete
. . .

Status: Downloaded newer image for centos
```

## 搜索镜像

使用 `docker pull` 命令可以搜索镜像：

```sh
$ docker search sinatra
NAME                                   DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
training/sinatra                       Sinatra training image                          0                    [OK]
marceldegraaf/sinatra                  Sinatra test app                                0
mattwarren/docker-sinatra-demo                                                         0                    [OK]
luisbebop/docker-sinatra-hello-world                                                   0                    [OK]
bmorearty/handson-sinatra              handson-ruby + Sinatra for Hands on with D...   0
subwiz/sinatra                                                                         0
bmorearty/sinatra                                                                      0
. . .
```

你也能在 [Docker Hub](https://registry.hub.docker.com/) 的网站搜索：

![Docker Hub](https://docs.docker.com/engine/userguide/containers/search.png)

## 创建自己的镜像

有两种方式来创建你自己的镜像：

1. 使用一个镜像创建一个容器，在容器内部更新容器，把结果提交到一个新的镜像。

2. 在一个 Dockerfile 文件编写指令集，然后 `docker build` 这个文件，生成一个新的镜像。

### 更新和提交镜像

首先，用一个镜像创建一个容器：

```sh
$ docker run -t -i training/sinatra /bin/bash
root@0b2616b0e5a8:/#
```

> 注意：容器号已经被创建，在这里是 `0b2616b0e5a8`。

在容器中用 gem 安装 `json`：

```sh
root@0b2616b0e5a8:/# gem install json
```

完成后，使用 `exit` 退出。

现在，你得到一个改变的容器。使用 `docker commit` 把容器的副本提交到一个新的镜像：

```sh
$ docker commit -m "Added json gem" -a "Kate Smith" \
  0b2616b0e5a8 ouruser/sinatra:v2
4f177bd27a9ff0f6dc2a830403925b5360bfe0b93d476f7fc3231110e7f71b1c
```

这条命令中，`-m` 指定注释，`-a` 指定作者。另外，指定 `0b2616b0e5a8` 作为容器，指定 `ouruser/sinatra:v2` 作为新的镜像。 

之后，就可以用这个新镜像运行容器：

```sh
$ docker run -t -i ouruser/sinatra:v2 /bin/bash
root@78e82f680994:/#
```

### 编译 Dockerfile

首先，创建一个 Dockerfile 文件：

```sh
$ mkdir sinatra
$ cd sinatra
$ touch Dockerfile
```

每条指令创建一个新层。看下下面这个简单的例子：

```Dockerfile
# This is a comment
FROM ubuntu:14.04
MAINTAINER Kate Smith <ksmith@example.com>
RUN apt-get update && apt-get install -y ruby ruby-dev
RUN gem install sinatra
```

每条指令的格式类似这样：`INSTRUCTION statement`。

第一条指令是 `FROM`，告诉 Docker 新镜像的基础镜像，在这里，是一个 `ubuntu::14.04` 镜像。`MAINTAINER` 指定新镜像的维护者。

最后，指令了两条 `RUN` 指令。第一条 `RUN` 执行一条命令，在镜像中安装 ruby 和 ruby-dev 包。第二条 `RUN` 执行一条命令，在镜像中安装 sinatra 包。

现在，使用 `docker build` 编译这个 Dockerfile 文件，生成一个新的镜像：

```sh
$ docker build -t ouruser/sinatra:v2 .
Sending build context to Docker daemon 2.048 kB
Sending build context to Docker daemon
Step 1 : FROM ubuntu:14.04
 ---> e54ca5efa2e9
Step 2 : MAINTAINER Kate Smith <ksmith@example.com>
 ---> Using cache
 ---> 851baf55332b
Step 3 : RUN apt-get update && apt-get install -y ruby ruby-dev
 ---> Running in 3a2558904e9b
Selecting previously unselected package libasan0:amd64.
(Reading database ... 11518 files and directories currently installed.)
Preparing to unpack .../libasan0_4.8.2-19ubuntu1_amd64.deb ...
Unpacking libasan0:amd64 (4.8.2-19ubuntu1) ...
Selecting previously unselected package libatomic1:amd64.
Preparing to unpack .../libatomic1_4.8.2-19ubuntu1_amd64.deb ...
Unpacking libatomic1:amd64 (4.8.2-19ubuntu1) ...
Selecting previously unselected package libgmp10:amd64.
Preparing to unpack .../libgmp10_2%3a5.1.3+dfsg-1ubuntu1_amd64.deb ...
Unpacking libgmp10:amd64 (2:5.1.3+dfsg-1ubuntu1) ...
Selecting previously unselected package libisl10:amd64.
Preparing to unpack .../libisl10_0.12.2-1_amd64.deb ...
Unpacking libisl10:amd64 (0.12.2-1) ...
Selecting previously unselected package libcloog-isl4:amd64.
Preparing to unpack .../libcloog-isl4_0.18.2-1_amd64.deb ...
Unpacking libcloog-isl4:amd64 (0.18.2-1) ...
Selecting previously unselected package libgomp1:amd64.
Preparing to unpack .../libgomp1_4.8.2-19ubuntu1_amd64.deb ...
Unpacking libgomp1:amd64 (4.8.2-19ubuntu1) ...
Selecting previously unselected package libitm1:amd64.
Preparing to unpack .../libitm1_4.8.2-19ubuntu1_amd64.deb ...
Unpacking libitm1:amd64 (4.8.2-19ubuntu1) ...
Selecting previously unselected package libmpfr4:amd64.
Preparing to unpack .../libmpfr4_3.1.2-1_amd64.deb ...
Unpacking libmpfr4:amd64 (3.1.2-1) ...
Selecting previously unselected package libquadmath0:amd64.
Preparing to unpack .../libquadmath0_4.8.2-19ubuntu1_amd64.deb ...
Unpacking libquadmath0:amd64 (4.8.2-19ubuntu1) ...
Selecting previously unselected package libtsan0:amd64.
Preparing to unpack .../libtsan0_4.8.2-19ubuntu1_amd64.deb ...
Unpacking libtsan0:amd64 (4.8.2-19ubuntu1) ...
Selecting previously unselected package libyaml-0-2:amd64.
Preparing to unpack .../libyaml-0-2_0.1.4-3ubuntu3_amd64.deb ...
Unpacking libyaml-0-2:amd64 (0.1.4-3ubuntu3) ...
Selecting previously unselected package libmpc3:amd64.
Preparing to unpack .../libmpc3_1.0.1-1ubuntu1_amd64.deb ...
Unpacking libmpc3:amd64 (1.0.1-1ubuntu1) ...
Selecting previously unselected package openssl.
Preparing to unpack .../openssl_1.0.1f-1ubuntu2.4_amd64.deb ...
Unpacking openssl (1.0.1f-1ubuntu2.4) ...
Selecting previously unselected package ca-certificates.
Preparing to unpack .../ca-certificates_20130906ubuntu2_all.deb ...
Unpacking ca-certificates (20130906ubuntu2) ...
Selecting previously unselected package manpages.
Preparing to unpack .../manpages_3.54-1ubuntu1_all.deb ...
Unpacking manpages (3.54-1ubuntu1) ...
Selecting previously unselected package binutils.
Preparing to unpack .../binutils_2.24-5ubuntu3_amd64.deb ...
Unpacking binutils (2.24-5ubuntu3) ...
Selecting previously unselected package cpp-4.8.
Preparing to unpack .../cpp-4.8_4.8.2-19ubuntu1_amd64.deb ...
Unpacking cpp-4.8 (4.8.2-19ubuntu1) ...
Selecting previously unselected package cpp.
Preparing to unpack .../cpp_4%3a4.8.2-1ubuntu6_amd64.deb ...
Unpacking cpp (4:4.8.2-1ubuntu6) ...
Selecting previously unselected package libgcc-4.8-dev:amd64.
Preparing to unpack .../libgcc-4.8-dev_4.8.2-19ubuntu1_amd64.deb ...
Unpacking libgcc-4.8-dev:amd64 (4.8.2-19ubuntu1) ...
Selecting previously unselected package gcc-4.8.
Preparing to unpack .../gcc-4.8_4.8.2-19ubuntu1_amd64.deb ...
Unpacking gcc-4.8 (4.8.2-19ubuntu1) ...
Selecting previously unselected package gcc.
Preparing to unpack .../gcc_4%3a4.8.2-1ubuntu6_amd64.deb ...
Unpacking gcc (4:4.8.2-1ubuntu6) ...
Selecting previously unselected package libc-dev-bin.
Preparing to unpack .../libc-dev-bin_2.19-0ubuntu6_amd64.deb ...
Unpacking libc-dev-bin (2.19-0ubuntu6) ...
Selecting previously unselected package linux-libc-dev:amd64.
Preparing to unpack .../linux-libc-dev_3.13.0-30.55_amd64.deb ...
Unpacking linux-libc-dev:amd64 (3.13.0-30.55) ...
Selecting previously unselected package libc6-dev:amd64.
Preparing to unpack .../libc6-dev_2.19-0ubuntu6_amd64.deb ...
Unpacking libc6-dev:amd64 (2.19-0ubuntu6) ...
Selecting previously unselected package ruby.
Preparing to unpack .../ruby_1%3a1.9.3.4_all.deb ...
Unpacking ruby (1:1.9.3.4) ...
Selecting previously unselected package ruby1.9.1.
Preparing to unpack .../ruby1.9.1_1.9.3.484-2ubuntu1_amd64.deb ...
Unpacking ruby1.9.1 (1.9.3.484-2ubuntu1) ...
Selecting previously unselected package libruby1.9.1.
Preparing to unpack .../libruby1.9.1_1.9.3.484-2ubuntu1_amd64.deb ...
Unpacking libruby1.9.1 (1.9.3.484-2ubuntu1) ...
Selecting previously unselected package manpages-dev.
Preparing to unpack .../manpages-dev_3.54-1ubuntu1_all.deb ...
Unpacking manpages-dev (3.54-1ubuntu1) ...
Selecting previously unselected package ruby1.9.1-dev.
Preparing to unpack .../ruby1.9.1-dev_1.9.3.484-2ubuntu1_amd64.deb ...
Unpacking ruby1.9.1-dev (1.9.3.484-2ubuntu1) ...
Selecting previously unselected package ruby-dev.
Preparing to unpack .../ruby-dev_1%3a1.9.3.4_all.deb ...
Unpacking ruby-dev (1:1.9.3.4) ...
Setting up libasan0:amd64 (4.8.2-19ubuntu1) ...
Setting up libatomic1:amd64 (4.8.2-19ubuntu1) ...
Setting up libgmp10:amd64 (2:5.1.3+dfsg-1ubuntu1) ...
Setting up libisl10:amd64 (0.12.2-1) ...
Setting up libcloog-isl4:amd64 (0.18.2-1) ...
Setting up libgomp1:amd64 (4.8.2-19ubuntu1) ...
Setting up libitm1:amd64 (4.8.2-19ubuntu1) ...
Setting up libmpfr4:amd64 (3.1.2-1) ...
Setting up libquadmath0:amd64 (4.8.2-19ubuntu1) ...
Setting up libtsan0:amd64 (4.8.2-19ubuntu1) ...
Setting up libyaml-0-2:amd64 (0.1.4-3ubuntu3) ...
Setting up libmpc3:amd64 (1.0.1-1ubuntu1) ...
Setting up openssl (1.0.1f-1ubuntu2.4) ...
Setting up ca-certificates (20130906ubuntu2) ...
debconf: unable to initialize frontend: Dialog
debconf: (TERM is not set, so the dialog frontend is not usable.)
debconf: falling back to frontend: Readline
debconf: unable to initialize frontend: Readline
debconf: (This frontend requires a controlling tty.)
debconf: falling back to frontend: Teletype
Setting up manpages (3.54-1ubuntu1) ...
Setting up binutils (2.24-5ubuntu3) ...
Setting up cpp-4.8 (4.8.2-19ubuntu1) ...
Setting up cpp (4:4.8.2-1ubuntu6) ...
Setting up libgcc-4.8-dev:amd64 (4.8.2-19ubuntu1) ...
Setting up gcc-4.8 (4.8.2-19ubuntu1) ...
Setting up gcc (4:4.8.2-1ubuntu6) ...
Setting up libc-dev-bin (2.19-0ubuntu6) ...
Setting up linux-libc-dev:amd64 (3.13.0-30.55) ...
Setting up libc6-dev:amd64 (2.19-0ubuntu6) ...
Setting up manpages-dev (3.54-1ubuntu1) ...
Setting up libruby1.9.1 (1.9.3.484-2ubuntu1) ...
Setting up ruby1.9.1-dev (1.9.3.484-2ubuntu1) ...
Setting up ruby-dev (1:1.9.3.4) ...
Setting up ruby (1:1.9.3.4) ...
Setting up ruby1.9.1 (1.9.3.484-2ubuntu1) ...
Processing triggers for libc-bin (2.19-0ubuntu6) ...
Processing triggers for ca-certificates (20130906ubuntu2) ...
Updating certificates in /etc/ssl/certs... 164 added, 0 removed; done.
Running hooks in /etc/ca-certificates/update.d....done.
 ---> c55c31703134
Removing intermediate container 3a2558904e9b
Step 4 : RUN gem install sinatra
 ---> Running in 6b81cb6313e5
unable to convert "\xC3" to UTF-8 in conversion from ASCII-8BIT to UTF-8 to US-ASCII for README.rdoc, skipping
unable to convert "\xC3" to UTF-8 in conversion from ASCII-8BIT to UTF-8 to US-ASCII for README.rdoc, skipping
Successfully installed rack-1.5.2
Successfully installed tilt-1.4.1
Successfully installed rack-protection-1.5.3
Successfully installed sinatra-1.4.5
4 gems installed
Installing ri documentation for rack-1.5.2...
Installing ri documentation for tilt-1.4.1...
Installing ri documentation for rack-protection-1.5.3...
Installing ri documentation for sinatra-1.4.5...
Installing RDoc documentation for rack-1.5.2...
Installing RDoc documentation for tilt-1.4.1...
Installing RDoc documentation for rack-protection-1.5.3...
Installing RDoc documentation for sinatra-1.4.5...
 ---> 97feabe5d2ed
Removing intermediate container 6b81cb6313e5
Successfully built 97feabe5d2ed
```

在这条命令中，`-t` 指定新镜像属于用户 `ouruser`、仓库名字是 `sinatra`、标签是 `v2`。

另外，使用 `.` 指定 Dockerfile 位于当前目录中。也可以用 `-f` 指定具体路径。

当所有的编译指令完成后，得到一个新的镜像 `97feabe5d2ed` --- `ouruser/sinatra:v2`。

> 一个镜像内不能超过 127 层（不管何种存储驱动）。这个限制是全局性的，以鼓励大家尽可能优化镜像尺寸。

之后，就可以用这个新镜像运行容器：

```sh
$ docker run -t -i ouruser/sinatra:v2 /bin/bash
root@78e82f680994:/#
```

###

## 为镜像设置标签

也可以使用 `docker tag` 命令为镜像设置标签：

```sh
$ docker tag 5db5f8471261 ouruser/sinatra:devel
```

这条命令告诉 Docker，为镜像 `5db5f8471261` 设置用户名 `ouruser`、仓库 `sinatra`、标签 `devel`。

使用 `docker images` 看看结果：

```sh
$ docker images ouruser/sinatra
REPOSITORY         TAG       IMAGE ID        CREATED         SIZE
ouruser/sinatra    latest    5db5f8471261    11 hours ago    446.7 MB
ouruser/sinatra    devel     5db5f8471261    11 hours ago    446.7 MB
ouruser/sinatra    v2        5db5f8471261    11 hours ago    446.7 MB
```

## 镜像摘要

使用 v2 或更高版本的格式，镜像有一个内容寻址标识，称为 digest。想要列出镜像的 digest，指定 `--degist` 标志位：

```sh
$ docker images --digests | head
REPOSITORY       TAG      
ouruser/sinatra  latest  
DIGEST 
sha256:cbbf2f9a99b47fc460d422812b6a5adff7dfee951d8fa2e4a98caa0382cfbdbf 
IMAGE ID         CREATED       SIZE
5db5f8471261     11 hours ago  446.7 MB
```

你可以在 `pull` 时指定 degist：

```sh
$ docker pull ouruser/sinatra@sha256:cbbf2f9a99b47fc460d422812b6a5adff7dfee951d8fa2e4a98caa0382cfbdbf
```

也能在 `create`、`run`、`rmi`、... 命令时通过 degist 引用镜像。

## 推送镜像到 Docker Hub

一旦你创建了一个新的镜像，你可以把它推送到 [Docker Hub](https://hub.docker.com/)：

```sh
$ docker push ouruser/sinatra
The push refers to a repository [ouruser/sinatra] (len: 1)
Sending image list
Pushing repository ouruser/sinatra (3 tags)
. . .
```

这样推送后，将会与其他人分享这个镜像。也可以[推送到私有镜像仓库](https://registry.hub.docker.com/plans/)。

## 删除镜像

使用命令 `docker rmi` 删除一个已有的镜像：

```sh
$ docker rmi training/sinatra
Untagged: training/sinatra:latest
Deleted: 5bc342fa0b91cabf65246837015197eecfa24b2213ed6a51a8974ae250fedd8d
Deleted: ed0fffdcdae5eb2c3a55549857a8be7fc8bc4241fb19ad714364cbfd7a56b22f
Deleted: 5c58979d73ae448df5af1d8142436d81116187a7633082650549c52c3a2418f0
```



