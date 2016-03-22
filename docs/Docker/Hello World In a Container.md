# [容器示范](https://docs.docker.com/engine/userguide/containers/dockerizing/)

Docker 允许你运行应用程序 --- 包含在容器中，你创建的那个世界。在容器中运行应用程序，常常使用命令 `docker run` 。

> 注意：依赖你的系统配置，当你执行 `docker` 命令时可能需要 `sudo`。想要避免每次输入 `sudo`,你可以创建一个 `docker` 组，添加一个用户，并使用该用户执行 `docker` 命令。

## 运行 Hello World

现在，来尝试一下。

```sh
$ docker run ubuntu /bin/echo 'Hello world'
Hello world
```

这条命令刚刚启动了一个容器。那么，到底发生了什么？

首先，我们调用 `docker` 命令，指定 `run` 子命令运行一个容器。

然后，指定一个镜像 `ubuntu`。它是容器的来源，Docker 称之为镜像。这里，我们使用 Ubuntu 操作系统镜像。当指定镜像后，Docker 在主机上查找该镜像。如果没有找到，就从 [Docker Hub](https://hub.docker.com/) 下载。

然后，告诉 Docker 在容器中执行的命令：

```sh
/bin/echo 'Hello world'
```

当容器启动后，它会创建一个新的 Ubuntu 环境，在里面执行 `/bin/echo` 命令。我们能从命令行看到结果：

```sh
Hello world
```

那么，之后容器会怎么样呢？ Docker 容器只会在你指定的命令是活动的情况下运行。在上面的例子，一旦打印完 `Hello world`，容器就停止了。

## 交互式容器

现在，再来试一下 `docker run` 命令：

```sh
$ docker run -t -i ubuntu /bin/bash
root@af8bae53bdd3:/#
```

这一次我们再次使用 `ubuntu` 镜像启动一个容器。但是，这里同时指定了两个标志位：`-t`、`-i`。`-t` 在新容器内分配一个伪终端，`-i` 允许我们通过抢占容器内的标准流（`stdin`）制作一个交互式连接。

另外，还指定了在容器内执行的新命令 `/bin/bash`。这会使容器在内部启动一个 Bash Shell。

现在，当容器启动后，我们能获得一个命令行提示：

```sh
root@af8bae53bdd3:/#
```

在容器内试着输入一些命令：

```sh
root@af8bae53bdd3:/# pwd
/
root@af8bae53bdd3:/# ls
bin boot dev etc home lib lib64 media mnt opt proc root run sbin srv sys tmp usr var
```

正如所看到的，当输入 `pwd` 时显示当前工作目录。在容器内存在着一个经典 Linux 文件系统。

你能在容器内把玩许多内容，当你完成的时候，可以使用 `exit` 命令或 `Ctrl-D`退出：

```sh
root@af8bae53bdd3:/# exit
```

和前面的容器一样，一旦 Bash Shell 进程结束，这个容器就停止了。

## 守护进程式容器

再一次，试一下 `docker run` 命令：

```sh
$ docker run -d ubuntu \
  /bin/sh -c "while true; do echo hello world; sleep 1; done"
1e5535038e285177d5214659a068137486f96ee5c2e85a4ac52dc83f2ebe4147
```

这一次，执行 `docker run` 命令，指定了一个标志位：`-d`。`-d` 告诉 Docker 在后台运行这个容器，使它成为守护进程。

此外，还指定了要运行的新命令：

```sh
/bin/sh -c "while true; do echo hello world; sleep 1; done"
```

这条命令告诉容器：执行一条 Shell 脚本，循环打印 `hello world`。

那么，我们无法看到任何 `hello world` 输出？对，Docker 没有返回这些输出，而是返回一个长字符串 --- 容器号，唯一标识该容器：

```sh
1e5535038e285177d5214659a068137486f96ee5c2e85a4ac52dc83f2ebe4147
``` 

> 这个容器号有点长，不好记。稍后，我们会看到短写容器号，以及容器名，它们都可以使工作更简便。

现在，执行 `docker ps` 命令，列出所有正在运行的容器：

```sh
$ docker ps
CONTAINER ID  IMAGE   COMMAND               CREATED        STATUS       PORTS  NAMES
1e5535038e28  ubuntu  /bin/sh -c 'while tr  2 minutes ago  Up 1 minute         insane_babbage
``` 

在这里，你可以看到这个守护进程化的容器。`docker ps` 返回了许多有用的信息，最开始是一个短写的容器号 `1e5535038e28`。还包括容器所使用的镜像 `ubuntu`、容器内部执行的命令、容器名字、... 。

> 如果没有指定 `--name="container_name"`，Docker 会自动为容器生成名字。

想看看这个容器里面都做了什么？使用 `docker logs` 命令：

```sh
$ docker logs insane_babbage
hello world
hello world
hello world
. . .
```

现在，你能看到这个容器输出了很多 `hello world`。

当想要后台容器停止时，执行 `docker stop` 命令：

```sh
$ docker stop insane_babbage
insane_babbage
```

`docker stop` 告诉 Docker 优雅地停止这个正在运行的容器。如果成功停止，返回这个容器的名字。

## Web App 和网络端口

现在，用 Docker 来运行一个 web app。在这里，运行一个 Python Flask App：

```sh
$ docker run -d -P training/webapp python app.py
```

这一次，执行 `docker run` 命令，指定了两个标志位：`-d` 和 `-P`。`-d` 告诉 Docker 在后台运行这个容器，使它成为守护进程。`-P` 告诉 Docker 把容器内所有需要的网络端口映射到主机。

这里指定了新的镜像 `training/webapp` --- 一个 Python Flask App。

此外，还指定了要运行的新命令：

```sh
python app.py
``` 

这条命令使容器启动该 web app。

现在，执行 `docker ps -l` 看一下容器：

```sh
$ docker ps -l
CONTAINER ID    IMAGE                      COMMAND            CREATED      
bc533791f3f5    training/webapp:latest     python app.py      5 seconds ago
STATUS          PORTS                      NAMES
Up 2 seconds    0.0.0.0:49155->5000/tcp    nostalgic_morse
```

> 默认情况下，`docker ps` 只显示正在运行的容器，如果想显示所有容器，请指定 `-a` 标志位。

你能看到 `PORTS` 列的细节：

```sh
PORTS
0.0.0.0:49155->5000/tcp
```

当执行 `docker run` 指定 `-P` 时，Docker 会把镜像所暴露的所有端口映射到主机端口（`32768` 到 `61000` 之间）。也可以使用 `-p 5000` 明确指定端口：

```sh
$ docker run -d -p 80:5000 training/webapp python app.py
```

这条命令把容器内的 `5000` 端口映射到主机的 `80` 端口。

现在，你能在浏览器通过 `http://localhost:49155` 来访问该 app 了。

![app](https://docs.docker.com/engine/userguide/containers/webapp1.png)

> 如果你在虚拟机使用 Docker，那么需要得到该虚拟主机的 IP 地址。可以使用 `docker-machine ip your_vm_name` 来完成：
> ```sh   
> $ docker-machine ip my-docker-vm   
> 192.168.99.100
> ```
> 在这个时候，你应该浏览 `http://192.168.99.100:49155`。

## 一些有用的命令

使用 `docker port` 命令可以查看容器所映射的端口：

```sh
$ docker port nostalgic_morse 5000
0.0.0.0:49155
``` 

使用 `docker logs` 命令可以查看容器的输出：

```sh
$ docker logs -f nostalgic_morse
* Running on http://0.0.0.0:5000/
10.0.2.2 - - [23/May/2014 20:16:31] "GET / HTTP/1.1" 200 -
10.0.2.2 - - [23/May/2014 20:16:31] "GET /favicon.ico HTTP/1.1" 404 -
```

使用 `docker top` 命令可以查看容器内正在运行的进程：

```sh
$ docker top nostalgic_morse
PID        USER        COMMAND
854        root        python app.py
```

使用 `docker inspect` 命令可以查看容器的底层信息，它返回一个 JSON 文档：

```sh
$ docker inspect nostalgic_morse
[{
    "ID": "bc533791f3f500b280a9626688bc79e342e3ea0d528efe3a86a51ecb28ea20",
    "Created": "2014-05-26T05:52:40.808952951Z",
    "Path": "python",
    "Args": [
       "app.py"
    ],
    "Config": {
       "Hostname": "bc533791f3f5",
       "Domainname": "",
       "User": "",
. . .
```

也可以指定模板来过滤容器的底层信息：

```sh
$ docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nostalgic_morse
172.17.0.5
```

使用 `docker stop` 命令可以停止该容器：

```sh
$ docker stop nostalgic_morse
nostalgic_morse
```

使用 `docker start` 命令可以启动一个已经停止的容器：

```sh
$ docker start nostalgic_morse
nostalgic_morse
```

使用 `docker rm` 命令可以删除已经停止的容器：

```sh
$ docker rm nostalgic_morse
Error: Impossible to remove a running container, please stop it first or use -f
2014/05/24 08:12:56 Error: failed to remove one or more containers
$ docker stop nostalgic_morse
nostalgic_morse
$ docker rm nostalgic_morse
nostalgic_morse
```

> 当容器不再需要时，记得删除容器！
