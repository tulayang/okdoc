# [构建高可用的 Swarm](https://docs.docker.com/v1.9/swarm/multi-manager-setup/)

在 Docker Swarm，Swarm manager 以可伸缩的方式管理整个集群主机的资源。如果 Swarm manager 坏掉了，整个集群都不可用，你必须创建一个新的 manager 重新接管服务。

本文来介绍如何同时部署多个 Swarm manager，以构建高可用的 Swarm cluster。这个功能，会创建一个主 manager 和多个副本 manager。

主 manager 是联系 Swarm cluster 的主点。你也能创建一个副本 manager 并和其对话。发送到副本 manager 的请求，会被自动转发到主 manager。如果主 manager 失效了，一个副本 manager 会接管成为主 manager。通过这种方式，你总能和集群保持联系。

## 架设主 manager 和副本 manager

### 假设

你需要一个基于 Consul、Etcd、或 Zookeeper 的 cluster。这里假定使用 Consul 服务器，运行在 `192.168.42.10:8500`。所有主机都有一个 Docker Engine，监听 `2375` 端口。另外，配置 manager 监听 `4000` 端口。在这里，我们架设三个 manager：

* `manager-1` on `192.168.42.200`
* `manager-2` on `192.168.42.201`
* `manager-3` on `192.168.42.202`

### 创建主 manager

使用 `swarm manage` 命令指定 `--replication` 和 `--advertise` 创建一个主 manager：

```sh
user@manager-1 $ swarm manage -H :4000 <tls-config-flags>       \
                              --replication                     \
                              --advertise 192.168.42.200:4000   \
                              consul://192.168.42.10:8500/nodes
 INFO[0000] Listening for HTTP addr=:4000 proto=tcp
 INFO[0000] Cluster leadership acquired
 INFO[0000] New leader elected: 192.168.42.200:4000
 [...]
```

`--replication` 告诉 Swarm 这是一个多 manager 的副本。`--advertise` 指定该 manager 的地址。从输出中你能看到，该 manager 已经被推举为主 manager。

### 创建两个副本 manager

```sh
user@manager-2 $ swarm manage -H :4000 <tls-config-flags>       \
                              --replication                     \
                              --advertise 192.168.42.201:4000   \
                              consul://192.168.42.10:8500/nodes
INFO[0000] Listening for HTTP addr=:4000 proto=tcp
INFO[0000] Cluster leadership lost
INFO[0000] New leader elected: 192.168.42.200:4000
[...]

user@manager-2 $ swarm manage -H :4000 <tls-config-flags>       \
                              --replication                     \
                              --advertise 192.168.42.202:4000   \
                              consul://192.168.42.10:8500/nodes
INFO[0000] Listening for HTTP                            addr=:4000 proto=tcp
INFO[0000] Cluster leadership lost
INFO[0000] New leader elected: 192.168.42.200:4000
[...]
```

### 列出 cluster 中的机器

```sh
user@my-machine $ export DOCKER_HOST=192.168.42.200:4000
user@my-machine $ docker info
Containers: 0
Images: 25
Storage Driver:
Role: Primary  <--------- manager-1 is the Primary manager
Primary: 192.168.42.200
Strategy: spread
Filters: affinity, health, constraint, port, dependency
Nodes: 3
 swarm-agent-0: 192.168.42.100:2375
  └ Containers: 0
  └ Reserved CPUs: 0 / 1
  └ Reserved Memory: 0 B / 2.053 GiB
  └ Labels: executiondriver=native-0.2, kernelversion=3.13.0-49-generic, operatingsystem=Ubuntu 14.04.2 LTS, storagedriver=aufs
 swarm-agent-1: 192.168.42.101:2375
  └ Containers: 0
  └ Reserved CPUs: 0 / 1
  └ Reserved Memory: 0 B / 2.053 GiB
  └ Labels: executiondriver=native-0.2, kernelversion=3.13.0-49-generic, operatingsystem=Ubuntu 14.04.2 LTS, storagedriver=aufs
 swarm-agent-2: 192.168.42.102:2375
  └ Containers: 0
  └ Reserved CPUs: 0 / 1
  └ Reserved Memory: 0 B / 2.053 GiB
  └ Labels: executiondriver=native-0.2, kernelversion=3.13.0-49-generic, operatingsystem=Ubuntu 14.04.2 LTS, storagedriver=aufs
Execution Driver:
Kernel Version:
Operating System:
CPUs: 3
Total Memory: 6.158 GiB
Name:
ID:
Http Proxy:
Https Proxy:
No Proxy:
```

## 测试故障转移机制

要测试故障转移机制，首先停止已经选定的主 manager --- `Ctrl-C` 关闭 `manager-1` 或其他停止方法。一些时间后，其他的 manager 进行选举产生一个新的主 manager。

比如，看一下 `manager-2` 的日志：

```sh
user@manager-2 $ swarm manage -H :4000 <tls-config-flags>       \
                              --replication                     \
                              --advertise 192.168.42.201:4000   \
                              consul://192.168.42.10:8500/nodes
INFO[0000] Listening for HTTP addr=:4000 proto=tcp
INFO[0000] Cluster leadership lost
INFO[0000] New leader elected: 192.168.42.200:4000
INFO[0038] New leader elected: 192.168.42.201:4000
INFO[0038] Cluster leadership acquired   <--- We have been elected as the new Primary Manager
[...]
```

因为原 manager `manager-1` 已经失效，副本集进行新的选举并推举 `192.168.42.201:4000` 也就是 `manager-2` 作为新的主 manager。

如果看一看 `manager-3` 的日志会看到：

```sh
user@manager-2 $ swarm manage -H :4000 <tls-config-flags>       \
                              --replication                     \
                              --advertise 192.168.42.202:4000   \
                              consul://192.168.42.10:8500/nodes
INFO[0000] Listening for HTTP addr=:4000 proto=tcp
INFO[0000] Cluster leadership lost
INFO[0000] New leader elected: 192.168.42.200:4000
INFO[0036] New leader elected: 192.168.42.201:4000   <--- manager-2 sees the new Primary Manager
[...]
```

你可以这样切换 `DOCKER_HOST` 到 `manager-2`：

```sh
user@my-machine $ export DOCKER_HOST=192.168.42.201:4000 # Points to manager-2
user@my-machine $ docker info
Containers: 0
Images: 25
Storage Driver:
Role: Replica  <--------- manager-2 is a Replica
Primary: 192.168.42.200
Strategy: spread
Filters: affinity, health, constraint, port, dependency
Nodes: 3
```


