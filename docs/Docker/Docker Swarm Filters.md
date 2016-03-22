# [过滤 Swarm cluster](https://docs.docker.com/v1.9/swarm/scheduler/filter/)

过滤器告诉 Docker Swarm 调度器，当创建和运行一个容器时使用哪个节点。

## 配置可用的过滤器

过滤器有两种，节点过滤器和容器配置过滤器。节点过滤器的操作依赖 Docker 主机的特性或者 Docker daemon 的配置。容器配置过滤器的操作依赖容器的特性或者主机镜像的可用性。

每一个过滤器有一个名字用于标识。节点过滤器是：

* `constraint`
* `health`

容器配置过滤器是：

* `affinity`
* `dependency`
* `port`

当你用 `swarm manage` 启动一个 Swarm manager 时，所有的过滤器被启用。如果你想要限制启用的过滤器，指定 `--filter` 标志位：

```sh
$ swarm manage --filter=health --filter=dependency
```

> 容器配置过滤器匹配所有的容器，包括已经停止的容器。想要释放一个已经被容器使用的节点，你必须先从节点把容器删除。

## 节点过滤器

当创建一个容器或者编译一个镜像时，你需要用 `constraint` 或 `health` 过滤器来选择节点的子集（调度）。

### constraint

`constraint` 过滤器关联 Docker 默认的 tags 或自定义 labels。默认 tags 源自 `docker info`。通常，它们设计到 Docker 主机的属性。当前，默认  tags 包括：

* `node` 节点 ID 或名字
* `storagedriver`
* `executiondriver`
* `kernelversion`
* `operatingsystem`

当你启动 `docker daemon` 时采用自定义节点 labels，比如：

```sh
$ docker daemon --label com.example.environment="production"  \
                --label com.example.storage="ssd"
```

然后，当你在 cluster 启动一个容器时，你可以配置 `constraints` 使用默认 tags 或 自定义 labels。Swarm 调度器会在 cluster 查找匹配的节点，然后在该节点启动容器。这个方法有几个实际价值：

* 调度建立在特定的主机属性基础上。比如，`storage=ssd` 在指定的硬件调度容器。

* 强制容器运行在给定的位置。比如，` region=us-east`。

* 通过不同属性指定一个 cluster 作为 sub-clusters 创建逻辑 cluster 扇区。比如，`environment=production`。

下面我们来看一个例子。

为一个节点 `node-1` 指定自定义 label `storage=ssd`：

```sh
$ docker daemon --label storage=ssd
$ swarm join --advertise=192.168.0.42:2375 token://XXXXXXXXXXXXXXXXXX
```

启动第二个节点 `node-2`：

```sh
$ docker daemon --label storage=disk
$ swarm join --advertise=192.168.0.43:2375 token://XXXXXXXXXXXXXXXXXX
```

一旦节点加入到 cluster，Swarm master 就会拉取它们各自的 tags。然后，master 在调度新的容器时就把这些 tags 纳入考虑。

继续上面的例子，在 cluster 启动一个 Mysql 容器。当启动时，你可以指定 `constraint` 确保这个数据库得到最好的 IO 性能：

```sh
$ docker run -d -P -e constraint:storage==ssd --name db mysql
f8b693db9cd6

$ docker ps
CONTAINER ID  IMAGE           COMMAND   CREATED                 STATUS  
f8b693db9cd6  mysql:latest    "mysqld"  Less than a second ago  running 
PORTS                         NODE      NAMES
192.168.0.42:49178->3306/tcp  node-1    db
```

在这个例子中，master 选择所有匹配 `storage=ssd` 的节点，并且对最上面一个采用资源管理。只有 `node-1` 被选择，因为只有它符合匹配。

假设你想在 cluster 运行一个 Nginx 前端，这种情况下，你会需要其把日志写到磁盘：

```sh
$ docker run -d -P -e constraint:storage==disk --name frontend nginx
963841b138d8

$ docker ps
CONTAINER ID  IMAGE           COMMAND   CREATED                 STATUS  
963841b138d8  nginx:latest    "nginx"   Less than a second ago  running
f8b693db9cd6  mysql:latest    "mysqld"  Less than a second ago  running 
PORTS                         NODE      NAMES
192.168.0.43:49177->80/tcp    node-2    frontend
192.168.0.42:49178->3306/tcp  node-1    db
```

最后，`docker build` 会匹配编译 tags：

