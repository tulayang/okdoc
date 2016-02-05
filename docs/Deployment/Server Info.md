服务器结构
---------

    操作系统 Linux (Ubuntu CentOS)   

<span>   

    2      台服务器   Nginx                负载均衡，反向代理   M  CPU  LL RAM  LL DISK
    2+ × 4 台服务器   Node.js              节点               MM CPU  L  RAM  LL DISK
    1+     台服务器   Redis                缓存               L  CPU  MM RAM  L  DISK
    3+     台服务器   MySQL | PostgreSQL   存储               L  CPU  MM RAM  MM DISK
    1+     台服务器   Mongodb              日志               L  CPU  L  RAM  M  DISK
    2+     台服务器   Linux                文件               L  CPU  L  RAM  MM DISK

物理架构 (Physical Structure)

                        +-------------+   
         ++------=------| | | | | | | |   Nginx (负载均衡 反向代理)        
         ||             +-------------+
         ||
         ||------=---+---------+---------+---------+---------+---------+
         ||          |         |         |         |         |         |     
         ||       +-----+   +-----+   +-----+   +-----+   +-----+   +-----+
         ||       |cc cc|   |cc cc|   |cc cc|   |cc cc|   |cc cc|   |cc cc|   Nodejs (节点服务器)
         ||       +-----+   +-----+   +-----+   +-----+   +-----+   +-----+
         ||
         ||------=---+---------+---------+---------+---------+
         ||          |         |         |         |         |        
         ||       +-----+   +-----+   +-----+   +-----+   +-----+  
         ||       |  P  |   |  S  |   |  S  |   |  S  |   |  S  |             Redis (缓存服务器)
         ||       +-----+   +-----+   +-----+   +-----+   +-----+ 
         ||
    <==> ||------=---+---------+---------+---------+---------+
         ||          |         |         |         |         |        
         ||       +-----+   +-----+   +-----+   +-----+   +-----+   
         ||       |  P  |   |  S  |   |  S  |   |  S  |   |  S  |             Mysql (数据服务器)
         ||       +-----+   +-----+   +-----+   +-----+   +-----+  
         ||
         ||------=---+---------+---------+
         ||          |         |         |        
         ||       +-----+   +-----+   +-----+  
         ||       |  P  |   |  S  |   |  S  |                                 Mongo (日志服务器)
         ||       +-----+   +-----+   +-----+  
         ||
         ||------=---+---------+
         ||          |         |        
         ||       +-----+   +-----+    
         ||       |  P  |   |  S  |                                           Fs (文件服务器)
         ||       +-----+   +-----+   
         ++

逻辑架构 (Logical Structure)

         +--------+ +--------+ +--------+              +--------+ 
         | Client | | Client | | Client | ............ | Client |       (客户端)
         +--------+ +--------+ +--------+              +--------+
             ^          ^          ^                       ^
             |          |          |      ............     |   
             v          v          v                       v
    ------------------------------------------------------------------
                                   /\
                                   ||
                                   \/
                             +-------------+   
                             |    Nginx    |                            (负载均衡 反向代理)
                             +-------------+
                                   /\
                                   ||
                                   \/
    ------------------------------------------------------------------
             ^          ^          ^                       ^
             |          |          |      ............     |   
             v          v          v                       v

         +--------+ +--------+ +--------+              +--------+ 
         | Nodejs | | Nodejs | | Nodejs | ............ | Nodejs |       (节点服务器)
         +--------+ +--------+ +--------+              +--------+
             ^          ^          ^                       ^
             |          |          |      ............     |   
             v          v          v                       v
    +-----------------------------------------------------------------
    |
    |     +---------+ +---------+ +---------+              +---------+ 
    |<--->| Redis P | | Redis S | | Redis S | ............ | Redis S |  (缓存服务器)
    |     +---------+ +---------+ +---------+              +---------+
    |
    |     +---------+ +---------+ +---------+              +---------+ 
    |<--->| Mysql P | | Mysql S | | Mysql S | ............ | Mysql S |  (数据服务器)
    |     +---------+ +---------+ +---------+              +---------+
    | 
    |     +---------+ +---------+ +---------+
    |<--->| Mongo P | | Mongo S | | Mongo S |                           (日志服务器)
    |     +---------+ +---------+ +---------+
    |
    |     +---------+ +---------+
    |<--->| File  P | | File  S |                                       (文件服务器)
    |     +---------+ +---------+ 
    |
    +-----------------------------------------------------------------

配置操作系统
-------------

1. 配置启动程序 (Config Init)

   linux 内核启动时，首先加载 init 进程（1号进程），然后按照运行级别运行相关脚本和配置。

   /etc/init.d 里的 shell 脚本（SysVinit 工具所包含的函数库）能够响应 start，stop，restart，reload 命令来管理某个具体的应用。比如经常看到的命令：/etc/init.d/networking start。这些脚本也可被其他 trigger 直接激活运行，这些 trigger 被软连接在/etc/rc{level}.d/中。这些原理可以用来写 daemon 程序，让某些程序在开关机时运行。

   /etc/init 包含的是 Upstart （Sysinit 的替代版本）的配置文件，和 /etc/init.d 的作用几乎差不多。/etc/init 可以看作 /etc/init.d 的演化版本。而 SysVinit 脚本是和新的 Upstart 兼容的。这就是这两个文件目录的来历和前世今生。

   /etc/rc2.d 有很多软链接到 /etc/init.d 的启动脚本, 集中管理，方便使用, 并且可以使用 service 程序对进程进行管理。将启动脚本放到/etc/rcN.d，脚本要以大写S开头, 后面接一个两位数的数字，表示启动顺序，数字越小表示越先启动。

   比如，编译安装完 php 后，将 sapi/fpm 的 init.d.php-fpm 文件复制到 /etc/init.d，然后在 /etc/rc2.d 创建一个软链接

       $ cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
       $ chmod +x /etc/init.d/php-fpm
       $ ln -s /etc/init.d/php-fpm /etc/rc2.d/S20php-fpm
       $ service php-fpm start

   <span>

       /etc/init.d                                        // 加载脚本
       /etc/rc{level}.d/init.d                            // 链接脚本

       $ aptitude install sysv-rc-conf                    // 安装服务器管理程序

       $ runlevel                                         // 查看服务器运行级别
       N 2

2. 添加用户 (Add User)

       $ adduser username --home /home --group group  // 添加用户
         • root
         • user1
         • user2
         • ...
       $ passwd  username                             // 设置密码
      
       $ chmod /home/which 755 -R                     // 修改文件权限
       $ chown /home/which username:group             // 修改文件用户组

3. 安装工具包 (Install Core)

       $ apt-get  install aptitude                     
       $ aptitude install gcc 
       $ ...   

       • gcc
       • openssl
       • openssh
       • vsftp
       • ...

4. 安装 Node.js

       $ ./configure → make → make install → make clean

       $ npm install -g babel
       $ npm install -g supervisor

       $ npm install rocore
       $ npm install path-to-regexp
       $ npm install formidable
       $ npm install redis
       $ npm install mysql
       $ npm install mongodb
       
       $ npm start &

5. 安装 Redis

       $ ./configure → make → make install → make clean

6. 安装 Mysql

       $ ./configure → make → make install → make clean

7. 安装 Mongo

       $ ./configure → make → make install → make clean

8. 安装 FS