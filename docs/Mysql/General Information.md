## 何谓 Mysql

### Mysql 为什么流行？

Mysql，是一个开源 SQL 数据库管理系统，非常流行。使用 C C++ 编写，多线程设计。由甲骨文公司开发、发布，并提供支持。[官方网站](http://www.mysql.com)

###

### Mysql 支持哪些操作系统？

Mysql 支持许多操作系统，[查看支持列表](http://www.mysql.com/support/supportedplatforms/database.html)。

###

## 安装包

### 下载安装包

Mysql 有两种安装方式：预先安装包和源代码。预先安装包，支持 RPM （[**yum** 库](http://dev.mysql.com/downloads/repo/yum/)）、APT （[**apt-get** 库](http://dev.mysql.com/downloads/repo/apt/)）安装。

#### 官方提供 deb 包，使你可以通过 APT 快速安装。当前，支持以下平台：

* Debian 7.x (“wheezy”) 
* Debian 8.x (“jessie”) 
* Ubuntu 12.04 LTS (“Precise Pangolin”)  
* Ubuntu 14.04 LTS (“Trusty Tahr”) 
* Ubuntu 15.10 (“Wily Werewolf”) 

### 使用 MD5 校验安装包的完整度

下载包后，在安装前，应该确保包是完整的，并且没有被篡改。在 Linux，使用 **md5sum** （也可能叫aaaaaaaa **md5**） 进行校验---它是 GNU Text Utilities 包的一部分，可以从[这里下载](http://www.gnu.org/software/textutils/)。例子：

```sh
$ md5sum mysql-standard-5.7.12-linux-i686.tar.gz
aaab65abbec64d5e907dcd41b8699945  mysql-standard-5.7.12-linux-i686.tar.gz
```

结果校验和 `aaab65abbec64d5e907dcd41b8699945`，应该匹配下载页面的值。

