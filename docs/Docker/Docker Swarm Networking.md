# [搭建 Swarm cluster 的网络](https://docs.docker.com/v1.9/swarm/networking/)

Docker Swarm 完全兼容 Docker 网络功能。在 Swarm cluster 中建立 overlay 网络后，容器之间就能跨主机进行通信。

## 在 Swarm cluster 创建一个用户网络

多主机网络需要一个 key-value 存储。这个存储用来保存网络状态，包括探测、网络、进入点、IP 地址、... 。通过 Docker libkv project，Docker 支持 Consul、Etcd、ZooKeeper 等 key-value 存储后端。关于这些支持后端的细节，[请参看 libkv project](https://github.com/docker/libkv)。

为了创建一个用户网络，你必须选择一个 key-value 存储后端，并且部署在你的网络。然后，配置 Docker Engine daemon 来使用这个存储。你会需要两个标志位 `--cluster-store` 和 `--cluster-advertise` 来关联你的 key-value 存储服务器。

一旦你在每个 Swarm 节点配置并且重新启动 Docker Engine daemon，那么你就准备好了创建一个网络。

## 列出所有网络

```sh
$ docker network ls
NETWORK ID          NAME                   DRIVER
3dd50db9706d        node-0/host            host
09138343e80e        node-0/bridge          bridge
8834dbd552e5        node-0/none            null
45782acfe427        node-1/host            host
8926accb25fd        node-1/bridge          bridge
6382abccd23d        node-1/none            null
```

在这个例子中，每个网络名字前面都有一个节点名字的前缀。

## 创建一个网络

默认情况下，Swarm 使用 overlay 网络驱动 --- 一个全局作用域的网络，跨越整个 Swarm cluster。在 Swarm 环境下创建一个 overlay 网络时，可以省略 `-d` 标志位：

```sh
$ docker network create swarm_network
42131321acab3233ba342443Ba4312

$ docker network ls
NETWORK ID          NAME                   DRIVER
3dd50db9706d        node-0/host            host
09138343e80e        node-0/bridge          bridge
8834dbd552e5        node-0/none            null
42131321acab        node-0/swarm_network   overlay
45782acfe427        node-1/host            host
8926accb25fd        node-1/bridge          bridge
6382abccd23d        node-1/none            null
42131321acab        node-1/swarm_network   overlay
```

如你所看到的，`node-0/swarm_network` 和 `node-1/swarm_network` 有相同的 ID。这是因为当你在 Swarm cluster 创建一个网络时，这个网络对所有节点都是可访问的。

想要创建一个本机作用域的网络（比如通过 bridge 网络驱动创建），你应该用 `<node>/<name>`，否则你创建的网络会分配到一个随机节点：

```sh
$ docker network create node-0/bridge2 -b bridge
921817fefea521673217123abab223

$ docker network create node-1/bridge2 -b bridge
5262bbfe5616fef6627771289aacc2

$ docker network ls
NETWORK ID          NAME                   DRIVER
3dd50db9706d        node-0/host            host
09138343e80e        node-0/bridge          bridge
8834dbd552e5        node-0/none            null
42131321acab        node-0/swarm_network   overlay
921817fefea5        node-0/bridge2         brige
45782acfe427        node-1/host            host
8926accb25fd        node-1/bridge          bridge
6382abccd23d        node-1/none            null
42131321acab        node-1/swarm_network   overlay
5262bbfe5616        node-1/bridge2         bridge
```

## 删除一个网络

想要删除一个网络，你可以指定其 ID 或名字。如果两个不同的网络有相同的名字，那么你应该指定其所在节点 `<node>/<name>`：

```sh
$ docker network rm swarm_network
42131321acab3233ba342443Ba4312

$ docker network rm node-0/bridge2
921817fefea521673217123abab223

$ docker network ls
NETWORK ID          NAME                   DRIVER
3dd50db9706d        node-0/host            host
09138343e80e        node-0/bridge          bridge
8834dbd552e5        node-0/none            null
45782acfe427        node-1/host            host
8926accb25fd        node-1/bridge          bridge
6382abccd23d        node-1/none            null
5262bbfe5616        node-1/bridge2         bridge
```

在这个例子中，`swarm_network` 从所有节点删除，`bridge2` 只从 `node-0` 删除。

