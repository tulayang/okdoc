
Network (网络)
--------------

```
$ ulimit    -n                                       // 查看最大连接数(socket描述符、文件描述符)
$ ifconfig  -a                                       // 查看IP
$ netstat   -apn                                     // 查看网络状态
$ netstat   -nr                                      // 查看默认网关 
$ lsof      -i:10000                                 // 查看端口
$ route     -n                                       // 查看默认网关 
$ fuser     -n tcp 8800                              // 查看TCP网络状态
$ ifconfig                                           // 查看网卡
$ ntpdate   192.168.1.101                            // 同步时间服务器  
```

Process (进程)
--------------

```
$ top                                                // 查看进程内存CPU消耗
$ ps        -aux | grep  mysqld                      // 查找进程（管道过滤）
$ ps        -ef                                      // 进程清单       
$ kill      -9[2]  1102                              // 强制关闭进程
$ pkill     -9     -U    username                    // 强制关闭用户进程
```

System (系统参数)
----------------

```
$ env                                                // 查看系统环境变量
$ pwd                                                // 查看当前目录
$ who       -r                                       // 查看服务器运行级别
$ runlevel                                           // 查看服务器运行级别

$ whereis   nodejs
$ whatis    nodejs
```

File System (文件管理)
---------------------

```
$ mkdir   /opt/mydir                                 // 创建目录
$ cd      /opt/mydir                                 // 进入目录
$ vi      /opt/mydir/test                            // 创建文件
$ gedit   /opt/mydir/test                            // 创建文件
$ cat     /opt/mydir/test                            // 查看文件
$ head    /opt/mydir/test                            // 查看文件，只有头部
$ tail    /opt/mydir/test                            // 查看文件，只有尾部
$ cp      /opt/mydir/test  /opt/mydir/test2  -R      // 复制
$ mv      /opt/mydir/test  /opt/mydir/test2          // 转移
$ rename  /opt/mydir/test  /opt/mydir/test2          // 重命名
$ rm      /opt/mydir/test  -rf                       // 删除 （递归，强制）

$ ln      /home/king/test  /bin/test                 // 创建硬连接
$ ln      /home/king/test  /bin/test  -s             // 创建软连接

$ find    /usr   -size   +10M                        // 在/usr目录下找出大小超过10MB的文件
$ find    /home  -mtime  +120                        // 在/home目录下找出120天之前被修改过的文件
$ find    /var   \!  -atime  -90                     // 在/var目录下找出90天之内未被访问过的文件
$ find    /      -name  core  -exec  rm  {}  \       // 在整个目录树下查找文件“core”，
                                                     // 如发现则无需提示直接删除它们
```

User (用户权限)
--------------

```
$ adduser lili                                       // 创建用户
          --home-dir /home/king
          --group root
$ chmod   -R  755    /home/king/test                 // 修改文件，目录权限 （递归）
$ chown   lili：root /home/king                      // 修改文件，目录用户组
```

Manager (管理员)
---------------

```
$ su                                                 // 切换管理员
$ su king                                            // 切换用户
$ passwd                                             // 重设密码
$ shutdown now                                       // 关机
$ reboot   now                                       // 重启
```

Configuation (系统配置)
------------------------

```
$ vi      /etc/profile                               // 修改系统配置，针对所有用户
$ vi      ~/.bashrc                                  // 修改系统配置，针对当前用户
$ source  /etc/profile                               // 使配置生效

 export NAME=/home/king/name                         // 提供NAME系统变量
 export PATH=${PATH}:${NAME}/bin                     // 提供并修改PATH系统变量
 ```

Important (重要文件)
--------------------

1. 用户安全

       /etc/profile                                     // 用户配置文件
       /etc/shadow                                      // 用户密码数据文件
       /etc/passwd                                      // 用户伪密码数据文件
       /etc/group                                       // 用户组数据文件

2. 系统硬件信息

       /proc/cpuinfo                                    // CPU信息
       /proc/meminfo                                    // 内存信息
       /proc/*info                                      // 所有硬件信息

3. 系统程序入口

       /bin
       /usr/bin
       /usr/local/bin
       ...

Vi
---

```
i                                                    // 光标前插入字符
a                                                    // 光标后插入字符
u                                                    // ctrl+r 撤销、还原
q                                                    // 退出
x                                                    // 删除光标后字符
d                                                    // 删除当前行
q!                                                   // 强制退出
w                                                    // 保存
```

shell
------

    #!/usr/bin/env node


OTHER
-----

$ man hier 显示文件系统分层的描述信息


