部署 Mysql 集群
---------------

* 主服务器创建具有复制权限的用户账号，设置server-id，启动二进制日志
* 备服务器启动中继日志，设置server-id，启动复制线程]

<span>


    +---------------------+  同步   +-------------------+               
    | Master - Binary log | -----> | Slave - Relay log |--------------+
    +---------------------+  复制   +-------------------+              |
                                                            重放日志 <--+

<span>

    选取主库备库

    Master  192.168.0.1  1
    Slave   192.168.0.2  2
    Slave   192.168.0.3  3

1. Master Slave 各自创建登录账号、密码、权限 (限制在本地网络) 
       
       > grant replication slave, replication client
         on *.* 
         to repl@'192.168.0.%'
         identified by '123456';
       > show master status;

2. 配置 Master Slave (/etc/my.cnf | /etc/mysql/my.cnf)
   
   Master

       log-bin                        = mysql-bin                       // Slave 基于此复制  
       server-id                      = 1                               // 服务器标识符  

       # 复制安全选项
       # log-bin                      = /var/lib/mysql/mysql-bin        // 命名二进制日志
       sync-binlog                    = 1                               // 每次提交事务前，将二进制日志同步到磁盘 (当作为主库时，需要)
       innodb-flush-log-at-trx-commit = 1                               // 5.0+ 默认配置，InnoDB 刷新每次的写缓冲
       innodb-support-xz-binlog       = 1                               // 5.0+ 默认配置

   Slave

       log-bin                        = mysql-bin                       // 当作为另一个 Slave 的 Master 时需要
       server-id                      = 2                               // 服务器标识符  
       relay-log                      = /var/lib/mysql/mysql-relay-bin  // 配置中继日志
       log-slave-updates              = 1                               // 允许备库将重放事件记录到自身的二进制日志
       read-only                      = 1                               // 只读，备库必需
   
       # 复制安全选项
       skip-slave-start               = 1                               // 当备库崩溃时，禁止自动重启动复制
       sync-master-info               = 1                               // 同步写入 master.info (性能开销)
       sync-relay-log                 = 1                               // 同步写入 relay log (性能开销)
       sync-relay-log-info            = 1                               // 同步写入 relay log info (性能开销)

3. Slave 连接到 Master，启动复制

       > change master to master_host = '192.168.0.1',
         master_user     = 'repl',
         master_password = '123456',
         master_log_file = 'mysql-bin.000001',
         master_log_pos  = 0;
       > start slave;
       > show slave status;

                Slave_IO_State: Wating for master to send event
                   Master_Host: 192.168.0.1
                   Master_User: repl
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000001
           Read_Master_Log_Pos: 164
                Relay_Log_File: mysql-relay-bin.000001
                 Relay_Log_Pos: 164
         Relay_Master_Log_File: mysql-bin.000001
              Slave_IO_Running: Yes                         // IO  线程
             Slave_SQL_Running: Yes                         // SQL 线程
                                ...omitted...
         Seconds_Behind_Master: 0

       > show processlist\g                                 // 显示线程列表

添加新的备库
-----------

拷贝数据的要求

* 某个时间点的主库的数据快照
* 主库当前的二进制日志文件、获得数据快照时在该文件的偏移量 (show master status)
* 从快照时间到现在的二进制日志

拷贝数据的方法

* 冷拷贝

      → 停止 Master
      → 拷贝数据到 Slave 
      → 重启 Master，使用一个新的二进制日志文件
      → 备库 change master to 文件起始处

* 热拷贝 (仅使用 MyISAM表 mysqlhotcopy)

* mysqldump 转储 (仅包含 InnoDB 表)

      $ mysqldump --single-transaction --all-databases 
                  --master-data=1      --host=192.168.0.1
                  | mysql --host=192.168.0.6

node-mysql cluster api
-----------------------

    var poolCluster = mysql.createPoolCluster();
    poolCluster.add(config); // anonymous group
    poolCluster.add('MASTER', masterConfig);
    poolCluster.add('SLAVE1', slave1Config);
    poolCluster.add('SLAVE2', slave2Config);

    poolCluster.remove('SLAVE2'); // By nodeId
    poolCluster.remove('SLAVE*'); // By target group : SLAVE1-2

    poolCluster.getConnection(function (err, connection) {});
    poolCluster.getConnection('MASTER', function (err, connection) {});
    poolCluster.getConnection('SLAVE*', 'ORDER', function (err, connection) {});
    poolCluster.of('*').getConnection(function (err, connection) {});

    poolCluster.on('remove', function (nodeId) {
        console.log('REMOVED NODE : ' + nodeId); // nodeId = SLAVE1 
    });
    poolCluster.end(function (err) {
        // all connections in the pool cluster have ended
    });

Article
--------

一主多备 (复制，读的负载均衡)
    
    +---+    +---+
    | M | -- | S |
    +---+    +---+
             +---+
          -- | S |
             +---+
             +---+
          -- | S | (一个更高版本，用于测试版本兼容)
             +---+
             
记录二进制日志 (同步 | 异步)
   
    Master

        → 事务到来
        → 记录二进制日志 (按照事务提交的顺序)
        → 存储引擎提交事务
        → 唤醒 IO 线程：向 Slave 发送信号通知：新的日志

    Slave

        → 唤醒 IO 线程：复制 Master 二进制日志 → 本地中继日志
        → 完成，挂起 IO 线程
        → SQL 线程：读取中继日志，更新数据  