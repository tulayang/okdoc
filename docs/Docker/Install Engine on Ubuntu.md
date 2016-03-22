# [安装 Engine，基于 Ubuntu](https://docs.docker.com/engine/installation/ubuntulinux/)

现在，我们聊聊如何使用 Ubuntu APT 包管理器安装 Docker。Docker 支持如下 Ubuntu 操作系统：

* Ubuntu Wily 15.10 (64-bit)
* Ubuntu Trusty 14.04 (LTS) (64-bit)
* Ubuntu Precise 12.04 (LTS) (64-bit)

> 注意: 官方不再支持 Ubuntu 14.10 和 15.04 的 Docker 包。

## 预备条件

Docker 需要 64 位版本的 Ubuntu。此外，内核版本至少是 3.10；主版本号是 3.10，新的维护版本也可以。
在低于 3.10 版本的内核上运行 Docker 会丢失一些功能。另外，还会出现一些 bug 导致数据丢失，并且经常报错。

打开终端，使用 `uname -r` 命令查看内核版本：

```sh
$ uname -r
3.13.0-74-generic
```

> 注意：如果之前使用 APT 安装了 Docker，请先更新 APT 源 --- 以得到最新的 Docker 库。

### 更新 APT 资源，得到最新的库

1. 作为超级用户登录 Ubuntu，打开终端。

2. 更新 APT 包信息，并确认已安装 https 和 CA certificates：

   ```sh
   $ apt-get update
   $ apt-get install apt-transport-https ca-certificates
   ```

3. 添加 `GPG` 秘钥：

   ```sh
   $ sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
   ``` 

4. 打开 */etc/apt/sources.list.d/docker.list* 文件，如果不存在，则创建它。删除任何已有的指令，添加一条指令：

   * Ubuntu Precise 12.04 (LTS)

     ```sh
     deb https://apt.dockerproject.org/repo ubuntu-precise main
     ```

   * Ubuntu Trusty 14.04 (LTS)

     ```sh
     deb https://apt.dockerproject.org/repo ubuntu-trusty main
     ```

   * Ubuntu Vivid 15.04

     ```sh
     deb https://apt.dockerproject.org/repo ubuntu-vivid main
     ```

   * Ubuntu Wily 15.10

     ```sh
     deb https://apt.dockerproject.org/repo ubuntu-wily main
     ```

8. 更新 APT 包信息：

   ```sh
   $ sudo apt-get update
   ```

9. 清除旧的库（如果存在的话）：

   ```sh
   $ sudo apt-get purge lxc-docker
   ```

10. 验证 **apt** 得到了正确的库信息：

    ```sh
    $ sudo apt-cache policy docker-engine
    ```

    从现在起，如果运行 `$ apt-get upgrade`，APT 会拉取新的库。

### 更新内核，安装必要的包

Ubuntu Trusty 14.04 (LTS) (64-bit)、Ubuntu Vivid 15.04 (64-bit)、Ubuntu Wily 15.10 (64-bit)，推荐安装 linux-image-extra 内核包 --- 允许你使用 aufs 存储驱动。Ubuntu Trusty 14.04 (LTS) (64-bit)、Ubuntu Precise 12.04 (LTS) (64-bit)，必须安装 apparmor。命令如下：

  ```sh
  $ sudo apt-get update
  $ sudo apt-get install linux-image-extra-$(uname -r) apparmor
```

Ubuntu Precise 12.04 (LTS) (64-bit)，需要确保内核版本至少是 3.13。从这个表看一下你的环境需要哪些包：

包|描述
--|--
**linux-image-generic-lts-trusty** | 通用内核镜像。内置 aufs 。**docker** 需要它。
**linux-headers-generic-lts-trusty** | 允许依赖 ZFS 和 VirtualBox 这些辅助包。如果你不确信是否需要，就安装它以防万一。
**xserver-xorg-lts-trusty** | 没有 Unity/Xorg 图形环境时的可选包。当运行 **docker** 会得到一个图形环境。
**libgl1-mesa-glx-lts-trusty** | To learn more about the reasons for these packages, read the installation instructions for backported kernels, specifically the LTS Enablement Stack — refer to note 5 under each version. 

