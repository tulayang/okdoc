# [Docker Engine 新手指南](https://docs.docker.com/engine/userguide/)

**docker** 是一个开源引擎，它的目的是帮助各种应用程序，快捷地创建轻量的、可移植的、自给自足的容器。你甚至可以在笔记本上编译测试，然后将其部署在生产环境，包括虚拟机、裸设备、OpenStack 集群、或者任何基础平台。

**docker** 通常用在以下场景：

* 自动打包和部署 web 应用

* 自动化测试和持续集成、部署

* 部署和调整数据库及其后台服务

* 从头编译或者扩展现有的 OpenShift 或 Cloud Foundry 平台，来搭建自己的 PaaS 环境

## Ubuntu 支持

**docker** 支持以下 Ubuntu 版本

* Ubuntu Trusty 14.04 (LTS) (64-bit)
* Ubuntu Precise 12.04 (LTS) (64-bit)
* Ubuntu Raring 13.04 and Saucy 13.10 (64 bit)

**docker** 需要 64 位版本的 Ubuntu。此外，其 Linux 内核版本不低于 3.10。

使用 `$ uname -r` 查看你的 Linux 内核版本。Trusty 14.04 (LTS) 不需要任何安装条件，Precise 12.04 (LTS)需要升级内核到 3.10 以上：

```sh
$ sudo apt-get update
$ sudo apt-get install linux-image-generic-lts-trusty linux-headers-generic-lts-trusty
$ sudo reboot
```

## Ubuntu 安装

这个安装过程是写给那些对软件包管理器不熟悉的用户看的。如果你熟悉软件包管理器，不喜欢使用 **wget**，或者有安装问题，请使用我们的 **apt** 和 **yum** 仓库来安装。

1. 使用 `sodu` 作为特权用户进入你的 **shell**

2. 看看有没有 **wget**

   ```sh
   $ which wget
   ```

   如果没有，请更新下软件包管理器，然后安装 **wget**

   ```sh
   $ sudo apt-get update
   $ sudo apt-get install wget  
   ```

   或者

   ```
   $ sudo aptitude install wget
   ```

3. 下载最新的 **docker** 包

   ```sh
   $ wget -qO- https://get.docker.com/ | sh  # 下载安装脚本，然后运行脚本
   ```

   系统会提示你输入密码，然后，程序会下载并安装 **docker** 和依赖。

   > 注意：如果你的公司存在过滤代理，你会发现在安装时出现 `apt-key` 命令项失败。使用下面的法子，解决这个问题：
   > ```sh
   $ wget -qO- https://get.docker.com/gpg | sudo apt-key add -
   ```

4. 看看 **docker** 是否装好了

   ```sh
   $ sudo docker run hello-world   # 下载一个测试镜像，并在容器内运行这个镜像
   ```

## 什么是镜像，什么是容器

`docker run hello-world` 这条命令，使用 **docker** 完成一条核心任务。这条命令有三部分：

* `docker` 告诉操作系统：你正在使用 **docker** 程序

* `run` 创建并运行一个容器

* `hello-world` 告诉 **docker**：将该镜像加载进容器

一个容器，其实是一个基础版本的 Linux 操作系统。镜像，是你加载进容器的软件。当你运行这条命令，**docker**：

* 检查看看你是否有 hello-world 这个软件镜像

* 从 docker Hub 下载这个镜像

* 将该镜像加载进容器，然后运行

根据镜像的编译，镜像可能会运行一条简单的、单一的命令，然后退出。hello-world 就是这么干的。

**docker** 镜像，非常灵活。它可以作为一个复杂的数据库启动，等待你加入数据，然后存储数据。

谁负责构建 hello-world 镜像？在上面的例子，是由 **docker** 构建的，但是其他任何人都可以构建。**docker** 帮助人们（或公司）通过镜像创建和分享软件。使用 **docker**，你不用担心你的电脑是否可以运行镜像中的软件---**docker** 容器总能运行它。

## 找到镜像，然后运行

