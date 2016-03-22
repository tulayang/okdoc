# [Docker Machine 和本地虚拟机](https://docs.docker.com/machine/get-started/)

## 准备条件

确保你已经正确安装了最新版本的 [VirtualBox](https://www.virtualbox.org/wiki/Downloads)。

## 如何使用虚拟主机运行 Docker 容器

想要在虚拟主机运行一个 Docker 容器，你需要：

1. 创建一个新的 Docker 虚拟机（或者启动一个已有的）

2. 把环境变量转换到这个新的虚拟机

3. 使用 Docker client 来管理容器

一旦你创建了一个虚拟机，随时可以重用它。

## 创建一个虚拟主机

1. 使用 `docker-machine ls` 列出所有可用的虚拟主机：

   ```sh
   $ docker-machine ls
   NAME   ACTIVE   DRIVER   STATE   URL   SWARM   DOCKER   ERRORS
   ```

   这里，我们还没有创建任何虚拟主机。

2. 使用 `docker-machine create` 创建虚拟主机，指定 `--driver=virtualbox` 使用 VirtualBox 驱动：
    
   ```sh
   $ docker-machine create --driver virtualbox default
   Running pre-create checks...
   Creating machine...
   (staging) Copying /Users/ripley/.docker/machine/cache/boot2docker.iso to /Users/ripley/.docker/machine/machines/default/boot2docker.iso...
   (staging) Creating VirtualBox VM...
   (staging) Creating SSH key...
   (staging) Starting the VM...
   (staging) Waiting for an IP...
   Waiting for machine to be running, this may take a few minutes...
   Machine is running, waiting for SSH to be available...
   Detecting operating system of created instance...
   Detecting the provisioner...
   Provisioning with boot2docker...
   Copying certs to the local machine directory...
   Copying certs to the remote machine...
   Setting Docker configuration on the remote daemon...
   Checking connection to Docker...
   Docker is up and running!
   To see how to connect Docker to this machine, run: docker-machine env default
   ```

   这条命令会下载一个轻量的 Linux 发行版 （[boot2docker](https://github.com/boot2docker/boot2docker)） --- 里面已经安装好了 Docker daemon，然后，创建一个名为 `default` 的虚拟主机，并且启动虚拟主机。
   
   > 如果出现错误，表示 VT-d 没有启用，需要你在 Bios 启用该功能，这表示该物理主机的虚拟功能没有开启，请到 Bios 启用 CPU 虚拟功能。

3. 再次列出可用的虚拟主机：

   ```sh
   $ docker-machine ls
   NAME     ACTIVE  DRIVER      STATE    URL                        SWARM  DOCKER  ERRORS
   default  *       virtualbox  Running  tcp://192.168.99.187:2376         v1.9.1
   ```

4. 使用 `docker-machine env` 从新的虚拟主机获得环境变量 --- 我们需要这些变量来连接到该虚拟主机：

   ```sh
   $ docker-machine env default
   export DOCKER_TLS_VERIFY="1"
   export DOCKER_HOST="tcp://172.16.62.130:2376"
   export DOCKER_CERT_PATH="/Users/<yourusername>/.docker/machine/machines/default"
   export DOCKER_MACHINE_NAME="default"
   # Run this command to configure your shell:
   # eval "$(docker-machine env default)"
   ```

5. 用你的 Shell 连接新的虚拟主机：

   ```sh
   $ eval "$(docker-machine env default)"
   ```

   This sets environment variables for the current shell that the Docker client will read which specify the TLS settings. You need to do this each time you open a new shell or restart your machine.

   现在，你能够在这台主机上运行 Docker 命令了。

## 对虚拟主机做一些实验

现在，运行 `docker run` 来验证你上面的操作。

1. 运行 `docker run` 下载 `busybox` 并运行一个容器，执行简单的命令 `echo`：

   ```sh
   $ docker run busybox echo hello world
   Unable to find image 'busybox' locally
   Pulling repository busybox
   e72ac664f4f0: Download complete
   511136ea3c5a: Download complete
   df7546f9f060: Download complete
   e433a6c5b276: Download complete
   hello world
   ```

2. 获取 IP 地址。这个 Docker 虚拟主机暴露的所有 IP 地址都是可用的，你能使用 `docker-machine ip` 来获取：

   ```sh
   $ docker-machine ip default
   192.168.99.100
   ```

3. 启动一个容器，运行一个 web 服务器 （nginx）：
   
   ```sh
   $ docker run -d -p 8000:80 nginx
   ```

   当这个镜像下载完毕并且启动容器后，你可以通过 `docker-machine ip` 获得 IP 地址和端口号 `8000` 来访问这个服务：

   ```sh
   $ curl $(docker-machine ip default):8000
   <!DOCTYPE html>
   <html>
   <head>
   <title>Welcome to nginx!</title>
   <style>
       body {
           width: 35em;
           margin: 0 auto;
           font-family: Tahoma, Verdana, Arial, sans-serif;
       }
   </style>
   </head>
   <body>
   <h1>Welcome to nginx!</h1>
   <p>If you see this page, the nginx web server is successfully installed and
   working. Further configuration is required.</p>

   <p>For online documentation and support please refer to
   <a href="http://nginx.org/">nginx.org</a>.<br/>
   Commercial support is available at
   <a href="http://nginx.com/">nginx.com</a>.</p>

   <p><em>Thank you for using nginx.</em></p>
   </body>
   </html>
   ```

你能够在本地创建和管理尽可能多的运行着 Docker 的虚拟机，只需要使用 `docker-machine create`。所有创建的虚拟机，会出现在 `docker-machine ls` 的结果中。

## 启动和停止虚拟主机

如果你想停止虚拟主机，使用 `docker-machine stop`；如果你想再次启动它，使用 `docker-machine start`：

```sh
$ docker-machine stop default
$ docker-machine start default
```

## 不指定名字，操作虚拟主机

当执行命令的时候，如果没有指定虚拟主机的名字，一些 `docker-machine` 命令会假设给定的虚拟主机名字是 `default` （如果该虚拟主机存在的话）。

例子：

```sh
$ docker-machine stop
Stopping "default"....
Machine "default" was stopped.

$ docker-machine start
Starting "default"...
(default) Waiting for an IP...
Machine "default" was started.
Started machines may have new IP addresses.  You may need to re-run the `docker-machine env` command.

$ eval $(docker-machine env)

$ docker-machine ip
192.168.99.100
```

这些命令会是这样的风格：

```sh
docker-machine config
docker-machine env
docker-machine inspect
docker-machine ip
docker-machine kill
docker-machine provision
docker-machine regenerate-certs
docker-machine restart
docker-machine ssh
docker-machine start
docker-machine status
docker-machine stop
docker-machine upgrade
docker-machine url
```

## 如何自动启动本地虚拟主机

为了确保在每次 Shell 会话开始的时候自动配置 Docker client，你可能会想要在 Shell profiles （比如：*~/.bash_profile* 文件）中加入 `eval $(docker-machine env default)`。但是，如果这个 `default` 虚拟主机没有运行，这么做就会失败。如果需要的话，你可以配置下你的系统，让它自动启动 `default` 虚拟主机。

这儿是一个在 OS X 配置的例子。

在 *~/Library/LaunchAgents* 下创建 *com.docker.machine.default.plist* 文件，输入下面内容：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>EnvironmentVariables</key>
        <dict>
            <key>PATH</key>
            <string>/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin</string>
        </dict>
        <key>Label</key>
        <string>com.docker.machine.default</string>
        <key>ProgramArguments</key>
        <array>
            <string>/usr/local/bin/docker-machine</string>
            <string>start</string>
            <string>default</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
    </dict>
</plist>
```

你可以修改上面的 `default` 为任何其他虚拟主机的名字，以使操作系统能够自动启动该虚拟主机。



