# [何谓 Swarm cluster 探测服务](https://docs.docker.com/v1.9/swarm/discovery/)

当使用 Docker Swarm 构建 Swarm cluster 时，需要一个探测服务。这个服务维护你的 Swarm cluster 中的 IP 地址列表。当前，有几个可用的探测服务，分别是 Consul、Etcd、Zookeeper，至于哪个最适合你，这得看你依赖的环境。你甚至可以使用一个静态文件。Docker Hub 也提供探测服务，但是只适合用于测试、开发。

## 使用 Docker Hub 探测服务

Docker Hub 探测服务只适合用于测试、开发，不要把它用于生产环境。创建一个 Docker Hub 探测服务：

1. 创建一个 cluster，获取 cluster_id：

   ```sh
   $ swarm create
   6856663cdefdec325839a4b7e1de38e8   # <- this is your unique <cluster_id>
   ```

2. 把每个节点都加入到 cluster：

   ```sh
   $ swarm join --advertise=<node_ip:2375> token://<cluster_id>
   ```

3. 启动 Swarm manager （在任何机器上都可以）：

   ```sh
   $ swarm manage -H tcp://<swarm_ip:swarm_port> token://<cluster_id>
   ```

4. 使用常规的 Docker CLI 和你的 Swarm cluster 交互：

   ```sh
   $ docker -H tcp://<swarm_ip:swarm_port> info
   $ docker -H tcp://<swarm_ip:swarm_port> run ...
   $ docker -H tcp://<swarm_ip:swarm_port> ps
   $ docker -H tcp://<swarm_ip:swarm_port> logs ...
   ...
   ```

5. 列出 Swarm cluster 所有的节点：

   ```sh
   $ swarm list token://<cluster_id>
   <node_ip:2375>
   ```

## 使用静态文件分布 Swarm cluster

1. 在一个静态文件中（比如 */tmp/my_cluster*），为你的每个节点添加一行：

   ```sh
   $ echo <node_ip1:2375> >> /tmp/my_cluster
   $ echo <node_ip2:2375> >> /tmp/my_cluster
   $ echo <node_ip3:2375> >> /tmp/my_cluster
   ```

2. 启动 Swarm manager （在任何机器上都可以）：

   ```sh
   $ swarm manage -H tcp://<swarm_ip:swarm_port> file:///tmp/my_cluster
   ```

3. 使用常规的 Docker CLI 和你的 Swarm cluster 交互：

   ```sh
   $ docker -H tcp://<swarm_ip:swarm_port> info
   $ docker -H tcp://<swarm_ip:swarm_port> run ...
   $ docker -H tcp://<swarm_ip:swarm_port> ps
   $ docker -H tcp://<swarm_ip:swarm_port> logs ...
   ...
   ```

4. 列出 Swarm cluster 所有的节点：

   ```sh
   $ swarm list file:///tmp/my_cluster
   <node_ip1:2375>
   <node_ip2:2375>
   <node_ip3:2375>
   ```

## 使用 Etcd 探测服务

1. 在你的每个节点启动 Swarm 代理：

   ```sh
   $ swarm join --advertise=<node_ip:2375>                              \
                etcd://<etcd_addr1>,<etcd_addr2>/<optional path prefix>
   ```

2. 启动 Swarm manager （在任何机器上都可以）：

   ```sh
   $ swarm manage -H tcp://<swarm_ip:swarm_port>                             \
                     etcd://<etcd_addr1>,<etcd_addr2>/<optional path prefix>
   ```

3. 使用常规的 Docker CLI 和你的 Swarm cluster 交互：

   ```sh
   $ docker -H tcp://<swarm_ip:swarm_port> info
   $ docker -H tcp://<swarm_ip:swarm_port> run ...
   $ docker -H tcp://<swarm_ip:swarm_port> ps
   $ docker -H tcp://<swarm_ip:swarm_port> logs ...
   ...
   ```

4. 列出 Swarm cluster 所有的节点：

   ```sh
   $ swarm list etcd://<etcd_addr1>,<etcd_addr2>/<optional path prefix>
   <node_ip1:2375>
   ```

## 使用 Consul 探测服务

1. 在你的每个节点启动 Swarm 代理：

   ```sh
   $ swarm join --advertise=<node_ip:2375>                     \
                consul://<consul_addr>/<optional path prefix>
   ```

