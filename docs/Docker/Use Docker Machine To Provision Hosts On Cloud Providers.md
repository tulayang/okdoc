# [Docker Machine 和云端服务商](https://docs.docker.com/machine/get-started-cloud/)

许多云平台提供可用的 Docker Machine 插件，你可以用 Machine 来提供云端主机。当你用 Docker Machine 提供这样的服务时，你只需要在云端创建虚拟主机，并在主机上安装 Docker Engine。

你会需要一个云服务商的账户，并且在本地安装并运行 Docker Machine。

然后，使用 `docker-machine create` 并且使用一个标志位指定账户身份、安全证书、服务商需要的配置项。对于不同的云服务商，这个标志位可能是不同的。比如，Digital Ocean 需要你指定 `--digitalocean-access-token` 标志位。

## Digital Ocean

Digital Ocean 创建一个云端主机 `docker-sandbox` 的方法如下：

```sh
$ docker-machine create --driver digitalocean               \
                        --digitalocean-access-token xxxxx   \ 
                        docker-sandbox
```

[更多的例子，看这里](https://docs.docker.com/machine/examples/ocean/)

## Amazon Web Services

AWS EC2 创建一个云端主机 `aws-sandbox` 的方法如下：

```sh
$ docker-machine create --driver amazonec2                   \
                        --amazonec2-access-key AKI*******    \
                        --amazonec2-secret-key 8T93C*******  \
                        aws-sandbox
```

[更多的例子，看这里](https://docs.docker.com/machine/examples/aws/)

## `docker-machine create` 命令

通常，`docker-machine create` 命令需要你至少指定：

* `--driver`

  指定用来创建虚拟主机的提供商（驱动）。比如 VirtualBox、DigitalOcean、AWS 等等。

* `<machine>`

  你要创建的虚拟主机的名字。

For convenience, `docker-machine` will use sensible defaults for choosing settings such as the image that the server is based on, but you override the defaults using the respective flags (e.g. `--digitalocean-image`). This is useful if, for example, you want to create a cloud server with a lot of memory and CPUs (by default `docker-machine` creates a small server).

## 云服务商的驱动

当你安装 Docker Machine 时，你会得到许多云服务商驱动（比如  Amazon Web Services、Digital Ocean、Microsoft Azure），以及本地驱动（比如 Oracle VirtualBox、VMWare Fusion、Microsoft Hyper-V）。

[支持的驱动列表](https://docs.docker.com/machine/drivers/)

## 第三方驱动插件

支持第三方 Docker Machine 驱动插件。

## 不使用驱动添加一个主机

你可以不使用驱动，只指定一个 URL 添加一个主机。之后，你就能用设定的主机名执行 Docker 命令：

```sh
$ docker-machine create --url=tcp://50.134.234.20:2376 custombox
$ docker-machine ls
NAME        ACTIVE   DRIVER    STATE     URL
custombox   *        none      Running   tcp://50.134.234.20:2376
```

## 使用 Docker Machine 提供 Docker Swarm clusters

Docker Machine 也能用来提供 Docker Swarm clusters。此种情景下，你能使用任何驱动来构建，也能使用 TLS 增加安全。

