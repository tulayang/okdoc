# [Linux 平台，基于源码，安装和升级 Mysql](http://dev.mysql.com/doc/refman/5.7/en/binary-installation.html)

甲骨文分别提供了一组源码和二进制的 Mysql 发行版。它们是 tar 文件格式（以 .tar.gz 作为扩展名），可以适用很多平台。另外，这些 tar 文件以 mysql-VERSION-OS.tar.gz 的格式命名：其中，VERSION 是数字（比如，5.7.12）,OS 是操作系统（比如，pc-linux-i686、winx64）。

> 警告：如果之前已经安装了 Mysql，那么安装源码或二进制发行版，会引发错误。应该先卸载之前的 Mysql，并且删除配置文件：*/etc/my.cnf*、*/etc/mysql* 等等。

<span>

> 警告：Mysql 依赖 libaio 库。如果系统没有这个库，数据目录初始化和随后的服务器启动就会失败。使用我们的包管理器安装它：
>
$ apt-cache search libaio  
$ apt-get install libaio1 

## 安装布局

默认，安装位置在 */usr/local/mysql*，安装后的目录有：

目录|内容
---|------
bin、scripts|**mysqld** 服务器、客户端和实用工具
data|日志文件、数据库文件
docs|手册
man|帮助页
include|头文件
lib|库文件
share|杂项文件，包括错误消息、示例配置文件、安装 SQL 语句

## 安装所需要的工具

基于 Mysql 源码安装前，我们需要准备好以下几个工具：

* **CMake** 

  如果想编译结果兼容全平台，请使用 CMake 来编译。[→ 从这里下载](http://www.cmake.org/)。

* **make** 

  强烈推荐 GNU make 3.75 或更新版本。[→ 从这里下载](http://www.gnu.org/software/make/)。

* **ANSI C++ 编译器** 

  推荐 GCC 4.4.6 或更新版本、Clang 3.3 或更新版本（FreeBSD、OSX）、Visual Studio 2013 或更新版本。

* **Boost C++ 库** 

  1.59.0 或更新版本。[→ 从这里下载](http://www.boost.org/)。安装 Boost 后，告诉编译系统 Boost 文件所在的位置---使用 **CMake** 的 `WITH_BOOST` 编译项，例子：

  ```sh
  $ cmake . -DWITH_BOOST=/usr/local/boost_1_59_0
  ``` 

* **Perl** 如果打算运行测试脚本，就必须安装。大多数 Unix-like 系统，都内置了 Perl。

另外，我们还需要解压缩工具：

* **以 .tar.gz 压缩的 tar 文件** 

  非常推荐 GNU tar，[→ 从这里下载](http://www.gnu.org/software/tar/)。

* **以 .zip 压缩的 zip 文件** 

  WinZip 或类似的工具。

* **以 .rpm 打包的 RPM 文件** 

  rpmbuild 工具可以完成这个任务。 

## 开始安装

首先，[→ 从这里下载 Mysql tar 源码文件](http://dev.mysql.com/downloads/)。[→ 所有的包获取方法](http://dev.mysql.com/doc/refman/5.7/en/getting-mysql.html)。我们在这里，只描述基于 tar 压缩文件的源码安装方法：

1. 为 Mysql 建立用户和组：

   ```sh
   $ groupadd mysql
   $ useradd -r -g mysql -s /bin/false mysql
   ```

2. 解压缩、编译源文件：

   ```sh
   $ tar zxvf mysql-VERSION.tar.gz
   $ cd mysql-VERSION
   $ cmake .
   $ make
   $ make install
   ```

   > 如果是已编译的二进制源文件，则不需要编译，直接创建软链接就可以：   
   >
   $ tar zxvf mysql-VERSION-OS.tar.gz   
   $ cd mysql-VERSION-OS   
   $ ln -s full-path-to-mysql-VERSION-OS bin/mysql

3. 初始化（用户和组、数据库目录、配置文件等等），然后启动服务器：

   ```
   $ cd /usr/local/mysql
   $ chown -R mysql .
   $ chgrp -R mysql .
   $ bin/mysql_install_db --user=mysql    # Before MySQL 5.7.6
   $ bin/mysqld --initialize --user=mysql # MySQL 5.7.6 and up
   $ bin/mysql_ssl_rsa_setup              # MySQL 5.7.6 and up
   $ chown -R root .
   $ chown -R mysql data
   $ bin/mysqld_safe --user=mysql &
   ```

   复制默认的配置文件内容，这一步是可选的：

   ```
   $ cp support-files/mysql.server /etc/init.d/mysql.server
   ```

