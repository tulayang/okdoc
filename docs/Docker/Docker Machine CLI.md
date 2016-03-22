#  [Docker Machine 命令行接口](https://docs.docker.com/machine/reference/create/)

## `$ docker-machine help subcommand`

显示帮助信息。例子：

```sh
$ docker-machine help config
```

## `$ docker-machine create [OPTIONS] [arg...]`

OPTIONS|描述
-------|----
`--driver`,`-d` "none"|驱动
`-engine-install-url` "https://get.docker.com"|自定义安装 Engine 的 URL [$MACHINE_DOCKER_INSTALL_URL]
`--engine-opt` | 通用配置标志位，为创建的 Engine 指定配置项
`--engine-insecure-registry`|为创建的 Engine 指定（个人）仓库
`--engine-label`|为创建的 Engine 指定标签
`--engine-storage-driver`|为创建的 Engine 指定存储驱动
`--engine-env`|为创建的 Engine 指定环境变量
`--swarm`|为机器配置 Swarm 
`--swarm-image` "swarm:latest"|指定使用的 Swarm 镜像
`--swarm-master`|使机器成为一个 Swarm master
`--swarm-discovery`|使用 Swarm 的探测服务
`--swarm-strategy` ""spread|设置 Swarm 定义的调度策略
`--swarm-opt`|通用配置标志位，为机器指定 Swarm 配置项
`--swarm-host` "tcp://0.0.0.0:3376"|设置 Swarm master 监听的 IP 地址和端口号
`--swarm-addr`|addr to advertise for Swarm (default: detect and use the machine IP)

创建一个机器。需要指定 `--driver` 标志位提供驱动（VirtualBox、DigitalOcean、AWS、...），以及机器名字：

```sh
$ docker-machine create --driver virtualbox dev
Creating CA: /home/username/.docker/machine/certs/ca.pem
Creating client certificate: /home/username/.docker/machine/certs/cert.pem
Image cache does not exist, creating it at /home/username/.docker/machine/cache...
No default boot2docker iso found locally, downloading the latest release...
Downloading https://github.com/boot2docker/boot2docker/releases/download/v1.6.2/boot2docker.iso to /home/username/.docker/machine/cache/boot2docker.iso...
Creating VirtualBox VM...
Creating SSH key...
Starting VirtualBox VM...
Starting VM...
To see how to connect Docker to this machine, run: docker-machine env dev
```

### 指定驱动后，查看帮助信息

`docker-machine create` 的许多标志位支持所有驱动，此外，特定驱动还有一些额外的标志位。比如 `--amazonec2-instance-type m1.medium`、`--amazonec2-region us-west-1`、... 。

想查看特定驱动的标志位，可以这样做：

```sh
$ docker-machine create --driver virtualbox --help
Usage: docker-machine create [OPTIONS] [arg...]

Create a machine.

Run 'docker-machine create --driver name' to include the create flags for that driver in the help text.

Options:

   --driver, -d "none"               

   --engine-env [--engine-env option --engine-env option]

   --engine-insecure-registry [--engine-insecure-registry option --engine-insecure-registry option]
   Specify insecure registries to allow with the created engine

   --engine-install-url "https://get.docker.com"     
   Custom URL to use for engine installation [$MACHINE_DOCKER_INSTALL_URL]

   --engine-label [--engine-label option --engine-label option]   
   Specify labels for the created engine

   --engine-opt [--engine-opt option --engine-opt option]  
   Specify arbitrary flags to include with the created engine in the form flag=value

   --engine-registry-mirror [--engine-registry-mirror option --engine-registry-mirror option]   
   Specify registry mirrors to use

   --engine-storage-driver    
   Specify a storage driver to use with the engine

   --swarm        
   Configure Machine with Swarm

   --swarm-addr      
   addr to advertise for Swarm (default: detect and use the machine IP)

   --swarm-discovery             
   Discovery service to use with Swarm

   --swarm-host "tcp://0.0.0.0:3376"  
   ip/socket to listen on for Swarm master

   --swarm-image "swarm:latest"       
   Specify Docker image to use for Swarm [$MACHINE_SWARM_IMAGE]

   --swarm-master                 
   Configure Machine to be a Swarm master

   --swarm-opt [--swarm-opt option --swarm-opt option]    
   Define arbitrary flags for swarm

   --swarm-strategy "spread"  
   Define a default scheduling strategy for Swarm

   --virtualbox-boot2docker-url    
   The URL of the boot2docker image. Defaults to the latest available version [$VIRTUALBOX_BOOT2DOCKER_URL]

   --virtualbox-cpu-count "1"     
   number of CPUs for the machine (-1 to use the number of CPUs available) [$VIRTUALBOX_CPU_COUNT]

   --virtualbox-disk-size "20000"     
   Size of disk for host in MB [$VIRTUALBOX_DISK_SIZE]
   
   --virtualbox-memory "1024"     
   Size of memory for host in MB [$VIRTUALBOX_MEMORY_SIZE]

   --virtualbox-no-share  
   Disable the mount of your home directory

   --virtualbox-host-dns-resolver   
   Use the host DNS resolver [$VIRTUALBOX_HOST_DNS_RESOLVER]

   --virtualbox-dns-proxy   
   Proxy all DNS requests to the host [$VIRTUALBOX_DNS_PROXY]

   --virtualbox-hostonly-cidr "192.168.99.1/24" 
   Specify the Host Only CIDR [$VIRTUALBOX_HOSTONLY_CIDR]

   --virtualbox-hostonly-nicpromisc "deny" 
   Specify the Host Only Network Adapter Promiscuous Mode [$VIRTUALBOX_HOSTONLY_NIC_PROMISC]

   --virtualbox-hostonly-nictype "82540EM" 
   Specify the Host Only Network Adapter Type [$VIRTUALBOX_HOSTONLY_NIC_TYPE]

   --virtualbox-import-boot2docker-vm  
   The name of a Boot2Docker VM to import
```

