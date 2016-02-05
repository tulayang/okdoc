## 服务器管理 （server）
   
    $ service mysql start                               # 启动
    $ service mysql stop                                # 关闭
    $ mysqld_safe &                                     # 启动
    $ mysqld_safe -u username -p                        # 启动
                  [--port 8080] 
                  [--host localhost]    
    $ mysqladmin shutdown                               # 关闭

## 配置 （configuation）

1. 文件位置

   * etc/my.cnf
   * etc/mysql/my.cnf

2. 手动查找文件位置

       $ which mysqld
       /usr/sbin/mysqld

       $ /usr/sbin/mysqld --verbose --help | grep -A 1 'Default options'
       Default options are read from the following files in the given order:
       /etc/my.cnf /etc/mysql/my.cnf /usr/etc/my.cnf ~/.my.cnf 

3. 配置测试

       $ show global status                                # 观测配置后的状态变量
       $ mysqladmin extended-status -ri60                  # 每60秒查看状态变量的增量变化
   工具:

   * PerconaToolkit pt-mext                            # 状态变量计数器工具
   * PT-mysql-summary                                  # 状态变量计数器工具
   * innotop                                           # 内存观测工具

## 导入脚本 （script）

	$ source /home/king/test.sql
	$ \.     /home/king/test.sql

## 查询操作 （operate）

1. 创建数据库、表格、索引

       drop database if exists `box`;
       create database `box`;
       use `box`;

       set FOREIGN_KEY_CHECKS = 0;

       drop table if exists `users`;
       create table `users` (
         `userid`    int unsigned not null auto_increment primary key,
         `username`  varchar(20)  not null,
         `email`     varchar(100) not null,
         `password`  char(40)     not null,
         `sex`       char(1)      not null,
         `country`   varchar(20)  not null,
         `language`  varchar(20)  not null,
         `joindate`  datetime     not null,
         unique index (`username`),
         unique index (`email`)
       ) engine = InnoDB default charset = utf8;

       set FOREIGN_KEY_CHECKS = 1;

2. 创建索引

       primary key (id),
       constraint pk_RS primary key (id, name2), 
       foreign key (eid) references tb2(id), 
       constraint fk_RS foreign key (eid, name3) references tb2(id),
       unique (id), 
       constraint uq_RS unique (id, name1),
       check (td>0) 
       constraint ck_RS check (td>0 and tname='New York')

       create unique index it on users (userid, username);

3. CRUD

       insert into users set username = 'lili', sex = 'F', joindate = now();
       update      users set username = 'lina' where userid = 1;
       delete from users where userid = 1;

       set @name = 100;

       select @name := username from box where userid = 1;

4. 事务

       start transaction;
       begin
       savepoint name;
       commit;
       rollback;
       rollback to name

       SET AUTOCOMMIT = {0 | 1} 可以禁用或启用默认的autocommit模式，用于当前连接

5. 存储过程

        delimiter //
        create procedure procedureName (in param0 int, inout param1 int)
        begin

        declare m int(10) default 100;
        declare n int(10) default 100;
        declare a varchar(100) default 'foo' not null;
        declare b varchar(100) default 'foo' not null;

        set @a = 'bar';

        -- IF ELSE
        if param0 = 1 then
            select @a from tableA where tableA.id = param0;
        else 
            select * from tableA;
        end if

        -- CASE 
        case param1
        when 0 then
            insert into tableB set name = @a;
        when 1 then
            insert into tableB set name = @b;
        else
            insert into tableB set name = 'default';
        end case

        -- WHILE
        while @n > 0
            insert into tableC set pid = @n;
            set @n = @n - 1;
        end while

        -- LOOP
        loop_label : loop
            insert into tableD set pid = @m;
            set @m = @m - 1;
            if @m = 0 then
                leave loop;
            end if
        end loop

        end
        //
        delimiter ;

   :
   
       call   procedure procedureName
       drop   procedure procedureName
       alter  procedure procedureName
       select name from mysql.proc where db = 'tbname'
       show   procedure status where db='tbname'

6. 查看Sheme 

       describe users;

