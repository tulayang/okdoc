# [Linux 平台，基于 APT 库，安装和升级 Mysql](http://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/)

我们可以使用 MySQL APT 库安装 Mysql。APT 库提供 deb 包，便于安装和管理。里面包括：服务器、客户端、和一些其它组件。

MySQL APT 库支持以下平台：

* Debian 7.x (“wheezy”) 
* Debian 8.x (“jessie”)
* Ubuntu 12.04 LTS (“Precise Pangolin”) 
* Ubuntu 14.04 LTS (“Trusty Tahr”) 
* Ubuntu 15.10 (“Wily Werewolf”) 

## 全新安装 Mysql

既然是全新安装，那么之前应该没有安装过任何版本的 Mysql。如果之前安装了 Mysql，那么你应该看看下面的 [替换 Mysql]()。

### 添加 Mysql APT 库

首先，把 Mysql APT 库加入到系统软件库列表：

1. [→ 到该页面，下载 deb 包](http://dev.mysql.com/downloads/repo/apt/)

2. 使用下面的命令安装下载的包--- `version-specific-package-name` 替换为下载的包所在的路径：

   ```sh
   $ sudo dpkg -i /PATH/version-specific-package-name.deb
   ```

   举个例子，w.x.y-z 版本的包，其命令应该是：

   ```sh
   $ sudo dpkg -i mysql-apt-config_w.x.y-z_all.deb  
   ```

3. 安装期间，会要求我们选择服务器和组件的版本。如果不确定选哪个，就保持默认选择。如果不想安装某个组件，选择 none。选择完所有的内容后，选定 Apply 开始安装。

4. 更新 Mysql APT 库：

   ```sh
   $ sudo apt-get update
   ``` 

### 使用 APT 库安装 Mysql

1. 使用下面的命令安装 Mysql：

   ```sh
   $ sudo apt-get install mysql-server 
   ```

2. 安装期间，会要求我们为 `root` 用户设定密码，以及询问是否安装 test 数据库。

### 启动和停止 Mysql 服务器

安装后，Mysql 服务器自动启动。服务器守护进程支持以下命令：

1. 查看状态：

   ```sh
   $ sudo service mysql status
   ```

2. 启动服务器

   ```sh
   $ sudo service mysql start
   ```

3. 停止服务器

   ```sh
   $ sudo service mysql stop
   ```   

###

## 安装时选择主版本号

默认，安装和更新 Mysql 服务器和组件时，采用已经选择的版本。然而，我们可以使用下面的命令，修改主版本：

```sh
$ sudo dpkg-reconfigure mysql-apt-config
```

然后，会出现一个对话框，要求你选择主版本号。选择完后，选定 Apply，然后更新 Mysql APT 库：

```sh
$ sudo apt-get update
```

当你下次执行 `apt-get install` 时，会安装新选择的版本。

## 单独安装 Mysql 组件

我们可以使用 Mysql APT 库单独安装组件。首先，我们应该已经把 Mysql APT 库加入到你的系统软件库列表。然后，使用下面的命令安装组件：

```sh
$ sudo apt-get install package-name   
```

比如，安装 Workbench：

```sh
$ sudo apt-get install mysql-workbench-community
```

比如，安装共享客户端库：

```sh
$ sudo apt-get install libmysqlclient18
```

## 使用 Mysql APT 库升级 Mysql

使用 Mysql APT 库升级本地 Mysql （也就是说，用新版本替换旧版本---不会影响到数据）：

1. 我们应该已经使用 Mysql APT 库安装了 Mysql。

2. 确保 Mysql APT 库有最新的包信息：

   ```sh
   $ sudo apt-get update
   ```

3. 升级 Mysql：

   ```sh
   $ sudo apt-get install mysql-server
   ```

   Mysql 服务器、客户端、数据库通用文件，会升级到最新版本（如果可用的话）。使用同样的命令，升级其他组件：

   ```sh
   $ sudo apt-get install package-name 
   ```

   > 使用下面的命令，查看从 Mysql APT 库安装的包名：
   >
   $ dpkg -l | grep mysql | grep ii

5. 升级之后，Mysql 服务器总是自动重启。一旦重启后，我们可以运行 `mysql_upgrade`，检查是否存在不兼容的问题---旧的数据和新的软件之间。

## 使用 Mysql APT 库替换第三方发行版

...

## 使用 Mysql APT 库卸载 Mysql

使用 Mysql APT 库卸载 Mysql 服务器和相关的组件：

1. 卸载 Mysql 服务器：

   ```sh
   $ sudo apt-get remove mysql-server
   ```

2. 卸载其他自动安装的软件：

   ```sh
   $ sudo apt-get autoremove
   ```

3. 卸载其他手动安装的组件：

   ```sh
   $ sudo apt-get remove package-name
   ```
   
   > 使用下面的命令，查看从 Mysql APT 库安装的包名：
   >
   $ dpkg -l | grep mysql | grep ii
   
## 升级共享客户端库的注意事项

我们可以像上面一样安装和升级共享客户端库。当你升级了共享客户端库后，之前基于旧的共享客户端库编写的应用程序，已经编译过的能继续工作。

但是，如果我们重新编译程序，并且动态链接升级后的库，就可能会出现问题：这些库依赖的其他库，有可能需要新的版本。我们应该升级对应的依赖库。使用 Mysql APT 库，可以帮主我们完成这个任务，方法、步骤和上面的相同。

## 手动添加和配置 Mysql APT 库

如果不想使用我们发布的 deb 包安装，我们也可以手动添加和配置 Mysql APT 库：

1. [→ 到这里，下载 Mysql GPG 公钥](http://dev.mysql.com/doc/refman/5.7/en/checking-gpg-signature.html)，然后保存为一个文件。

2. 把这个公钥加入到我们的系统 GPG 钥匙扣：

   ```sh
   $ sudo apt-key add path/to/signature-file
   ```

3. 创建文件 */etc/apt/sources.list.d/mysql.list*，加入下面内容：

   ```sh
   deb http://repo.mysql.com/apt/{debian|ubuntu}/ {jessie|wheezy|precise|trusty|utopic|vivid} {mysql-5.6|mysql-5.7|workbench-6.2|utilities-1.4|connector-python-2.0}
   ```

   上面的内容，我们要选择平台对应的项：

   * Debian 或 Ubuntu 系统
   * 系统对应的代号
   * Mysql 服务器和通用文件的版本
   * 如果要安装 Workbench、实用工具、连接器，应该为每个添加单独一项

   例子：

   ```sh
   deb http://repo.mysql.com/apt/ubuntu/ precise mysql-5.6
   deb http://repo.mysql.com/apt/ubuntu/ precise connector-python-2.0
   ```

4. 更新 Mysql APT 库的包信息：

   ```sh
   $ sudo apt-get update
   ```

现在，我们已经把 Mysql APT 库添加到了系统软件库列表，然后，就可以安装了。

## Mysql APT 库可用的软件包

包名|描述
---|------
mysql-server |Mysql 服务器的元包
mysql-community-server |Mysql 服务器
mysql-client |Mysql 客户端的元包
mysql-community-client |Mysql 客户端
mysql-common |Mysql 数据库通用文件
libmysqlclient20 |Mysql 客户端库
libmysqlclient-dev |Mysql 开发文件
libmysqld-dev |Mysql 嵌入式开发文件
mysql-testsuite |Mysql 测试套件元包
mysql-community-test |Mysql 测试套件
mysql-community-bench |Mysql benchmark 套件
mysql-community-source |Mysql 源代码
mysql-workbench-community |Mysql Workbench （不支持 Debian）
mysql-connector-python-py3 |Mysql 连接器 （Ubuntu 14.04、14.10、15.04 python 3.2+）
mysql-connector-python |mysql 连接器 （Debian 7.x、Debian 8.x、Ubuntu 12.04 python 2.6.3+;Ubuntu 14.04、14.10、15.04 python 2.6.3～3.1）
mysql-utilities |Mysql 实用工具
mysql-router |Mysql 路由器