### 为 Docker Engine 指定配置

作为创建过程的一部分，Docker Machine 会安装 Docker 并为其做一些默认配置。比如，和外部连接使用基于 TLS 编码的 TCP，使用 aufs 作为存储驱动。

用户可能想要设定自己的配置。比如，为 Docker Engine 设定自己的仓库。Docker Machine 支持用户配置创建的 Docker Engine，这些标志位前面带有 `engine`。例子：

```sh
$ docker-machine create -d virtualbox            \
    --engine-label foo=bar                       \
    --engine-label spam=eggs                     \
    --engine-storage-driver overlay              \
    --engine-insecure-registry registry.myco.com \
    foobarmachine
```

这条命令用 Virtualbox 在本地创建一个虚拟机，在其中安装 Docker Engine。这个 Docker Engine 使用 `overlay` 存储驱动，有 `foo=bar` 和 `spam=eggs` 标签，允许从 `registry.myco.com` 推送拉取镜像。你可以使用 `docker info` 验证一下：

```sh
$ eval $(docker-machine env foobarmachine)
$ docker info
Containers: 0
Images: 0
Storage Driver: overlay
...
Name: foobarmachine
...
Labels:
 foo=bar
 spam=eggs
 provider=virtualbox
```

为创建的 Docker Engine 指定配置，支持的标志位有：

* `--engine-insecure-registry`

  为创建的 Engine 指定不安全的仓库。

