# [Swarm cluster 策略](https://docs.docker.com/v1.9/swarm/scheduler/strategy/)

Docker Swarm 调度器支持几个策略来 ranking 节点。你所选择的策略决定了 Swarm 的 ranking 算法。当你运行一个新容器时，Swarm 使用你所选择的策略计算要选择的节点。

执行 `swarm manage` 命令时指定 `--strategy` 选择一个 ranking 策略。当前支持以下策略：

* `spread`
* `binpack`
* `random`

`spread` 和 `binpack` 根据节点的可用 CPU、RAM、已有容器数计算 rank。`random` 随机选择一个节点，这个策略主要用来调试。

选择策略的前体是根据你的公司需要最优化 Swarm。

在 `spred` 策略下，Swarm 保持每个节点最少数量的容器。在 `binpack` 策略下，Swarm 使节点逐个达到最满容器数。注意，容器在生命周期是占用资源的 --- 包括 `exited` 状态。比如，`spread` 策略只会检查容器的数量而不管它们的状态。一个节点，它可能有很多容器但是都是停止的，由于容器数很多，它很可能不会被选定，这经常会造成一些负载均衡的困惑。用户可以删除已经停止的容器，或者启动它们，来达到负载均衡的目的。

使用 `spread` 策略的结果是，容器均匀分散在 cluster 的各个主机。优点是一旦有一个主机下线，会丢失较少的容器。

使用 `binpack` 则是每当填满一个节点，才会选择另一个节点。优点是可以用较少的节点部署较多的容器。

如果没有指定 `--strategy`，则 Swarm 默认使用 `spread` 策略。

## spread

在下面这个例子中，`node-1` 和 `node-2` 都有 `2G` 内存、`2` CPU，都没有运行任何容器。在 `spread` 策略下，`node-1` 和 `node-2` 有相同的 rank。

首先，运行一个容器，你会看到，它被分配到 `node-1`：

```sh
$ docker run -d -P -m 1G --name db mysql
f8b693db9cd6

$ docker ps
CONTAINER ID  IMAGE           COMMAND   CREATED                 STATUS  
f8b693db9cd6  mysql:latest    "mysqld"  Less than a second ago  running 
PORTS                         NODE      NAMES
192.168.0.42:49178->3306/tcp  node-1    db
```

然后，运行另一个容器。因为 `spread` 策略的原因，它被分配到 `node-2`：

```sh
$ docker run -d -P -m 1G --name frontend nginx
963841b138d8

$ docker ps
CONTAINER ID  IMAGE           COMMAND   CREATED                 STATUS 
963841b138d8  nginx:latest    "nginx"   Less than a second ago  running 
f8b693db9cd6  mysql:latest    "mysqld"  Less than a second ago  running 
PORTS                         NODE      NAMES
192.168.0.42:49177->80/tcp    node-2    frontend
192.168.0.42:49178->3306/tcp  node-1    db
```

## binpack

在下面这个例子中，`node-1` 和 `node-2` 都有 `2G` 内存、`2` CPU，都没有运行任何容器。

首先，运行一个容器，你会看到，它被分配到 `node-1`：

```sh
$ docker run -d -P -m 1G --name db mysql
f8b693db9cd6

$ docker ps
CONTAINER ID  IMAGE           COMMAND   CREATED                 STATUS  
f8b693db9cd6  mysql:latest    "mysqld"  Less than a second ago  running 
PORTS                         NODE      NAMES
192.168.0.42:49178->3306/tcp  node-1    db
```

然后，运行另一个容器。因为 `binpack` 策略的原因，它又被分配到 `node-1`：

```sh
$ docker run -d -P -m 1G --name frontend nginx
963841b138d8

$ docker ps
CONTAINER ID  IMAGE           COMMAND   CREATED                 STATUS 
963841b138d8  nginx:latest    "nginx"   Less than a second ago  running 
f8b693db9cd6  mysql:latest    "mysqld"  Less than a second ago  running 
PORTS                         NODE      NAMES
192.168.0.42:49177->80/tcp    node-1    frontend
192.168.0.42:49178->3306/tcp  node-1    db
```