```sh
$ mkdir sinatra
$ cd sinatra

$ echo "FROM ubuntu:14.04" > Dockerfile
$ echo "MAINTAINER Kate Smith <ksmith@example.com>" >> Dockerfile
$ echo "RUN apt-get update && apt-get install -y ruby ruby-dev" >> Dockerfile
$ echo "RUN gem install sinatra" >> Dockerfile

$ docker build --build-arg=constraint:storage==disk -t ouruser/sinatra:v2 .
Sending build context to Docker daemon 2.048 kB
Step 1 : FROM ubuntu:14.04
 ---> a5a467fddcb8
Step 2 : MAINTAINER Kate Smith <ksmith@example.com>
 ---> Running in 49e97019dcb8
 ---> de8670dcf80e
Removing intermediate container 49e97019dcb8
Step 3 : RUN apt-get update && apt-get install -y ruby ruby-dev
 ---> Running in 26c9fbc55aeb
 ---> 30681ef95fff
Removing intermediate container 26c9fbc55aeb
Step 4 : RUN gem install sinatra
 ---> Running in 68671d4a17b0
 ---> cd70495a1514
Removing intermediate container 68671d4a17b0
Successfully built cd70495a1514

$ docker images
REPOSITORY          TAG      IMAGE ID       CREATED          VIRTUAL SIZE
dockerswarm/swarm   master   8c2c56438951   2 days ago       795.7 MB
ouruser/sinatra     v2       cd70495a1514   35 seconds ago   318.7 MB
ubuntu              14.04    a5a467fddcb8   11 days ago      187.9 MB
```

### health

`health` 过滤器阻止调度器为容器选择不健康的节点。如果节点下线或不能和 cluster 存储通信，就被认为是不健康的。

### 

## 容器配置过滤器

当创建一个容器时，你能使用以下三个过滤器：

* `affinity`
* `dependency`
* `port`

### affinity

`affinity` 过滤器在容器之间创建一个“吸引力”。比如，你能运行一个容器，并且指导 Swarm 基于以下规则调度它：

* 容器 ID 或名字

  
  例子，启动一个 Nginx 容器 `frontend`：

  ```sh
  $ docker run -d -p 80:80 --name frontend nginx
  87c4376856a8

  $ docker ps
  CONTAINER ID  IMAGE           COMMAND   CREATED                 STATUS  
  87c4376856a8  nginx:latest    "nginx"   Less than a second ago  running
  PORTS                         NODE      NAMES
  192.168.0.43:49177->80/tcp    node-1    frontend
  ```

  然后，使用 `-e affinity:container==frontend` 调度第二个容器，将其定位到容器 `frontend` 所在的位置：

  ```sh
  $ docker run -d --name logger -e affinity:container==frontend logger
  87c4376856a8

  $ docker ps
  CONTAINER ID  IMAGE           COMMAND   CREATED                 STATUS  
  87c4376856a8  nginx:latest    "nginx"   Less than a second ago  running
  963841b138d8  logger:latest   "logger"  Less than a second ago  running
  PORTS                         NODE      NAMES
  192.168.0.43:49177->80/tcp    node-1    frontend
                                node-1    logger
  ```
   
  你也能用 ID 来指定：

  ```sh
  $ docker run -d --name logger -e affinity:container==87c4376856a8
  ```

* 主机的一个镜像 

  你能调度 Swarm cluster 只在已经拉取完镜像的节点运行容器。比如，假设拉取三个镜像：  

  ```sh
  $ docker -H node-1:2375 pull redis
  $ docker -H node-2:2375 pull mysql
  $ docker -H node-3:2375 pull redis
  ```

  只有 `node-1` 和 `node-3` 拉取完 `redis` 镜像，然后，运行下面这些容器：

  ```sh
  $ docker run -d --name redis1 -e affinity:image==redis redis
  $ docker run -d --name redis2 -e affinity:image==redis redis
  $ docker run -d --name redis3 -e affinity:image==redis redis
  $ docker run -d --name redis4 -e affinity:image==redis redis
  $ docker run -d --name redis5 -e affinity:image==redis redis
  $ docker run -d --name redis6 -e affinity:image==redis redis
  $ docker run -d --name redis7 -e affinity:image==redis redis
  $ docker run -d --name redis8 -e affinity:image==redis redis

  $ docker ps
  CONTAINER ID  IMAGE           COMMAND   CREATED                 STATUS  
  87c4376856a8  redis:latest    "redis"   Less than a second ago  running
  1212386856a8  redis:latest    "redis"   Less than a second ago  running
  87c4376639a8  redis:latest    "redis"   Less than a second ago  running
  1234376856a8  redis:latest    "redis"   Less than a second ago  running
  86c2136253a8  redis:latest    "redis"   Less than a second ago  running
  87c3236856a8  redis:latest    "redis"   Less than a second ago  running
  87c4376856a8  redis:latest    "redis"   Less than a second ago  running
  963841b138d8  redis:latest    "redis"   Less than a second ago  running
  PORTS                         NODE      NAMES
                                node-1    redis1
                                node-1    redis2
                                node-3    redis3
                                node-1    redis4
                                node-3    redis5
                                node-3    redis6                              
                                node-3    redis7
                                node-1    redis8
  ```

  如你所看到的，容器只会被调度到已经有 `redis` 镜像的节点。你也能用 ID 来指定：

  ```sh
  $ docker run -d --name redis1 -e affinity:image==06a1f75304ba redis
  ```