* `--engine-registry-mirror`

  为创建的 Engine 指定 [registry mirrors](https://github.com/docker/distribution/blob/master/docs/mirror.md) 。

* `--engine-label`

  为创建的 Engine 指定标签。

* `--engine-storage-driver`

  为创建的 Engine 指定存储驱动。

除了上面支持的直接指定 Engine 配置标志位，Docker Machine 也支持另一个通用的配置标志位 `--engine-opt`，使用语法 `--engine-opt flagname=value` 配置 Engine 。比如，让 daemon 对所有的容器使用 `8.8.8.8` DNS 服务器，并且用 `syslog` 日志驱动：

```sh
$ docker-machine create -d virtualbox           \
                 --engine-opt dns=8.8.8.8       \
                 --engine-opt log-driver=syslog \
                 gdns
```

此外，也支持为创建的引擎设定环境变量，标志位语法是 `--engine-env name=value`。比如，为创建的引擎指定代理服务器是 `example.com`：

```sh
$ docker-machine create -d virtualbox                              \
                 --engine-env HTTP_PROXY=http://example.com:8080   \
                 --engine-env HTTPS_PROXY=https://example.com:8080 \
                 --engine-env NO_PROXY=example2.com                \
                 proxbox
```

### 为机器指定 Docker Swarm 配置

Docker Machine 除了能够为创建的 Docker Engine 指定配置，还能为创建的机器配置 Swarm master。`--swarm-strategy` 用来配置调度策略 --- Docker Swarm 需要使用（默认是 `spread`）。也支持一个通用的配置标志位 `--swarm-opt`，它和 `--engine-opt` 很相似。例子：

```sh
$ docker-machine create -d virtualbox              \
                 --swarm                           \
                 --swarm-master                    \
                 --swarm-discovery token://<token> \
                 --swarm-strategy binpack          \
                 --swarm-opt heartbeat=5           \
                 upbeat
```

如果你不确定如何配置这些内容，最好让它们保持默认。

### 

## `$ docker-machine start machinname`

启动机器：

```sh
$ docker-machine start dev
Starting VM...
```

## `$ docker-machine stop machinname`

优雅地停止机器：

```sh
$ docker-machine ls
NAME   ACTIVE   DRIVER       STATE     URL
dev    *        virtualbox   Running   tcp://192.168.99.104:2376
$ docker-machine stop dev
$ docker-machine ls
NAME   ACTIVE   DRIVER       STATE     URL
dev    *        virtualbox   Stopped
```

## `$ docker-machine restart machinname`

重新启动机器，相当于 `docker-machine stop; docker-machine start`：

```sh
$ docker-machine restart dev
Waiting for VM to start...
```

## `$ docker-machine kill machinename`

强制停止机器：

```sh
$ docker-machine ls
NAME   ACTIVE   DRIVER       STATE     URL
dev    *        virtualbox   Running   tcp://192.168.99.104:2376
$ docker-machine kill dev
$ docker-machine ls
NAME   ACTIVE   DRIVER       STATE     URL
dev    *        virtualbox   Stopped
```

## `$ docker-machine rm [OPTIONS] machinename`

OPTIONS|描述
-------|----
`--force`，`-f`|强制删除机器
`-y`|当删除的时候，自动回复 `yes`

删除一个机器：

```sh
$ docker-machine ls
NAME   ACTIVE   URL          STATE     URL                         SWARM   DOCKER   ERRORS
bar    -        virtualbox   Running   tcp://192.168.99.101:2376           v1.9.1
baz    -        virtualbox   Running   tcp://192.168.99.103:2376           v1.9.1
foo    -        virtualbox   Running   tcp://192.168.99.100:2376           v1.9.1
qix    -        virtualbox   Running   tcp://192.168.99.102:2376           v1.9.1


$ docker-machine rm baz
About to remove baz
Are you sure? (y/n): y
Successfully removed baz


$ docker-machine ls
NAME   ACTIVE   URL          STATE     URL                         SWARM   DOCKER   ERRORS
bar    -        virtualbox   Running   tcp://192.168.99.101:2376           v1.9.1
foo    -        virtualbox   Running   tcp://192.168.99.100:2376           v1.9.1
qix    -        virtualbox   Running   tcp://192.168.99.102:2376           v1.9.1


$ docker-machine rm bar qix
About to remove bar, qix
Are you sure? (y/n): y
Successfully removed bar
Successfully removed qix


$ docker-machine ls
NAME   ACTIVE   URL          STATE     URL                         SWARM   DOCKER   ERRORS
foo    -        virtualbox   Running   tcp://192.168.99.100:2376           v1.9.1

$ docker-machine rm -y foo
About to remove foo
Successfully removed foo
```

## `$ docker-machine upgrade machinename`

升级一个机器，让其获得最新版本的 Docker Engine。如何执行升级过程，依赖底层操作系统。

比如，如果机器安装的是 Ubuntu，它会运行类似 `sudo apt-get upgrade lxc-docker` 的命令。例子：

```sh
$ docker-machine upgrade dev
Stopping machine to do the upgrade...
Upgrading machine dev...
Downloading latest boot2docker release to /home/username/.docker/machine/cache/boot2docker.iso...
Starting machine back up...
Waiting for VM to start...
```

## `$ docker-machine regenerate-certs machinename`

重新生成 TLS 证书，并用这些新证书更新机器：

```sh
$ docker-machine regenerate-certs dev
Regenerate TLS machine certs?  Warning: this is irreversible. (y/n): y
Regenerating TLS certificates
```

## `$ docker-machine env [OPTIONS] machinename`

OPTIONS|描述
-------|----
`--swarm`|显示该 Docker Engine 的 Swarm 配置
`--shell`|
`--unset`，`-u`|取消已经配置的项
`-no-proxy`|把机器 IP 地址添加到 `NO_PROXY` 环境变量

配置到指定的机器的环境变量，以便于能在该机器运行 `docker` 命令。

`docker-machine env machinename` 会打印 `export` 命令 --- 它们能够在子 Shell 中运行。`docker-machine env -u` 会置空已经配置的环境变量。例子：

```sh
$ env | grep DOCKER
$ eval "$(docker-machine env dev)"
$ env | grep DOCKER
DOCKER_HOST=tcp://192.168.99.101:2376
DOCKER_CERT_PATH=/Users/nathanleclaire/.docker/machines/.client
DOCKER_TLS_VERIFY=1
DOCKER_MACHINE_NAME=dev
$ # If you run a docker command, now it will run against that host.
$ eval "$(docker-machine env -u)"
$ env | grep DOCKER
$ # The environment variables have been unset.
```

`--no-proxy` 能确保创建的机器 IP 地址加入到 `NO_PROXY` 环境变量。当使用 Docker Machine 使用本地虚拟驱动（比如 `virtualbox`、`vmwarefusion`）通过 HTTP 代理进行网络访问时，这会很有用：

```sh
$ docker-machine env --no-proxy default
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.99.104:2376"
export DOCKER_CERT_PATH="/Users/databus23/.docker/machine/certs"
export DOCKER_MACHINE_NAME="default"
export NO_PROXY="192.168.99.104"
# Run this command to configure your shell:
# eval "$(docker-machine env default)"
```

## `$ docker-machine status machinename`

显示机器的状态：

```sh
$ docker-machine status dev
Running
```

## `$ docker-machine inspect [OPTIONS] machinename`

OPTIONS|描述
-------|----
`--format`，`-f`|格式化输出

显示机器的底层信息。默认情况下，输出被渲染成 JSON 。例子：

```sh
$ docker-machine inspect dev
{
    "DriverName": "virtualbox",
    "Driver": {
        "MachineName": "docker-host-128be8d287b2028316c0ad5714b90bcfc11f998056f2f790f7c1f43f3d1e6eda",
        "SSHPort": 55834,
        "Memory": 1024,
        "DiskSize": 20000,
        "Boot2DockerURL": "",
        "IPAddress": "192.168.5.99"
    },
    ...
}
```

获取一个 IP 地址：

```sh
$ docker-machine inspect --format='{{.Driver.IPAddress}}' dev
192.168.5.99
```

## `$ docker-machine config machinename`

显示指定机器的 Docker client 配置：

```sh
$ docker-machine config dev
--tlsverify
--tlscacert="/Users/ehazlett/.docker/machines/dev/ca.pem"
--tlscert="/Users/ehazlett/.docker/machines/dev/cert.pem"
--tlskey="/Users/ehazlett/.docker/machines/dev/key.pem"
-H tcp://192.168.99.103:2376
```

## `$ docker-machine ls [OPTIONS] [arg...]`

OPTIONS|描述
-------|----
`--quiet`，`-q`|启用静默模式
`--filter`，`-f`|过滤输出
`--timeout`，`-t`|超时时间，默认是 `10s`
`--help`|打印帮助信息

列出所有机器。

### 超时

`ls` 尝试向各主机发送探测信息。当某个主机超过一定时间（默认是 `10s`）没有回复时，其会被认为是 `Timeout`。例子：

```sh
$ docker-machine ls -t 12
NAME      ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER   ERRORS
default   -        virtualbox   Running   tcp://192.168.99.100:2376           v1.9.1
```

### 过滤器

`--filter` 是一个 `key=value` 格式的过滤标志位。当前支持的过滤器：

* `driver` 驱动名
* `swarm` Swarm master 名
* `state` 运行状态（`Running|Paused|Saved|Stopped|Stopping|Starting|Error`）
* `name` 机器名
* `label` 标签

```sh
$ docker-machine ls
NAME   ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER   ERRORS
dev    -        virtualbox   Stopped
foo0   -        virtualbox   Running   tcp://192.168.99.105:2376           v1.9.1
foo1   -        virtualbox   Running   tcp://192.168.99.106:2376           v1.9.1
foo2   *        virtualbox   Running   tcp://192.168.99.107:2376           v1.9.1

$ docker-machine ls --filter name=foo0
NAME   ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER   ERRORS
foo0   -        virtualbox   Running   tcp://192.168.99.105:2376           v1.9.1

$ docker-machine ls --filter driver=virtualbox --filter state=Stopped
NAME   ACTIVE   DRIVER       STATE     URL   SWARM   DOCKER   ERRORS
dev    -        virtualbox   Stopped                 v1.9.1

$ docker-machine ls --filter label=com.class.app=foo1 --filter label=com.class.app=foo2
NAME   ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER   ERRORS
foo1   -        virtualbox   Running   tcp://192.168.99.105:2376           v1.9.1
foo2   *        virtualbox   Running   tcp://192.168.99.107:2376           v1.9.1
```

### 

## `$ docker-machine active`

查看 active 机器（如果 `DOCKER_HOST` 环境变量指向该机器，该机器就被认为是 active）：

```sh
$ docker-machine ls
NAME      ACTIVE   DRIVER         STATE     URL
dev       -        virtualbox     Running   tcp://192.168.99.103:2376
staging   *        digitalocean   Running   tcp://203.0.113.81:2376

$ echo $DOCKER_HOST
tcp://203.0.113.81:2376

$ docker-machine active
staging
```

## `$ docker-machine ip machinename`

获取一个或多个机器的 IP 地址：

```sh
$ docker-machine ip dev
192.168.99.104

$ docker-machine ip dev dev2
192.168.99.104
192.168.99.105
```

## `$ docker-machine url machinename`

获取机器的 URL：

```sh
$ docker-machine url dev
tcp://192.168.99.109:2376
```

## `$ docker-machine ssh machinename`

通过 SSH 登录一个机器。例子：

```sh
$ docker-machine ssh dev
                        ##        .
                  ## ## ##       ==
               ## ## ## ##      ===
           /""""""""""""""""\___/ ===
      ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~
           \______ o          __/
             \    \        __/
              \____\______/
 _                 _   ____     _            _
| |__   ___   ___ | |_|___ \ __| | ___   ___| | _____ _ __
| '_ \ / _ \ / _ \| __| __) / _` |/ _ \ / __| |/ / _ \ '__|
| |_) | (_) | (_) | |_ / __/ (_| | (_) | (__|   <  __/ |
|_.__/ \___/ \___/ \__|_____\__,_|\___/ \___|_|\_\___|_|
Boot2Docker version 1.4.0, build master : 69cf398 - Fri Dec 12 01:39:42 UTC 2014
docker@boot2docker:~$ ls /
Users/   dev/     home/    lib/     mnt/     proc/    run/     sys/     usr/
bin/     etc/     init     linuxrc  opt/     root/    sbin/    tmp      var/
```

你也能指定 `docker-machine ssh` 命令直接运行远程命令，只需要再后面跟随命令即可：

```sh
$ docker-machine ssh dev free
             total         used         free       shared      buffers
Mem:       1023556       183136       840420            0        30920
-/+ buffers:             152216       871340
Swap:      1212036            0      1212036
```

跟随命令也可以有标志位：

```sh
$ docker-machine ssh dev df -h
Filesystem                Size      Used Available Use% Mounted on
rootfs                  899.6M     85.9M    813.7M  10% /
tmpfs                   899.6M     85.9M    813.7M  10% /
tmpfs                   499.8M         0    499.8M   0% /dev/shm
/dev/sda1                18.2G     58.2M     17.2G   0% /mnt/sda1
cgroup                  499.8M         0    499.8M   0% /sys/fs/cgroup
/dev/sda1                18.2G     58.2M     17.2G   0%
/mnt/sda1/var/lib/docker/aufs
```

默认情况下，Docker Machine 会检查本地是否有 ssh 二进制。如果有的话，就使用 ssh ；如果没有的话，则使用内部实现的 crypto/ssh。你也可以强制其使用内部实现的 crypto/ssh：

```sh
$ docker-machine --native-ssh ssh dev
```

## `$ docker-machine scp machinename:/path/to/files`

从本地主机到机器、从一个机器到另一个机器、从机器到本地主机传输文件（拷贝）。例子：

```sh
$ cat foo.txt
cat: foo.txt: No such file or directory

$ docker-machine ssh dev pwd
/home/docker

$ docker-machine ssh dev 'echo A file created remotely! >foo.txt'
$ docker-machine scp dev:/home/docker/foo.txt .
foo.txt                                                           100%   28     0.0KB/s   00:00

$ cat foo.txt
A file created remotely!
```

和 scp 相同的是，`docker-machine scp` 也能指定 `-r` 来执行递归拷贝。