世界各地的人们在构建 **docker** 镜像。你可以浏览 [docker Hub](https://hub.docker.com/) 找到这些镜像。这里，我们来聊聊怎么找镜像。

### 第一步：定位镜像

1. 打开你的浏览器，然后浏览 [docker Hub](https://hub.docker.com/) 

  ![docker Hub](https://docs.docker.com/tutimg/hub_signup.png) 

  [docker Hub](https://hub.docker.com/) 包含了多种多样的镜像，有个人的，有 RedHat、IBM、Google 等组织官方发布的，我们有一大堆。

2. 点击 Search 搜索框。

3. 输入关键字，比如 whalesay，然后你能得到如下：

  ![whalesay](https://docs.docker.com/tutimg/image_found.png)

4. 点击 docker/whalesay 镜像，然后会显示这个镜像的库：

  ![docker/whalesay](https://docs.docker.com/tutimg/whale_repo.png)

  每个镜像库包含一个镜像的信息。它应该包括这些信息：包含的时什么样的软件，以及如何使用它。你可能注意到 whalesay 镜像是基于 Ubuntu 的。

### 第二步：运行镜像

1. 打开你的控制终端。

2. 输入 `docker run docker/whalesay cowsay boo` 命令，按下回车。这条命令会在一个容器运行 whalesay 镜像。你的终端会出现以下显示：

   ```sh
   $ sudo docker run docker/whalesay cowsay boo 
   Unable to find image 'docker/whalesay:latest' locally
   latest: Pulling from docker/whalesay
   2880a3395ede: Pull complete 
   515565c29c94: Pull complete 
   98b15185dba7: Pull complete 
   2ce633e3e9c9: Pull complete 
   35217eff2e30: Pull complete 
   326bddfde6c0: Pull complete 
   3a2e7fe79da7: Pull complete 
   517de05c9075: Pull complete 
   8f17e9411cf6: Pull complete 
   ded5e192a685: Pull complete 
   Digest: sha256:178598e51a26abbc958b8a2e48825c90bc22e641de3d31e18aaf55f3258ba93b
   Status: Downloaded newer image for docker/whalesay:latest
   _____ 
   < boo >
   ----- 
     \
     \
      \     
             ##        .            
          ## ## ##       ==            
        ## ## ## ##      ===            
      /""""""""""""""""___/ ===        
    ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~   
      \______ o          __/            
       \    \        __/             
        \____\______/   
   ```
  
   如果你是第一次运行软件镜像，**docker** 命令会先查找你的本地系统。如果找不到镜像，就会去 Hub 查找。

3. 输入 `docker images` 命令，按下回车。这条命令列出你本地系统的所有镜像，你应该看到 docker/whalesay ：

   ```sh
   $ sudo docker images
   REPOSITORY         TAG       IMAGE ID        CREATED         VIRTUAL SIZE
   hello-world        latest    0a6ba66e537a    3 months ago    960 B
   docker/whalesay    latest    ded5e192a685    7 months ago    247 MB
   ```

   当你在一个容器运行镜像时，**Dorcker** 会适时为你的电脑下载镜像。这样做，可以为你留下本地副本。**Dorcker** 只会下载 Hub 上修改的镜像源。当然了，你也可以删除镜像。

4. 我们来玩会 whalesay 和它的容器：


   ```sh
   $ sudo docker run docker/whalesay cowsay boo-boo
   $ sudo docker run docker/whalesay cowsay boo-boo
    _________ 
   < boo-boo >
    --------- 
     \
      \
      \     
             ##        .            
          ## ## ##       ==            
         ## ## ## ##      ===            
       /""""""""""""""""___/ ===        
    ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~   
       \______ o          __/            
       \    \        __/             
        \____\______/ 
   ```
   
###

## 编译你自己的镜像

我们可以对 whalesay 镜像进行改良。现在它还不会说话，本节我们来改良它，让它可以说话。

### 第一步：写一个  Dockerfile

用你喜欢的编辑器写一个 Dockerfile。Dockerfile 描述软件如何放入镜像，指定运行环境和运行命令。

1. 打开你的控制终端。

2. 输入 `mkdir mydockerbuild` 创建一个目录：

   ```sh
   $ sudo mkdir mydockerbuild
   ```

   我们打算用这个目录来存放编译的文件。

3. 进入 mydockerbuild 目录：

   ```sh
   $ cd mydockerbuild
   ```

   现在它还是空的。

4. 在当前目录创建一个文件，名字叫 Dockerfile 。提示：你可以用 ** vi ** 或 ** nano ** 完成。

5. 打开你的 Dockerfile 。

6. 加入一行：

   ```docker
   FROM docker/whalesay:latest
   ``` 

   `FROM` 是一个关键字，告诉 **docker** 你的镜像依赖哪个镜像。whalesay 很小巧，并且已经有 **cowsay** 程序了，所以我们从这里开始。

7. 现在，把 **fortunes** 程序加入镜像：

   ```docker
   RUN apt-get -y update && apt-get install -y fortunes
   ```
  
   **fortunes** 程序有一个命令，可以随机打印一句话。第一步是安装它，第二步是把它安装到镜像。

8. 一旦镜像完成所需要的，当镜像加载时，通知软件运行：
    
   ```docker
   CMD /usr/games/fortune -a | cowsay
   ```
   
   这一行告诉 **fortune** 程序，把生成的话传给 **cowsay**。

9. 看看你的文件，看起来应该像：

   ```docker
   FROM docker/whalesay:latest
   RUN apt-get -y update && apt-get install -y fortunes
   CMD /usr/games/fortune -a | cowsay
   ```

10. 保存关闭 Dockerfile。现在，我们有了一个完备的 Dockerfile，接下来编译它。

### 第二步：从 Dockerfile 编译一个镜像

1. 输入 `docker build -t docker-whale` 命令，编译你的新镜像（不要漏掉 .）：

   ```sh
   $ sudo docker build -t docker-whale .
   Sending build context to docker daemon 158.8 MB
   ...snip...
   Removing intermediate container a8e6faa88df3
   Successfully built 7d9495d03763
   ```

   这个命令会花费几秒钟，并报告结果。在把玩新镜像前，先来聊聊 Dockerfile 的编译过程。

### 第三步：编译过程

`docker build -t docker-whale .` 命令会编译当前目录的 Dockerfile，并在本地机器生成一个称为 docker-whale 的镜像。编译过程稍微有点长，并输出一些信息。

首先，**docker** 检查是否符合编译要求：

```sh
Sending build context to docker daemon 158.8 MB
```

然后，**docker** 加载 whalesay 镜像。因为之前已经有了 whalesay 镜像，所以 **docker** 不需要下载它：

```sh
Step 0 : FROM docker/whalesay:latest
 ---> fb434121fc77
```

**docker** 移动到下一步，更新 **ape-get** 包管理器。这会输出很多行：

```sh
Step 1 : RUN apt-get -y update && apt-get install -y fortunes
 ---> Running in 27d224dfa5b2
Ign http://archive.ubuntu.com trusty InRelease
Ign http://archive.ubuntu.com trusty-updates InRelease
Ign http://archive.ubuntu.com trusty-security InRelease
Hit http://archive.ubuntu.com trusty Release.gpg
....snip...
Get:15 http://archive.ubuntu.com trusty-security/restricted amd64 Packages [14.8 kB]
Get:16 http://archive.ubuntu.com trusty-security/universe amd64 Packages [134 kB]
Reading package lists...
---> eb06e47a01d2
```

然后，**docker** 安装 **fortunes** 软件：

```sh
Removing intermediate container e2a84b5f390f
Step 2 : RUN apt-get install -y fortunes
 ---> Running in 23aa52c1897c
Reading package lists...
Building dependency tree...
Reading state information...
The following extra packages will be installed:
  fortune-mod fortunes-min librecode0
Suggested packages:
  x11-utils bsdmainutils
The following NEW packages will be installed:
  fortune-mod fortunes fortunes-min librecode0
0 upgraded, 4 newly installed, 0 to remove and 3 not upgraded.
Need to get 1961 kB of archives.
After this operation, 4817 kB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu/ trusty/main librecode0 amd64 3.6-21 [771 kB]
...snip......
Setting up fortunes (1:1.99.1-7) ...
Processing triggers for libc-bin (2.19-0ubuntu6.6) ...
 ---> c81071adeeb5
Removing intermediate container 23aa52c1897c
```

最后，**docker** 完成编译，报告结果：

```sh
Step 3 : CMD /usr/games/fortune -a | cowsay
 ---> Running in a8e6faa88df3
 ---> 7d9495d03763
Removing intermediate container a8e6faa88df3
Successfully built 7d9495d03763
```

### 第四步：运行新的 docker-whale

现在，来试试新的镜像。

1. 回到控制终端。

2. 输入 `docker images` 命令，按下回车：

   ```sh
   $ sudo docker images
   REPOSITORY         TAG       IMAGE ID        CREATED         VIRTUAL SIZE
   docker-whale       latest    7d9495d03763    4 minutes ago   273.7 MB
   docker/whalesay    latest    ded5e192a685    7 months ago    247 MB
   hello-world        latest    0a6ba66e537a    3 months ago    960 B  
   ```

3. 输入 `docker run docker-whale` 命令，按下回车：

   ```sh
   $ sudo docker run docker-whale
    _________________________________________
   / "He was a modest, good-humored boy. It  \
   \ was Oxford that made him insufferable." /
    -----------------------------------------
             \
              \
               \     
                             ##        .            
                       ## ## ##       ==            
                    ## ## ## ##      ===            
                /""""""""""""""""___/ ===        
           ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~   
                \______ o          __/            
                 \    \        __/             
                   \____\______/   
   ```
   
   正如你所看到的，我们已经让鲸鱼变得更加聪明。它会自己说话。你可能也注意到，**docker* 不必下载任何东西。那是因为镜像是在本地编译的，并且已经可用。
   
###

## 创建一个 Hub 账户和库

你已经编译了一些很酷的东西，应该分享它，不是吗？你需要一个 docker Hub 账户。然后，把你的镜像推送到 Hub，让其他人可以运行你的酷玩意。

### 第一步：注册一个账户

1. 用你的浏览器进入到 [docker Hub](https://hub.docker.com/?utm_source=getting_started_guide&utm_medium=embedded_Linux&utm_campaign=create_docker_hub_account)。

   ![docker Hub](https://docs.docker.com/tutimg/hub_signup.png)

2. 填入你的注册信息。docker Hub 是免费的，只需要一个用户名、密码、电子邮件地址。

3. 点击 Signup。

### 第二步：验证你的电子邮件，并加入一个库

在 Hub 开始分享前，你需要验证电子邮件。

1. 进入你的邮件收件箱。

2. 看看邮件，应该有个 **Please confirm email for your docker Hub account.**。

3. 打开邮件，点击确认按钮。

4. 选择创建库。

5. 输入库名字和描述。

6. 确保是公开的。

   ![Repository](https://docs.docker.com/tutimg/add_repository.png)

7. 点击 Create 按钮。恭喜！你创建了一个新库！

###

## 标签，推送，拉

这里，我们聊聊如何给你的库打标签，推送，和拉。

### 第一步：标签和推送

1. 返回你的终端。

2. 列出当前镜像：

   ```sh
   $ sudo docker images
   REPOSITORY         TAG       IMAGE ID        CREATED         VIRTUAL SIZE
   docker-whale       latest    7d9495d03763    4 minutes ago   273.7 MB
   docker/whalesay    latest    ded5e192a685    7 months ago    247 MB
   hello-world        latest    0a6ba66e537a    3 months ago    960 B
   ```

3. 看一下 docker-whale 的 `IMAGE ID` （镜像号）。在这个例子中，是 `7d9495d03763` 。你应该也注意到，`REPOSITORY` 显示 `docker-whale`，但是没有命名空间。你需要在 docker Hub 为它分配命名空间。命名空间是你的账户名。

4. 使用 `IMAGE ID` 和 `docker tag` 命令，为你的镜像打上标签。

   * `docker` 告诉操作系统：你正在使用 **docker** 程序

   * `tag` 打上标签

   * `7d9495d03763` 镜像号

   * `yourname/docker-whale:latest` 镜像名

   ```sh
   $ sudo docker tag 7d9495d03763 yourname/docker-whale:latest
   ```

5. 再次列出当前镜像：

   ```sh
   $ sudo docker images
   REPOSITORY               TAG       IMAGE ID        CREATED         VIRTUAL SIZE
   yourname/docker-whale    latest    7d9495d03763    5 minutes ago   273.7 MB
   docker-whale             latest    7d9495d03763    2 hours ago     273.7 MB
   docker/whalesay          latest    ded5e192a685    7 months ago    247 MB
   hello-world              latest    0a6ba66e537a    3 months ago    960 B
   ```

6. 使用 `docker login` 命令登录到 docker Hub：

   ```sh
   $ sudo docker login --username=yourname --email=mary@docker.com
   Password:
   WARNING: login credentials saved in C:\Users\sven\.docker\config.json
   Login Succeeded
   ```

7. 使用 `docker push` 命令把你的镜像推送到新的库：

   ```sh
   $ sudo docker push maryatdocker/docker-whale
   The push refers to a repository [maryatdocker/docker-whale] (len: 1)
   7d9495d03763: Image already exists
   c81071adeeb5: Image successfully pushed
   eb06e47a01d2: Image successfully pushed
   fb434121fc77: Image successfully pushed
   5d5bd9951e26: Image successfully pushed
   99da72cfe067: Image successfully pushed
   1722f41ddcb5: Image successfully pushed
   5b74edbcaa5b: Image successfully pushed
   676c4a1897e6: Image successfully pushed
   07f8e8c5e660: Image successfully pushed
   37bea4ee0c81: Image successfully pushed
   a82efea989f9: Image successfully pushed
   e9e06b06e14c: Image successfully pushed
   Digest: sha256:ad89e88beb7dc73bf55d456e2c600e0a39dd6c9500d7cd8d1025626c4b985011
   ```

8. 返回你的 Hub，看看你的新镜像：

   ![Hub Image](https://docs.docker.com/tutimg/new_image.png)

### 第二步：拉

现在，让我们把刚刚推送到 Hub 的镜像拉到本地。在这么做前，你会需要先移除本地机器的原始镜像。如果你没有这么做，**docker** 不会从 Hub 拉。为什么？因为这两个镜像一模一样。

1. 回到终端。

2. 输入 `docker images` 列出当前镜像：

   ```sh
   $ sudo docker images
   REPOSITORY               TAG       IMAGE ID        CREATED         VIRTUAL SIZE
   yourname/docker-whale    latest    7d9495d03763    5 minutes ago   273.7 MB
   docker-whale             latest    7d9495d03763    2 hours ago     273.7 MB
   docker/whalesay          latest    ded5e192a685    7 months ago    247 MB
   hello-world              latest    0a6ba66e537a    3 months ago    960 B
   ```

   为了更好的测试，你需要移除 yourname/docker-whale 和 docker-whale。

3. 使用 `docker rmi` 命令移除 yourname/docker-whale 和 docker-whale 镜像---你可以指定一个 ID 移除一个镜像：

   ```sh
   $ sudo docker rmi -f 7d9495d03763
   $ sudo docker rmi -f docker-whale
   ```

4. 使用 `docker pull` 命令从你的库拉一个镜像：

   ```sh
   $ sudo docker pull yourusername/docker-whale
   ```

   由于镜像在本地已经不可用，**docker** 从 docker Hub 下载：

   ```sh
   $ docker run maryatdocker/docker-whale
   Unable to find image 'maryatdocker/docker-whale:latest' locally
   latest: Pulling from maryatdocker/docker-whale
   eb06e47a01d2: Pull complete
   c81071adeeb5: Pull complete
   7d9495d03763: Already exists
   e9e06b06e14c: Already exists
   a82efea989f9: Already exists
   37bea4ee0c81: Already exists
   07f8e8c5e660: Already exists
   676c4a1897e6: Already exists
   5b74edbcaa5b: Already exists
   1722f41ddcb5: Already exists
   99da72cfe067: Already exists
   5d5bd9951e26: Already exists
   fb434121fc77: Already exists
   Digest: sha256:ad89e88beb7dc73bf55d456e2c600e0a39dd6c9500d7cd8d1025626c4b985011
   Status: Downloaded newer image for maryatdocker/docker-whale:latest
    ________________________________________
   / Having wandered helplessly into a      \
   | blinding snowstorm Sam was greatly     |
   | relieved to see a sturdy Saint Bernard |
   | dog bounding toward him with the       |
   | traditional keg of brandy strapped to  |
   | his collar.                            |
   |                                        |
   | "At last," cried Sam, "man's best      |
   \ friend -- and a great big dog, too!"   /
    ----------------------------------------
                   \
                    \
                     \
                             ##        .            
                       ## ## ##       ==            
                    ## ## ## ##      ===            
                /""""""""""""""""___/ ===        
           ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~   
                \______ o          __/            
                 \    \        __/             
                   \____\______/   
   ```
   
###
