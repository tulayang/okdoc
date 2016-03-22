#  [Docker Engine client 命令行接口](https://docs.docker.com/engine/reference/commandline/cli/)

## `$ docker info [OPTIONS]`

OPTIONS|描述
-------|----
`--help`|打印帮助信息

显示 Docker Engine 的系统信息。

全局选项 `-D` 告诉所有的 Docker 命令，输出调试信息：

```sh
$ docker -D info
```

## `$ docker version [OPTIONS]`

OPTIONS|描述
-------|----
`-f --format=""`|使用给定的模板格式化输出
`--help`|打印帮助信息

默认情况下，这条命令以可读的方式渲染所有的版本信息。例子：

```sh
$ docker version
Client:
 Version:      1.8.0
 API version:  1.20
 Go version:   go1.4.2
 Git commit:   f5bae0a
 Built:        Tue Jun 23 17:56:00 UTC 2015
 OS/Arch:      linux/amd64

Server:
 Version:      1.8.0
 API version:  1.20
 Go version:   go1.4.2
 Git commit:   f5bae0a
 Built:        Tue Jun 23 17:56:00 UTC 2015
 OS/Arch:      linux/amd64
```

获取服务器版本信息：

```sh
$ docker version --format '{{.Server.Version}}'
1.8.0
```

## `$ docker help`

显示帮助信息。

## `$ docker daemon [OPTIONS]`

OPTIONS|描述
-------|----
`--api-cors-header=""`                   |设置 remote API 的 CORS headers
`--authorization-plugin=[]`              |设置验证插件
`-b, --bridge=""`                        |容器连结到的 bridge 网络 
`--bip=""`                               |指定网络 bridge IP
`--cgroup-parent=`                       |为所有的容器设置的 parent cgroup
`-D, --debug`                            |启用调试模式
`--default-gateway=""`                   |容器的默认网关 IPv4 地址
`--default-gateway-v6=""`                |容器的默认网关 IPv6 地址
`--cluster-store=""`                     |后端分布式存储的 URL
`--cluster-advertise=""`                 |集群中 Daemon 实例的地址
`--cluster-store-opt=map[]`              |配置集群
`--config-file=/etc/docker/daemon.json`  |Daemon 配置文件
`--dns=[]`                               |使用的 DNS 服务器
`--dns-opt=[]`                           |使用的 DNS 配置 
`--dns-search=[]`                        |使用的 DNS 搜索域
`--default-ulimit=[]`                    |为容器设置默认的 ulimit 
`--exec-opt=[]`                          |配置 exec 驱动
`--exec-root="/var/run/docker"`          |设置 Docker exec 驱动的 root
`--fixed-cidr=""`                        |用于固定 IP 的 IPv4 子网
`--fixed-cidr-v6=""`                     |用于固定 IP 的 IPv6 子网
`-G, --group="docker"`                   |用于 Unix Socket 的组（默认绑定 Unix Socket）
`-g, --graph="/var/lib/docker"`          |Docker 运行时的 root
`-H, --host=[]`                          |用于连接的 Daemon Socket(s)
`--help`                                 |打印帮助信息
`--icc=true`                             |启用跨容器通信
`--insecure-registry=[]`                 |启用不安全的 registry 通信
`--ip=0.0.0.0`                           |为容器绑定端口时，为其使用的默认 IP
`--ip-forward=true`                      |启用 net.ipv4.ip_forward
`--ip-masq=true`                         |启用 IP masquerading
`--iptables=true`                        |启用 iptables 规则扩展
`--ipv6`                                 |启用 IPv6 网络
`-l, --log-level="info"`                 |设置日志 level
`--label=[]`                             |为 Daemon 设置 key=value labels
`--log-driver="json-file"`               |为容器设置默认日志驱动
`--log-opt=[]`                           |配置日志驱动
`--mtu=0`                                |为容器设置网络 MTU
`--disable-legacy-registry`              |不要联系过时的 registries
`-p, --pidfile="/var/run/docker.pid"`    |Daemon 使用的 PID 文件
`--registry-mirror=[]`                   |Preferred Docker registry mirror
`-s, --storage-driver=""`                |使用的存储驱动
`--selinux-enabled`                      |启用 selinux 支持
`--storage-opt=[]`                       |配置存储驱动
`--tls`                                  |使用 TLS; implied by --tlsverify
`--tlscacert="~/.docker/ca.pem"`         |只信任这个 CA 的证书签名
`--tlscert="~/.docker/cert.pem"`         |TLS 证书文件的路径
`--tlskey="~/.docker/key.pem"`           |TLS 密钥文件的路径
`--tlsverify`                            |使用 TLS 并且验证远程访问
`--userns-remap="default"`               |启用用户命名空间重新映射
`--userland-proxy=true`                  |为环回测试使用用户层的代理

Docker Daemon 是持久存在的守护进程，主要用来管理容器。Docker 为 Daemon 和 Client 使用同一个二进制文件。想要运行 Daemon 你需要输入 `docker daemon`。

想要以调试模式运行，请输入 `docker daemon -D`。

### 配置套接字

Docker Daemon 能监听 Remote API 的请求，主要通过三种方式：Unix Domain Socket、TCP Socket、fd。

默认情况下，使用 Unix Domain Socket，路径是 */var/run/docker.sock*。可以通过 `root` 权限，或者 `docker` 组成员发送请求。

