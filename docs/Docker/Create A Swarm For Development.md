# [创建一个 Swarm](https://docs.docker.com/v1.9/swarm/install-manual/)

## 必备条件

你会在其中一个主机（称为 Swarm manager，或者 Swarm cluster manager）上安装 Docker Swarm。你会创建 Swarm cluster，这个集群中的每个节点都必须：

* 打开一个 TCP 端口监听 Swarm cluster manager，以使 Swarm cluster manager 能通过网络访问它

* 安装 Docker Engine 1.6.0+

* 不能用虚拟机镜像的方式制作它的多个副本

Docker Engine 会在 */etc/docker/key.json* 文件生成一个唯一的 Engine ID。如果你用虚拟机来重建 Docker Engine 主机，这会造成一些解析冲突（有多个 Engine ID 相同了）。

你能在 Linux 64 位架构运行 Docker Swarm。

## 拉取 swarm 镜像，创建一个 cluster

```sh
$ docker pull swarm
$ docker run --rm swarm create
6856663cdefdec325839a4b7e1de38e8
```

这条命令会从 Docker Hub 拉取 `swarm` 镜像，然后运行一个容器，执行 `create` 命令来创建一个唯一的 cluster ID `6856663cdefdec325839a4b7e1de38e8`。这个 cluster ID 即是基于 Docker Hub 作为探测服务所用的访问号（token）。

## 加入 Swarm 节点

每个 Swarm 节点会运行一个 Swarm 节点代理。这些代理注册相关的 Docker daemon，并且进行管理，并且负责更新节点在探测服务的状态。

这个例子使用  Docker Hub 作为探测服务（只能用于测试、开发环境，请不要用于生产环境）。登录到每个节点，然后：

1. 启动 Docker daemon，指定 `-H` 确保 TCP 和 Unix Domain Socket 都可用：

   ```sh
   $ docker daemon -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock
   ```

2. 为探测服务注册 Swarm 节点代理，节点的 IP 地址必须能被 Swarm manager 访问：

   ```sh
   $ docker run -d swarm join --addr=<node_ip:2375> token://<cluster_id>
   ```

   例子：

   ```sh
   $ docker run -d swarm join --addr=172.31.40.100:2375                \
                              token://6856663cdefdec325839a4b7e1de38e8
   ```

## 配置一个 manager

一旦你的节点建立，配置一个 manager 来管理它们。

1. 启动 Swarm manager：

   ```sh
   $ docker run -d -p <manager_port>:2375 swarm manage token://<cluster_id>
   ```

2. 一旦该 manager 运行，使用 `docker info` 检查一下它的配置：

   ```sh
   $ docker -H tcp://<manager_ip:manager_port> info
   ```

   例子：

   ```sh
   $ docker -H tcp://0.0.0.0:2375 info
   Containers: 0
   Nodes: 3
    agent-2: 172.31.40.102:2375
       └ Containers: 0
       └ Reserved CPUs: 0 / 1
       └ Reserved Memory: 0 B / 514.5 MiB
    agent-1: 172.31.40.101:2375
       └ Containers: 0
       └ Reserved CPUs: 0 / 1
       └ Reserved Memory: 0 B / 514.5 MiB
    agent-0: 172.31.40.100:2375
       └ Containers: 0
       └ Reserved CPUs: 0 / 1
       └ Reserved Memory: 0 B / 514.5 MiB
   ```

   如果你运行测试 cluster 时没有启用 TLS，可能会得到错误。你可以取消 TLS：

   ```sh
   $ unset DOCKER_TLS_VERIFY
   ```

## 使用 CLI 访问节点

现在，你能用常规的 Docker CLI 访问所有这些节点：

```sh
$ docker -H tcp://<manager_ip:manager_port> info
$ docker -H tcp://<manager_ip:manager_port> run ...
$ docker -H tcp://<manager_ip:manager_port> ps
$ docker -H tcp://<manager_ip:manager_port> logs ...
```

## 列出所有节点

你能使用 `swarm list` 命令得到所有运行节点的列表：

```sh
$ docker run --rm swarm list token://6856663cdefdec325839a4b7e1de38e8
172.31.40.100:2375
172.31.40.101:2375
172.31.40.102:2375
```

## TLS

Swarm 支持 TLS 验证。所有的 Docker daemon 证书和 client 证书必须使用相同的 CA-certificate 的签名。

为了对 daemon 和 client 启用 TLS，使用如下的命令：

```sh
$ swarm manage --tlsverify           \
               --tlscacert=<CACERT>  \
               --tlscert=<CERT>      \
               --tlskey=<KEY>        \ 
               [...]
```

> 注意：Swarm 证书生成的时候必须有 `extendedKeyUsage = clientAuth,serverAuth`。