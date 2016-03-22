# [多主机网络](https://docs.docker.com/v1.9/engine/userguide/networking/get-started-overlay/)

Docker Engine 支持多主机网络，这是通过 overlay 网络驱动实现的。overlay 网络驱动，拆箱即用。此外，overlay 网络驱动需要一些必备前提：

* 主机必须是 3.6 内核或更高版本

* 有一个 key-value 存储。支持 Consul、Etcd、ZooKeeper 这些 key-value 存储

* 集群中的主机和 key-value 存储建立连接

* 正确配置集群中的每个主机中的 Docker Engine daemon

Docker Machine 和 Docker Swarm 并不是必需的，但是使用它们可以简化问题。

开始之前，你应该有一台主机，上面安装了最新版本的 Docker Engine 和 Docker Machine。此外，本文的例子中，还要求你在此主机上安装了 VirtualBox。

## 1 架设一个 key-value 存储

key-value 存储用来存储集群状态，包括探测、网络、进入点、IP 地址、... 。

1. 创建一个称为 `keystore` 的 VirtualBox 虚拟主机：

   ```sh
   $ docker-machine create -d virtualbox keystore
   ```

2. 我们不去手动安装 Consul，代替的是，使用镜像 [Consul Image](https://hub.docker.com/r/progrium/consul/) 在 `keystore` 主机部署一个容器：

   ```sh
   $ docker $(docker-machine config keystore) run  \
            -d                                     \
            -p "8500:8500"                         \
            -h "consul"                            \
            progrium/consul -server -bootstrap
   ```

   `$(docker-machine config keystore)` 用来设定连接配置。这条命令通过 `progrium/consul` 镜像启动了一个服务器，服务器名字是 `consul`，监听端口 `8500`。

3. 配置环境变量为 `keystore` 主机，查看一下：

   ```sh
   $ eval "$(docker-machine env mh-keystore)"
   $ docker ps
   ```

## 2 创建一个 Swarm 集群

1. 创建一个 Swarm master 虚拟主机，作为集群 master：

   ```sh
   $ docker-machine create                                             \
                    -d virtualbox                                      \
                    --swarm                                            \ 
                    --swarm-master                                     \
                    --swarm-discovery=                                 \
                      "consul://$(docker-machine ip keystore):8500"    \
                    --engine-opt=                                      \
                      "cluster-store=consul://$(docker-machine ip      \
                      keystore):8500"                                  \
                    --engine-opt=                                      \
                      "cluster-advertise=eth1:2376"                    \
                    master
   ```

   创建时，指定了 `--cluster-store` 告诉 Docker Engine 使用的 key-value 存储所在位置 --- 用来搭建 overlay 网络。`cluster-advertise` 告诉 Docker Engine 集群 master 所在位置。

2. 创建另一个虚拟主机，并把它加入到 Swarm 集群：

   ```sh
   $ docker-machine create                                             \
                    -d virtualbox                                      \
                    --swarm                                            \
                    --swarm-discovery=                                 \
                      "consul://$(docker-machine ip keystore):8500"    \
                    --engine-opt=                                      \
                      "cluster-store=consul://$(docker-machine ip      \
                      keystore):8500"                                  \
                    --engine-opt=                                      \
                      "cluster-advertise=eth1:2376"                    \
                    machine1
   ```

3. 列出这些主机看看：

   ```sh
   $ docker-machine ls
   ```

   现在，你已经有了一组运行在网络上的主机。它们可以用来创建跨多网络的容器。

## 3 创建一个 overlay 网络

1. 配置环境变量为 `master` 主机：

   ```sh
   $ eval "$(docker-machine env --swarm master)"
   ```

   `--swarm` 可以限制 Docker 只输出 Swarm 信息。

2. 查看一下 Swarm：

   ```sh
   $ docker info
   Containers: 3
   Images: 2
   Role: primary
   Strategy: spread
   Filters: affinity, health, constraint, port, dependency
   Nodes: 2
   mhs-demo0: 192.168.99.104:2376
   └ Containers: 2
   └ Reserved CPUs: 0 / 1
   └ Reserved Memory: 0 B / 1.021 GiB
   └ Labels: executiondriver=native-0.2, kernelversion=4.1.10-boot2docker, operatingsystem=Boot2Docker 1.9.0-rc1 (TCL 6.4); master : 4187d2c - Wed Oct 14 14:00:28 UTC 2015, provider=virtualbox, storagedriver=aufs
   mhs-demo1: 192.168.99.105:2376
   └ Containers: 1
   └ Reserved CPUs: 0 / 1
   └ Reserved Memory: 0 B / 1.021 GiB
   └ Labels: executiondriver=native-0.2, kernelversion=4.1.10-boot2docker, operatingsystem=Boot2Docker 1.9.0-rc1 (TCL 6.4); master : 4187d2c - Wed Oct 14 14:00:28 UTC 2015, provider=virtualbox, storagedriver=aufs
   CPUs: 2
   Total Memory: 2.043 GiB
   Name: 30438ece0915
   ```

3. 创建一个 overlay 网络：

   ```sh
   $ docker network create --driver overlay mynet
   ```
   
   只需要在集群上的一个主机创建这个网络。

4. 检查一下正在运行的网络：

   ```sh
   $ docker network ls
   NETWORK ID          NAME                DRIVER
   412c2496d0eb        master/host         host
   dd51763e6dd2        machine1/bridge     bridge
   6b07d0be843f        mynet               overlay
   b4234109bd9b        master/none         null
   1aeead6dd890        master/host         host
   d0bb78cbe7bd        machine1/bridge     bridge
   1c0eb8f69ebb        machine1/none       null
   ```

5. 配置环境变量为 `master` 和 `machine1` 主机，查看下它们正在运行的网络：

   ```sh
   $ eval $(docker-machine env master)
   $ docker network ls
   NETWORK ID          NAME                DRIVER
   dd51763e6dd2        bridge              bridge
   b4234109bd9b        none                null
   1aeead6dd890        host                host
   6b07d0be843f        mynet               overlay

   $ eval $(docker-machine env machine1)
   $ docker network ls
   NETWORK ID          NAME                DRIVER
   d0bb78cbe7bd        bridge              bridge
   1c0eb8f69ebb        none                null
   412c2496d0eb        host                host
   6b07d0be843f        mynet               overlay
   ```
   
   你能看到，这些主机中也都运行了 `mynet` 网络，而且其 ID 都是 `6b07d0be843f`。现在，你有了一个正在运行的多主机容器网络。

## 4 在网络中运行一个 app

一旦你的网络创建完毕，你就能在其中的任何主机上启动一个容器，这个容器会自动加入到网络。

1. 配置环境变量为 `master` 主机，启动一个 Nginx web server：

   ```sh
   $ eval "$(docker-machine env --swarm master)"
   $ docker run -itd --name=web --net=my-net       \
                --env="constraint:node==master"    \ 
                nginx
   ```

2. 在 `machine1` 主机启动一个容器，访问 Nginx 服务：

   ```sh
   $ docker run -it --rm --net=my-net --env="constraint:node==mhs-demo1" \
                busybox wget -O- http://web
   Unable to find image 'busybox:latest' locally
   latest: Pulling from library/busybox
   ab2b8a86ca6c: Pull complete
   2c5ac3f849df: Pull complete
   Digest: sha256:5551dbdfc48d66734d0f01cafee0952cb6e8eeecd1e2492240bf2fd9640c2279
   Status: Downloaded newer image for busybox:latest
   Connecting to web (10.0.0.2:80)
   <!DOCTYPE html>
   <html>
   <head>
   <title>Welcome to nginx!</title>
   <style>
   body {
           width: 35em;
           margin: 0 auto;
           font-family: Tahoma, Verdana, Arial, sans-serif;
   }
   </style>
   </head>
   <body>
   <h1>Welcome to nginx!</h1>
   <p>If you see this page, the nginx web server is successfully installed and
   working. Further configuration is required.</p>

   -
   <p><em>Thank you for using nginx.</em></p>
   </body>
   </html>
   -                    100% |*******************************|   612   0:00:00 ETA
   ```

## 5 检查外部连接

如你所见，Docker 内置的 overlay 网络驱动为容器在同一个网络互相访问提供了开箱即用的方便。此外，容器们连接到多主机网络时会自动连接到 `docker_gwbridge` 网络。这个网络允许容器们走出集群和外界通信。

1. 配置环境变量为 `master` 和 `machine1` 主机，看看 `docker_gwbridge` 网络：

   ```sh
   $ eval $(docker-machine env master)
   $ docker network ls
   NETWORK ID          NAME                DRIVER
   d0bb78cbe7bd        bridge              bridge
   1c0eb8f69ebb        none                null
   412c2496d0eb        host                host
   6b07d0be843f        mynet               overlay
   97102a22e8d2        docker_gwbridge     bridge

   $ eval $(docker-machine env machine1)
   $ docker network ls
   NETWORK ID          NAME                DRIVER
   dd51763e6dd2        bridge              bridge
   b4234109bd9b        none                null
   1aeead6dd890        host                host
   6b07d0be843f        mynet               overlay
   e1dbd5dff8be        docker_gwbridge     bridge
   ```

2. 检查下 Nginx 容器的网络接口：

   ```sh
   $ docker exec web ip addr
   1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default
   link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
   inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
   inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
   22: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP group default
   link/ether 02:42:0a:00:09:03 brd ff:ff:ff:ff:ff:ff
   inet 10.0.9.3/24 scope global eth0
       valid_lft forever preferred_lft forever
   inet6 fe80::42:aff:fe00:903/64 scope link
       valid_lft forever preferred_lft forever
   24: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
   link/ether 02:42:ac:12:00:02 brd ff:ff:ff:ff:ff:ff
   inet 172.18.0.2/16 scope global eth1
       valid_lft forever preferred_lft forever
   inet6 fe80::42:acff:fe12:2/64 scope link
       valid_lft forever preferred_lft forever
   ```

   `eth0` 接口表示连接到 `mynet` overlay 网络的容器接口。`eth1` 接口表示连接到 `docker_gwbridge` bridge 网络的容器接口。

## 6 利用 Docker Compose

你能用 Docker Compose 在你的 Swarm cluster 启动第二个网络。

1. 安装 Docker Compose。

2. 创建一个 docker-compose.yml 文件，加入以下内容：

   ```sh
   web:
       image: bfirsh/compose-mongodb-demo
       environment:
           - "MONGO_HOST=counter_mongo_1"
           - "constraint:node==master"
       ports:
           - "80:5000"
   mongo:
       image: mongo
   ```

3. 配置环境变量到 `master`，启动 Docker Compose：

   ```sh
   $ docker-compose --x-networking --project-name=counter up -d
   ```

4. 获取 Swarm master IP 地址，用浏览器浏览下：

   ```sh
   $ docker-machine ip master
   ```

   