升级你的内核，安装新加的包：

```sh
$ sudo apt-get update
$ sudo apt-get install linux-image-generic-lts-trusty
$ sudo reboot
```

依赖你的环境，你可以添加更多的包。

###

## 安装

1. 使用超级用户登录 Ubuntu，打开终端。

2. 更新 APT 包信息：

   ```sh
   $ sudo apt-get update
   ```

3. 安装 Docker：

   ```sh
   $ sudo apt-get install docker-engine
   ```

4. 启动 **docker** 守护进程（通常，安装后会自动启动）：

   ```sh
   $ sudo service docker start
   ```

5. 验证 **docker** 已正确安装：

   ```sh
   $ sudo docker run hello-world
   ```

   这条命令会下载一个测试镜像，然后运行一个容器。当运行时，它打印一个鲸鱼，然后退出。

## 可选的配置

可以做一些配置，来更方便的使用 Docker。

### 创建一个 Docker 组

**docker** 守护进程绑定到 Unix 套接字，而不是 TCP 端口。默认，该套接字属主是 `root` 用户，其他用户需要使用 `sudo` 来访问它。因此，**docker** 守护进程总是以 `root` 用户运行。

为了避免输入 `sudo` 的麻烦，可以创建一个组，比如叫做 docker，把用户加入该组。当 **docker** 守护进程启动时，组的所有成员都可以对其 Unix 套接字有读写访问权。

> 警告：上面的 docker 组等同于 `root` 用户。看一下 [docker 守护进程和攻击]() 了解更多细节 --- 系统安全。

1. 使用超级用户登录 Ubuntu，打开终端。

2. 创建 `docker` 组，并添加用户 `ubuntu`：

   ```sh
   $ sudo usermod -aG docker ubuntu
   ```

3. 注销，以确保用户获得正确的权限。

4. 确认 `docker` 组的用户运行 **docker** 不需要 `sudo`：

   ```sh
   $ docker run hello-world
   ```

   如果出现这样的失败消息：

   ```sh
   Cannot connect to the docker daemon. Is 'docker daemon' running on this host?
   ```

   检查下 `DOCKER_HOST` 环境变量，看看 **shell** 是否已经设置。如果是，撤销它。

### 调整内存和交换记账

当运行 Docker 时，可能会看到这样的消息：

```sh
WARNING: Your kernel does not support cgroup swap limit. WARNING: Your
kernel does not support swap limit capabilities. Limitation discarded.
```

启用系统的内存和交换记账，可以消除这个问题。启用后，会有一些内存开销，以及性能损耗，即使 Docker 不运行。内存开销大约是可用内存的 1%。性能损耗大约是 10%。

启用系统的内存和交换记账，需要使用 GNU GRUB （GNU GRand Unified Bootloader）：

1. 使用超级用户登录 Ubuntu，打开终端。

2. 编辑 */etc/default/grub* 文件，设置 `GRUB_CMDLINE_LINUX`：

   ```sh
   GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"
   ```

3. 更新 GRUB，重启系统：

   ```sh
   $ sudo update-grub
   $ sudo reboot
   ```

### 启用 UFW 转发

