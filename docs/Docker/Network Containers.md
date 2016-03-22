# [网络示范](https://docs.docker.com/engine/userguide/containers/networkingcontainers/)

## 为容器命名

当执行 `docker run` 运行容器时，你能指定 `--name` 标志位为容器命名：

```sh
$ docker run -d -P --name web training/webapp python app.py
```

使用 `docker ps` 看一下：

```sh
$ docker ps -l
CONTAINER ID  IMAGE                   COMMAND        
aed84ee21bde  training/webapp:latest  python app.py  
CREATED       STATUS                  PORTS                    NAMES
12 hours ago  Up 2 seconds            0.0.0.0:49154->5000/tcp  web
```

也可以使用 `docker inspect` 看下更底层的信息：

```sh
$ docker inspect web
[
{
    "Id": "3ce51710b34f5d6da95e0a340d32aa2e6cf64857fb8cdb2a6c38f7c56f448143",
    "Created": "2015-10-25T22:44:17.854367116Z",
    "Path": "python",
    "Args": [
        "app.py"
    ],
    "State": {
        "Status": "running",
        "Running": true,
        "Paused": false,
        "Restarting": false,
        "OOMKilled": false,
  ...

```

容器名必须是唯一的。如果之前把一个容器命名为 `web`，之后，就不能把其他容器命名为 `web`，直到删除之前那个容器。想要删除容器，请先停止容器：

```sh
$ docker stop web
web
$ docker rm web
web
```

## 运行一个容器，使用默认网络

默认情况下，Docker 提供了两个网络驱动：bridge 和 overlay。你也可以自己编写网络驱动插件，实现自己的网络驱动。

Docker Engine 安装时会自动包含三个默认网络。它们是：

```sh
$ docker network ls
NETWORK ID      NAME      DRIVER
18a2866682b8    none      null                
c288470c46f6    host      host                
7b369448dccb    bridge    bridge  
```

`bridge` 网络是一个特殊的网络。当运行容器时，如果不指定网络，则默认运行在 `bridge` 网络：

```sh
$ docker run -itd --name=networktest ubuntu
74695c9cea6d9810718fddadc01a727a5dd3ce6a69d09752239736c030599741
```

使用 `docker network inspect` 可以查看网络的底层信息：

```sh
$ docker network inspect bridge
[
    {
        "Name": "bridge",
        "Id": "f7ab26d71dbd6f557852c7156ae0574bbf62c42f539b50c8ebde0f728a253b6f",
        "Scope": "local",
        "Driver": "bridge",
        "IPAM": {
            "Driver": "default",
            "Config": [
                {
                    "Subnet": "172.17.0.1/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Containers": {
            "3386a527aa08b37ea9232cbcace2d2458d49f44bb05a6b775fba7ddd40d8f92c": {
                "EndpointID": "647c12443e91faf0fd508b6edfe59c30b642abb60dfab890b4bdccee38750bc1",
                "MacAddress": "02:42:ac:11:00:02",
                "IPv4Address": "172.17.0.2/16",
                "IPv6Address": ""
            },
            "94447ca479852d29aeddca75c28f7104df3c3196d7b6d83061879e339946805c": {
                "EndpointID": "b047d090f446ac49747d3c37d63e4307be745876db7f0ceef7b311cbba615f48",
                "MacAddress": "02:42:ac:11:00:03",
                "IPv4Address": "172.17.0.3/16",
                "IPv6Address": ""
            }
        },
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "9001"
        }
    }
]
```

使用 `docker network disconnect` 命令可以把容器从一个网络中断开连接，从网络中移除（指定网络名和容器名）：

```sh
$ docker network disconnect bridge networktest
```

尽管可以把容器从网络中移除，但是你不能移除内置的名为 `bridge` 的网络。网络是隔离容器的绝佳方式。

## 创建一个 bridge 网络

Docker Engine 原生支持 bridge 和 overlay 网络。bridge 网络只允许 Docker Engine 所在主机上的容器之间通信。overlay 网络则允许多个主机上的容器通信。

