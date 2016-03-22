# [Docker 的架构](https://docs.docker.com/engine/understanding-docker/) 

## Docker 是什么

Docker 是一个开放平台，用于开发、组装、运行应用程序。Docker 帮助你快速交付应用程序。Docker 帮助你把你的应用程序和基础设施隔离，使你的基础设施更专注地负责管理。Docker 帮助你快速构建代码、快速测试、快速部署，缩短编写代码和运行代码的周期。

Docker 提供了一种隔离途径：通过在容器中运行应用程序，使它们安全的隔离。你可以在主机上同时运行多个容器，而每个容器都提供安全的隔离。容器这个功能非常轻量，它消耗非常少的管理资源，使你能从硬件得到更多的资源。 

## 我能用 Docker 做什么

### 快速交付应用程序

Docker 帮助你改善部署周期，它是如此的完美。首先，开发者们在本地容器上开发应用程序和服务；然后，把它们一次性整合到部署工作流中。

比如，开发者们在本地写代码，同时，和他们的同事用 Docker 共享开发栈。当他们准备好后，把他们的代码和开发栈推送到测试环境，然后执行需要的测试。通过测试环境，你能把 Docker 镜像推送到生产环境，并且部署代码。

### 更容易的部署和伸缩

Docker 这种基于容器的平台，具有非常高的可移植性。Docker 容器能运行在开发者的本地主机、数据中心的物理主机或虚拟主机、或者云端。

Docker 的可移植性和轻量，也使得自动化管理更加方便。你能快速增加或移除应用程序和服务。伸缩的速度接近于实时，这真的是蛮快的。

### 实现高密度，运行更多负载

Docker 是轻量的、快速的。比起虚拟机，Docker 提供一种低成本的可行方案。在高密度环境，这尤其重要：比如，你自己的云或者 Platform-as-a-Service。不过，对于小型、中型的部署，Docker 也非常有用。

###

## 由何组成

Docker 由两部分组成：

* Docker：开放源码的集装化平台
* Docker Hub：我们的 Software-as-a-Service 平台 --- 分享、管理 Docker 镜像

> 注意：Docker 的许可协议是 the open source Apache 2.0 。 

## 架构

Docker 使用“客户端-服务器”架构。Docker client 与 Docker daemon 对话，以此完成各种繁琐的任务：编译、运行、分发容器。Docker client 与 Docker daemon 能运行在同一个系统，也能通过远程连接。它们之间通过 Unix Domain Socket 或 RESTful API 通信。