## 修改操作 (alter)

       alter table users add primary key (userid);
       alter table tbname add  constraint pk_RS primary key (id, name2);
       alter table tbname drop primary key pk_rs;
       alter table tbname add  foreign key (eid) references tb2(id);
       alter table tbname add  constraint fk_RS 
             foreign key (eid, name3) references tb2(id);
       alter table tbname drop foreign key fk_RS;
       alter table tbname add  unique (id);
       alter table tbname add  constraint uq_RS unique (id, name1);
       alter table tbname drop index uq_RS;
       alter table tbname add  check (td>0);
       alter table tbname add  constraint ck_RS 
             check (td>0 and tname='New York');
       alter table tbname drop check uq_RS;
       alter table tbname alter tname set default 'New York';
       alter table tbname alter tname drop default;
       alter table tbname add   tname  datatype;
       alter table tbname alter column tname int;
       alter table tbname drop  column tname;
       alter table tbname drop  index  indexname;

## 权限管理 （mysql.user）

1. 查看用户

       select 
           host, 
           user, 
           password
       from user;

2. 创建用户，

       insert into mysql.user 
       set
           host     = '127.0.0.1', 
           user     = 'mysql', 
           password = password('1234');

       host: 'localhost' '127.0.0.1' '%'(远程，任何终端) 

3. 删除用户

       delete from mysql.user 
       where  user = 'mysql' 
       and    host = '127.0.0.1';

3. 授予权限

       grant all privileges 
       on    tba.* 
       to    mysql@127.0.0.1 identified by '1234';

       grant select, update 
       on    tba.* 
       to    mysql@127.0.0.1 identified by '1234';

       grant select, delete, update, create, drop 
       on    *.* 
       to    mysql@% identified by '1234';

4. 查看权限

       show grants for mysql@127.0.0.1;

5. 刷新系统权限表

       flush privileges; 

6. 用户退出
 
       exit;
       quit;

## 表结构管理 （information_scheme）

    select * from INFORMATION_SCHEMA.TABLES

   `information_schema` 这张数据表保存了MySQL服务器所有数据库的信息。如数据库名，数据库的表，表栏的数据类型与访问权限等。再简单点，这台MySQL服务器上，到底有哪些数据库、各个数据库有哪些表，每张表的字段类型是什么，各个数据库要什么权限才能访问，等等信息都保存在 `information_schema `表里面。
 
   Mysql的 `INFORMATION_SCHEMA` 数据库包含了一些表和视图，提供了访问数据库元数据的方式。

   元数据是关于数据的数据，如数据库名或表名，列的数据类型，或访问权限等。有些时候用于表述该信息的其他术语包括“数据词典”和“系统目录”。

   * SCHEMATA表：提供了关于数据库的信息。
   * TABLES表：给出了关于数据库中的表的信息。
   * COLUMNS表：给出了表中的列信息。
   * STATISTICS表：给出了关于表索引的信息。
   * USER_PRIVILEGES表：给出了关于全程权限的信息。该信息源自mysql.user授权表。
   * SCHEMA_PRIVILEGES表：给出了关于方案（数据库）权限的信息。该信息来自mysql.db授权表。
   * TABLE_PRIVILEGES表：给出了关于表权限的信息。该信息源自mysql.tables_priv授权表。
   * COLUMN_PRIVILEGES表：给出了关于列权限的信息。该信息源自mysql.columns_priv授权表。
   * CHARACTER_SETS表：提供了关于可用字符集的信息。
   * COLLATIONS表：提供了关于各字符集的对照信息。
   * COLLATION_CHARACTER_SET_APPLICABILITY表：指明了可用于校对的字符集。
   * TABLE_CONSTRAINTS表：描述了存在约束的表。
   * KEY_COLUMN_USAGE表：描述了具有约束的键列。
   * ROUTINES表：提供关于存储子程序（存储程序和函数）的信息。ROUTINES表不包含自定义函数（UDF）。
   * VIEWS表：给出了关于数据库中的视图的信息。
   * TRIGGERS表：提供了关于触发程序的信息。


