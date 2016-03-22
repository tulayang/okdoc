# [Docker Machine](https://docs.docker.com/machine/overview/)

## 何谓 Docker Machine

Docker Machine 是一个工具，使你能在虚拟机上安装 Docker Engine，以及使用 `docker-machine` 命令管理这些主机。你能用 Docker Machine 在本地 Mac 或 Windows、你的公司网络、你的数据中心、云服务（比如 AWS、Digital Ocean）上创建 Docker 主机。

使用 `docker-machine`，你能启动、探查、停止、重新启动一个托管的主机，升级 Docker client 和 daemon，配置一个 Docker client 和主机对话。

通过 Machine CLI 指向一个正在运行的托管的主机，你能直接队该主机运行 `docker` 命令。比如，执行 `docker-machine env default` 命令以指向一个称为 default 的主机，按照屏幕指示完成 `env` 设置，然后运行 `docker ps`、`docker run hello-world`、... 等等。

## 为何使用 Docker Machine

Machine 是当前唯一能在 Mac 或 Windows 运行 Docker 的方式，是最好的提供基于多种 Linux 的多个远程 Docker 主机的方式。

* 我想在 Mac 或 Windows 运行 Docker

* 我想在远程系统提供多个 Docker 主机

  ![Remote](https://docs.docker.com/machine/img/provision-use-case.png)

  Docker Engine 运行在 Linux 系统上。如果你只是想有一个 Linux 主机来运行 Docker Engine，那么下载并安装 Docker Engine 就可以了。但是，如果你想有一个高效的方式能在网络上、云端、或本地提供多个 Docker 主机，你就需要 Docker Machine。

  无论你的系统是 Mac、Windows、还是 Linux，你都能安装 Docker Machine，并使用 `docker-machine` 命令提供和管理大量的 Docker 主机。它会自动创建主机，在主机上安装 Docker Engine，，然后配置 Docker client  。每个托管的主机（“机器”）都由一个 Docker 主机和一个配置好的 client 组成。

## Docker Engine 和 Docker Machine 之区别

当人们说 “Docker”，他们是在说 Docker Engine --- client-server 应用程序，由两部分组成：提供 REST API 规范接口用来交互的 daemon，提供 command line interface（CLI，是 REST API 的包装） 和 daemon 对话的 client。Docker Engine 从 CLI 接受 `docker` 命令，像 `docker run <image>`、`docker ps`、... 。

![Docker Engine](https://docs.docker.com/machine/img/engine.png)

Docker Machine 是一个工具，用来提供和管理你的 Dockerized 主机（带有 Docker Engine 的主机）。通常，你在本地系统安装 Docker Machine。Docker Machine 有自己的命令行客户端 `docker-machine`。你能用 Docker Machine 在一个或多个虚拟系统上安装 Docker Engine。这些虚拟系统可以是本地的（如同你在 Mac 或 Windows 用 VirtualBox 安装 Docker Engine），也可以是远程的（如同你在云端供应商提供 Dockerized 主机）。

![machine](https://docs.docker.com/machine/img/machine.png)

## 安装 Docker Machine

1. 安装 Docker Engine。

2. 下载 Docker Machine 二进制，并且导入你的可执行环境变量：

   ```sh
   $ wget https://github.com/docker/machine/releases/download/v0.6.0/docker-machine-`uname -s`-`uname -m`
   $ mv {Docker Machine} /usr/local/bin/docker-machine
   $ chmod +x /usr/local/bin/docker-machine
   ```

3. 检查 Machine 的版本：

   ```sh
   $ docker-machine version
   docker-machine version 0.6.0, build 61388e9
   ```