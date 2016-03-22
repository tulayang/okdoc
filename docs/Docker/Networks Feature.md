# [网络功能](https://docs.docker.com/engine/userguide/networking/)

本章描述如何使用 Docker 的网络功能。网络功能允许用户定义自己的网络，然后把容器连接到网络上。使用这项功能，你能创建一个网络（既可以在单个主机上，也可以在跨多个主机的网络上）。

## 默认的桥网络

当你安装 Docker Engine 的时候，会安装一个默认的网络 --- bridge （桥）。

## 和外部世界通信

一个容器能否和外界对话，由两个因素决定：

* 主机（机器）是否转发它的 IP 包？
* 主机的 `iptables` 是否允许这种特殊的连接？

IP 包转发由系统参数 `ip_forward` 限定。如果这个参数是 `1`，则包只可以在容器之间传输。通常你会简单的让 Docker 服务器使用默认值 `--ip-forward=true`，然后，当服务器启动时，Docker 会为你设置 `ip_forward` 为 `1`。假如你现在设置 `--ip-forward=false`，但是你的系统内核早已经启用，那么这次设置 `--ip-forward=false` 没有什么作用。检查下内核的设置，然后手动转换一下：

```sh
$ sysctl net.ipv4.conf.all.forwarding
net.ipv4.conf.all.forwarding = 0
$ sysctl net.ipv4.conf.all.forwarding=1
$ sysctl net.ipv4.conf.all.forwarding
net.ipv4.conf.all.forwarding = 1
```

大多数使用 Docker 的场景，会需要 `ip_forward` 启用，这样在容器和外界之间可以通信。如果你在一个多桥环境，可能也需要在容器之间通信。

当 Docker 守护进程启动时，如果你设置 `--iptables=false`，那么 Docker 绝对不会改变你系统的 `iptables` 规则。否则，Docker 服务器会把转发规则追加到 `DOCKER` 过滤项。

Docker 不会修改或删除任何在 `DOCKER` 过滤项已经存在的规则。这使得用户可以创建更高级的规则，以限制对容器的访问。

默认，Docker 的转发规则允许所有的外部 IP 源。想要限定容器只接受指定 IP 或网络的访问，在 `DOCKER` 过滤项顶部插入一条否定规则。比如，想要限定外部访问，只允许 IP 8.8.8.8 访问容器，那么加入下列规则：

```sh
$ iptables -I DOCKER -i ext_if ! -s 8.8.8.8 -j DROP
```

## 在容器之间通信

两个容器是否能通信，由两个因素决定（操作系统层级）：

* 网络拓扑是否连通容器的网络接口？默认，Docker 把所有的容器连结到一个 `docker0` 桥，提供它们传输包的路径。
* 你的 `iptables` 是否允许这种特殊的连接？当 Docker 守护进程启动时，如果你设置 `--iptables=false`，那么 Docker 绝对不会改变你系统的 `iptables` 规则。Otherwise the Docker server will add a default rule to the `FORWARD` chain with a blanket `ACCEPT` policy if you retain the default `--icc=true`, or else will set the policy to `DROP` if `--icc=false`。

. . .

## 把容器端口绑定到主机

这里讲述了使用 Docker 默认的桥绑定容器端口。`bridge` 网络是默认网络，当安装 Docker 时自动创建。

默认，Docker 容器能连接到外部世界，但是外部世界不能连接容器。每个外来连接，都假装是主机（机器）自己的 IP 地址 --- 基于主机（机器） `iptables` 的替代规则。Docker 服务器启动时会创建：

```sh
$ sudo iptables -t nat -L -n
...
Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination
MASQUERADE  all  --  172.17.0.0/16       0.0.0.0/0
...
```

Docker 服务器创建一个替代规则，让容器连接到外部世界的 IP 地址。

如果你想要容器接受外部世界的连接，需要在 `docker run` 时提供指定的选项。