举个例子，创建一个 bridge 网络：

```sh
$ docker network create -d bridge my-bridge-network
```

这条命令中，`-d` 指定使用的网络驱动。如果没有指定的话，则默认使用 bridge 网络。

现在，使用 `docker network ls` 看一下现有的网络：

```sh
$ docker network ls
NETWORK ID      NAME                 DRIVER
18a2866682b8    none                 null                
c288470c46f6    host                 host                
7b369448dccb    bridge               bridge  
615d565d498c    my-bridge-network    bridge        
```

使用 `docker network inspect` 看一下 `my-bridge-network` 的信息，你会发现什么东西也没有：

```sh
$ docker network inspect my-bridge-network
[
    {
        "Name": "my-bridge-network",
        "Id": "5a8afc6364bccb199540e133e63adb76a557906dd9ff82b94183fc48c40857ac",
        "Scope": "local",
        "Driver": "bridge",
        "IPAM": {
            "Driver": "default",
            "Config": [
                {
                    "Subnet": "172.18.0.0/16",
                    "Gateway": "172.18.0.1/16"
                }
            ]
        },
        "Containers": {},
        "Options": {}
    }
]
```

## 把容器添加到网络

网络，为容器提供了彻底的隔离。当你第一次运行容器的时候，你可以把容器添加到某个网络。

举个例子，启动一个容器（运行一个 PostgreSQL 数据库） `db`，指定 `--net=my-bridge-network` 把容器连接到该网络：

```sh
$ docker run -d --net=my-bridge-network --name db training/postgres
```

使用 `docker inspect` 你会发现容器已经添加到了这个网络：

```sh
$ docker inspect --format='{{json .NetworkSettings.Networks}}'  db
{"my-bridge-network":{"NetworkID":"7d86d31b1478e7cca9ebed7e73aa0fdeec46c5ca29497431d3007d2d9e15ed99",
"EndpointID":"508b170d56b2ac9e4ef86694b0a76a22dd3df1983404f7321da5649645bf7043","Gateway":"172.18.0.1","IPAddress":"172.18.0.2","IPPrefixLen":16,"IPv6Gateway":"","GlobalIPv6Address":"","GlobalIPv6PrefixLen":0,"MacAddress":"02:42:ac:11:00:02"}}
```

然后，继续启动一个容器 `web`（连接到默认网络 `bridge`）：

```sh
$ docker run -d --name web training/webapp python app.py
```

看一下 `web` 的 IP 地址：

```sh
$ docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' web
172.17.0.2
```

现在，为 `db` 容器打开一个 Shell，尝试 `ping` `web` 容器的 IP 地址：

```sh
$ docker exec -it db bash
root@a205f0dd33b2:/# ping 172.17.0.2
ping 172.17.0.2
PING 172.17.0.2 (172.17.0.2) 56(84) bytes of data.
^C
--- 172.17.0.2 ping statistics ---
44 packets transmitted, 0 received, 100% packet loss, time 43185ms
```
 
你会发现，在 `db` 容器 `ping` `web` 容器的 IP 地址失败了。这是因为两个容器连接到了不同的网络上。 

使用 `docker network connect` 把容器 `web` 连接到 `my-bridge-network web` 网络：

```sh
$ docker network connect my-bridge-network web
```  

现在，为 `db` 容器打开一个 Shell，再次尝试 `ping` `web` 容器的 IP 地址：

```sh
$ docker exec -it db bash
root@a205f0dd33b2:/# ping web
PING web (172.18.0.3) 56(84) bytes of data.
64 bytes from web (172.18.0.3): icmp_seq=1 ttl=64 time=0.095 ms
64 bytes from web (172.18.0.3): icmp_seq=2 ttl=64 time=0.060 ms
64 bytes from web (172.18.0.3): icmp_seq=3 ttl=64 time=0.066 ms
^C
--- web ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2000ms
rtt min/avg/max/mdev = 0.060/0.073/0.095/0.018 ms
```

从上面可以看出，能够成功 `ping` 通另一个容器的 IP 地址了。