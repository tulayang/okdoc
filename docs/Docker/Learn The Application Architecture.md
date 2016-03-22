# [Swarm cluster 应用架构](https://docs.docker.com/swarm/swarm_at_scale/01-about/)

本文讨论了一个 Swarm cluster 的应用例子。你的公司是一家宠物食品公司。现在，你们需要一个网上调查，要求用户投票：猫或狗。

你的调查必须确保数以百万计的人可以同时投票，而不会导致你的网站不可用。你不需要实时的结果，只需要在最后宣布结果。然而，你需要确信每一个投票都被计算在内。

## 理解应用架构

这个投票应用是一个 dockerized 微服务应用。它使用并行的 web 前端，为后端 workers 异步发送作业。这个应用的架构能使用任意大型伸缩。下面的图展示了这个应用的高阶架构：

![架构](https://docs.docker.com/swarm/images/app-architecture.jpg)

这个应用完全是 dockerized，所有的服务运行在容器中。

前端由一个 Interlock 负载均衡和 N 个 web 服务组成。负载均衡能够处理任意数量的 web 容器（`frontend01` - `frontendN`）。web 容器运行一个简单的 Python Flask 应用。每个 web 服务接受投票，然后把它们排队送到同一个节点的 redis 容器。每一个操作都由一个 web 容器和 redis 容器成对组成。

这种负载均衡 + 成对 web 服务允许整个应用以任意数量进行水平伸缩。

前端之后是一个 worker 组，运行在单独的节点。这个 worker  组负责：

* 扫描 redis 容器们
* 把投票出队列
* 复制投票，阻止重复投票
* 把结果提交到一个 Postgres 容器 --- 运行在单独的节点

和前端一样，worker 组也能容易的水平伸缩。worker 数量和前端数量是独立计算的。

## Swarm cluster 架构

要支持这个应用，你可以设计一个 Swarm cluster：

![Swarm cluster](https://docs.docker.com/swarm/images/swarm-cluster-arch.jpg) 

所有在 cluster 中的四个节点都运行 Docker Engine daemon，Swarm manager 和 interlock 负载均衡也一样。

容器的网络是 overlay 网络，这个 dockerized 微服务部署在这个网络上：

![Network](https://docs.docker.com/swarm/images/final-result.jpg)

cluster 的每个节点有下列容器：

* `frontend01`：

　　* Container：Python flask web app (web01)
  * Container：Redis (redis01)

* `frontend02`：

　　* Container：Python flask web app (web02)
  * Container：Redis (redis02)

* `worker01`：vote worker app (worker01)

* `store`：

　　* Container：Postgres (pg)
  * Container：results app (results-app)