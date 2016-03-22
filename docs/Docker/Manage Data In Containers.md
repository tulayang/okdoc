# [数据卷示范](https://docs.docker.com/engine/userguide/containers/dockervolumes/)

## 数据卷

数据卷是一种特意设计的目录：目录绕过联合文件系统，可以存在一个或多个容器中。数据卷提供了几个有用的功能：

* 当创建容器的时候，卷被初始化。如果该容器的镜像在某个挂载点含有数据，这些数据会被拷贝到新的卷（在该卷初始化时）。

  > 当挂载主机目录的时候，不支持这个功能。

* 数据卷能够跨容器共享和重用。

* 能够直接更改数据卷。

* 当更新镜像的时候，不会更改数据卷。

* 当容器被删除的时候，其数据卷能够继续存在。

数据卷用来持久化数据，它是脱离容器的生命周期的。也因为此，当删除一个容器时，Docker 并不会自动删除它相关的数据卷。如果需要的话，你必须手动删除数据卷。

## 添加一个数据卷

当执行 `docker create` 或 `docker run` 时，指定 `-v`、`--volume` 标志位可以为容器添加一个数据卷。也可以同时添加多个数据卷，只需要指定多个 `-v`：

```sh
$ docker run -d -P --name web -v /webapp training/webapp python app.py
```

这条命令在容器 `training/webapp` 内部创建一个新的数据卷 `/webap`。

> 你也能在 Dockerfile 文件中用 `VOLUME` 指令在镜像基础上添加一个或多个数据卷。

## 定位数据卷

使用 `docker inspect` 命令可以定位主机上的数据卷：

```sh
$ docker inspect web
...
Mounts": [
    {
        "Name": "fac362...80535",
        "Source": "/var/lib/docker/volumes/fac362...80535/_data",
        "Destination": "/webapp",
        "Driver": "local",
        "Mode": "",
        "RW": true,
        "Propagation": ""
    }
]
...
```

从这个输出可以看出，`Source` 表示容器的卷实际位于主机的位置，`Destination` 表示容器的卷位于容器内的位置，`RW` 表示这个卷是可读写的。

## 挂载一个主机目录作为数据卷

除了用 `-v` 创建新的数据卷，也可以用 `-v` 为容器挂载一个主机上已有的目录：

```sh
$ docker run -d -P --name web -v /src/webapp:/opt/webapp training/webapp python app.py
```

这条命令表示，为容器内的目录 `/opt/webapp` 挂载主机目录 `/src/webapp` 。如果 `/opt/webapp` 已经在容器的镜像中存在，那么 `/src/webapp` 进行覆盖，但是不会移除已有的内容。这个行为非常类似 Linux 的 `mount` 命令。

容器内的目录必须是绝对路径，比如 `/src/docs`。主机目录可以是绝对路径，也可以是一个名字 --- 如果是绝对路径，Docker 对其进行挂载；如果是一个名字，Docker 用这个名字创建一个新的卷。

名字必须以 alpha 字符开始，跟随 `a-z0-9`、`_`、`.` 或 `-`。绝对路径以 `/` 开始。

挂载主机目录，对于测试是非常有用的。比如，你可以把源代码挂载到一个容器。然后，修改源代码，在容器中运行看看结果。这个主机目录，在指定的时候必须是绝对路径。如果这个目录不存在，Docker 会自动创建它 --- 这个自动创建主机目录的功能已经被废弃。

默认情况下，Docker 卷挂载后是可读写模式，你能够设置挂载为只读模式：

```sh
$ docker run -d -P --name web -v /src/webapp:/opt/webapp:ro training/webapp python app.py
```