2. 启动 Swarm manager （在任何机器上都可以）：

   ```sh
   $ swarm manage -H tcp://<swarm_ip:swarm_port>                    \
                     consul://<consul_addr>/<optional path prefix>
   ```

3. 使用常规的 Docker CLI 和你的 Swarm cluster 交互：

   ```sh
   $ docker -H tcp://<swarm_ip:swarm_port> info
   $ docker -H tcp://<swarm_ip:swarm_port> run ...
   $ docker -H tcp://<swarm_ip:swarm_port> ps
   $ docker -H tcp://<swarm_ip:swarm_port> logs ...
   ...
   ```

4. 列出 Swarm cluster 所有的节点：

   ```sh
   $ swarm list consul://<consul_addr>/<optional path prefix>
   <node_ip1:2375>
   ```

## 使用 Zookeeper 探测服务

1. 在你的每个节点启动 Swarm 代理：

   ```sh
   $ swarm join --advertise=<node_ip:2375>                \
                zk://<zookeeper_addr1>,<zookeeper_addr2>  \
                     /<optional path prefix>
   ```

2. 启动 Swarm manager （在任何机器上都可以）：

   ```sh
   $ swarm manage -H tcp://<swarm_ip:swarm_port>               \
                     zk://<zookeeper_addr1>,<zookeeper_addr2>  \
                          /<optional path prefix>
   ```

3. 使用常规的 Docker CLI 和你的 Swarm cluster 交互：

   ```sh
   $ docker -H tcp://<swarm_ip:swarm_port> info
   $ docker -H tcp://<swarm_ip:swarm_port> run ...
   $ docker -H tcp://<swarm_ip:swarm_port> ps
   $ docker -H tcp://<swarm_ip:swarm_port> logs ...
   ...
   ```

4. 列出 Swarm cluster 所有的节点：

   ```sh
   $ swarm list zk://<zookeeper_addr1>,<zookeeper_addr2>  \
                     /<optional path prefix>
   <node_ip1:2375>
   ```

## 使用一个静态 IP 地址列表

1. 启动 Swarm manager （在任何机器上都可以）：

   ```sh
   $ swarm manage -H <swarm_ip:swarm_port> nodes://<node_ip1:2375>,<node_ip2:2375>
   ```

   或者

   ```sh
   $ swarm manage -H <swarm_ip:swarm_port> <node_ip1:2375>,<node_ip2:2375>
   ```

2. 使用常规的 Docker CLI 和你的 Swarm cluster 交互：

   ```sh
   $ docker -H tcp://<swarm_ip:swarm_port> info
   $ docker -H tcp://<swarm_ip:swarm_port> run ...
   $ docker -H tcp://<swarm_ip:swarm_port> ps
   $ docker -H tcp://<swarm_ip:swarm_port> logs ...
   ...
   ```

## IP 地址的范围模式

静态文件和静态 IP 地址列表这两个探测服务，支持 IP 地址的范围模式。比如，`10.0.0.[10:200]` 表示 `10.0.0.10` 到 `10.0.0.200` 的节点列表。

1. 在一个静态文件中（比如 */tmp/my_cluster*），为你的每个节点添加一行，启动 Swarm manager （在任何机器上都可以）：

   ```sh
   $ echo "10.0.0.[11:100]:2375"   >> /tmp/my_cluster
   $ echo "10.0.1.[15:20]:2375"    >> /tmp/my_cluster
   $ echo "192.168.1.2:[2:20]375"  >> /tmp/my_cluster

   $ swarm manage -H tcp://<swarm_ip:swarm_port> file:///tmp/my_cluster
   ```

   或者，也可以使用如下方式启动 Swarm manager （在任何机器上都可以）：
   
   ```sh
   $ swarm manage -H <swarm_ip:swarm_port>                            \
                  "nodes://10.0.0.[10:200]:2375,10.0.1.[2:250]:2375"
   ```

3. 使用常规的 Docker CLI 和你的 Swarm cluster 交互：

   ```sh
   $ docker -H tcp://<swarm_ip:swarm_port> info
   $ docker -H tcp://<swarm_ip:swarm_port> run ...
   $ docker -H tcp://<swarm_ip:swarm_port> ps
   $ docker -H tcp://<swarm_ip:swarm_port> logs ...
   ...
   ```