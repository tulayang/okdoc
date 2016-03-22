# [Mysql 的程序们](http://dev.mysql.com/doc/refman/5.7/en/programs.html)

本章聊聊 Mysql 的命令行程序---甲骨文公司提供。当你运行这些程序时，需要指定一些选项---这些程序的选项，其语法很相似。另外，我们会深入探讨几个程序，抓好你的安全带。

## 有哪些程序？

安装 Mysql 时，会一起安装很多程序。

大部分 Mysql 发行版包含所有的程序---除了一些平台特定的程序（比如，Windows 不包含服务器启动脚本）。RPM 发行版，做的更加专业点---有一个 RPM 是服务器，另一个 RPM 是客户端。

Mysql 的程序们，有许多选项。它们会提供 `--help` 选项，你可以用来获取该程序的其他选项信息。比如，` $ mysql --help`。这些选项的默认值，是可以重写的---通过命令行、或配置文件。

### 服务器和启动脚本

**mysqld** --- Mysql 服务器，提供数据服务。这个服务器，有几个脚本伴随左右，用来启动、停止服务器：

* **mysqld** 

  SQL 守护进程（Mysql 服务器）。客户端连接服务器，然后访问数据库。 

* **mysqld_safe**

  一个服务器启动脚本。

* **mysql.server**

  一个服务器启动脚本。这个脚本是为 System V 系统使用的，它调用 **mysqld_safe** 启动服务器。

* **mysqld_multi** 

  一个服务器启动脚本，可以启动、停止多个服务器（这些服务器，都在本系统上）。

### 安装操作工具

下面几个程序，在 Mysql 安装或升级时，执行安装操作：

* **comp_err**

  当编译、安装时使用。它从错误源文件，编译错误消息文件。

* **mysql_install_db**

  初始化 Mysql 数据目录，创建 `mysql` 数据库，并初始化其权限表---使用默认特权；以及配置 InnoDB 系统表空间。通常，只在第一次安装 Mysql 时执行一次。

* **mysql_plugin** 

  负责配置 Mysql 的插件。

* **mysql_secure_installation** 

  帮助你改善安装时的安全。

* **mysql_ssl_rsa_setup**

  创建 SSL 证书、密钥文件、RSA 密钥对文件，以支持安全连接---使用 SSL 或 RSA。

* **mysql_tzinfo_to_sql**

  通过主机系统的 `zoneinfo` 数据库，把时区信息加载到 `mysql` 数据库的时区表。

* **mysql_upgrade**

  每当 Mysql 升级后，执行这个程序。它检查表的兼容性，并在必要的时候修复它们；当新版本出现变化时，更新权限表。

### 客户端工具

下面几个程序，是 Mysql 客户端，它们连接服务器，然后执行操作：

* **mysql**

  一个命令行工具，提供交互式功能，用来执行 SQL 语句。

* **mysqladmin** 

  执行管理操作，比如：创建、销毁一个表、重新加载权限表、冲洗表到磁盘、重新打开日志文件。也能用来检索服务器的版本、进程号、状态信息。

* **mysqlcheck** 

  一个表维护客户端，负责检查、修复、分析、优化表。

* **mysqldump**

  把 Mysql 数据库转储到一个文件---SQL、文本、XML。

* **mysqlimport**

  使用 `LOAD DATA INFILE` 把文本文件导入到表。

* **mysqlpump**

  把 Mysql 数据库转储到一个文件---SQL。

* **mysqlshow**

  一个客户端，显示数据库 、表、列、索引信息。

* **mysqlslap**

  一个客户端，为服务器仿真客户端加载，看起来好像有多个客户端在访问服务器。

### 管理和实用工具

下面几个程序，是 Mysql 管理和实用工具：

* **innochecksum**

  一个离线的 InnoDB 文件检查工具。

* **myisam_ftdump**

  显示 MyISAM 表的全文索引信息。

* **myisamchk**

  描述、检查、优化、修复 MyISAM 表。

* **myisamlog**

  负责处理 MyISAM 日志文件的内容。

* **myisampack**

  压缩 MyISAM 表，生成小的只读表。

* **mysql_config_editor**

  使你可以通过名为 *.mylogin.cnf* 的文件（安全，需要加密登录）存储身份证书。

* **mysqlbinlog**

  从二进制日志读取语句。二进制日志的记录，可以帮助你从宕机中恢复。

* **mysqldumpslow**

  读一个慢查询日志，并做出总结。

### 开发工具

下面几个程序，是 Mysql 开发工具：

* **mysql_config** 

  一个 **shell** 脚本，当编译 Mysql 程序时，生成选项值。

* **my_print_defaults** 

  一个工具，显示现在配置文件的信息。

* **resolve_stack_dump** 

  一个工具，解析 a numeric stack trace dump to symbols。

### 杂项工具

下面几个程序，是一些杂项工具：

* **lz4_decompress**

  解压 **mysqlpump** （数据使用 LZ4 压缩）。

* **perror**

  显示 Mysql 或系统错误码的对应消息。

* **replace**

  在输入文本中，执行字符串替换。

* **resolveip**

  通过主机名解析 IP 地址，或反过来。

* **zlib_decompress**

  解压 **mysqlpump** （数据使用 ZLIB 压缩）。