如果你需要从远程访问 Docker Daemon，你需要启用 TCP Socket。需要注意，默认 TCP Socket 提供的是未加密和没有身份验证的直接访问。为了安全，应该使用内置的 [HTTPS encrypted socket](https://docs.docker.com/engine/security/https/)，或者在前面放置一个安全的 Web 代理。你可以选择监听网口的 `2375` 端口 --- `-H tcp://0.0.0.0:2375`，或者指定 IP 地址 --- `-H tcp://192.168.59.103:2375`。按照约定，（和 Daemon 通信），我们使用 `2375` 作为未加密的端口，`2376` 作为加密的端口。 

> 注意：如果你使用了一个 HTTPS encrypted socket，那么只支持 TLS1.0 和更高版本。SSLv3 及其以下不受支持 --- 它们不再安全。

在 Systemd 系统，你能通过 [Systemd socket activation](http://0pointer.de/blog/projects/socket-activation.html) 和 Daemon 通信。

你也能指定 Docker Daemon 同时监听多个套接字：

```sh
$ docker daemon -H unix:///var/run/docker.sock -H tcp://192.168.59.106 -H tcp://10.10.10.2
```

Docker Client 会搜寻 `DOCKER_HOST` 环境变量，作为连接的 Daemon 地址；也可以通过 `-H` 指定：

```sh
$ docker -H tcp://0.0.0.0:2375 ps
## 或者
$ export DOCKER_HOST="tcp://0.0.0.0:2375"
$ docker ps
## 两个是等价的
```

设置 `DOCKER_TLS_VERIFY` 环境变量为任意值，而不是空字符串，等价于设置 `--tlsverify`：

```sh
$ docker --tlsverify ps
# 或者
$ export DOCKER_TLS_VERIFY=1
$ docker ps
``` 

Docker Client 会搜寻 `HTTP_PROXY`、`HTTPS_PROXY`、`NO_PROXY` 环境变量（包括小写版本），作为代理设定值。`HTTPS_PROXY` 的优先级高于 `HTTP_PROXY`。

### 配置存储驱动

Docker Daemon 支持几个不同的层存储驱动：aufs、devicemapper、btrfs、zfs、overlay。

aufs 驱动是最旧的，但是它是基于 Linux 内核补丁集，不需要合并到主内核。也有一些已知的导致内核崩溃问题。然而，aufs 是唯一一个允许容器共享可执行文件和库内存的存储驱动。因此，当在同一个程序或库运行成百上千容器时，用 aufs 是很好的选择。

devicemapper 驱动使用精简配置和写时复制。

btrfs 驱动对于 `docker build` 非常快。

zfs 驱动大概不如 btrfs 块，但是稳定版有一个非常长的跟踪记录。

overlay 驱动是非常快的联合文件系统。现在合并到 Linux kernel 3.18.0。如果需要，请调用 `docker daemon -s overlay` 来使用 overlay 驱动。

你能使用 `--storage-opt` 来配置指定的存储驱动。[参看官方文档](https://docs.docker.com/engine/reference/commandline/daemon/#storage-driver-options)

### 配置 exec 驱动

Docker Daemon 使用内置的 libcontainer exec 驱动作为它到 Linux kernel namespaces、cgroups、SELinux 的接口。

你能使用 `--exec-opt` 来配置这个 exec 驱动。所有的选项前带有 `native` 前缀，当前只有 `native.cgroupdriver` 可用。

`native.cgroupdriver` 指定容器的 cgroup 的管理器。你能指定 `cgroupfs` 或 `systemd`。

### 配置 DNS

想要设置所有 Docker 容器的 DNS 服务器，请使用 `docker daemon --dns 8.8.8.8`。  

想要设置所有 Docker 容器的 DNS 搜索域名，请使用 `docker daemon --dns-search example.com`。

### 绑定 HTTPS_PROXY

当使用 `HTTPS` 代理运行在一个局域网时，Docker Hub 证书会被代理的证书替换。你需要把证书加到 Docker 所在主机的配置中：

1. 为你的系统安装 `ca-certificates` 包。

2. 问问你的网络管理员，取得代理的 CA 证书，并追加到 */etc/pki/tls/certs/ca-bundle.crt* 文件。

3. 然后，启动你的 Docker Daemon：`HTTPS_PROXY=http://username:password@proxy:port/ docker daemon`。`username:` 和 `password@` 是可选的 --- 为了通过你的代理验证。

这只是把代理和验证加到 Docker Daemon 的请求 --- 你的 `docker build` 和运行的容器会需要这个代理的额外配置。

### 默认的 Ulimits

`--default-ulimit` 允许你为所有的容器设置默认的 `ulimit` 。它和 `docker run --ulimit` 是相同的。当在 `docker run` 没有指定 `ulimit` 时，就会从 Docker Daemon 设置的 `ulimit` 继承其值；`docker run  --ulimit` 则会为容器重写该值。

注意 `nproc` 和 `ulimit` 标志位的关系。`nproc` 是由 Linux 设计用来配置用户可用进程最大数的，而不是面向容器的。更多细节，请参考 `docker run`。

### 节点探测

`--cluster-advertise` 指定 `host:port` 或 `interface:port`，表示把这个指定的 Daemon 实例加入到集群中。远程主机通过这个值知晓这个 Daemon。如果你指定的是 `interface`，确保它包含了 Docker 所在主机的真实 IP 地址。对于通过 `docker-machine` 安装的 Engine 实例，其 `interface` 通常是 `eth1`。

`--cluster-store` 指定这个 Daemon 所使用的 key-value 存储。

这个 Daemon 使用 libkv 来向集群宣布节点加入。某些后端 key-value 存储支持 TLS 通信。想要通过 Daemon 配置客户端访问的 TLS，请使用 `--cluster-store-opt`，指定 PEM 编码文件的路径：

```sh
$ docker daemon \
         --cluster-advertise 192.168.1.2:2376 \
         --cluster-store etcd://192.168.1.2:2379 \
         --cluster-store-opt kv.cacertfile=/path/to/ca.pem \
         --cluster-store-opt kv.certfile=/path/to/cert.pem \
         --cluster-store-opt kv.keyfile=/path/to/key.pem
```

当前支持的集群存储配置项是：

* `discovery.heartbeat`

  指定心跳定时器（秒），Daemon 根据此来保持一个持久连接（keeplive）。如果没有指定，则使用默认值 `20` 秒。

* `discovery.ttl`

  指定存在时间（秒），探测模块根据此来判断一个节点是否超时（超过一定时间，未收到心跳流量）。如果没有指定，则使用默认值 `60` 秒。

* `kv.cacertfile`

  指定可信任的 PEM 编码的 CA 认证机构所在的文件。

* `kv.certfile`

  指定 PEM 编码的证书文件。Client 需要使用这个证书来和 key-value 存储通信。

* `kv.keyfile`

  指定 PEM 编码的密钥文件。Client 需要使用这个密钥来和 key-value 存储通信。

* `kv.path`

  指定 key-value 存储的访问路径。如果没有指定，则使用默认值 `docker/nodes`。

### 身份认证 （插件扩展）

### 配置用户命名空间

Linux kernel 用户命名空间支持提供了额外的安全 --- 为容器的进程设定唯一的、与主机（机器）隔离的用户和组范围。潜在的安全问题是，默认情况下，容器的进程以 `root` 用户运行，但是实际上它们映射到主机（机器）上则是非特权用户。

当启用用户命名空间支持时，Docker 为所有运行在当前 Engine 的容器创建一个单一的映射。这个映射会利用已有的低级别用户和组（现代 Linux 发行版都支持这一功能）。*/etc/subuid* 和 * /etc/subgid* 会被读给用户；可选的组，则用过 `--userns-remap` 指定。如果你不想指定自己的用户或组，可以把 `--userns-remap` 设为 `default` 以提供默认值，这样将会以你的用户作为基础来创建用户，并且提供（从属的）用户号和组号范围。这个默认的用户名是 `dockremap`，并且会为其在 */etc/passwd* 和 */etc/group* 创建记录（使用你系统的标准用户和组创建工具来创建）。

> Note: The single mapping per-daemon restriction is in place for now because Docker shares image layers from its local cache across all containers running on the engine instance. Since file ownership must be the same for all containers sharing the same layer content, the decision was made to map the file ownership on `docker pull` to the daemon’s user and group mappings so that there is no delay for running containers once the content is downloaded. This design preserves the same performance for `docker pull`, `docker push`, and container startup as users expect with user namespaces disabled.

想要启用用户命名空间支持，使用 `--userns-remap` 启动 Daemon。

### 杂项配置

IP 伪装使用地址解释器，使容器不需要公共 IP 就可以和因特网的其他机器通信。这可能会干预某些网络拓扑，你可以使用 `--ip-masq=false` 关闭这项功能。

Docker 支持对 Docker 数据目录（*/var/lib/docker* 和 */var/lib/docker/tmp*）的软链接。使用 `DOCKER_TMPDIR` 指定数据目录：

```sh
DOCKER_TMPDIR=/mnt/disk2/tmp /usr/local/bin/docker daemon -D -g /var/lib/docker -H unix:// > /var/lib/docker-machine/docker.log 2>&1
## 或者
export DOCKER_TMPDIR=/mnt/disk2/tmp
/usr/local/bin/docker daemon -D -g /var/lib/docker -H unix:// > /var/lib/docker-machine/docker.log 2>&1
```

### 默认的 cgroup parent

`--cgroup-parent` 允许你为容器配置默认的 cgroup parent。如果没有设置，那么 fs cgroup 驱动使用 `/docker`，systemd cgroup 驱动使用 `system.slice`。

如果 cgroup 以 `/` 开始，那么在 root cgroup 下创建 cgroup；否则，在 Daemon cgroup 下创建 cgroup。

假设 Daemon 运行在 cgroup `daemoncgroup`，那么 `--cgroup-parent=/foobar` 创建一个位于 `/sys/fs/cgroup/memory/foobar` 的 cgroup，而 `--cgroup-parent=foobar` 创建一个位于 `/sys/fs/cgroup/memory/daemoncgroup/foobar` 的 cgroup。

也能为每个容器专门设定这个值，只需要使用 `docker run --cgroup-parent` 或 `docker create --cgroup-parent`，它们会为容器重写 Daemon 的 `--cgroup-parent`。

### Daemon 配置文件

`--config-file` 允许你设置 Daemon 的配置目录，其配置文件以 JSON 表示。这些文件使用和命令标志位相同的名字作为键，那些期望多个值的名字使用复数表示（后面加个 `s`，比如 `label` 标志位对应 `labels`）。默认情况下，Docker 尝试从 */etc/docker/daemon.json* （Linux 系统） 加载配置文件。

配置文件的标志位一定要书写正确，否则，Docker Daemon 有可能启动失败。没有配置内容的标志位，在 Daemon 启动时会被忽略。

这是一个完整的配置文件例子：

```json
{
    "authorization-plugins": [],
    "dns": [],
    "dns-opts": [],
    "dns-search": [],
    "exec-opts": [],
    "exec-root": "",
    "storage-driver": "",
    "storage-opts": "",
    "labels": [],
    "log-driver": "",
    "log-opts": [],
    "mtu": 0,
    "pidfile": "",
    "graph": "",
    "cluster-store": "",
    "cluster-store-opts": [],
    "cluster-advertise": "",
    "debug": true,
    "hosts": [],
    "log-level": "",
    "tls": true,
    "tlsverify": true,
    "tlscacert": "",
    "tlscert": "",
    "tlskey": "",
    "api-cors-headers": "",
    "selinux-enabled": false,
    "userns-remap": "",
    "group": "",
    "cgroup-parent": "",
    "default-ulimits": {},
    "ipv6": false,
    "iptables": false,
    "ip-forward": false,
    "ip-mask": false,
    "userland-proxy": false,
    "ip": "0.0.0.0",
    "bridge": "",
    "bip": "",
    "fixed-cidr": "",
    "fixed-cidr-v6": "",
    "default-gateway": "",
    "default-gateway-v6": "",
    "icc": false
}
```

###

## `$ docker images`

```sh
$ docker images
REPOSITORY         TAG       IMAGE ID        CREATED         SIZE
ubuntu             14.04     1d073211c498    3 days ago      187.9 MB
busybox            latest    2c5ac3f849df    5 days ago      1.113 MB
training/webapp    latest    54bb4e8718e8    5 months ago    348.7 MB
```

列出本地所有的镜像。

### `--digests`

```sh
$ docker images --digests | head
REPOSITORY         TAG       DIGEST                                                                  . . .
ouruser/sinatra    latest    sha256:cbbf2f9a99b47fc460d422812b6a5adff7dfee951d8fa2e4a98caa0382cfbdbf
```

列出本地所有的镜像，包括哈希摘要。

###

## `$ docker search`

```sh
$ docker search centos
NAME                  DESCRIPTION                                      STARS    OFFICIAL    AUTOMATED
centos                The official build of CentOS.                    1929     [OK]       
jdeathe/centos-ssh    CentOS-6 6.7 x86_64 / SCL/EPEL/IUS Repos /...    15                   [OK]
. . .
```

从 Docker Hub 查找镜像 `centos`。        

## `$ docker pull`

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

从 Docker Hub 拉取镜像 `centos` 到本地。

## `$ docker commit`

```sh
$ docker commit -m "Added json gem" -a "Kate Smith" 0b2616b0e5a8 ouruser/sinatra:v2
4f177bd27a9ff0f6dc2a830403925b5360bfe0b93d476f7fc3231110e7f71b1c
```

基于已运行容器 `0b2616b0e5a8` 生成镜像 `ouruser/sinatra:v2`，指定注释 `Added json gem`、作者 `Kate Smith`。成功后，返回一个镜像号。

## `$ docker build`

```sh
$ docker build -t ouruser/sinatra:v2 .
```

告诉 **docker**，编译当前目录的 Dockerfile （`.`），生成镜像 `ouruser/sinatra:v2`。你也可以指定 Dockerfile 的其他路径。在编译之前你应该编辑 Dockerfile 的内容，比如：

```Dockerfile
# This is a comment
FROM ubuntu:14.04                                         # 基于某个镜像   
MAINTAINER Kate Smith <ksmith@example.com>                # 作者
RUN apt-get update && apt-get install -y ruby ruby-dev    # 执行命令
RUN gem install sinatra                                   # 执行命令
```

## `$ docker push`

```sh
$ docker push ouruser/sinatra
The push refers to a repository [ouruser/sinatra] (len: 1)
Sending image list
Pushing repository ouruser/sinatra (3 tags)
. . .
```

把本地镜像 `ouruser/sinatra` 推送到 Docker Hub。

## `$ docker tag [OPTIONS] IMAGE[:TAG] [REGISTRYHOST/][USERNAME/]NAME[:TAG]` 

OPTIONS|描述
-------|----
`--help`|打印帮助信息

为一个镜像打上标签，以成为一个库。

例子，为镜像 `5db5f8471261` 设定名字 `ouruser/sinatra`、标签 `devel`：

```sh
$ docker tag 5db5f8471261 ouruser/sinatra:devel
```

## `$ docker rmi`

```sh
$ docker rmi training/sinatra
Untagged: training/sinatra:latest
Deleted: 5bc342fa0b91cabf65246837015197eecfa24b2213ed6a51a8974ae250fedd8d
Deleted: ed0fffdcdae5eb2c3a55549857a8be7fc8bc4241fb19ad714364cbfd7a56b22f
Deleted: 5c58979d73ae448df5af1d8142436d81116187a7633082650549c52c3a2418f0
```

删除本地镜像 `training/sinatra`。删除之前，确保没有容器在使用镜像。


## `$ docker run [OPTIONS] IMAGE[:TAG|@DIGEST] [COMMAND] [ARG...]`

OPTIONS|描述
-------|----
`-a --attach=[]`|连结到标准输入、标准输出、标准错误
`--add-host=[]`|添加一个自定义的 host-to-IP 映射（`host:ip`）
`--blkio-weight=0`|块 IO 权重（相对权重）
`--blkio-weight-device=[]`|块 IO 权重（相对权重，格式：`DEVICE_NAME:WEIGHT`）
`--cpu-shares=0`|CPU 占用率（相对权重）
`--cap-add=[]`|添加 Linux capabilities
`--cap-drop=[]`|删除 Linux capabilities
`--cgroup-parent=""`|（可选）容器的父 cgroup
`--cidfile=""`|把容器号写入文件
`--cpu-period=0`|限制 CPU CFS （完全公平调度器）的周期
`--cpu-quota=0`|限制 CPU CFS （完全公平调度器）的配额
`--cpuset-cpus=""`|允许哪几个 CPU 执行（比如：`0-3`、`0`、`1`） 
`--cpuset-mems=""`|允许哪几个内存节点执行（比如：`0-3`、`0`、`1`）
`-d --detach`|把容器运行在后端，并打印容器号
`--detach-keys`|指定“脱离”容器的快捷键
`--device=[]`|为容器添加一个主机设备
`--device-read-bps=[]`|限制从设备的读命中（字节/秒）（比如：`--device-read-bps=/dev/sda:1mb`）
`--device-read-iops=[]`|限制从设备的读命中（IO/秒）（比如：`--device-read-iops=/dev/sda:1000`）
`--device-write-bps=[]`|限制从设备的写命中（字节/秒）（比如：`--device-write-bps=/dev/sda:1mb`）
`--device-write-iops=[]`|限制从设备的写命中（IO/秒）（比如：`--device-write-iops=/dev/sda:1000`）
`--disable-content-trust=true`|跳过镜像验证
`-dns=[]`|设置自定义的 DNS 服务器
`--dns-opt=[]`|设置自定义的 DNS 配置
`--dns-search=[]`|设置自定义的 DNS 搜索域
`-e, --env=[]`|设置环境变量
`--entrypoint=""`|重写镜像默认的 `ENTRYPOINT`
`--env-file=[]`|读取这个环境变量文件
`--expose=[]`|暴露一个范围的端口
`--group-add=[]`|添加额外的组
`-h, --hostname=""`|容器的主机名
`--help`|打印帮助信息
`-i --interactive`|如果没有连结，保持标准输入打开
`--ip=""`|设置容器的 IPv4 地址（比如：`172.30.100.104`）
`--ip6=""`|设置容器的 IPv6 地址（比如：`2001:db8::33`）
`--ipc=""`|使用的 IPC 命名空间
`--isolation=""`|容器隔离技术
`--kernel-memory=""`|限制内核内存
`-l --label=[]`|设置容器的元数据（比如：`--label=com.example.key=value`）
`--label-file=[]`|读取这个元数据文件（EOL 定界）
`--link=[]`|链接到另一个容器
`--log-driver=""`|指定容器的日志驱动
`--log-opt=[]`|指定容器的日志驱动配置
`-m --memory=""`|限制内存
`--mac-address=""`|设置容器的 MAC 地址（比如：`92:d0:c6:0a:29:33`）
`--memory-reservation=""`|软限制内存
`--memory-swap=""`|正整数，内存 + 交换空间，`-1` 表示不限制
`--memory-swappiness=""`|调节容器的内存交换行为，接受 `0` 到 `100` 的整数
`--name=""`|为容器命名
`--net="bridge"`|把容器连接到网络
`--net-alias=[]`|为容器添加一个网络范围的别名
`--oom-kill-disable`|为容器禁用 Linux 的 OOM 终结器
`--oom-score-adj=0`|为容器调节主机的 OOM 参数（接受 `-1000` 到 `1000`）
`-P --publish-all`|把所有暴露的端口发布为随机端口
`-p --publish=[]`|把容器的一个端口发布给主机
`--pid=""`|使用的 PID 命名空间
`--privileged`|给予容器扩展的特权
`--read-only`|挂载容器的 root 文件系统时，作为只读的
`--restart="no"`|重启策略（`no`、`on-failure[:max-retry]`、`always`、`unless-stopped`）
`--rm`|当容器退出时，自动删除容器
`--shm-size=[]`|*/dev/shm* 的长度
`--security-opt=[]`|安全配置
`--sig-proxy=true`|代理进程所有接收的信号
`--stop-signal="SIGTERM"`|设置停止容器的信号
`-t --tty`|分配一个伪终端
`-u --user=""`|指定用户名或用户号（格式：`<name｜uid>[:<group｜gid>]`）
`--ulimit=[]`|Ulimit 配置
`--uts=""`|使用的 UTS 命名空间
`-v, --volume=[host-src:]container-dest[:<options>]`|挂载一个卷
`--volume-driver=""`|指定容器的卷驱动
`--volumes-from=[]`|从指定的容器挂载卷
`-w, --workdir=""`|容器内的工作目录

Docker 在隔离的容器运行进程。容器是运行在主机上的一个进程。主机可以是本机，也可以是远程。当执行 `docker run` 时，容器中的进程是隔离的，它们有自己的文件系统、网络、进程树（和主机不相干的）。

`docker run` 命令首先用镜像 `IMAGE` 创建一个可写的容器，然后启动容器。也就是说，`docker run` 等价于 API 的 `/containers/create` + `/containers/(id)/start`。一个停止的容器，能用 `docker start` 再次重启，其之前的内容不会改变。`docker ps -a` 列出所有的容器。例子：

```sh
$ docker run --name test -it debian
root@d6c0fe130dba:/# exit 13
$ echo $?
13
$ docker ps -a | grep test
d6c0fe130dba    debian:7    "/bin/bash"    26 seconds ago      
Exited (13) 17 seconds ago    test
```

### 后端

OPTIONS|描述
-------|----
`-d --detach`|把容器运行在后端，并打印容器号

当启动一个 Docker 容器时，你必须决定是在后端运行容器（也叫“脱离”模式），还是在前端运行容器（默认行为）。

想要在后端运行容器，使用 `-d=true` 或 `-d`。根据设计，当运行该容器的 root 进程退出时，以“脱离”模式启动的容器也会随之退出。这种容器停止时，也不能自动删除 --- 也就是说，不能同时指定 `--rm`。例子：

```sh
$ docker run -d ubuntu /bin/sh -c \
  "while true; do echo hello world; sleep 1; done"  ## 下边返回容器号
1e5535038e285177d5214659a068137486f96ee5c2e85a4ac52dc83f2ebe4147
```

不要对一个“脱离”容器执行 `service x start` 之类的命令。比如下面这个例子，它尝试启动 nginx 服务：

```sh
$ docker run -d -p 80:80 my_image service nginx start
```

这样能在容器中成功启动 nginx 服务。然而，它示范了“脱离”容器所潜在的失败问题：root 进程（`service nginx start`）返回，因此，根据设计，“脱离”容器也随之停止。结果，nginx 服务是启动了，但是不能用！为了使 nginx 类似的服务工作，请这样做：

```sh
$ docker run -d -p 80:80 my_image nginx -g 'daemon off;'
```

想与“脱离”容器执行 IO，请使用网络连接或者共享卷。这是必需的，因为这种容器不再监听命令行。

想重新连结“脱离”容器，请使用 `docker attach` 命令。

### 前端

`docker run` 运行在前端模式（没有指定 `-d`）时，能启动容器的进程，并且把控制台连结到进程的标准输入、标准输出、标准错误。甚至是作为伪终端（正如大多数命令行运行的可执行文件所期望的方式）来传送信号。下面这些是可配置的：

OPTIONS|描述
-------|----
`-a --attach=[]`|连结到 `stdin`、`stdout`、`stderr`
`-t --tty`|分配一个伪终端
`--sig-proxy=true`|代理进程所有接收的信号
`-i --interactive`|如果没有连结，保持标准输入打开

`-a` 告诉 `docker run` 绑定容器的 `stdin`、`stdout`、`stderr`，这样能使你操作容器内进程的输入输出。如果没有指定 `-a`，那么 Docker 会连结所有的标准流。你能指定想要连结的标准流：

```sh
$ docker run -a stdin -a stdout -i -t ubuntu /bin/bash
```

为了和进程交互（类似 **Shell**），你必须同时指定 `-t` 和 `-i`，来为容器的进程分配一个伪终端。通常，可以写作 `-it`。如果客户端标准输出被重定向或管道，则指定 `-t` 是不允许的，像这样：

```sh
$ echo test | docker run -i my_image cat
```

> 由于 Linux 的设定，容器内进程号为 `1` 的进程，会忽略所有的信号（默认行为）。因此，不能通过 `SIGINT`、`SIGTERM` 信号终止该进程；除非编写代码，明确终止该进程。

### 容器名

有三种方式来识别容器：

识别类型|例子
-------|----
UUID 完整|“f78375b1c487e03c9438c729345e54db9d20cfa2ac1fc3494b6eb60872e74778”
UUID 短写|“f78375b1c487”
名字|“evil_ptolemy”

UUID 来自 Docker Daemon。如果你没有用 `--name` 为容器命名，Daemon 为你生成一个随机名字。如果你定义了容器的名字，你就能更方便的引用容器 --- 比如，在网络通信。

> 注意：连接默认 `bridge` 网络的容器，必须用名字通信。

<span>

> 容器名必须是唯一的。如果你已经为一个容器命名 `web`，不能再为其他容器命名 `web`。

### 把容器号写入文件

OPTIONS|描述
-------|----
`--cidfile=""`|把容器号写入文件

你能让 Docker 把容器号写入一个指定的文件。例子：

```sh
$ docker run --cidfile /tmp/docker_test.cid ubuntu echo "test"
```

`--cidfile` 会尝试创建一个文件，并且把容器号写入。如果这个文件已经存在，Docker 会返回一个错误。当 `docker run` 退出时，会删除这个文件。

### 镜像标签

你能指定镜像的标签版本，比如：

```sh
$ docker run ubuntu:14.04
```

### PID 配置

OPTIONS|描述
-------|----
`--pid=""`|指定容器的进程号命名空间模式，可选的值：<br />• `host`：在容器内使用主机的进程号命名空间

默认情况下，所有容器启用进程号命名空间。

进程号命名空间使得进程可以隔离，移除了传统的系统进程视图，允许进程号重用（包括 `1`）。

在某些情况，你可能想让容器共享主机的进程命名空间，主要是想允许容器的进程能够看到系统的所有进程。比如，你可以用调试工具 strace 或 gdb 编译一个容器，但是，当在容器内调试进程时想用这些工具。

例子，指定 `--pid=host` 在容器内运行 htop：

1. 创建 Dockerfile：

   ```sh
   FROM alpine:latest
   RUN apk add --update htop && rm -rf /var/cache/apk/*
   CMD ["htop"]
   ```

2. 编译 Dockerfile：

   ```sh
   $ docker build -t myhtop .
   ```

3. 在容器内运行 htop：

   ```sh
   $ docker run -it --rm --pid=host myhtop
   ```

### UTS 配置

OPTIONS|描述
-------|----
`--uts=""`|指定容器的 UTS 命名空间模式，可选的值：<br />• `host`：在容器内使用主机的 UTS 命名空间

UTS 命名空间用来设定主机名和域名。默认，所有容器，包括 `--net=host` 的那些容器，有自己的 UTS 命名空间。置为 `host` 会使容器使用和主机相同的 UTS 命名空间。

如果想在主机的主机名改变时，同步改变容器的主机名，那么你会希望和主机共享 UST 命名空间。

> `--uts="host"` 使容器完全获得对主机的主机名访问权，容器可以修改它，因此，这通常被认为是不安全的。

### IPC 配置

OPTIONS|描述
-------|----
`--ipc=""`| 指定容器的 IPC 模式，可选的值：<br />• `container:<name｜id>`：重用另一个容器的 IPC 命名空间<br />• `host`：在容器内使用主机的 IPC 命名空间

默认情况下，所有容器启用 IPC 命名空间。

IPC (POSIX/SysV IPC) 命名空间，提供内存映射、信号量、消息队列。比起管道、网络，内存映射基于内存，能提供更快速的进程通信。通常，数据库和自定义的高性能应用，喜欢用内存映射。如果这些应用分散在多个容器，可能就会需要共享容器的 IPC 。   

### 网络配置

OPTIONS|描述
-------|----
`-dns=[]`|设置自定义的 DNS 服务器
`--net="bridge"`|把容器连接到网络，可选的值：<br />• `bridge`：使用默认的桥创建一个网络栈<br />• `none`：没有网络<br />• `container:<name｜id>`：重用另一个容器的网络栈<br />• `host`：使用主机的网络栈<br />• `<network-name>｜<network-id>`：连接到用户定义的网络 
`--net-alias=[]`|为容器添加一个网络范围的别名
`--add-host=[]`|向 /etc/hosts 添加一行 host-to-IP 映射（`host:ip`）
`--mac-address=""`|设置容器的网卡设备的 MAC 地址（比如：`92:d0:c6:0a:29:33`）
`--ip=""`|设置容器的网卡设备的 IPv4 地址（比如：`172.30.100.104`）
`--ip6=""`|设置容器的网卡设备的 IPv6 地址（比如：`2001:db8::33`）

默认情况下，所有的容器启用网络，并且可以对外连接。`docker run --net none` 可以彻底禁用容器的网络，包括输入和输出。这时，只能通过文件或 `stdin`、`stdout` 执行 IO。

发布端口并链接到另一个容器只能用默认的网络（`bridge`）。链接功能是过时的，你应该总是使用 Docker 网络驱动来连接通信。

默认情况下，你的容器使用相同的 DNS 服务器，使用 `--dns` 可以重写。

默认情况下，MAC 地址是通过分配给容器的 IP 地址生成的。使用 `--mac-address` 能显式指定容器的网卡的 MAC 地址（格式：`12:34:56:78:9a:bc`）。

* 网络 `none`

  容器没有网络，只有内部的环回测试网卡。

* 网络 `bridge`

  把网络设置为 `bridge` 会为容器使用默认的网络。桥是安装在主机上的，通常命名为 `docker0`。容器会创建一对 veth 网口，一个保留在主机，一个附加到容器内部。同时为容器分配一个 IP 地址，使其可以通过这个桥网络通信。

  默认情况下，容器只能通过 IP 地址通信。想要通过名字通信，必须使用链接。

* 网络 `host`

  容器共享主机的网络栈，并且主机的所有网口都能被容器使用。容器的主机名会匹配主机的主机名。注意：`--add-host --hostname --dns --dns-search --dns-opt --mac-address` 在 `host` 模式下不可用。

  比起默认的 `bridge` 模式，它有更好的网络性能 --- `host` 模式使用本地网络栈，而 `bridge` 模式则是虚拟的，需要经过 Docker Daemon 守护进程（转发）。当网络性能非常重要时，推荐使用这个模式，比如负载均衡、或者高性能 Web 服务器。

  > `--net="host"` 使容器完全获得对主机的服务访问权，因此，它被认为是不安全的。

* 网络 `container:<name|id>` 

  共享另一个容器的网络栈。注意：`--add-host --hostname --dns --dns-search --dns-opt --mac-address` 在 `container:<name|id>` 模式不可用，`--publish --publish-all --expose` 也不可用。

  例子，运行一个 Redis 容器。它绑定了 `localhost`，然后运行 `redis-cli` 命令连接到 Redis 服务器：

  ```sh
  $ docker run -d --name redis example/redis --bind 127.0.0.1
  $ docker run --rm -it --net container:redis example/redis-cli -h 127.0.0.1
  ```

* 网络 `<network-name>|<network-id>`

  连接到用户自定义的网络（通过 Docker 网络驱动或插件驱动创建）。你能把多个容器连接到同一个网络。一旦容器们连接到用户定义的网络，容器们就可以通过容器 IP 地址或容器名通信。

  对于 `overlay` 网络或支持多主机连接的插件网络，容器们连接到同一个多主机网络，但是它们是由不同的 Docker Engine 启动的。

  例子，使用内置的 bridge 创建一个网络，然后连接容器：

  ```sh
  $ docker network create -d bridge my-net
  $ docker run --net=my-net -itd --name=container3 busybox
  ```

容器的 */etc/hosts* 定义了容器的主机名和一些通用配置（比如 `localhost`）。`--add-host=[]` 能用来向容器的 */etc/hosts* 添加行映射（`host:ip`）：

```sh
$ docker run -it --add-host db-static:86.75.30.9 ubuntu cat /etc/hosts
172.17.0.22     09d03f76bf2c
fe00::0         ip6-localnet
ff00::0         ip6-mcastprefix
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
86.75.30.9      db-static
```

如果容器连接到用户定义的网络，容器的 */etc/hosts* 会更新，纳入所有通过该网络连接的容器名。

### 重启策略

OPTIONS|描述
-------|----
`--restart="no"`|重启策略（`no`、`on-failure[:max-retry]`、`always`、`unless-stopped`）

为容器指定一个重启策略，设定当容器退出时，是否应该重启。

当启用 `--restart` 时，用 `docker ps` 命令可以看到当前是 `Up` 还是 `Restarting` 。也能用 `docker events` 看到重启策略的影响。

Docker 支持以下重启策略：

策略|结果
----|----
`no`|默认，容器退出时不自动重启
`on-failure[:max-retries]`|如果容器退出时退出状态是非零，尝试重启动（设定最大尝试次数）
`always`|当容器退出时，总是重启。当守护进程启动时，容器也总是启动，不管当前是什么状态
`unless-stopped`|当容器退出时，总是重启。但是，如果守护进程启动时，容器是停止状态，则不重启

每次重启前，会有一个增量的延迟（最开始是 `100 ms`），以防止重启过度。也就是说，守护进程会等待 `100ms`，然后 `200ms`、`400ms`、`800ms`、`1600ms`、... 、或者直到 `on-failure` 最大值，才会重启；或者如果收到 `docker stop` 停止容器、`docker rm -f` 删除容器的命令，就放弃重启。

如果容器重启成功（容器启动并且至少运行了 `10s`），延迟被重设为 `100ms`。例子：

```sh
$ docker run --restart=always redis       ## 退出时总是自动重启 
$ docker run --restart=on-failure:10 redis## 退出状态非零时重启；最大重试次数10
```

可以用 `docker inspect` 看到重启的次数：

```sh
$ docker inspect -f "{{ .RestartCount }}" my-container
2
```

也可以看到最后一次重启的时间：

```sh
$ docker inspect -f "{{ .State.StartedAt }}" my-container
2015-03-04T23:47:07.691840179Z
```

组合 `--restart` 和 `--rm` 会引起错误。当容器重启时，已连接的客户端会断开连接。

### 退出状态

`docker run` 退出时，其返回的退出状态包含了一些退出信息。定义如下：

退出状态|描述
-------|-----
`125`|Docker Daemon itself
`126`|容器内的命令不能被调用
`127`|容器内的命令不能被找到
`{?}`|容器内的命令主动退出

例子：

```sh
$ docker run busybox /etc
docker: Error response from daemon: Contained command could not be invoked
$ echo $?
126
```

<span>

```sh
$ docker run busybox /bin/sh -c 'exit 3'; echo $?
3
```

### 自动删除

OPTIONS|描述
-------|----
`--rm`|当容器退出时，自动删除容器

默认，Docker 容器的文件系统是持久存在的，就算容器退出也仍然存在。调试因此变得更容易，而且还能保留想要的数据。然而，当运行许多短期的小进程，会导致大量的文件堆积。你可能想让 Docker 在容器退出时，自动清理容器和删除容器所用的文件系统。只需要指定 `--rm`：

```sh
$ docker run --rm ubuntu 
```

当指定 `--rm` 时，Docker 总是在删除容器时同时删除为容器分配的卷，类似 `docker rm -v my-container`。另外，只有那些未指定名字的卷会被删除。比如：

```sh
$ docker run --rm -v /foo -v awesome:/bar busybox top
``` 

卷 `/foo` 被删除，但是 `/bar` 不会被删除。通过 `--volumes-from ` 继承的卷也遵守同样的规则。

### 安全配置

OPTIONS|描述
-------|----
`--security-opt="label:user:USER"`|设置容器的 label 用户
`--security-opt="label:role:ROLE"`|设置容器的 label 角色
`--security-opt="label:type:TYPE"`|设置容器的 label 类型
`--security-opt="label:level:LEVEL"`|设置容器的 label 级别
`--security-opt="label:disable"`|关闭容器的 label 验证
`--security-opt="apparmor:PROFILE"`|设置容器的 apparmor 文件

### 设置自定义 cgroups

OPTIONS|描述
-------|----
`--cgroup-parent=""`|（可选）为容器指定一个 cgroup

这个指令，允许你为创建和管理 cgroups，以及自定义这些 cgroups 的资源。

### 运行时资源限制

OPTIONS|描述
-------|----
`-m --memory=""`|限制内存（格式：`<number>[<unit>]`）。`<number>` 是一个正数，`<unit>` 可以是 `b`、`k`、`m`、`g`。最小是 `4M`。
`--memory-swap=""`|正整数，内存 + 交换空间，`-1` 表示不限制（格式：`<number>[<unit>]`）。`<number>` 是一个正数，`<unit>` 可以是 `b`、`k`、`m`、`g`。
`--memory-reservation=""`|软限制内存（格式：`<number>[<unit>]`）。`<number>` 是一个正数，`<unit>` 可以是 `b`、`k`、`m`、`g`。
`--kernel-memory=""`|限制内核内存（格式：`<number>[<unit>]`）。`<number>` 是一个正数，`<unit>` 可以是 `b`、`k`、`m`、`g`。最小是 `4M`。
`-c --cpu-shares=0`|CPU 占用率（相对权重）
`--cpu-period=0`|限制 CPU CFS （完全公平调度器）的周期
`--cpuset-cpus=""`|允许哪几个 CPU 执行（比如：`0-3`、`0`、`1`） 
`--cpuset-mems=""`|允许哪几个内存节点执行（比如：`0-3`、`0`、`1`）
`--cpu-quota=0`|限制 CPU CFS （完全公平调度器）的配额
`--blkio-weight=0`|块 IO 权重（相对权重）
`--blkio-weight-device=[]`|块 IO 权重（相对权重，格式：`DEVICE_NAME:WEIGHT`）
`--device-read-bps=[]`|限制从设备的读命中（字节/秒）（比如：`--device-read-bps=/dev/sda:1mb`）
`--device-read-iops=[]`|限制从设备的读命中（IO/秒）（比如：`--device-read-iops=/dev/sda:1000`）
`--device-write-bps=[]`|限制从设备的写命中（字节/秒）（比如：`--device-write-bps=/dev/sda:1mb`）
`--device-write-iops=[]`|限制从设备的写命中（IO/秒）（比如：`--device-write-iops=/dev/sda:1000`）
`--oom-kill-disable`|为容器禁用 Linux 的 OOM 终结器
`--memory-swappiness=""`|调节容器的内存交换行为，接受 `0` 到 `100` 的整数
`--shm-size=[]`|*/dev/shm* 的长度

#### 限制内存使用

有四种配置用户内存的方式：

配置|描述
----|----
`memory=inf, memory-swap=inf (default)`|容器没有内存限制，可以使用需要的尽可能多的内存。
`memory=L<inf, memory-swap=inf`|（指定内存，交换置为 `-1`）容器不能超过 `L` 字节内存，但是可以使用尽可能多的交换空间。
`memory=L<inf, memory-swap=2*L`|容器不能超过 `L` 字节内存，交换空间不能超过 `L` 字节内存。
`memory=L<inf, memory-swap=S<inf, L<=S`|容器不能超过 `L` 字节内存，交换空间不能超过 `S-L` 字节内存。

* 例子，不指定内存，容器的进程可以使用尽可能多的内存和交换空间：

  ```sh
  $ docker run -it ubuntu:14.04 /bin/bash
  ``` 

* 例子，容器的进程最多只能用 `300M` 内存，可以用尽可能多的交换空间（如果主机支持交换空间的话）：
  
  ```sh
  $ docker run -it --memory 300M --memory-swap -1 ubuntu:14.04 /bin/bash
  ```

* 例子，只指定内存，容器的进程最多只能用 `300M` 内存和 `300M` 交换空间（如果主机支持交换空间的话）：

  ```sh
  $ docker run -it --memory 300M ubuntu:14.04 /bin/bash
  ```

* 例子，容器的进程最多只能用 `300M` 内存和 `700M` 交换空间（如果主机支持交换空间的话）：

  ```sh
  $ docker run -it --memory 300M --memory-swap 1G ubuntu:14.04 /bin/bash
  ```

默认，如果容器发生内存溢出（out-of-memory）错误，内核会终结进程。`--oom-kill-disable=false` 可以禁用这个行为。

另外，指定 `--oom-kill-disable=false` 时，请一定同时指定 `--memory`；否则，主机内存有可能被耗光。例子：

```sh
$ docker run -it --memory 100M --oom-kill-disable ubuntu:14.04 /bin/bash
```

下面这个例子，没有限制最大内存使用量，容器有可能耗光主机内存：

```sh
$ docker run -it --oom-kill-disable ubuntu:14.04 /bin/bash
```

#### 限制内核内存

内核内存和用户内存完全不同：内核内存不能交换。内核内存包括：

* 栈页
* slab 页
* 套接字内存
* tcp 内存

可以指定内核内存限制，以限制上面的内存使用。通过限制内核内存，当内核使用太多内存时，会阻止它创建新的进程。

内核内存和用户内存不是完全独立的。我们通过用户内存限制来限制内核内存。假设 `U` 是用户内存、`K` 是内核内存，有三种方式来限制：

配置|描述
----|----
`U != 0, K = inf (default)`|标准内存限制方式，内核内存被完全忽略。
`U != 0, K < U`|内核内存是用户内存的子集。
`U != 0, K > U`|对于跟踪内核内存的使用比较有帮助。

```sh
$ docker run -it --memory 500M --kernel-memory 50M ubuntu:14.04 /bin/bash
```

在上面的例子中，容器的进程最多可以使用 `500M` 内存；在这 `500M` 内存中，最多能使用 `50M` 内核内存。

```sh
$ docker run -it --kernel-memory 50M ubuntu:14.04 /bin/bash
```

在上面的例子中，容器的进程可以使用尽可能多的内存；但是，最多能使用 `50M` 内核内存。


#### 限制 CPU 占用率

默认，所有容器获得相同 CPU 周期使用百分比。通过指定权重，可以修改这一百分比。如果设定 `0`，会忽略该值并使用默认值 `1024`。

举个例子：三个容器，一个是 `1024`，另外两个是 `512`。当三个进程都试图占用 100% CPU 时，第一个容器有 `50%` CPU 使用时间。如果加入第四个容器，权重是 `1024`，那么第一个容器有 `33%` CPU 使用时间，剩余的分别有 `16.5%`、`16.5%`、`33%` CPU 使用时间。

在多核系统，CPU 占用时间被分发到多个 CPU 核。甚至在容器少于 100% 占用 CPU 时，也可能有 `100%` CPU 时间。

比如，一个三核系统，如果启动容器 `{C0}` 指定 `--cpu-shares=512` 运行一个进程，启动另一个容器 `{C1}` 指定 `--cpu-shares=1024` 运行两个进程，能够得到如下结果：

```sh
PID    container     CPU CPU share
100    {C0}     0    100% of CPU0
101    {C1}     1    100% of CPU1
102    {C1}     2    100% of CPU2
```

#### 限制 CPU 占用周期

默认的 CPU CFS 周期是 `100ms`，指定 `--cpu-period` 限制容器对 CPU 的使用。通常 `--cpu-period` 应该和 `--cpu-quota` 一起使用：

```sh
$ docker run -it --cpu-period=50000 --cpu-quota=25000 ubuntu:14.04 /bin/bash
```

上面的例子中，如果只有 1 个 CPU，容器每 `50ms` 可以获得 `50%` CPU 资源。

> CFS 负责进程的资源分配，是 Linux 的默认调度器。

#### 限制 CPU 集

我们能为容器设置允许哪些 CPU 执行。例子：

```sh
$ docker run -it --cpuset-cpus="1,3" ubuntu:14.04 /bin/bash
```

上例表示，容器的进程只能使用 CPU 1 和 3。

```sh
$ docker run -it --cpuset-cpus="0-2" ubuntu:14.04 /bin/bash
```

上例表示，容器的进程只能使用 CPU 0、1 和 3。

我们也能为容器设置允许哪些内存执行。例子：

```sh
$ docker run -it --cpuset-mems="1,3" ubuntu:14.04 /bin/bash
```

上例表示，容器的进程只能使用内存 1 和 3。

```sh
$ docker run -it --cpuset-mems="0-2" ubuntu:14.04 /bin/bash
```

上例表示，容器的进程只能使用内存 0、1 和 3。

#### 限制 CPU 配额

`--cpu-quota` 限制 CPU 的使用率。默认值是 `0`，表示容器可以使用 `100%` CPU 资源（1 CPU）。设置为 `50000`，表示限制容器可以使用 `50%` CPU 资源。对于多核 CPU，调整 `--cpu-quota` 是必要的。

#### 限制块 IO 吞吐量

默认，所有容器获得相同块 IO 百分比。通过指定权重，可以修改这一百分比。例子：

```sh
$ docker run -it --name c1 --blkio-weight 300 ubuntu:14.04 /bin/bash
$ docker run -it --name c2 --blkio-weight 600 ubuntu:14.04 /bin/bash
```

> 块 IO 权重只对直接 IO 有效。不支持缓冲 IO。

### 附加组 

OPTIONS|描述
-------|----
`--group-add=[]`|添加额外的组

默认，Docker 容器运行时会从附属组查找用户。如果想加入更多的组，可以这样做：

```sh
$ docker run --rm --group-add audio --group-add nogroup --group-add 777 busybox id
uid=0(root) gid=0(root) groups=10(wheel),29(audio),99(nogroup),777
```

### 运行时特权和 Linux capabilities

OPTIONS|描述
-------|----
`--cap-add=[]`|添加 Linux capabilities
`--cap-drop=[]`|删除 Linux capabilities
`--privileged`|给予容器扩展的特权
`--device=[]`|为容器添加一个主机设备

默认，Docker 容器是非特权的，许多功能并不能执行。比如，在容器中运行一个 Docker 守护进程，这会失败。这是因为，默认，容器不允许访问任何设备。然而，一个拥有了特权的容器，则可以访问任何设备。

指定 `--privileged` 可以让容器拥有特权，能访问主机所有的设备，包括在 AppArmor 或 SELinux 配置参数。

当启用特权后，如果想限定特定设备的访问，指定 `--device`，使得容器只可以访问特定设备：

```sh
$ docker run --device=/dev/snd:/dev/snd ...
```

默认，容器可以读写设备，并且 `mknod` 设备。指定 `:rwm` 可以操纵这一行为：

```sh
$ docker run --device=/dev/sda:/dev/xvdc --rm -it ubuntu fdisk  /dev/xvdc

Command (m for help): q
$ docker run --device=/dev/sda:/dev/xvdc:r --rm -it ubuntu fdisk  /dev/xvdc
You will not be able to write the partition table.

Command (m for help): q

$ docker run --device=/dev/sda:/dev/xvdc:w --rm -it ubuntu fdisk  /dev/xvdc
    crash....

$ docker run --device=/dev/sda:/dev/xvdc:m --rm -it ubuntu fdisk  /dev/xvdc
fdisk: unable to open /dev/xvdc: Operation not permitted
```

### 日志驱动

OPTIONS|描述
-------|----
`--log-driver=""`|指定容器的日志驱动
`--log-opt=[]`|指定容器的日志驱动配置

能为容器指定特定的日志驱动。当前，支持以下日志驱动：

驱动|描述
----|----
none|禁用日志。此时，`docker logs` 无效。
json-file|默认的日志驱动。把日志以 JSON 写入文件。没有任何配置选项。
syslog|把日志写入 Syslog 。
journald|把日志写入 journald 。
gelf|把日志写入 GELF 端点 。
fluentd|把日志写入 fluentd 。
awslogs|把日志写入 Amazon 云日志 。
splunk|把日志写入 splunk。

只有在 `json-file` 和 `journald` 日志驱动下，`docker logs` 命令是可用的。

### 重写 Dockerfile 默认值

开发者编译 Dockerfile 生成镜像后，可以重写一些命令，影响容器的启动。`FROM`、`MAINTAINER`、`RUN`、`ADD` 这几个命令不能被重写。其他的命令，在 `run` 时可以重写。

#### `CMD`

创建镜像的那位，一般会通过 `CMD` 提供默认的 `COMMAND` 命令。启动镜像时指定 `COMMAND` 可以重写该行为。如果镜像还同时指定了 `ENTRYPOINT`，那么 `COMMAND` 追加到 `ENTRYPOINT` 的参数。

#### `ENTRYPOINT`

OPTIONS|描述
-------|----
`--entrypoint=""`|重写镜像默认的 `ENTRYPOINT`

`ENTRYPOINT` 指定执行哪个可执行文件，它比起 `CMD` 更难重写 --- 可执行文件是二进制文件，你可以为其传入参数。当运行容器时可以这样重写：

```sh
$ docker run -it --entrypoint /bin/bash example/redis
```

<span>

```sh
$ docker run -it --entrypoint /bin/bash example/redis -c ls -l
$ docker run -it --entrypoint /usr/bin/redis-cli example/redis --help
```

#### `EXPOSE`

OPTIONS|描述
-------|----
`--expose=[]`|暴露一个范围的端口
`-P --publish-all`|把所有暴露的端口发布为随机端口
`-p --publish=[]`|把容器的一个端口发布给主机
`--link=[]`|链接到另一个容器

这些是用于容器网络工作的命令。

`EXPOSE` 指令为一个镜像提供网络控制，但是还不够多，它只定义了初始的服务端口。只有容器内的进程能使用这些端口。`--expose` 可以添加更多的端口。

`-p` 可以向主机暴露容器的内部端口，以使得主机能通过该端口通过网络访问容器。`—P` 把所有端口发布给主机，Docker 通常为每个端口随机绑定一个主机端口。

容器内的端口号，不需要匹配外部的端口号。比如，容器内部的 HTTP 服务监听 `80` 端口（镜像开发者在 Dockerfile 指定 `EXPOSE 80`），运行时，这个端口可能被绑定到主机的 `42800` 端口。想找出主机端口和容器暴露端口的映射，使用 `docker port`。

`-p` 的格式是：`ip:hostPort:containerPort | ip::containerPort | hostPort:containerPort | containerPort`。比如 `-p 1234-1236:1234-1236/tcp`。例子：

```sh
$ docker run -d -p 80:5000 training/webapp python app.py
```

#### `ENV`

OPTIONS|描述
-------|----
`-e, --env=[]`|设置环境变量

`ENV` 可以为镜像设定环境变量。当新的容器创建时，Docker 自动还会为其设置以下环境变量：

变量|值
----|----
`HOME`|设置基础 `USER` 值
`HOSTNAME`|为容器分配的主机名
`PATH`|包含流行的目录，像：`/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin`
`TERM`|如果容器分配了伪终端，则是 `xterm`

指定一个或多个 `-e` 可以设置更多的环境变量，甚至重写默认的环境变量：

```sh
$ docker run -e "deep=purple" --rm ubuntu /bin/bash -c export
declare -x HOME="/"
declare -x HOSTNAME="85bc26a0e200"
declare -x OLDPWD
declare -x PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
declare -x PWD="/"
declare -x SHLVL="1"
declare -x deep="purple"
```

#### `TMPFS`

OPTIONS|描述
-------|----
--tmpfs|为容器挂载一个 tmpfs 文件系统

例子：

```sh
$ docker run -d --tmpfs /run:rw,noexec,nosuid,size=65536k my_image
```

#### `VOLUME`

OPTIONS|描述
-------|----
`-v, --volume=[host-src:]container-dest[:<options>]`|挂载一个卷
`--volumes-from=[]`|从指定的容器挂载卷

挂载一个卷：

```sh
$ docker run -d -p 80:5000 --name web -v /webapp training/webapp python app.py

$ docker run -d -p 80:5000 --name web -v /src/webapp:/opt/webapp training/webapp python app.py
$ docker run -d -p 80:5000 --name web -v /src/webapp:/opt/webapp:ro training/webapp python app.py

$ docker run --rm -it -v ~/.bash_history:/root/.bash_history ubuntu /bin/bash
```

加载镜像 `training/webapp`，运行一个容器（`web`），指定 `-v` 为 `/webapp` 作为卷挂载点。

你也可以把机器的历史目录作为挂载点（第二行），指定 `-v`，把机器上的 `/src/webapp` 映射到容器卷挂载点 `/opt/webapp`。如果 `/opt/webapp` 已经在容器的镜像中存在，则指向新的目录 `/src/webapp`，旧的文件不会删除。机器目录可以是绝对路径，或一个名字；卷目录必须是绝对路径。此外，卷默认是可读写的。指定 `ro` 可以设为只读。

也可以挂载机器的单个文件，而不是整个目录。比如：把机器的 `~/.bash_history` 挂载给容器的 `/root/.bash_history`，这样在机器和容器同时获得 **bash** 的历史信息。

执行 `inspect`，你能看到卷挂载的信息：

```sh
$ docker inspect web
...
Mounts": [
    {
        "Name": "fac362...80535",
        "Source": "/var/lib/docker/volumes/fac362...80535/_data",  ## 卷在机器上的位置
        "Destination": "/webapp",                                  ## 卷（相对机器位置）挂载点
        "Driver": "local",
        "Mode": "", 
        "RW": true,                                                ## 卷可读写？
        "Propagation": ""
    }
]
...
```

> 也能在 Dockerfile 中指定 `VOLUME` 指令，设定卷挂载点。

<span>

> 挂载点，给予容器访问机器文件系统的能力。

```sh
$ docker run -d --volumes-from dbstore --name db2 training/postgres
```

上例中，加载镜像 `training/postgres`，运行一个容器（`db2`），指定 `--volumes-from` 把卷挂载到容器 `dbstore` 的卷，这样容器之间就能共享数据，也可以完成备份、重载、迁移。可以指定多个 `--volumes-from`，把一个容器的卷挂载到多个容器。例子：

```sh
$ docker create -v /dbdata --name dbstore training/postgres /bin/true ## 容器 dbstore 挂载 /dbdata
$ docker run -d --volumes-from dbstore --name db1 training/postgres   ## 容器 db1 挂载容器 dbstore 的卷
$ docker run -d --volumes-from dbstore --name db2 training/postgres   ## 容器 db2 挂载容器 dbstore 的卷
$ docker run -d --name db3 --volumes-from db1 training/postgres       ## 容器 db3 挂载容器 db1 的卷
```

如果删除容器（包含卷），卷不会被删除。其他容器仍然可以继续使用。显式执行 `$ docker rm -v` 才能从磁盘删除卷。如果你删除容器时没有指定 `-v`，那么卷会成为悬垂的，执行 `$ docker volume ls -f dangling=true` 找出悬垂的卷，然后执行 `docker volume rm <volume name>` 从磁盘删除卷。 

一些例子：

```sh
## 备份，把容器（随机命名）的 /dbdata 压缩到容器  dbstore 的 /backup/backup.tar
$ docker run --rm --volumes-from dbstore -v $(pwd):/backup ubuntu tar cvf /backup/backup.tar /dbdata  

## 重载，把容器（随机命名）的 /backup/backup.tar 解压到容器 dbstore2 的 /dbdata
$ docker run -v /dbdata --name dbstore2 ubuntu /bin/bash
$ docker run --rm --volumes-from dbstore2 -v $(pwd):/backup ubuntu bash -c "cd /dbdata && tar xvf /backup/backup.tar --strip 1"
```

#### `USER`

OPTIONS|描述
-------|----
`-u --user=""`|指定用户名或用户号（格式：`<name|uid>[:<group|gid>]`）

`root` （`id=0`）是容器的默认用户。镜像开发者可以添加更多的用户。指定 `--user` 可以重写用户。

#### `WORKDIR"`

OPTIONS|描述
-------|----
`-w, --workdir=""`|容器内的工作目录

`/` 是容器的默认工作目录。指定 `-w` 可以重写工作目录。

###

## `$ docker exec [OPTIONS] CONTAINER COMMAND [ARG...]`

OPTIONS|描述
-------|----
`-d --detach`|脱离模式：在后端运行
`--detach-keys`|指定“脱离”容器的快捷键
`--help`|打印帮助信息
`-i --interactive`|如果没有连结，保持标准输入打开
`--privileged`|给予容器扩展的特权
`-t --tty`|分配一个伪终端
`-u --user=""`|指定用户名或用户号（格式：`<name｜uid>[:<group｜gid>]`）

`docker exec` 对一个已经运行的容器执行一个新的命令。

如果容器正在暂停状态，那么执行 `docker exec` 命令会失败：

```sh
$ docker pause test
test
$ docker ps
CONTAINER ID  IMAGE          COMMAND  CREATED         STATUS                  PORTS  NAMES
1ae3b36715d2  ubuntu:latest  "bash"   17 seconds ago  Up 16 seconds (Paused)         test
$ docker exec test ls
FATA[0000] Error response from daemon: Container test is paused, unpause the container before exec
$ echo $?
1
```

例子：

```sh
$ docker run --name ubuntu_bash --rm -i -t ubuntu bash
## 将 `ubuntu_bash` 容器运行在后端
$ docker exec -d ubuntu_bash touch /tmp/execWorks
## 将 `ubuntu_bash` 容器运行在前端
$ docker exec -it ubuntu_bash bash
```

## `$ docker attach [OPTIONS] CONTAINER`

OPTIONS|描述
-------|----
`--detach-keys="<sequence>"`|重写 detach （脱离）快捷键功能
`--help`|打印帮助信息
`--no-stdin`|连结的时候，不要连结标准输入
`--sig-proxy=true`|为进程代理所有接收的信号

`docker attach` 命令允许你连结到一个正在运行的容器（通过容器号或容器名），也允许你查看它正在执行的输出，或者与其交互进行控制。你能同时多次连结到同一个容器内的进程 --- 以屏幕共享的方式，或者快速查看进程的进度。

想要停止容器，使用 `CTRL+C`。这个快捷键向容器发送一个 `SIGKILL` 信号。如果 `--sig-proxy` 是 `true` （默认是 `false`），`CTRL+C` 则向容器一个 `SIGINT` 信号。你可以使用 `CTRL+P`、`CTRL+Q` 从容器脱离，并让容器继续运行。

> 注意：在容器内进程号是 `1` 的进程，Linux 会特殊对待 --- 内核会为其忽略任何信号（默认行为）。因此，收到 `SIGINT`、`SIGTERM` 该进程不会终止，除非你编写代码指定它终止。

当用 `docker attach` 连结到一个启用伪终端的容器时（即：以 `-t` 启动），重定向标准输入是禁止的。

### 重写脱离快捷键

如果你想的话，你可以重写 detach （脱离） 的快捷键功能。当你的应用程序和 Docker 快捷键产生冲突时，重写会很有帮助。有两种方法定义你的快捷键：

* 重写单个容器的 detach 快捷键，请使用 `--detach-keys="<sequence>"`。`<sequence>` 是 `[a-Z]` 的字母，或下列与 `ctrl` 的组合：

  * `a-z`
  * `@`
  * `[`
  * `\\`
  * `_`
  * `^`

  举几个例子：`a`、`ctrl+a`、`X`、`ctrl+\\`。

* 重写所有容器的 detach 快捷键，请编辑配置文件。

这儿有个例子，当执行 `docker attach` 时，你能看到 bash 进程返回时的退出码：

```sh
$ docker run --name test -d -it debian
275c44472aebd77c926d4527885bb09f2f6db21d878c75f0a1c212c03d3bcfab
$ docker attach test
$$ exit 13
exit
$ echo $?
13
$ docker ps -a | grep test
275c44472aeb    debian:7    "/bin/bash"    26 seconds ago
Exited (13) 17 seconds ago    test
```

###

## `$ docker create [OPTIONS] IMAGE [COMMAND] [ARG...]`

用镜像创建一个可写的容器层，准备好运行，返回容器号。然后，你能使用 `docker start <container_id>` 运行这个容器。`OPTIONS` 和 `docker run [OPTIONS]` 大部分相同。

## `$ docker rm [OPTIONS] CONTAINER [CONTAINER...]`

OPTIONS|描述
-------|----
`-f --force`|强制删除正在运行的容器（使用 `SIGKILL`）
`--help`|打印帮助信息
`-l --link`|删除指定的链接
`-v --volumes`|删除为容器分配的卷

```sh
$ docker rm $(docker ps -a -q)
```

这条命令删除所用停止的容器。`docker ps -a -q` 会返回所有已经存在的容器号，并将它们传递给 `docker rm`。

```sh
$ docker rm -v redis
redis
```

这条命令删除容器和为容器分配的卷。注意：如果一个卷被指定了名字，这个卷不会被删除：

```sh
$ docker create -v awesome:/foo -v /bar --name hello redis
hello
$ docker rm -v hello
```

在上面的例子，`/foo` 卷会完整保留，而 `/bar` 卷则被删除。`--volumes-from` 设定的卷有相同的行为。

> 一旦你不再需要容器，请删除容器。

## `$ docker wait [OPTIONS] CONTAINER [CONTAINER...]`

OPTIONS|描述
-------|----
`--help`|打印帮助信息

阻塞，直到容器停止，然后打印退出代码。

## `$ docker start [OPTIONS] CONTAINER [CONTAINER...]`

OPTIONS|描述
-------|----
`-a --attach`|脱离模式：在后端运行
`--detach-keys`|指定“脱离”容器的快捷键
`--help`|打印帮助信息
`-i --interactive`|如果没有连结，保持标准输入打开

```sh
$ docker start insane_babbage
insane_babbage
```

告诉 Docker Daemon，启动已经停止的容器 `insane_babbage`。

## `$ docker stop [OPTIONS] CONTAINER [CONTAINER...]`

OPTIONS|描述
-------|----
`--help`|打印帮助信息
`-t --time=10`|先优雅停止，超过这个时间，则强行终止

容器内的进程会收到 `SIGTERM` 信号，如果超出 `--time`，则收到 `SIGKILL` 信号。

## `$ docker kill [OPTIONS] CONTAINER [CONTAINER...]`

OPTIONS|描述
-------|----
`--help`|打印帮助信息
`-s, --signal="KILL"`|发送给容器的信号

使用 `SIGKILL` 或指定的信号强制终止容器。

> 注意：`ENTRYPOINT` 和 `CMD` 中的 `/bin/sh -c` 执行的子命令，不会为其传送任何信号。

## `$ docker restart [OPTIONS] CONTAINER [CONTAINER...]`

OPTIONS|描述
-------|----
`--help`|打印帮助信息
`-t --time=10`|先优雅停止，超过这个时间，则强行终止

告诉 Docker Daemon，停止正在运行的容器，然后重新启动。

## `$ docker stats [OPTIONS] [CONTAINER...]`

OPTIONS|描述
-------|----
`-a --all`|显示所有的容器（默认只包括正在运行的）
`--help`|打印帮助信息
`--no-stream`|禁用流状态，只拉取第一个结果

这条命令返回容器的一个实时数据流。限制数据流来自一个或多个容器，请列出容器的名字或编号（用空格隔开）。你能指定停止的容器，但是不会为停止的容器返回任何数据。

如果你想了解更多容器所使用资源的信息，请使用 `/containers/(id)/stats` API。

* 显示所有运行的容器

  ```sh
  $ docker stats
  CONTAINER     CPU %  MEM USAGE/LIMIT  MEM %   NET I/O         BLOCK I/O
  1285939c1fd3  0.07%  796 KB/64 MB     1.21%   788 B/648 B     3.55 MB/512 KB
  9c76f7834ae2  0.07%  2.746 MB/64 MB   4.29%   1.266 KB/648 B  12.4 MB/0 B
  d1ea048f04e4  0.03%  4.583 MB/64 MB   6.30%   2.854 KB/648 B  27.7 MB/0 B
  ```

* 显示多个容器
 
  ```sh
  $ docker stats fervent_panini 5acfcb1b4fd1
  CONTAINER       CPU %  MEM USAGE/LIMIT    MEM %   NET I/O         BLOCK I/O
  5acfcb1b4fd1    0.00%  115.2 MB/1.045 GB  11.03%  1.422 kB/648 B
  fervent_panini  0.02%  11.08 MB/1.045 GB  1.06%   648 B/648 B
  ```

## `$ docker ps [OPTIONS]`

OPTIONS|描述
-------|----
`-a --all`|显示所有容器（默认只包括正在运行的）
`-f --filter`|过滤输出
`--format`|使用 GO 模板格式化输出
`--help`|打印帮助信息
`-l --last`|显示最新创建的容器（包含所有的状态）
`-n=-1`|显示 `n` 个最新创建的容器（包含所有的状态）
`--no-trunc`|不要截断输出
`-q --quiet`|只显示数字编号
`-s --size`|显示文件尺寸总和

这条命令列出所有正在运行的容器（默认行为）。想要列出全部容器，请使用 `docker ps -a`。

### 过滤器

`-f --filter` 过滤输出，是一个 `key=value` 格式，可以传递多个过滤（比如：`--filter "foo=bar" --filter "bif=baz"`）。

当前支持下列过滤：

* `id=<id>` 容器号
* `label=<key>` 或 `label=<key>=<value>`
* `name=<name>` 容器名
* `exited=<code>` 退出状态吗
* `status=created|restarting|running|paused|exited` 运行状态
* `ancestor=<image-name>[:tag]|<image-id>|<image@digest>` 镜像
* `before=<container-name>|<container-id>` 过滤指定名字或编号创建之前
* `since=<container-name>|<container-id>` 过滤由指定名字或编号创建    

###

## `$ docker inspect [OPTIONS] CONTAINER|IMAGE [CONTAINER|IMAGE...]`

OPTIONS|描述
-------|----
`-f --format=""`|使用 GO 模板格式化输出
`--help`|打印帮助信息
`--type=container｜image`|返回的结果渲染成 JSON 
`-s --size`|如果 `type` 是 `container`，显示全部文件尺寸

返回容器或镜像的底层信息。默认情况下，这条命令把结果渲染成 JSON。

例子，获取一个实例的 IP 地址：

```sh
$ docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $INSTANCE_ID
```

例子，获取一个实例的 MAC 地址：

```sh
$ docker inspect --format='{{range .NetworkSettings.Networks}}{{.MacAddress}}{{end}}' $INSTANCE_ID
```

例子，获取一个实例的日志路径：

```sh
$ docker inspect --format='{{.LogPath}}' $INSTANCE_ID
```

例子，列出所有绑定的端口（循环映射结果）：

```sh
$ docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}} {{$p}} -> {{(index $conf 0).HostPort}} {{end}}' $INSTANCE_ID
```

例子，查找指定的端口映射：

```sh
$ docker inspect --format='{{(index (index .NetworkSettings.Ports "8787/tcp") 0).HostPort}}' $INSTANCE_ID
```

例子，获取一个子内容：

```sh
$ docker inspect --format='{{json .Config}}' $INSTANCE_ID
```

## `$ docker logs [OPTIONS] CONTAINER`

OPTIONS|描述
-------|----
`-f --follow`|日志输出
`--help`|打印帮助信息
`--since="" `|显示日志（从指定的时间戳开始）
`-t, --timestamps`|显示时间戳
`--tail="all"`|显示日志行数

检索容器的日志信息。例子：

```sh
$ docker logs insane_babbage
hello world
hello world
hello world
. . .
```

例子，显示容器 `nostalgic_morse` 的标准输出的尾部内容：

```sh
$ docker logs -f nostalgic_morse
* Running on http://0.0.0.0:5000/
10.0.2.2 - - [23/May/2014 20:16:31] "GET / HTTP/1.1" 200 -
10.0.2.2 - - [23/May/2014 20:16:31] "GET /favicon.ico HTTP/1.1" 404 -
```

`--timestamps` 会为每一项添加一个时间戳，比如 `2014-09-16T06:17:46.000000000Z`。`--since` 只显示指定日期后的日志，格式：`2006-01-02T15:04:05`、`2006-01-02T15:04:05.999999999`、`2006-01-02Z07:00`、`2006-01-02`（UNIX 时间戳）。

## `$ docker port [OPTIONS] CONTAINER [PRIVATE_PORT[/PROTO]]`

OPTIONS|描述
-------|----
`--help`|打印帮助信息

列出容器 `CONTAINER` 的端口映射、或对应私有端口的公共端口：

```sh
$ docker ps
CONTAINER ID  IMAGE        .  PORTS
b650456536c7  busybox:1.0  .  0.0.0.0:1234->9876/tcp, 0.0.0.0:4321->7890/tcp

$ docker port test
7890/tcp -> 0.0.0.0:4321
9876/tcp -> 0.0.0.0:1234

$ docker port test 7890/tcp
0.0.0.0:4321

$ docker port test 7890/udp
2014/06/24 11:53:36 Error: No public port '7890/udp' published for test

$ docker port test 7890
0.0.0.0:4321
```

## `$ docker top [OPTIONS] CONTAINER [ps OPTIONS]`

OPTIONS|描述
-------|----
`--help`|打印帮助信息

列出容器中正在运行的进程：

```sh
$ docker top nostalgic
PID    USER    COMMAND
854    root    python app.py
```

## `$ docker cp [OPTIONS] SRC_PATH DEST_PATH` 

OPTIONS|描述
-------|----
`-L, --follow-link`|总是跟随 `SRC_PATH` 的符号链接
`--help`|打印帮助信息

在容器和机器文件系统之间复制文件。你能把 `SRC_PATH` 的内容复制到 `DEST_PATH`。既能从容器的文件系统复制到机器，也能从机器的文件系统复制到容器。

## `$ docker network ls [OPTIONS]`

OPTIONS|描述
-------|----
`-f --filter=[]`|过滤输出
`--help`|打印帮助信息
`--no-trunc`|不要截断输出
`-q --quiet`|只显示数字号，不显示其他信息

列出所有 Docker Daemon 已知的网络。包括集群（跨多个主机）的网络，比如： 

```sh
$ sudo docker network ls
NETWORK ID          NAME              DRIVER
7fca4eb8c647        bridge            bridge
9f904ee27bf5        none              null
cf03ee007fb4        host              host
78b03ee04fc4        multi-host        overlay
```

使用 `--no-trunc` 显示所有的网络号：

```sh
docker network ls --no-trunc
NETWORK ID                                                        NAME    DRIVER
18a2866682b85619a026c81b98a5e375bd33e1b0936a26cc497c283d27bae9b3  none    null 
c288470c46f6c8949c5f7e5099b5b7947b07eabe8d9a27d79a9cbf111adcbf47  host    host 
7b369448dccbf865d397c8d2be0cda7cf7edc6b0945f77d2529912ae917a0185  bridge  bridge
95e74588f40db048e86320c6526440c504650a1ff3e9f7d60a497c4d2163e5bd  foo     bridge
63d1ff1f77b07ca51070a8c227e962238358bd310bde1529cf62e6c307ade161  dev     bridge
```

### 过滤器

过滤标志位（`-f --filter=[]`），是一个键值对格式 `key=value`。如果多于一个过滤，可以传递多个，多个过滤用 OR 组合（比如：`-f type=custom -f type=builtin` 返回 `custom` 和 `builtin` 网络）。

当前支持的过滤器有：

* `id` 

  匹配指定的网络号。下面这个例子，返回网络号是 `63d1ff1f77b0...` 的网络：

  ```sh
  $ docker network ls --filter id=63d1ff1f77b07ca51070a8c227e962238358bd310bde1529cf62e6c307ade161
  NETWORK ID          NAME        DRIVER
  63d1ff1f77b0        dev         bridge
  ```

  你也可以只指定部分网络号：

  ```sh
  $ docker network ls --filter id=95e74588f40d
  NETWORK ID          NAME        DRIVER
  95e74588f40d        foo         bridge

  $ docker network ls --filter id=95e
  NETWORK ID          NAME        DRIVER
  95e74588f40d        foo         bridge
  ```

* `name`

  匹配网络名。下面这个例子，返回网络名是 `foobar` 的网络：

  ```sh
  $ docker network ls --filter name=foobar
  NETWORK ID          NAME        DRIVER
  06e7eef0a170        foobar      bridge
  ```

  你也可以只指定部分网络名：

  ```sh
  $ docker network ls --filter name=foo
  NETWORK ID          NAME        DRIVER
  95e74588f40d        foo         bridge
  06e7eef0a170        foobar      bridge
  ```

* `type`

  只支持两个值：`builtin` 显示所有预定义的网络（`bridge`、`none`、`host`），`custom` 显示所有用户定义的网络。下面这个例子，返回用户定义的网络：

  ```sh
  $ docker network ls --filter type=custom
  NETWORK ID          NAME         DRIVER
  95e74588f40d        foo          bridge
  63d1ff1f77b0        dev          bridge
  ```

  此外，通过这个标志位还能执行批量清除。比如，使用这个过滤器删除所有用户定义的网络：

  ```sh
  $ docker network rm `docker network ls --filter type=custom -q`
  ```

  当试图删除一个正处于连结的容器时，会发出一个警告。

###

## `$ docker network inspect [OPTIONS] NETWORK [NETWORK..]`

OPTIONS|描述
-------|----
`-f --format=`|使用给定的模板格式化输出
`--help`|打印帮助信息

返回一个或多个网络的信息。默认情况下，这条命令把所有结果渲染成 JSON 对象。比如，连接两个容器到默认的 `bridge` 网络：

```sh
$ sudo docker run -itd --name=container1 busybox
f2870c98fd504370fb86e59f32cd0753b1ac9b69b7d80566ffc7192a82b3ed27

$ sudo docker run -itd --name=container2 busybox
bda12f8922785d1f160be70736f26c1e331ab8aaf8ed8d56728508f2e2fd4727
```

`network inspect` 命令在结果中显示了含有的容器（通过容器号）：

```sh
$ sudo docker network inspect bridge
[
    {
        "Name": "bridge",
        "Id": "b2b1a2cba717161d984383fd68218cf70bbbd17d328496885f7c921333228b0f",
        "Scope": "local",
        "Driver": "bridge",
        "IPAM": {
            "Driver": "default",
            "Config": [
                {
                    "Subnet": "172.17.42.1/16",
                    "Gateway": "172.17.42.1"
                }
            ]
        },
        "Containers": {
            "bda12f8922785d1f160be70736f26c1e331ab8aaf8ed8d56728508f2e2fd4727": {
                "Name": "container2",
                "EndpointID": "0aebb8fcd2b282abe1365979536f21ee4ceaf3ed56177c628eae9f706e00e019",
                "MacAddress": "02:42:ac:11:00:02",
                "IPv4Address": "172.17.0.2/16",
                "IPv6Address": ""
            },
            "f2870c98fd504370fb86e59f32cd0753b1ac9b69b7d80566ffc7192a82b3ed27": {
                "Name": "container1",
                "EndpointID": "a00676d9c91a96bbe5bcfb34f705387a33d7cc365bac1a29e4e9728df92d10ad",
                "MacAddress": "02:42:ac:11:00:01",
                "IPv4Address": "172.17.0.1/16",
                "IPv6Address": ""
            }
        },
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        }
    }
]
```

返回用户自定义网络的信息：

```sh
$ docker network create simple-network
69568e6336d8c96bbf57869030919f7c69524f71183b44d80948bd3927c87f6a
$ docker network inspect simple-network
[
    {
        "Name": "simple-network",
        "Id": "69568e6336d8c96bbf57869030919f7c69524f71183b44d80948bd3927c87f6a",
        "Scope": "local",
        "Driver": "bridge",
        "IPAM": {
            "Driver": "default",
            "Config": [
                {
                    "Subnet": "172.22.0.0/16",
                    "Gateway": "172.22.0.1/16"
                }
            ]
        },
        "Containers": {},
        "Options": {}
    }
]
```

## `$ docker network create [OPTIONS] NETWORK-NAME`

OPTIONS|描述
-------|----
`--aux-address=map[]`|指定网络驱动使用的辅助 IPv4 或 IPv6 地址
`-d --driver=DRIVER`|指定管理网络的驱动：`bridge` 或 `overlay`。默认值是 `bridge`。
`--gateway=[]`|指定管理子网络的 IPv4 或 IPv6 网关
`--help`|打印帮助信息
`--internal`|禁止外界访问网络
`--ip-range=[]`|从一个范围为容器分配 IP 地址
`--ipam-driver=default`|指定 IP 地址的管理驱动
`--ipam-opt=map[]`|设置自定义 IPAM 驱动的特定选项
`-o --opt=map[]`|设置自定义驱动的特定选项
`--subnet=[]`|指定子网络

创建一个新的网络。指定 `--driver=DRIVER`，通过内置的 `bridge` 或 `overlay` 网络驱动，来创建一个新的网络。如果安装了第三方网络驱动，也可以以此创建新的网络。如果没有指定 `--driver`，则自动创建一个 `bridge` 网络。当你安装 Docker Engine 时，自动为你创建一个 `bridge` 网络。这个网络对应 `docker0` 桥（传统上，Docker Engine 依赖这个 `bridge` 网络）。当 `docker run` 启动一个新容器时，容器自动连接到这个 `bridge` 网络。你不能删除这个默认的 `bridge` 网络，但是你能创建一个新的网络：

```sh
$ docker network create -d bridge my-bridge-network
```

在单个 Docker Engine 安装场景，桥网络是隔离网络。如果你想创建一个跨多个主机、每个主机运行一个 Docker Engine 的网络，你必须创建一个 `overlay` 网络。和 `bridge` 网络不同，在创建 `overlay 网络之前，需要一些预先准备的条件。这些条件是：

* 一个键值对存储系统。Docker Engine 支持 Consul、Etcd、ZooKeeper（分布式存储） 这些键值对存储系统。

* 连接到键值对存储系统的主机集群。

* 在集群的每台主机，配有一个 Docker Engine 的 daemon，并正确对其配置。

在 `overlay 网络上的 Docker Daemon，其配置项支持：

* `--cluster-store`
* `--cluster-store-opt`
* `--cluster-advertise` 

有一个好的选择，（尽管不是必需的），就是安装 Docker Swarm 来管理你的集群，以及架设网络。Swarm 提供精细的探测和服务器管理，协助你实现集群。

一旦你准备好 `overlay` 网络所需要的，你只需要简单的在集群中选择一个 Docker 主机，然后发出下面的命令来创建 `overlay` 网络：

```sh
$ docker network create -d overlay my-multihost-network
```

网络名字必须是唯一的。Docker Daemon 会尝试鉴定命名没有冲突，不过这个可没法保证一定稳妥。避免命名冲突，由用户来负责。

### 连接容器

下面这个例子，启动容器 `busybox`，指定 `--net` 连接到 `mynet` 网络：

```sh
$ docker run -itd --net=mynet busybox
```

如果容器已经启动后，你想把容器加入到某个网络，请使用 `docker network connect` 命令。

你可以把多个容器连接到同一个网络。一旦连接，容器之间可以通过容器的 IP 地址或名字通信。对于 `overlay` 网络或支持多主机连接的自定义插件网络，容器连接到同一个多主机网络，但是它们由不同的 Docker Engine 启动（`bridge` 网络的容器必须位于同一个 Docker Engine，也意味着它们必须位于同一个主机）。

想把容器从网络断开连接，请使用 `docker network disconnect` 命令。

### 指定高级配置

当你创建一个网络时，默认情况下，Docker Engine 为该网络创建一个非重叠子网络。这个子网络并非某个现有网络的分支。它的目的纯粹是为了 IP 定位。你能重写这个默认行为，并且使用 `--subnet` 直接指定子网络的值。在一个 `bridge` 网络，你只能创建单个子网络：

```sh
$ docker network create -d --subnet=192.168.0.0/16
```

此外，你也能指定 `--gateway`、`--ip-range`、`--aux-address`：

```sh
$ docker network create --driver=bridge            \
                        --subnet=172.28.0.0/16     \
                        --ip-range=172.28.5.0/24   \
                        --gateway=172.28.5.254 
                        br0
```

假如你忽略了 `--gateway`，Docker Engine 会为你从预选池中选择一个。对于支持 `--gateway` 的 `overlay` 网络和插件驱动网络，你能创建多个子网络：

```sh
$ docker network create -d overlay                                \
         --subnet=192.168.0.0/16 --subnet=192.170.0.0/16          \
         --gateway=192.168.0.100 --gateway=192.170.0.100          \
         --ip-range=192.168.1.0/24                                \
         --aux-address a=192.168.1.5 --aux-address b=192.168.1.6  \
         --aux-address a=192.170.1.5 --aux-address b=192.170.1.6  \
         my-multihost-network
```

一定要确定你的子网络没有重叠。否则，网络创建失败，Docker Engine 返回一个错误。

### 桥驱动配置

当创建自定义网络时，默认的网络驱动（即：`bridge`）有额外的选项可以指定。下面的表格列出了这些选项，它们等价于用于 Docker Daemon 的 `docker0` 桥的标志位：

选项|等价于|描述
----|----|----
`com.docker.network.bridge.name`|`-`|当创建 Linux 桥时用的桥名字
`com.docker.network.bridge.enable_ip_masquerade`|`--ip-masq`|启用 IP 伪装
`com.docker.network.bridge.enable_icc`|`--icc`|启用或禁用跨容器连接
`com.docker.network.bridge.host_binding_ipv4`|`--ip`|绑定容器端口时，使用的默认 IP
`com.docker.network.mtu`|`--mtu`|设置容器网络 MTU
`com.docker.network.enable_ipv6`|`--ipv6`|启用 IPv6 网络

举个例子，使用 `-o` 或 `--opt`，设定 IP 地址绑定：当发布端口时，自动绑定一个 IP 地址：

```sh
$ docker network create                                         \
  -o "com.docker.network.bridge.host_binding_ipv4"="172.19.0.1" \
  simple-network
```

### 隔离外界

默认情况下，当你把容器连接到一个 `overlay` 网络时，Docker 也把它连接到一个 `bridge` 网络以提供外部连接。如果你想创建一个与外部隔离的 `overlay` 网络，请使用 `--internal`。

###

## `$ docker network connect [OPTIONS] NETWORK CONTAINER`

OPTIONS|描述
-------|----
`--alias=[]`|为容器添加网络范围内的别名
`--help`|打印帮助信息
`--ip`|指定 IPv4 地址
`--ip6`|指定 IPv6 地址
`--link=[]`|链接到另一个容器

把一个容器连接到一个网络。你能用容器号或名字来连接。一旦连接，容器之间在同一个网络通信：

```sh
$ docker network connect multi-host-network container1
```

你也能用 `docker run --net=<network-name>` 启动一个容器，这会立刻连接到指定的网络：

```sh
$ docker run -itd --net=multi-host-network busybox
```

你能为容器的网口指定想要赋予的 IP 地址：

```sh
$ docker network connect --ip 10.10.36.122 multi-host-network container2
```

你能用 `--link` 通过别名链接另一个容器：

```sh
$ docker network connect --link container1:c1 multi-host-network container2
```

`--alias` 能用来为容器在网络上赋予另一个别名（帮助网络名解析）：

```sh
$ docker network connect --alias db --alias mysql multi-host-network container2
```

你能暂停、重启、停止连接到网络的容器。暂停的容器仍然连接到网络，能被 `docker network inspect` 探测到。当容器停止时，它不会出现在网络上，直到重新启动。

如果指定的话，当容器停止后再次启动，容器的 IP 地址可以重新使用。如果这个 IP 地址不再可用，容器启动会失败。保证 IP 地址可用的一个法子是：当创建一个网络时，指定 `--ip-range`，并且从这个范围外选择静态 IP 地址。这能确保当该容器不在网络时，其 IP 地址不会被分配给其他容器：

```sh
$ docker network create --subnet 172.20.0.0/16      \
                        --ip-range 172.20.240.0/20  \ 
                        multi-host-network
```

<span>

```sh
$ docker network connect --ip 172.20.128.2 multi-host-network container2
```

想要验证容器是否正在连接，请使用 `docker network inspect` 命令。想要把容器从网络删除，请使用 `docker network disconnect` 命令。

容器一旦连接到网络，只能与其他容器的 IP 地址或名字通信。对于 `overlay` 网络或支持多主机的插件网络，容器连接到同一个多主机网络通信，但是它们是由不同的 Docker Engine 启动的。

你能把容器连接到一个或多个网络。这些网络不必是同一种类型。比如，你能把容器同时连接到 `bridge` 网络和 `overlay` 网络。

两个容器通过网络通信的例子：

```sh
## 加载镜像 `training/postgres`，运行一个容器（`db`），作为守护进程，指定网络 `my-bridge-network`：
$ docker run -d --net=my-bridge-network --name db training/postgres    

## 查看容器 `db` 的配置信息和状态信息（JSON 格式） --- 网络：
$ docker inspect --format='{{json .NetworkSettings.Networks}}'  db
{"my-bridge-network":{"NetworkID":"7d86d31b1478e7cca9ebed7e73aa0fdeec46c5ca29497431d3007d2d9e15ed99",
"EndpointID":"508b170d56b2ac9e4ef86694b0a76a22dd3df1983404f7321da5649645bf7043","Gateway":"172.18.0.1","IPAddress":"172.18.0.2","IPPrefixLen":16,"IPv6Gateway":"","GlobalIPv6Address":"","GlobalIPv6PrefixLen":0,"MacAddress":"02:42:ac:11:00:02"}}    

## 加载镜像 `training/webapp`，运行一个容器（`web`），作为守护进程，执行命令 `python app.py`：
$ docker run -d --name web training/webapp python app.py

## 查看容器 `db` 的配置信息和状态信息（JSON 格式） --- 网络：
$ docker inspect --format='{{json .NetworkSettings.Networks}}'  web
{"bridge":{"NetworkID":"7ea29fc1412292a2d7bba362f9253545fecdfa8ce9a6e37dd10ba8bee7129812",
"EndpointID":"508b170d56b2ac9e4ef86694b0a76a22dd3df1983404f7321da5649645bf7043","Gateway":"172.17.0.1","IPAddress":"172.17.0.2","IPPrefixLen":16,"IPv6Gateway":"","GlobalIPv6Address":"","GlobalIPv6PrefixLen":0,"MacAddress":"02:42:ac:11:00:02"}}

## 查看容器 `web` 的配置信息和状态信息（JSON 格式） --- IPv4 地址：
$ docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' web
172.17.0.2

## 连接容器 `db` 的 **Shell**，`ping` 容器 `web` 的 IPv4 地址 `172.17.0.2` （在 `bridge` 网络）。结果失败，原因：容器 `db` 和 容器 `web` 位于不同的网络 `my-bridge-network` 和 `bridge`：
$ docker exec -it db bash
root@a205f0dd33b2:/# ping 172.17.0.2
ping 172.17.0.2
PING 172.17.0.2 (172.17.0.2) 56(84) bytes of data.
^C
--- 172.17.0.2 ping statistics ---
44 packets transmitted, 0 received, 100% packet loss, time 43185ms

## 为容器 `web` 添加网络 `my-bridge-network` --- 一个容器可以运行在多个网络，你可以为其添加多个网络：
$ docker network connect my-bridge-network web

## 连接容器 `db` 的 **Shell**，`ping` 容器 `web` 的 IPv4 地址 `172.18.0.3` （在 `my-bridge-network` 网络）：
$ docker exec -it db bash
root@a205f0dd33b2:/# ping web
PING web (172.18.0.3) 56(84) bytes of data.
64 bytes from web (172.18.0.3): icmp_seq=1 ttl=64 time=0.095 ms
64 bytes from web (172.18.0.3): icmp_seq=2 ttl=64 time=0.060 ms
64 bytes from web (172.18.0.3): icmp_seq=3 ttl=64 time=0.066 ms
^C
--- web ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2000ms
rtt min/avg/max/mdev = 0.060/0.073/0.095/0.018 ms
```

###

## `$ docker network disconnect [OPTIONS] NETWORK CONTAINER`

OPTIONS|描述
-------|----
`-f --force`|强制容器从网络断开
`--help`|打印帮助信息

把容器从网络断开连接。容器必须正在运行，并且在该网络上：

```sh
$ docker network disconnect multi-host-network container1
```

> 不能从网络 `bridge` 中断开容器 `bridge` 的连接 --- 这是内置的。

## `$ docker network rm [OPTIONS] NETWORK [NETWORK...]`

OPTIONS|描述
-------|----
`--help`|打印帮助信息

通过名字或识别符删除一个或多个网络。想要删除一个网络，你必须先把该网络的所有容器断开连接：

```sh
$ docker network rm my-network
```

想要在单个 `docker network rm` 命令删除多个网络，请提供多个网络名或网络号：

```sh
$ docker network rm 3695c422697f my-network
```

当你指定多个网络时，这条命令尝试挨个删除。如果有一个删除失败，这条命令会继续删除下一个。另外，这条命令会为每条删除报告成功或错误消息。

## `$ docker-machine ip`

如果你的 **docker** 位于一个虚拟机之内，这条命令可以显示该虚拟机的 IP 地址：

```sh
$ docker-machine ip my-docker-vm
192.168.99.100
```