* 容器采用的一个自定义标签

  根据自定义 label 过滤。比如，运行一个 Nginx 容器：

  ```sh
  $ docker run -d -p 80:80 --label com.example.type=frontend nginx
  87c4376856a8

  $ docker ps  --filter "label=com.example.type=frontend"
  CONTAINER ID  IMAGE           COMMAND   CREATED                 STATUS  
  87c4376856a8  nginx:latest    "nginx"   Less than a second ago  running
  PORTS                         NODE      NAMES
  192.168.0.43:49177->80/tcp    node-1    trusting_yonath
  ```

  然后，使用 `-e affnity:com.example.type==frontend` 调度第二个容器，将其定位到匹配 label 所在的位置：

  ```sh
  $ docker run -d -e affinity:com.example.type==frontend logger
  87c4376856a8

  $ docker ps
  CONTAINER ID  IMAGE           COMMAND   CREATED                 STATUS  
  87c4376856a8  nginx:latest    "nginx"   Less than a second ago  running
  963841b138d8  logger:latest   "logger"  Less than a second ago  running
  PORTS                         NODE      NAMES
  192.168.0.43:49177->80/tcp    node-1    trusting_yonath
                                node-1    happy_hawking
  ```

### dependency

`dependency` 过滤器重调依赖的容器（保持相同模式）。当前，依赖是这样声明的：

* `--volumes-from=dependency` 共享卷
* `--link=dependency:alias` 链接
* `--net=container:dependency` 共享网络栈

Swarm 尝试在同一个模式重调依赖的容器。如果不能完成（因为依赖的容器不存在，或者节点没有足够资源），则会阻止容器创建。

如果同时指定 `--volumes-from=A --net=container:B`，如果 `A` 容器和 `B` 容器不是运行在一个节点，那么调度器不对其进行调度。

### port

当 `port` 过滤器启用时，容器的端口配置作为唯一的约束。Swarm 选择一个可用的、未被其他容器或进程占用的端口。需要的端口必须被映射到主机端口，或者使用主机网络并且暴露一个端口。

例子，启动一个容器：

```sh
$ docker run -d -p 80:80 nginx
87c4376856a8

$ docker ps
CONTAINER ID  IMAGE           COMMAND   CREATED                 STATUS  
87c4376856a8  nginx:latest    "nginx"   Less than a second ago  running
PORTS                         NODE      NAMES
192.168.0.43:49177->80/tcp    node-1    prickly_engelbart
```

Docker Swarm 选择了一个节点 `node-1`，其端口号 `80` 是可用的并且未被其他容器或进程占用。尝试运行另一个容器，使其使用 Swarm cluster 主机的 `80` 端口，会选择一个不同的节点，因为 `node-1` 的 `80` 端口已经被占用了：

```sh
$ docker run -d -p 80:80 nginx
963841b138d8

$ docker ps
CONTAINER ID  IMAGE           COMMAND   CREATED                 STATUS  
963841b138d8  nginx:latest    "nginx"   Less than a second ago  running
87c4376856a8  nginx:latest    "nginx"   Less than a second ago  running
PORTS                         NODE      NAMES
192.168.0.43:80->80/tcp       node-2    dreamy_turing
192.168.0.42:80->80/tcp       node-1    prickly_engelbart
```

再次，重复运行一个容器，使其使用 `80` 端口，会选择 `node-3`：

```sh
$ docker run -d -p 80:80 nginx
963841b138d8

$ docker ps
CONTAINER ID  IMAGE           COMMAND   CREATED                 STATUS  
f8b693db9cd6  nginx:latest    "nginx"   Less than a second ago  running
963841b138d8  nginx:latest    "nginx"   Less than a second ago  running
87c4376856a8  nginx:latest    "nginx"   Less than a second ago  running
PORTS                         NODE      NAMES
192.168.0.44:80->80/tcp       node-3    stoic_albattani
192.168.0.43:80->80/tcp       node-2    dreamy_turing
192.168.0.42:80->80/tcp       node-1    prickly_engelbart
```

最后，如果再次运行一个容器使其使用 `80` 端口，因为 cluster 已经没有任何节点有 `80` 端口可用，这次请求会被拒绝：

```sh
$ docker run -d -p 80:80 nginx
2014/10/29 00:33:20 Error response from daemon: no resources available to schedule container
```

