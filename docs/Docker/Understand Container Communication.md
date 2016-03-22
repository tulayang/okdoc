# [理解容器通信](https://docs.docker.com/v1.9/engine/userguide/networking/default_network/container-communication/)

## 和外部世界通信

容器能否和外部世界通信，由两个因素决定：

* 主机（机器）是否转发它的 IP 包？
* 主机的 `iptables` 是否允许这种特殊的连接？

IP 包转发由系统参数 `ip_forward` 限定。如果这个参数是 `1`，则包只可以在容器之间传输。通常，你会简单的让 Docker daemon 使用默认配置值 `--ip-forward=true`，然后，当启动时 Docker 会为你把系统参数 `ip_forward` 设置为 `1`。假如你设置 `--ip-forward=false`，但是你的系统内核早已经启用，那么这次设置 `--ip-forward=false` 没有什么作用。检查下你的内核设置，然后手动转换一下：

```sh
$ sysctl net.ipv4.conf.all.forwarding
net.ipv4.conf.all.forwarding = 0
$ sysctl net.ipv4.conf.all.forwarding=1
$ sysctl net.ipv4.conf.all.forwarding
net.ipv4.conf.all.forwarding = 1
```

大多数使用 Docker 的场景，会需要启用 `ip_forward` ，这样在容器和外界可以通信。如果你在一个多桥环境，可能也需要它启用，以便在容器之间通信。

当 Docker daemon 启动时，如果你设置 `--iptables=false`，Docker 绝对不会改变你系统的 `iptables` 规则。否则，Docker  daeon 会把转发规则追加到 `DOCKER` 过滤项。

Docker 不会修改或删除任何在 `DOCKER` 过滤项已经存在的规则。这使得用户可以创建更高级的规则，以限制对容器的访问。

默认，Docker 的转发规则允许所有的外部 IP 源。想要限定容器只接受指定 IP 或网络的访问，在 `DOCKER` 过滤项顶部插入一条否定规则。比如，想要限定外部访问，只允许 IP 8.8.8.8 访问容器，那么加入下列规则：

```sh
$ iptables -I DOCKER -i ext_if ! -s 8.8.8.8 -j DROP
```

## 容器之间通信

两个容器是否能通信，由两个因素决定（操作系统层级）：

* 网络拓扑是否连通容器的网络接口？默认，Docker 把所有的容器连结到一个 `docker0` 桥，提供它们传输包的路径。

* 你的 `iptables` 是否允许这种特殊的连接？当 Docker 守护进程启动时，如果你设置 `--iptables=false`，那么 Docker 绝对不会改变你系统的 `iptables` 规则。Otherwise the Docker server will add a default rule to the `FORWARD` chain with a blanket `ACCEPT` policy if you retain the default `--icc=true`, or else will set the policy to `DROP` if `--icc=false`。

. . .