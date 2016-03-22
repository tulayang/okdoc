# [如何配置和运行 Docker](https://docs.docker.com/v1.9/engine/articles/configuring/)

成功安装 Docker Engine 后，`docker` 守护进程使用默认的配置自动运行。

在产品环境中，系统管理员往往根据环境要求来配置 `docker` 守护进程，以管理启动和停止。大多数情况下，是通过进程管理器 `SysVinit`、`Upstart`、或 `systemd` 来配置 `docker` 守护进程的启动和停止。

## 直接运行 Docker daemon 

可以使用 `docker daemon` 命令直接运行 `docker` 守护进程。默认情况下，它监听 Unix Domain Socket `unix:///var/run/docker.sock`：

```sh
$ docker daemon

INFO[0000] +job init_networkdriver()
INFO[0000] +job serveapi(unix:///var/run/docker.sock)
INFO[0000] Listening for HTTP on unix (/var/run/docker.sock)
...
...
```

## 直接配置 Docker daemon 

如果你没有用进程管理器，而是直接使用 `docker daemon` 运行 `docker` 守护进程，那么你在命令行指定配置项。下面是其中的一些配置项：

OPTIONS|描述
-------|----
`-D`，`--debug=false`|启用或禁用调试模式。默认，是 `false`。
`-H`，`--host=[]`|守护进程监听的套接字。
`--tls=false`|启用或禁用 TLS。默认，是 `false`。
``

例子：

```sh
$ docker daemon -D                                           \
                --tls=true --tlscert=/var/docker/server.pem  \
                --tlskey=/var/docker/serverkey.pem           \
                -H tcp://192.168.59.3:2376
```

## Ubuntu 配置

Ubuntu 14.04 使用 `Upstart` 作为进程管理器。默认情况下，`Upstart` 作业定位在 */etc/init*，Docker 的相关作业可以在 */etc/init/docker.conf* 找到。

### 配置 Docker daemon 

可以在 */etc/default/docker* 配置 Docker daemon --- 指定其中的 `DOCKER_OPTS`。例子：

```sh
DOCKER_OPTS="-D --tls=true --tlscert=/var/docker/server.pem --tlskey=/var/docker/serverkey.pem -H tcp://192.168.59.3:2376"
``` 

### 日志

`Upstart` 作业的默认日志放在 */var/log/upstart*，Docker daemon 的相关日志在 */var/log/upstart/docker.log*：

```sh
$ tail -f /var/log/upstart/docker.log
INFO[0000] Loading containers: done.
INFO[0000] docker daemon: 1.6.0 4749651; execdriver: native-0.2; graphdriver: aufs
INFO[0000] +job acceptconnections()
INFO[0000] -job acceptconnections() = OK (0)
INFO[0000] Daemon has completed initialization
```

###
