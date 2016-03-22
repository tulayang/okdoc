```
[mysqld]

# GENERAL
datadir                         = C:/ProgramData/MySQL/MySQL Server 5.6/Data
pid_file                        = C:/ProgramData/MySQL/MySQL Server 5.6/Data/mysql.pid
user                            = mysql
password                        = 1234
port                            = 3306
default_storage_engine          = InnoDB
character-set-server            = utf8

# INNODB
innodb_buffer_pool_size         = 6G        # 75% ~ 80%
innodb_log_file_size            = 512M
innodb_log_buffer_size          = 8M
innodb_flush_log_at_trx_commit  = 1
innodb_file_per_table           = 1
innodb_flush_method             = O_DIRECT


# MYISAM
key_buffer_size                 = 128M
myisam_max_sort_file_size       = 32G
myisam_sort_buffer_size         = 128M

# LOGGING
log-output                      = FILE
log_error                       = C:/ProgramData/MySQL/MySQL Server 5.6/Data/mysql-error.log
slow_query_log                  = 1
slow_query_log_file             = C:/ProgramData/MySQL/MySQL Server 5.6/Data/mysql-slow.log
general-log                     = 0
general_log_file                = C:/ProgramData/MySQL/MySQL Server 5.6/Data/mysql-general.log
long_query_time                 = 10

# OTHER
tmp_table_size                  = 32M
max_heap_table_size             = 32M
query_cache_type                = 0
query_cache_size                = 0
max_connections                 = 500
thread_cache_size               = 100    # 可缓存线程数
table_open_cache                = 5000   # 可缓存描述符数
open_files_limit                = 65535  
max_allowed_packet              = 4M
skip_name_resolve                        # 禁用DNS反向解析
sql_mode                        = NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES 

query_cache_type                = 0
query_cache_size                = 32M 
read_buffer_size                = 64K
read_rnd_buffer_size            = 256K
sort_buffer_size                = 256K
join_buffer_size                = 256K
max_connect_errors              = 100
binlog_row_event_max_size       = 8K
sync_master_info                = 10000
sync_relay_log                  = 10000
sync_relay_log_info             = 10000
group_concat_max_len            = 99999999999999999
server-id                       = 1

### socket                      = ?


[client]

port                            = 3306

[mysql]

default-character-set           = utf8

```