每当容器创建的时候就占用其所在节点的端口，当容器删除的时候则释放该端口。在 `exited` 状态的容器仍然占有端口。如果容器 `prickly_engelbart` 在 `node-1`，是停止状态但是没有删除，尝试在 `node-1` 启动另一个容器并让其监听 `80` 端口会失败，因为 `80` 端口已经被 `prickly_engelbart` 占用了。

以 `--net=host` 运行的容器和默认的 `--net=bridge` 有些不同，`host` 不执行任何端口绑定。代替的是，需要你明确指出要暴露的端口号。你可以在 Dockerfile 文件的 `EXPOSE` 或命令行 `--expose` 暴露端口。Swarm 确保在 cluster 选择一个端口可用的节点。

比如，启动一个 Nginx：

```sh
$ docker run -d --expose=80 --net=host nginx
640297cb29a7
$ docker run -d --expose=80 --net=host nginx
7ecf562b1b3f
$ docker run -d --expose=80 --net=host nginx
09a92f582bc2
```

执行 `docker ps` 命令，你会发现其中的端口号信息不可用 --- 它们都以 `--net=host` 模式运行：

```sh
$ docker ps
CONTAINER ID  IMAGE        COMMAND               CREATED                 STATUS  
640297cb29a7  nginx:1      "nginx -g 'daemon of  Less than a second ago  running
7ecf562b1b3f  nginx:1      "nginx -g 'daemon of  Less than a second ago  running
09a92f582bc2  nginx:1      "nginx -g 'daemon of  Less than a second ago  running
PORTS                      NODE                  NAMES
                           node-3                box3/furious_heisenberg
                           node-2                box2/ecstatic_meitner
                           node-1                box1/mad_goldstine
```

当再次尝试运行一个这样的监听 `80` 主机端口的容器时，Swarm 会拒绝该请求：

```sh
$  docker run -d --expose=80 --net=host nginx
FATA[0000] Error response from daemon: unable to find a node with port 80/tcp available in the Host mode
```

然后，端口绑定到不同的值，比如 `81`，是有效的：

```sh
$  docker run -d -p 81:80 nginx:latest
832f42819adc

$  docker ps
CONTAINER ID  IMAGE        COMMAND               CREATED                 STATUS  
832f42819adc  nginx:1      "nginx -g 'daemon of  Less than a second ago  running
640297cb29a7  nginx:1      "nginx -g 'daemon of  Less than a second ago  running
7ecf562b1b3f  nginx:1      "nginx -g 'daemon of  Less than a second ago  running
09a92f582bc2  nginx:1      "nginx -g 'daemon of  Less than a second ago  running
PORTS                       NODE                  NAMES
192.168.136.136:81->80/tcp  node-3                box3/thirsty_hawking
                            node-3                box3/furious_heisenberg
                            node-2                box2/ecstatic_meitner
                            node-1                box1/mad_goldstine
```

###
  
## 如何写过滤器表达式

为了采用 `constraint` 或 `affinity` 过滤器，你必须使用过滤器表达式指定容器的环境变量：

```sh
$ docker run -d --name redis1 -e affinity:image==~redis redis
```

每个表达式必须是这种格式：

```sh
<filter-type>:<key><operator><value>
```

`<filter-type>` 是 `constraint` 或 `affinity` 关键字，指定过滤器的类型。

`<key>` 必须是：

* `container` 关键字
* `node` 关键字
* 一个默认 tag （对应 `constraint`）
* 一个自定义元数据 label （节点或容器）

`<operator>` 可以是 `==` 或 `!=`。默认情况下，表达式是精确匹配的。如果表达式没有正确匹配，manager 不会调度这个容器。你可以用 `~` 创建一个 soft 表达式，如果表达式没有匹配，调度器放弃这个过滤器，并根据策略来调度这个容器。

`value` 是下列值：

* 通配符模式，比如 `abc*`
* 正则表达式，形式为 `/regexp/`

下面列出了一些合法的表达式：

* `constraint:node==node1` 匹配 `node1` 节点
* `constraint:node!=node1` 匹配所有节点，除了 `node1` 节点
* `constraint:region!=us*` 匹配所有节点 --- `region` 前面没有 `us` 前缀
* `constraint:node==/node[12]/` 匹配节点 `node1` 和 `node2`
* `constraint:node==/node\d/` 匹配所有 `node` + 数字的节点 
* `constraint:node!=/node-[01]/` 匹配所有节点，除了 `node0`、`node1`
* `constraint:node!=/foo\[bar\]/` 匹配所有节点，除了 `foo[bar]`
* `affinity:image==~redis` 尝试匹配有 `redis` 镜像的节点