![架构](https://docs.docker.com/engine/article-img/architecture.svg)

### Docker daemon

Docker daemon 运行在主机上。用户不直接和 Docker daemon 交互，而是通过 Docker client 和其交互。

### Docker client

Docker client，以二进制文件形式，是 Docker 的主要用户接口。它接受用户的命令行，然后和 Docker daemon 进行通信。

### Docker 内部

Docker 有三个重要的内部构件：

* Docker 镜像

  一个 Docker 镜像是一个只读的模板。举个例子，一个镜像可以包含一个 Ubuntu 操作系统，带有 Apache 和 Web 应用程序。镜像用来创建 Docker 容器。Docker 提供了简便的方法，来编译新的镜像、更新已有的镜像、从其他用户那里下载镜像。

* Docker 仓库

  Docker 仓库用于容纳 Docker 镜像。有公开的，也有私有的，你可以上传或下载它们。[Docker Hub](http://hub.docker.com/) 为你提供公开的 Docker 仓库，里边有大量用户上传的镜像。

* Docker 容器

  Docker 容器类似一个目录。一个 Docker 容器容纳了一个应用程序运行所需要的所有内容。每个容器由 Docker 镜像创建。Docker 容器能运行、启动、停止、移动、删除、... 每个容器都是一个隔离的、安全的应用程序平台。   

###

## 如何工作

### Docker 镜像如何工作

Docker 镜像是只读的模板。每个镜像由一连串的层组成。Docker 使用联合文件系统，把这些层组合到单个镜像。联合文件系统允许分离的文件和目录，即所谓的分支，通过透明的粘合，形成一个统一的文件系统。

Docker 如此轻量的一个原因，就是因为这些层。当你改变一个 Docker 镜像时 --- 比如，把一个应用程序更新到新版本，这时一个新的层就会产生。因此，比起替换整个镜像、或者完全重建，（虚拟机经常干这种事情），这种方式只有这个层被加入或更新。现在，你不需要分发整个镜像，只需要分发更新的部分，这使得 Docker 镜像更块、更简单的分发。

每个镜像起自一个基础镜像，比如 ubuntu --- 一个 Ubuntu 镜像；或者 fedora --- 一个 Fedora 镜像。你也能用你自己的镜像，作为一个基础镜像。 

> 注意：Docker 通常从 [Docker Hub](https://hub.docker.com/) 获得这些基础镜像。 

之后，Docker 镜像基于这些基础镜像，以一个简单的、描述性的指令集进行编译。每条指令在镜像中创建一个新层。指令集包括：

* RUN 一条命令
* ADD 一个文件或目录
* 创建一个环境变量
* 当从这个镜像启动容器时，所要运行的进程

这些指令集存储在一个名叫 Dockerfile 的文件中。当你请求编译一个镜像时，Docker 读取这个文件，执行里边的指令集，返回一个完成的镜像。    

### Docker 仓库如何工作

Docker 仓库存储 Docker 镜像。一旦你编译了一个 Docker 镜像，你可以把它推送到公开的仓库，像 [Docker Hub](https://hub.docker.com/)，或者作为你自己的私有库。

用 Docker client，你能搜索已经发布的镜像，然后把它们拉取到你的 Docker 所在的主机上。

[Docker Hub](https://hub.docker.com/) 为镜像提供公开和私有的存储。公开存储是可被搜索的，能被别人下载。私有存储是不能被搜索的，只有你和用户群能拉取。[你可以在这儿注册一个账户](https://hub.docker.com/plans)。

### Docker 容器如何工作

一个 Docker 容器由一个操作系统、用户添加的文件、元数据组成。每个容器都来自一个镜像。镜像告诉 Docker 这个容器应该容纳些什么、运行的进程是什么、以及一些其他配置数据。Docker 镜像是只读的。当 Docker 从一个镜像运行一个容器时，它在这个镜像上面添加一个读写层（通过联合文件系统），在这里，你的应用程序得以运行。

### 当运行容器时发生了什么

通过二进制或者 API，Docker client 告诉 Docker daemon 运行一个容器：

```sh
$ docker run -i -t ubuntu /bin/bash
```

我们分析下这条命令。Docker client 由 docker 二进制文件发动，`run` 告诉 Docker daemon 启动一个新容器。Docker client 至少要告诉 Docker daemon：

* 容器所依赖的镜像，这里是 ubuntu --- 一个 Ubuntu 镜像
* 当容器启动后，想在里面运行的命令，这里是 `/bin/bash` --- 启动 Bash Shell

那么，底层究竟发生了什么？

按照顺序，Docker 会做这些事情：

* 拉取 ubuntu 镜像：

  Docker 检查本机当前是否有 ubuntu 镜像。如果没有，就从  [Docker Hub](https://hub.docker.com/) 下载；如果有，就使用它。

* 创建一个新容器：

  一旦取得镜像，Docker 用它创建一个容器。

* 分配一个文件系统，挂载一个读写层：

  容器在文件系统中创建，并且一个读写层加入到镜像。

* 分配一个网络/bridge 网口：

  创建一个网口，允许 Docker 容器和本机对话。

* 配置 IP 地址：

  从池中查找一个可用的 IP 地址，附加到容器。

* 执行你指定的进程：

  运行你的应用程序。

* 捕捉和提供应用程序输出：

  连接和日志标准输入、输出、错误。

现在，你有了一个正在运行的容器！之后，你就能管理你的容器，和你的应用程序交互。    

###

## 依赖的底层技术

Docker 是用 GO 语言写的，利用几个 kernel 功能来提供我们所看到的功能。

### 命名空间

Docker 利用一项称为命名空间的技术，来提供隔离的工作空间 --- 容器。当你运行一个容器时，Docker 就为该容器创建了一套命名空间。

这提供了一个隔离层：容器运行在它自己的命名空间中，不会和外界存在访问。

Docker 使用的 Linux 命名空间有：

* pid 命名空间

  用于进程隔离（PID：进程号）。

* net 命名空间

  用于管理网络接口（NET：网络）。

* ipc 命名空间

  用于管理 IPC 资源的访问（IPC：跨进程通信）。

* mnt 命名空间

  用于管理挂载点（MNT：挂载）。

* uts 命名空间

  用于隔离 kernel 和版本验证（UTS：Unix 分时系统）。

### 控制组

Docker 还使用了另一项 Linux 技术 cgroups --- 控制组。隔离应用程序的关键，就是让它们只使用你想要的资源。控制组允许 Docker 把可用的硬件资源共享给容器，并且，如果需要的话，能配置限制和约束。比如，限制某个容器的内存使用量。

### 联合文件系统

联合文件系统，或者叫 UnionFS，是一种通过创建层执行操作的文件系统，使它们非常轻量，非常快速。Docker 使用联合文件系统为容器提供结构单元。Docker 能使用如下几个联合文件系统：aufs、btrfs、vfs、devicemapper。

### 容器格式

Docker 将这些组件集成到一个封装，我们称之为容器格式。默认的容器格式是  libcontainer。将来，Docker 可能会支持其他的容器格式。
