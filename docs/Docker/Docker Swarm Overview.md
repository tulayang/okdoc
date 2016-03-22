# [Docker Swarm](https://docs.docker.com/v1.9/swarm/)

Docker Swarm 是 Docker 原生的集群工具。它把多个 （虚拟） Docker 主机汇集成一个（虚拟）主机。

## 创建过程

在网络上创建一个 Swarm 第一步是拉取 Docker Swarm 镜像。然后，用 Docker 配置 Swarm manager，并让所有（主机）节点运行在 Docker Swarm。这个方法需要：

* 每个与 Swarm manager 通信的节点都需要打开一个 TCP 端口

* 每个（主机）节点都需要安装 Docker

* 创建和管理 TLS 证书以加强 Swarm 安全

使用 Docker Machine，你能在云服务或你自己的数据中心快速安装一个 Docker Swarm。[使用 Docker Machine 是开始 Docker Swarm 最好的方法](https://docs.docker.com/v1.9/swarm/install-w-machine/)。[此外，你也可以手动安装 Docker Swarm](https://docs.docker.com/v1.9/swarm/install-manual/)。

## 探测服务

为了动态配置和管理容器中的服务，你需要在 Docker Swarm 中使用[探测后端](https://docs.docker.com/v1.9/swarm/discovery/)。

## 高级调度

[策略](https://docs.docker.com/v1.9/swarm/scheduler/strategy/)、[过滤器](https://docs.docker.com/v1.9/swarm/scheduler/filter/)

## Swarm API

[Docker Swarm API](https://docs.docker.com/v1.9/swarm/api/swarm-api/) 兼容 [Docker Remote API](http://docs.docker.com/reference/api/docker_remote_api/)，并且提供了一些扩展。