当运行 Docker 时，同一主机上使用 [UFW 防火墙](https://help.ubuntu.com/community/UFW)，那么需要一些必要的配置。Docker 使用桥管理容器的网络。默认，UFW 丢掉所有的转发流量。因此，你必须为它配置正确的策略。

另外，UFW 默认拒绝所有的进入流量。如果你想让另一个主机连通你的容器，必须允许开放 Docker 端口。Docker 端口默认是 `2376`，如果启用 TLS 则是 `2375`。如果没有启用 TLS，通信是未加密的。默认，Docker 不启用 TLS。

1. 使用超级用户登录 Ubuntu，打开终端。

2. 确认 UFW 已安装并可用：

   ```sh
   $ sudo ufw status
   ``` 

3. 编辑 */etc/default/ufw* 文件：

   ```sh
   $ sudo vi /etc/default/ufw
   ``` 

4. 设置 `DEFAULT_FORWARD_POLICY` 策略：

   ```sh
   DEFAULT_FORWARD_POLICY="ACCEPT"
   ```

5. 重新加载配置：

   ```sh
   $ sudo ufw reload
   ```

6. 允许连接 Docker 端口：

   ```sh
   $ sudo ufw allow 2375/tcp
   ```

### 为 Docker 配置一个 DNS 服务器

Ubuntu 系统或衍生的桌面系统，通常使用 `127.0.0.1` 作为默认的域名服务器 --- 记录在 */etc/resolv.conf* 文件。网络管理器，也能在 * /etc/resolv.conf* 文件设置 `dnsmasq` 以使用真实的 DNS 服务器，并且设置 `127.0.0.1` 作为域名服务器。

当使用这些配置启动 Docker 容器时，会出现这样的警告：

```sh
WARNING: Local (127.0.0.1) DNS resolver found in resolv.conf and containers
can't use it. Using default external servers : [8.8.8.8 8.8.4.4]
```

这是因为 Docker 容器不能使用本地 DNS 域名服务器，而是（默认）使用一个外部的域名服务器。

为了避免这个问题，你可以为 Docker 容器指定一个 DNS 服务器。或者，禁用网络管理器的 `dnsmasq`。然而，禁用 `dnsmasq` 可能导致 DNS 对某些网络解析变慢。

下面聊聊怎么为 Docker 配置 DNS，需要 Ubuntu 14.10 或以下版本。Ubuntu 15.01 和以上版本使用 `systemd` 作为引导和服务管理器，需要使用 [systemd 配置](https://docs.docker.com/engine/articles/systemd/#custom-docker-daemon-options)。

1. 使用超级用户登录 Ubuntu，打开终端。

2. 编辑 */etc/default/docker* 文件，添加：

   ```sh
   DOCKER_OPTS="--dns 8.8.8.8"
   ```

   用本地 DNS 服务器替换 `8.8.8.8`，比如 `192.168.1.1`。你也可以指定多个 DNS 服务器。用空格隔开它们，比如：

   ```sh
   --dns 8.8.8.8 --dns 192.168.1.1
   ```

   > 警告：如果你做这些时是在笔记本上，并且连接多个网络，一定要选择一个公开的 DNS 服务器。

3. 重启 Docker 守护进程：

   ```sh
   $ sudo restart docker
   ```

或者，在网络管理器禁用 `dnsmasq` （这可能让你的网络变慢）：

1. 编辑 */etc/NetworkManager/NetworkManager.conf* 文件，注释掉 `dns=dsnmasq` 这一行：

   ```sh
   #dns=dnsmasq
   ```

2. 重启网络管理器和 Docker：

   ```sh
   $ sudo restart network-manager
   $ sudo restart docker
   ```

### 引导时启动

Ubuntu 15.04 和以上版本使用 systemd 作为引导和服务管理器，14.10 和以下版本则使用 upstart。

对于 15.04 和以上版本，配置 Docker 在引导时启动：

```sh
$ sudo systemctl enable docker
```

对于 14.10 和以下版本，上面的方法会自动配置 uostart 以使 Docker 在引导时启动。

###

## 升级

使用 APT 安装最新版本的 Docker：

```sh
$ sudo apt-get upgrade docker-engine
```

## 卸载

卸载 Docker 包：

```sh
$ sudo apt-get purge docker-engine
```

卸载 Docker 包及其依赖---不再需要了：

```sh
$ sudo apt-get autoremove --purge docker-engine
```

上面的命令不会删除镜像、容器、卷、或用户创建的配置文件。使用下面的命令，删除所有的镜像、容器、卷：

```sh
$ rm -rf /var/lib/docker
```

必须手动删除用户创建的配置文件。