甲骨文还提供了 MySQL Workbench 图形工具，帮助管理 Mysql 服务器、执行 SQL 语句、迁移数据等等。另外，还有 MySQL Notifier 和 MySQL for Excel 图形工具。  

### 

## 环境变量

Mysql 客户端和服务器通信时，使用内置的库、以及下面的环境变量：

环境变量|描述
-------|----
`MYSQL_UNIX_PORT`|默认的 UNIX 套接字文件，用于本地连接
`MYSQL_TCP_PORT`|默认的端口号，用于 TCP/IP 连接
`MYSQL_PWD`|默认的密码
`MYSQL_DEBUG`|当调试时，作为调试跟踪项
`TMPDIR`|这个目录，用来创建临时表、及其文件

所有的环境变量列表，[→ 环境变量](http://dev.mysql.com/doc/refman/5.7/en/environment-variables.html)。

使用 `MYSQL_PWD` 是不安全的！！！[→ 用户密码安全指南](http://dev.mysql.com/doc/refman/5.7/en/password-security-user.html)    
 
### 

## 如何使用这些程序？

### 调用程序

调用 Mysql 程序：打开终端，输入程序名，指定选项和值。例子：

```sh
$ mysql --user=root test
$ mysqladmin extended-status variables
$ mysqlshow --help
$ mysqldump -u root personnel
```

以 `--` 或 `-` 开始的参数，用来指定程序选项。非选项参数（没有 `--`、`-` 引导），提供附加信息。比如，在上面的 `mysql`，会把第一个非选项参数作为数据库名---使用 `test` 数据库。

许多程序有一些相同的选项。经常使用的有：`--host`（`-h`）、`--user`（`-u`）、`--password`（`-p`），它们指定连接参数。分别表示：Mysql 服务器所在的主机、用户名、密码。所有 Mysql 客户端拥有这些选项，以此连接到指定的服务器。其他的连接选项有：`--port（`-P`） 指定 TCP/IP 端口号、`--socket`（`-S`） 指定 UNIX 本地套接字文件。

Mysql 程序安装在 *bin* 目录。为了更方便使用 Mysql 程序，在环境变量 `PATH` 加入 Mysql 的 *bin* 目录。之后，你可以只输入程序名，而不用输入完整的路径，即可运行程序。比如：如果 **mysql** 安装在 */usr/local/mysql/bin*，加入环境变量后，只需要输入 `mysql`，而不必输入 `/usr/local/mysql/bin/mysql`。

### 连接到服务器

客户端程序，可以连接到服务器，不过你必须指定正确的连接参数：主机、用户名、密码。每个连接参数有一个默认值，但是，你可以重写它们---通过命令行或配置文件。

我们在这儿用 **mysql** 程序举例，但是它的这些规则适用其他客户端程序：**mysqldump**、**mysqladmin**、**mysqlshow** 等。

不指定任何连接参数，调用 **mysql** 程序：

```sh
$ mysql
```

由于没有指定参数，使用默认值：

* 默认主机名是 `localhost`。

* 默认用户名是登录名（Unix）或 `ODBC` （Windows）。

* 如果既不指定 `-p` 也不指定 `--password`，则不发送密码。

* 对于 **mysql**，第一个非选项参数作为默认数据库。如果没有，则不选择默认数据库。

指定主机名、用户名、密码：

```sh
$ mysql --host=localhost --user=myname --password=mypass mydb
$ mysql -h localhost -u myname -pmypass mydb
```    

密码的值是可选的：

* 如果指定 `-p` 或 `--password`，以及值，那么值必须紧随其后---不能有空格。

* 如果指定 `-p` 或 `--password`，没有指定值，客户端程序会提示你输入密码。输入的密码以 `*` 显示。这种输入更加安全---可以防止别人偷窥你的密码。

在命令行包含密码值，存在安全风险。为了避免风险，指定 `-p` 或 `--password`，不要指定值：

```sh
$ mysql --host=localhost --user=myname --password mydb
$ mysql -h localhost -u myname -p mydb
```

客户端程序随后打印一条提示，要求输入密码。

在某些系统，Mysql 依赖的库，会限制密码最长 8 个字符。这是系统库的问题，并非 Mysql 的问题。Mysql 不对密码长度做任何限制。如果你碰到这个问题，把密码设定的短一些，或者放在配置文件。

在 Unix，对于 Mysql 程序，主机名 `localhost` 有特殊含义。连接到 `localhost` 时，Mysql 尝试通过本地套接字文件连接。即便指定了 `--port` 或 `-P`，也会这么做。如果你想坚持用 TCP/IP 连接，指定 `--host` 或 `-h` 为 `127.0.0.1`，或者本地服务器的 IP 地址。也可以指定连接协议 `--protocol=TCP`。例子：

```sh
$ mysql --host=127.0.0.1
$ mysql --protocol=TCP
```

`--protocol` 使你建立指定类型的连接，即便其他选项是默认值。

如果服务器配置后，可以接受 IPv6 连接，客户端可以使用 IPv6 地址 ` --host=::1` 连接服务器。

连接到远程服务器时，总是使用 TCP/IP。例子（默认端口号 `3306`）：

```sh
shell> mysql --host=remote.example.com
```

使用 `--port` 或 `-P` 指定端口号：

```sh
shell> mysql --host=remote.example.com --port=13306
```

你也可以指定本地服务器的端口号。然而，正如上面提到的，连接 `localhost`，默认使用 Unix 本地套接字文件---端口号会被忽略：

```sh
shell> mysql --port=13306 --host=localhost
```

使端口号起作用，需要这么做：

```sh
shell> mysql --port=13306 --host=127.0.0.1
shell> mysql --port=13306 --protocol=TCP
```

下面汇总了客户端程序连接服务器的选项：

* `--host=host_name`、`-h host_name` 指定主机。默认值是 ` localhost`。

* `--user=user_name`、`-u user_name` 指定用户名。默认值是登录名（Unix）或 `ODBC` （Windows）。

* `--password[=pass_val]`、`-p[pass_val]` 指定密码。如果不指定，不发送密码。

* `--port=port_num`、`-P port_num` 指定端口号，使用 TCP/IP 连接。默认值是 `3306`。

* `--protocol={TCP|SOCKET|PIPE|MEMORY}` 指定协议。`TCP` 可以在 Unix 和 Windows 使用；`SOCKET` 只能在 Unix 使用；`PIPE`、`MEMORY` 只能在 Windows 使用。

* `--shared-memory-base-name=name` Windows 专用。

* `--socket=file_name`、`-S file_name` Unix 本地套接字文件名。默认值是 */tmp/mysql.sock*。

* `--ssl*` 以 `--ssl` 开始的选项，用来建立安全连接---通过 SSL。

* `--tls-version=protocol_list` 指定 SSL 的库版本。

  > 这个选项是 Mysql 5.7.10 增加的。

每次运行程序时都指定选项？这太麻烦了。我们有两个解决方法：

1. 在配置文件设置 `[client]` 块的选项。例子：

   ```?
   [client]
   host=host_name
   user=user_name
   password=your_pass
   ```

2. 使用环境变量指定一些连接参数：`MYSQL_HOST` 指定主机，`USER` 指定用户名，`MYSQL_PWD` 指定密码（不过这不安全）。 

### 指定选项

为 Mysql 程序指定选项，有如下几个办法：

* 在命令行依次列出。

* 在配置文件列出，程序启动时自动读它。

* 在环境变量列出。

选项是按照顺序处理的。因此，如果一个选项被指定多次，只有最后一个被接受。例子：

```sh
shell> mysql -h example.com -h localhost
```

如果同时给出了相冲突或相关的选项，只接受后边的。例子---运行，没有列名：

```sh
shell> mysql --column-names --skip-column-names
```

Mysql 程序先从环境变量确定选项，然后读配置文件，最后检查命令行。因此，环境变量是最低的优先级，命令行是最高的优先级。

你可以利用这一点，在配置文件设置通用值。然后，在特殊之处，通过命令行修改。

> 注意：5.7.2 版本前，允许用模糊前缀来表示选项。比如，`--compress` 可以写作 `--compr`（但是不能写作 `--comp`）。自 5.7.2 版本，禁止用模糊前缀来表示，毕竟这太容易引发问题了。

### 使用命令行指定选项

在命令行指定选项，遵循下列规则：

* 选项要在命令名之后。

* 以 `-`、`--` 开始的选项，附有参数值。

* 选项名是大小写敏感的。`-v` 和 `-V` 有不同的意思。

* 一些选项后面跟着值。比如 `-h localhost` 或 `--host=localhost` 表示主机。

* 后面跟着值的选项，以 `--` 开始的用 `=` 赋值；以 `-` 开始的跟随空格和值，`-p` 比较特殊---没有空格。

* 选项名中，`-` 和 `_` 可以互换。比如：`--skip-grant-tables` 和 `--skip_grant_tables` 是等价的。

* 选项值是数字的，可以有后缀 `K`、`M`、`G`（大写、小写都可以），表示 1024、1024 * 1024、1024 * 1024 * 1024。例子：

  ```sh
  shell> mysqladmin --count=1K --sleep=10 ping
  ```

含有空格的选项值，必须用引号包裹。比如：`--execute`（`-e`）选项，可以用 **mysql** 传送 SQL 语句给服务器，当使用的时候，其值必须用引号包裹：

```sh
shell> mysql -u root -p --execute="SELECT User, Host FROM mysql.user"
Enter password: ******
+------+-----------+
| User | Host      |
+------+-----------+
|      | gigan     |
| root | gigan     |
|      | localhost |
| jon  | localhost |
| root | localhost |
+------+-----------+
shell>
``` 

如果你想传送语句，可能也需要转义内部引号，或者使用一个不同的包裹符号。你的命令处理器决定是否可以用单引号、双引号包裹转义引号。比如：如果你的命令处理器即支持单引号也支持双引号，你可以使用双引号包裹，用单引号在语句内作为字符串。

多个 SQL 语句使用 `;` 隔开：

```sh
shell> mysql -u root -p -e "SELECT VERSION();SELECT NOW()"
Enter password: ******
+------------------+
| VERSION()        |
+------------------+
| 5.7.10-debug-log |
+------------------+
+---------------------+
| NOW()               |
+---------------------+
| 2015-11-05 20:01:02 |
+---------------------+
```

### 启用、关闭选项

一些选项是布尔值，可以启用或关闭该选项。比如：**mysql** 支持 `--column-names` 选项---启用或关闭在结果中显示列名；默认，是启用，然而，你可以关闭。要关闭显示列名，有如下几个办法：

```sh
--disable-column-names
--skip-column-names
--column-names=0
``` 

`--disable`、`--skip` 前缀和 `=0` 后缀有相同的效果：关闭该选项。

启用该选项有如下几个办法：

```sh
--column-names
--enable-column-names
--column-names=1
```

值 `ON`、`TRUE`、`OFF`、`FALSE` 也都是可用的值。

以 `--loose` 开始的选项，如果该选项不存在，程序不会错误退出，而是发出一个警告：

```sh
shell> mysql --loose-no-such-option
mysql: WARNING: unknown option '--loose-no-such-option'
```

The `--loose` prefix can be useful when you run programs from multiple installations of MySQL on the same machine and list options in an option file. An option that may not be recognized by all versions of a program can be given using the `--loose` prefix (or loose in an option file). Versions of the program that recognize the option process it normally, and versions that do not recognize it issue a warning and ignore it. 

对于 **mysqld** 使用的动态变量，可以用 `--maximum` 前缀加变量名，设定该变量的最大值。比如 `--maximum-query_cache_size=4M` 指定任何客户端的查询缓存长度不能大于 `4M`。

### 使用配置文件指定选项

大部分 Mysql 程序，可以从配置文件读取启动项。配置文件为指定选项提供了便利。

使用 `--help` 看看 Mysql 程序是否支持读配置文件。如果支持，会列出它查找的文件，以及支持的选项组。

*.mylogin.cnf* 文件包含了登录路径，它由 **mysql_config_editor** 工具创建。登录路径是一个特定的选项组合：主机、用户名、密码、端口号、套接字。客户端程序使用 `--login-path` 指定登录路径。

在 Unix、Linux、OS X，Mysql 通过下列文件读取启动项（按照顺序，先读最上边的，然后依次往下读）：

文件名|目的
-----|---
*/etc/my.cnf*|全局配置
*/etc/mysql/my.cnf*|全局配置
*SYSCONFDIR/my.cnf*|全局配置
*$MYSQL_HOME/my.cnf*|服务器指定配置
defaults-extra-file|`--defaults-extra-file=file_name` 指定的文件名
*~/.my.cnf*|用户指定配置
*~/.mylogin.cnf*|登录路径配置

其中，`~` 表示当前工作目录（`$HOME`）。

`SYSCONFDIR` 表示：当 Mysql 用 Cmake 编译时指定的 `SYSCONFDIR` 目录。默认，是编译目录的 etc 目录。

`$MYSQL_HOME` 是一个环境变量，包含服务器指定的目录。如果没有设置 `$MYSQL_HOME`，使用 **mysqld_safe** 启动服务器，**mysqld_safe** 尝试设置 `$MYSQL_HOME`：

* 用 `BASEDIR` 和 `DATADIR` 分别表示 Mysql 主目录和数据目录。

* 在 5.7.8 版本，如果没有设置 `$MYSQL_HOME`，将其设置为 `BASEDIR`。

* 在 5.7.8 版本之前，如果在 `DATADIR` 有 *my.cnf* 文件，但是 `BASEDIR` 没有，设置 `$MYSQL_HOME` 为 `DATADIR`。否则，如果 `DATADIR` 没有 *my.cnf* 文件，设置 `$MYSQL_HOME` 为 `BASEDIR`。

通常，`DATADIR` 是 */usr/local/mysql/data* （二进制安装） 或 */usr/local/var* （源安装）。这是在配置期指定的数据目录，而不是 **mysqld** 启动时指定的 `--datadir`。运行期指定 `--datadir` 不影响查找配置文件。

如果这些配置文件不存在，你需要自己创建一个。

如果找到了多个配置文件，最后一个享有最高的优先级。只有一个例外：对于 **mysqld**，`--user` 选项使用第一个设定的文件，以防止在命令行重写。

> 注意：在 Unix 平台，Mysql 会忽略那些人人可写的文件。这样做，是为了安全考虑。

配置文件的语法，类似命令行语法，只不过省略了 `--` 前缀。比如：命令行 `--host=localhost`，在配置文件写作 `host=localhost`。

空行会被忽略。非空行可以是下列形式：

* `#comment`、`;comment` 注释行以 `#`、`;` 开始。

* `[group]`

  `group` 是程序名或想要设置的组。其下面的所有项都属于该程序或组，直到一个新 `group` 出现。`group` 名不区分大小写。

* `opt_name`

  等价于命令行的  `--opt_name`。

* `opt_name=value` 

  等价于命令行的  `--opt_name=value`。在配置文件中，可以在 `=` 周围有空格。

选项名和值的头尾空格被自动删除。

可以在选项值使用转义字符 `\b` （回退）、`\t` （制表符）、`\n` （换行符）、`\r` （回车符）、`\\` （反斜杠）、`\s` （空白符）。配置文件中的转义规则如下：

* 如果反斜杠跟随一个有效的转义字符，则进行转换。比如：`\s` 转换为空格。

* 如果反斜杠跟随一个无效的转义字符，则保持不变。比如：`\S` 变为 `S`。

如果 `group` 是一个程序名，那么其配置项作为程序的配置。比如：`[mysqld]` 和 `[mysql]` 分别应用到 **mysqld** 和 **mysql**。

`[client]` 作为所有客户端的配置（而不是 **mysqld**）。这能让你为所有客户端指定选项。

这儿有个全局配置文件的例子：

```?
[client]
port=3306
socket=/tmp/mysql.sock

[mysqld]
port=3306
socket=/tmp/mysql.sock
key_buffer_size=16M
max_allowed_packet=8M

[mysqldump]
quick
```

这是一个用户配置文件：

```sh
[client]
# The following password will be sent to all standard MySQL clients
password="my_password"

[mysql]
no-auto-rehash
connect_timeout=2
```

你可以指定发行版本，只有该版本使用设定的选项：

```sh
[mysqld-5.7]
sql_mode=TRADITIONAL
```

可以使用 `!include` 导入其他配置文件，`!includedir` 查找指定的目录。比如，导入 */home/mydir/myopt.cnf* 文件：

```sh
!include /home/mydir/myopt.cnf
```

查找 */home/mydir* 并读取配置文件：

```sh
!includedir /home/mydir
```

读这个目录的文件，其顺序是不确定的。

> 注意：在 Unix，`!includedir` 查找文件时只会找 `.cnf` 结尾的文件。在 Windows，只会找 `.ini`、`.cnf` 结尾的文件。

### 只能在命令行指定的选项

以下的选项会影响配置文件的处理，它们必须通过命令行指定，不能放在配置文件。

* `--print-defaults` 

  可能会在 `--defaults-file`、`--defaults-extra-file`、或 `--login-path` 后立刻使用。当指定文件名，尽量不要用 `～`，因为可能无法正确解析。

* `--defaults-extra-file=file_name` 

  在全局配置文件后，用户配置文件前，登录路径文件前读该配置文件。如果文件不存在，或者无法访问，则发生错误。如果 `file_name` 可以是相对路径----以当前目录作为解析。

* `--defaults-file=file_name` 

  只使用指定的文件。如果文件不存在，或者无法访问，则发生错误。如果 `file_name` 可以是相对路径----以当前目录作为解析。

* `--defaults-group-suffix=str` 

  不止读常用 group，也读有后缀的 group。比如： **mysql** 客户端通常读 `[client]` 和 `[mysql]`，设定 `--defaults-group-suffix=_other` 后，**mysql** 也读 `[client_other]` 和 `[mysql_other]`。

* `--login-path=name` 

* `--no-defaults` 
  
  禁止读取任何配置文件。如果程序启动时读取了配置文件，出现未知错误，这个选项可以避免读取它们。

  有一个例外：程序仍然会读 *.mylogin.cnf* 文件（如果存在的话）。

* `--print-defaults` 

  打印程序名，和从配置文件获取的所有选项。在 5.7.8 版本，密码会被掩饰。

### 通过选项设置程序变量

许多 Mysql 程序有内部变量，可以在运行期通过 `SET` 设置。

其中的许多变量，也可以在程序启动时，通过选项设置。比如：**mysql** 有一个 `max_allowed_packet` 变量，用来控制通信缓冲区的最大长度。设置 `max_allowed_packet` 为 `16MB`：

```sh
shell> mysql --max_allowed_packet=16777216
shell> mysql --max_allowed_packet=16M
```

在配置文件中：

```?
[mysql]
max_allowed_packet=16777216
```

或

```?
[mysql]
max_allowed_packet=16M
```

使用 `SET`，你可以为变量设置表达式，但是配置文件不行。下面例子，第一个是合法的，第二个不是：

```sh
shell> mysql --max_allowed_packet=16M
shell> mysql --max_allowed_packet=16*1024*1024
```

下面例子，第二个是合法的，第一个不是：

```sh
mysql> SET GLOBAL max_allowed_packet=16M;
mysql> SET GLOBAL max_allowed_packet=16*1024*1024;
```

### 配置文件和命令行的解析问题

按照约定，以 `--` 开始的选项，用 `=` 赋值：

```sh
shell> mysql --host=tonfisk --user=jon
```

那些需要赋值的选项（它们没有默认值），可以不用 `=`，写作这样：

```sh
shell> mysql --host tonfisk --user jon
```

然而，这个设定容易引发问题。举个例子，主机 `tonfisk`、用户 `json` 连接到服务器：

```sh
shell> mysql --host 85.224.35.45 --user jon
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 3
Server version: 5.7.12 Source distribution

Type 'help;' or '\h' for help. Type '\c' to clear the buffer.

mysql> SELECT CURRENT_USER();
+----------------+
| CURRENT_USER() |
+----------------+
| jon@%          |
+----------------+
1 row in set (0.00 sec)
```

如果省略选项值，则引发错误：

```sh
shell> mysql --host 85.224.35.45 --user
mysql: option '--user' requires an argument
```

下面的也一样：

```sh
shell> mysql --host --user jon
ERROR 2005 (HY000): Unknown MySQL server host '--user' (1)
```

解析器会把这条命令解析为：`--host=--user`，从而引发错误。

那些有默认值的选项，则必须用 `=` 赋值（不能省略）。比如，`--log-error` 有一个默认值 `host_name.err`，host_name 是主机名。假设服务器运行在 `tonfisk` 主机，然后：

```sh
shell> mysqld_safe &
[1] 11699
shell> 080112 12:53:40 mysqld_safe Logging to '/usr/local/mysql/var/tonfisk.err'.
080112 12:53:40 mysqld_safe Starting mysqld daemon with databases from /usr/local/mysql/var
shell>
```

关闭服务器，重新启动，然后：

```sh
shell> mysqld_safe --log-error &
[1] 11699
shell> 080112 12:53:40 mysqld_safe Logging to '/usr/local/mysql/var/tonfisk.err'.
080112 12:53:40 mysqld_safe Starting mysqld daemon with databases from /usr/local/mysql/var
shell>
```

如你所见，上面两个结果是一样的。`--log-error` 使用默认值 `/usr/local/mysql/var/tonfisk.err`。现在，我们这样做：

```sh
shell> mysqld_safe --log-error my-errors &
[1] 31357
shell> 080111 22:53:31 mysqld_safe Logging to '/usr/local/mysql/var/tonfisk.err'.
080111 22:53:32 mysqld_safe Starting mysqld daemon with databases from /usr/local/mysql/var
080111 22:53:34 mysqld_safe mysqld from pid file /usr/local/mysql/var/tonfisk.pid ended

[1]+  Done                    ./mysqld_safe --log-error my-errors
```

结果出现错误，`--log-error` 仍然使用默认值 `/usr/local/mysql/var/tonfisk.err`。让我们看看错误日志里写了什么：

```sh
shell> tail /usr/local/mysql/var/tonfisk.err
2013-09-24T15:36:22.278034Z 0 [ERROR] Too many arguments (first extra is 'my-errors').
2013-09-24T15:36:22.278059Z 0 [Note] Use --verbose --help to get a list of available options!
2013-09-24T15:36:22.278076Z 0 [ERROR] Aborting
2013-09-24T15:36:22.279704Z 0 [Note] InnoDB: Starting shutdown...
2013-09-24T15:36:23.777471Z 0 [Note] InnoDB: Shutdown completed; log sequence number 2319086
2013-09-24T15:36:23.780134Z 0 [Note] mysqld: Shutdown complete
```

`--log-error` 有默认值，因此，你必须用 `=` 为其赋值（不能省略）！！！像这样：

```sh
shell> mysqld_safe --log-error=my-errors &
[1] 31437
shell> 080111 22:54:15 mysqld_safe Logging to '/usr/local/mysql/var/my-errors.err'.
080111 22:54:15 mysqld_safe Starting mysqld daemon with databases from /usr/local/mysql/var

shell>
```

现在，服务器启动成功了，错误日志设定为 `/usr/local/mysql/var/my-errors.err`。

在配置文件中，也会存在类似的问题。例子：

```sh
[mysql]

host
user
```

这会被解析为 `--host=--user`，因此，引发下面的错误：

```sh
shell> mysql
ERROR 2005 (HY000): Unknown MySQL server host '--user' (1)
```

而且，在配置文件赋值时，不能省略 `=` ---虽然在命令行有时可以（没有默认值的选项）。例子：

```sh
[mysql]

user jon
```

这也会引发错误：

```sh
shell> mysql
mysql: unknown option '--user jon'
```

你必须使用 `=` 赋值：

```sh
[mysql]

user=jon
```

现在，可以成功运行：

```sh
shell> mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 5
Server version: 5.7.12 Source distribution

Type 'help;' or '\h' for help. Type '\c' to clear the buffer.

mysql> SELECT USER();
+---------------+
| USER()        |
+---------------+
| jon@localhost |
+---------------+
1 row in set (0.00 sec)
```

然而，在命令行则不需要 `=` ：

```sh
shell> mysql --user jon --host tonfisk
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 6
Server version: 5.7.12 Source distribution

Type 'help;' or '\h' for help. Type '\c' to clear the buffer.

mysql> SELECT USER();
+---------------+
| USER()        |
+---------------+
| jon@tonfisk   |
+---------------+
1 row in set (0.00 sec)
```

在配置文件，那些没有默认值的选项，省略值也同样引发错误。例子：

```sh
[mysqld]
log_error
relay_log
relay_log_index
```

这会引发错误：

```sh
shell> mysqld_safe &

130924 10:41:46 mysqld_safe Logging to '/home/jon/bin/mysql/var/tonfisk.err'.
130924 10:41:46 mysqld_safe Starting mysqld daemon with databases from /home/jon/bin/mysql/var
130924 10:41:47 mysqld_safe mysqld from pid file /home/jon/bin/mysql/var/tonfisk.pid ended
```

`--log-error` 没有问题，它提供默认值；但是，`relay_log` 需要值。我们看看日志文件写了什么：

```sh
shell> tail -n 3 ../var/tonfisk.err

130924 10:41:46 mysqld_safe Starting mysqld daemon with databases from /home/jon/bin/mysql/var
2013-09-24T15:41:47.217180Z 0 [ERROR] /home/jon/bin/mysql/libexec/mysqld: option '--relay-log' requires an argument
2013-09-24T15:41:47.217479Z 0 [ERROR] Aborting
```    

解析器把配置文件解析为 `--relay-log=relay_log_index`，结果，错误就出现了！！！

### 设置环境变量

你可以在命令行设置环境变量，影响当前调用；或者，在操作系统的启动文件设置环境变量，永久影响调用。

在 Unix，假设你想指定 TCP/IP 端口号，可以使用 `MYSQL_TCP_PORT` 环境变量：

```sh
$ MYSQL_TCP_PORT=3306
$ export MYSQL_TCP_PORT
```

第一行设定变量，第二行暴露接口，以使 Mysql 和其他进程可以使用。

上面的方法，在你退出终端后就失效。如果你想设定永久影响的环境变量，在以下文件中设定环境变量：*.bashrc* 或 *.bash_profile* （如果不是 bash，而是 tcsh，则是 *.tcshrc*）。

假设你的 Mysql 程序们安装在 */usr/local/mysql/bin*。如果你想更方便地调用程序（通过程序名，而不是绝对路径），在环境变量 `PATH` 加入该目录。比如，如果你用的 **bash**，把下面内容添加到 *.bashrc* 文件：

```sh
PATH=${PATH}:/usr/local/mysql/bin
```

**bash** 使用不同的启动文件，为 **登录 shell** 和 **非登录 shell** 工作。因此，在 *.bashrc* 文件 （**登录 shell**） 和 *.bash_profile* 文件 （**非登录 shell**） 设定 `PATH`，以确保总能方便调用。

如果你用的 **tcsh**，把下面内容添加到 *.tcshrc* 文件：

```sh
setenv PATH ${PATH}:/usr/local/mysql/bin
```

如果这些启动文件不存在，就手动创建它。

修改 `PATH` 后，重新登录，以使设置生效。   

###

## mysqld 服务器

**mysqld**，就是鼎鼎大名的 Mysql 服务器，管理数据目录的访问---包含众多数据库和表。这个数据目录，也作为其他一些文件的默认安装目录，比如：日志文件、状态文件。

**mysqld** 程序启动时，可以指定很多选项。列出所有选项：

```sh
shell> mysqld --verbose --help
```

它也有一些系统变量，影响某些操作。可以在启动时设置系统变量，其中很多可以在运行时修改。另外，还有一些状态变量，提供关于某些操作的信息。你可以监视这些状态变量，来评估运行时性能如何。

## mysqld_safe 启动脚本

在 Unix，强烈推荐使用 **mysqld\_safe** 启动服务器。**mysqld_safe** 有一些安全功能，比如：当出现错误时重启服务器、把运行期信息记录到错误日志文件。 

> 注意：在 5.7.6 版本，对于一些 RPM 发布的安装包，在使用 **systemd** 启动和关机的 Linux 系统上，安装时不再包含 **mysqld_safe**，因为不再需要了。

**mysqld\_safe** 尝试启动可执行文件 **mysqld**。如果你想重写默认的行为，修改服务器的名字，指定 `--mysqld` 或 `--mysqld-version` 选项。也可以指定 `--ledir` 告诉 **mysqld_safe** 查找该目录，以找寻服务器（可执行文件）。

**mysqld_safe** 的许多选项和 **mysqld** 相同。

### 选项解析

在命令行指定的选项，如果 **mysqld_safe** 不认识，它会把选项传递给 **mysqld**；但是在配置文件 `[mysqld_safe]` 指定的选项，如果不认识，则忽略。

**mysqld\_safe** 会从配置文件的 `[mysqld]`、`[server]`、`[mysqld_safe]` 读所有选项。比如，如果在 `[mysqld]` 指定以下内容，**mysqld_safe** 会找到并使用 `--log-error` 选项：

```sh
[mysqld]
log-error=error.log
``` 

基于向后兼容，**mysqld_safe** 也会读 `[safe_mysqld]`，不过你还是都放在 `[mysqld_safe]` 吧。

### 选项汇总

* `--help` 

  显示帮助信息，然后退出。

* `--basedir=dir_name` 

  Mysql 的安装目录。

* `--core-file-size=size` 

  **mysqld** 会创建核心文件，这个选项指定其长度上限。它会被传递到 **ulimit-c**。

* `--datadir=dir_name` 

  数据所在目录。

* `--defaults-extra-file=file_name` 

  除了读常规配置文件，还会读这个文件。当在命令行设置时，它必须是第一个选项。如果这个文件不存在或不能访问，服务器报告错误，并退出。

* `--defaults-file=file_name` 
  
  不要读常规配置文件，读这个文件。当在命令行设置时，它必须是第一个选项。

* `--ledir=dir_name` 

  如果 **mysqld_safe** 不能找到服务器，则到这个目录查找。

* `--log-error=file_name` 

  指定错误日志文件。

* `--mysqld-safe-log-timestamps` 

  控制 **mysqld_safe** 产生的日志输出格式。下面的是合法值---如果是其他值，产生一个警告，并使用 UTC 格式：

  * `UTC`、`utc` 

    ISO 8601 UTC 格式（等同于服务器的 `--log_timestamps=UTC`）。默认值。

  * `SYSTEM`、`system` 

    ISO 8601 本地时间格式（等同于服务器的 `--log_timestamps=SYSTEM`）。

  * `HYPHEN`、`hyphen` 

    YY-MM-DD h:mm:ss 格式。
 
  * `LEGACY`、`legacy` 

    YYMMDD hh:mm:ss 格式。

  > 这个选项是 5.7.11 加入的。

* `--malloc-lib=[lib_name]` 

  替代 `malloc()` 的内存分配库的名字。更多细节 ......

* `--mysqld=prog_name` 

  指定服务器程序（在 `--ledir` 目录）。

* `--mysqld-version=suffix` 

  类似 `--mysqld`，为服务器程序名指定后缀。比如，你指定 `--mysqld-version=debug`，**mysqld_safe** 启动 `--ledir` 目录中的 **mysqld-debug** 程序。

* `--nice=priority` 

  使用 **nice** 程序设置服务器的调度优先级。

* `--no-defaults` 

  不要读取任何配置文件。如果使用该选项，则必须是第一个选项。

* `--open-files-limit=count` 

  **mysqld_safe** 打开的文件上限值，会被传递给 **ulimit -n**。

* `--pid-file=file_name` 

  指定进程号文件。在 5.7.2 版本及其以后，**mysqld\_safe** 创建一个进程号文件，名为 *mysqld\_safe.pid*。

* `--plugin-dir=dir_name` 

  指定插件目录。

* `--port=port_num` 

  指定接受连接的端口号---TCP/IP 连接。端口号必须不小于 `1024`，除非你是用 `root` 用户启动。

* `--skip-kill-mysqld` 

  不尝试在启动时关掉偏离进程。只能在 Linux 使用。

* `--socket=path` 

  指定接受连接的 Unix 本地套接字文件。

* `--syslog`、`--skip-syslog` 

  在支持 **syslog** 的系统，`--syslog` 会把错误消息发送给 **syslog**；`--skip-syslog` 则禁止使用 **syslog**，消息被写入错误日志。

  当使用 **syslog** 时，*daemon.err* 负责存储所有日志消息。

  > 在 5.7.5 已经弃用这种方式，使用服务器的 `log_syslog` 系统变量代替。控制 `facility`，请使用 `log_syslog_facility` 系统变量。

* `--syslog=tag` 

  当使用 **syslog** 时，**mysqld\_safe** 和 **mysqld** 产生的消息发送时，会附带 mysqld_safe 和 mysqld 标识符。可以使用该选项，为标识符添加后缀。比如，`--syslog-tag=tag` 会修改标识符为 `mysqld_safe-tag` 和 `mysqld-tag`。

  > 在 5.7.5 已经弃用这种方式，使用服务器的 `log_syslog_tag` 系统变量代替。

* `--timezone=timezone` 

  设置时区。

* `--user={user_name|user_id}` 

  指定运行 **mysqld** 服务器的用户。

###

## mysql 命令行客户端

**mysql** 是一个简单的 Sql Shell，用来和服务器进行交互。

如果我们的内存不怎么大，而要查询的结果很大，我们可以使用 `--quick` 选项---它强制每次从服务器返回一行结果，而不用缓冲区存储（可以返回大的结果）。

### 利用重定向，执行脚本文件

我们可以通过 **mysql** 执行脚本文件（由 Sql 语句编写）：

```sh
$ mysql db_name < script.sql > output.tab
```

### 选项汇总

**mysql** 支持下列选项，可以在命令行或配置文件的 `[mysql]`、`[client]` 指定。 

* ` --help`、`-?`

  显示帮助消息。

* `--auto-rehash`

  启用自动散列计算，它能使数据库、表、列的名字自动补全。默认启用，使用 `--disable-auto-rehash` 关闭。

* `--auto-vertical-output`

   如果结果集太大，窗口显示不完全，就让它们垂直显示。

* `--batch`、`-B`

  打印结果时，用制表符作为列分隔符。选择这个选项，**mysql** 不再使用历史文件。

* `--binary-mode`

  当包含 BLOB 值时，帮助处理二进制输出。

* `--bind-address=ip_address`

  当对端有多个网卡时，使用这个选项，可以绑定要连接的 Mysql 服务器地址。

* `--character-sets-dir=dir_name`

  指定字符集安装的目录。

* `--column-names`

  显示结果集的列名。

* `--column-type-info`

  显示结果集的元数据。

* `--comments`、`-c`

  发送给服务器的语句，保留注释。默认是去掉注释 `--skip-comments`。

* `--compress`、`-C`

  如果客户端和服务器支持压缩，则压缩传输的数据。

* `--connect-expired-password`

  禁止用过期密码连接。5.7.2 加入。

* `--database=db_name`、`-D db_name`

  指定选择哪个数据库。

* `--debug[=debug_options]`、`-# [debug_options]`

  把输出也写入到一个调试日志。

* `--debug-check`

  当程序退出时，打印调试信息。

* `--debug-info`、`-T`

  当程序退出时，打印调试信息、内存使用、CPU 使用。

* `--default-auth=plugin`

  指定客户端身份验证提示的插件。

* `--default-character-set=charset_name`

  指定客户端连接的默认字符集。

  客户端默认字符集是 `latin1`。当服务器输出 utf8 或其他多字节字符时，这会出现问题。我们可以使用这个选项，强制客户端使用正确的字符集。   

* ... 更多内容请参看官方文档

