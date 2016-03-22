# [何谓机器，如何获得帮助](https://docs.docker.com/machine/concepts/)

Docker Machine 允许你在多种环境提供 Docker 机器服务，包括：本地系统运行的虚拟机器、云端服务商、多个物理机器。Docker Machine 创建一个 Docker 主机，然后，使用 Docker Engine client 在这个主机上编译镜像、创建容器。

## 指定驱动创建机器

想要创建一个虚拟机器，你需要为 Docker Machine 指定驱动名字。驱动决定了创建的虚拟机器是哪一种。比如，在本地 Mac 或 WIndows，驱动常常是 Oracle VirtualBox。对于多个物理机器，提供了一个通用驱动。对于云端服务商，Docker Machine 支持 AWS、Microsoft Azure、Digital Ocean、... 等等驱动。

[具体可以参考这个驱动列表](https://docs.docker.com/machine/drivers/)

## 本地和云端主机的默认操作系统

由于 Docker 只能运行在 Linux，每个 Docker Machine 提供的虚拟主机都需要依赖一个基础操作系统。对于 Oracle VirtualBox 驱动，基础操作系统是 [boot2docker](https://github.com/boot2docker/boot2docker)。对于云端服务商驱动，基础操作系统是 Ubuntu 12.04+。当创建机器的时候，你能改变这些默认的基础操作系统。

[默认的基础操作系统列表](https://docs.docker.com/machine/drivers/os-base/)

## Docker 主机的 IP 地址

每一个你创建的机器，其 Docker 主机地址是该 Linux 虚拟机器的 IP 地址。这个地址由 `docker-machine create ` 命令赋值。`docker-machine ls` 命令可以列出所有已经创建的机器。`docker-machine ip <machine-name>` 命令获得指定主机的 IP 地址。

## 为 Docker 主机配置 CLI 环境变量

对一个机器运行 `docker` 命令之前，你需要配置你的 command-line，使其指向这个机器。`docker-machine env <machine-name>` 命令输出你应该使用的配置命令。

## 崩溃报告

. . .

