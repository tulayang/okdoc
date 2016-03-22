# [绑定容器端口和主机端口](https://docs.docker.com/v1.9/engine/userguide/networking/default_network/binding/)

这里所描述的容器端口，是 Docker 默认的 bridge。然而，你可以创建自定义的网络。

默认情况下，Docker 容器可以连接到外部世界，但是，外部世界不能连接到容器。借助于 `iptables` 的伪装规则，Docker daemon 启动时创建一个伪装规则，能够连接到外部世界：

```sh
$ sudo iptables -t nat -L -n
...
Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination
MASQUERADE  all  --  172.17.0.0/16       0.0.0.0/0
...
```

如果你想要 Docker 容器能接受外部世界的连接，必须在 `docker run` 时指定特殊配置。有两种方法。

1. 在 `docker run` 中指定 `-P` 或 `--publish-all=true|false`，把镜像 Dockerfile `EXPOSE` 或 `--expose <port>` 映射到主机端口的一个范围。`docker port` 命令能看到已经创建的映射。主机端口的可用范围配置在 */proc/sys/net/ipv4/ip_local_port_range* （内核参数），通常是 `32768` 到 `61000`。

2. 也能用 `-p` 或 `--publish` 明确指定映射到哪一个主机端口。
 
无论哪种方法，都能在 NAT 表中查看已经建立的网络栈：

```sh
# What your NAT rules might look like when Docker
# is finished setting up a -P forward:

$ iptables -t nat -L -n
...
Chain DOCKER (2 references)
target     prot opt source               destination
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:49153 to:172.17.0.2:80

# What your NAT rules might look like when Docker
# is finished setting up a -p 80:80 forward:

Chain DOCKER (2 references)
target     prot opt source               destination
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:80 to:172.17.0.2:80
```

你能看到 Docker 已经在 `0.0.0.0` 暴露了容器端口，这个通配 IP 地址会匹配该主机（机器）端口任何进入的流量。如果你想加入一些限制，只允许容器联系主机的某个特定网络接口，可以这样做：`docker run` 时指定 `-p IP:host_port:container_port` 或 `-p IP::port` 绑定一个特定的网络接口。

或者，如果你总是希望 Docker 端口转发被绑定到一个特定的 IP 地址，你可以配置 Docker daemon 的配置 `--ip=IP_ADDRESS`。之后，重启 Docker daemon。

> Note: With hairpin NAT enabled (`--userland-proxy=false`), containers port exposure is achieved purely through iptables rules, and no attempt to bind the exposed port is ever made. This means that nothing prevents shadowing a previously listening service outside of Docker through exposing the same port for a container. In such conflicting situation, Docker created iptables rules will take precedence and route to the container.

The `--userland-proxy` parameter, true by default, provides a userland implementation for inter-container and outside-to-container communication. When disabled, Docker uses both an additional `MASQUERADE` iptable rule and the `net.ipv4.route_localnet` kernel parameter which allow the host machine to connect to a local container exposed port through the commonly used loopback address: this alternative is preferred for performance reasons.