因为 [limitations in the mount function](http://lists.linuxfoundation.org/pipermail/containers/2015-April/035788.html)，在主机的源目录移动子目录，能赋予容器到主机文件系统的访问。恶意用户可能会利用这来访问主机和它挂载的目录。

> 主机目录是依赖主机的操作系统的。因此，不要在 Dockerfile 中挂载一个主机目录 --- 这会导致文件系统的不兼容。

## 卷标签

标签操作系统，像 SELinux，当为容器挂载卷时需要放置正确的标签。如果没有标签，安全系统可能会阻止容器内使用这些卷内容的进程运行。Docker 不会修改操作系统所设置的标签设置。

. . .

## 挂载一个主机文件作为数据卷

`-v` 标志位也能挂载一个主机文件：

```sh
$ docker run --rm -it -v ~/.bash_history:/root/.bash_history ubuntu /bin/bash
```

这会把你的主机 Shell 的历史同步到容器的 Shell 历史中。

> Many tools used to edit files including `vi` and `sed --in-place` may result in an inode change. Since Docker v1.1.0, this will produce an error such as “sed: cannot rename ./sedKdJ9Dy: Device or resource busy”. In the case where you want to edit the mounted file, it is often easiest to instead mount the parent directory.   

## 挂载另一个容器的卷

如果你有许多持久化数据想要在容器之间分享，那么最好的方式就是创建一个命名容器，然后挂载它的数据。

首先，创建一个命名的容器 `dbstore`，添加一个数据卷 `/dbdata`：

```sh
$ docker create -v /dbdata --name dbstore training/postgres /bin/true
```

然后，创建另外两个命名的容器 `db1`、`db2`，指定 `--volumes-from` 标志位挂载另一个容器的卷：

```sh
$ docker run -d --volumes-from dbstore --name db1 training/postgres
$ docker run -d --volumes-from dbstore --name db2 training/postgres
```

在上面的过程中，如果 `postgres` 镜像含有一个称为 `/dbdata` 的目录，那么挂载 `dbstore` 的卷 `/dbdata
` 会隐藏 `postges` 的 `/dbdata`。

你能指定多个 `--volumes-from` 从多个容器挂载卷。

这种挂载是可以链式作用的：

```sh
$ docker run -d --volumes-from db1 --name db3 training/postgres
```

如果你移除了挂载卷的容器，包括最初的 `dbstore`，或者后来的挂载的，这些卷都不会删除。想要从磁盘上删除这些卷，必须使用 `docker rm -v` 删除卷。

> 当删除一个容器却没有指定 `-v` 删除卷的时候，Docker 不会警告你。如果你这么做了，之后想要删除卷，你可以使用 `docker volume ls -f dangling=true` 找出悬垂的卷，然后使用 `docker volume rm <volume name>` 删除卷。

## 备份、重载入、迁移数据卷

数据卷的另一些有用的功能是备份、重载入、迁移。当执行下面的命令：

```sh
$ docker run --rm --volumes-from dbstore -v $(pwd):/backup ubuntu tar cvf /backup/backup.tar /dbdata
```

启动一个新的容器，挂载容器 `dbstore` 的卷，为 `/backup` 挂载主机当前工作目录。最后，执行命令 `tar` 把 `/dbdata` 内的文件打包到 `/backup/backup.tar`。这条命令把 `dbstore` 的 `/dbdata` 数据备份到主机的当前工作目录。

使用下面的命令也可以重新载入：

```sh
$ docker run -v /dbdata --name dbstore2 ubuntu /bin/bash
$ docker run --rm --volumes-from dbstore2 -v $(pwd):/backup ubuntu bash -c "cd /dbdata && tar xvf /backup/backup.tar --strip 1"
```

你能用这些技术制定自动化备份、重载入、以及迁移。

## 共享卷的写问题

多个容器可以共享数据卷。不过，当多个容器同时向一个卷写入时，会引发数据竞争。一定要避免你的应用程序存在数据竞争问题。

数据卷可以被 Docker 所在的主机直接访问。你能用 Linux 工具来读写它们。大多数情况都不需要这么做，因为这可能引起数据竞争，而且你的容器和应用程序可能无法探知这些访问。





