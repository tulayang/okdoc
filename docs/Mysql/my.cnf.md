```
[mysqld_safe]

nice                            = 0

[mysqld]

# GENERAL
datadir                         = /var/lib/mysql
tmpdir                          = /tmp
lc-messages-dir                 = /usr/share/mysql
socket                          = /var/run/mysqld/mysqld.sock
pid_file                        = /var/run/mysqld/mysqld.pid
user                            = root
#password                       = 1234
port                            = 3306
default_storage_engine          = InnoDB
character-set-server            = utf8
bind-address                    = 127.0.0.1
skip-external-locking

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
log_output                      = FILE
log_error                       = /var/log/mysql/mysql-error.log
slow_query_log                  = 1
slow_query_log_file             = /var/log/mysql/mysql-slow.log
general-log                     = 0
general_log_file                = /var/log/mysql/mysql-general.log
long_query_time                 = 2
log_bin                         = /var/log/mysql/mysql-bin.log
expire_logs_days                = 10
max_binlog_size                 = 100M
binlog_do_db                    = include_database_name
binlog_ignore_db                = include_database_name

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

[client]

port                            = 8080
socket                          = /var/run/mysqld/mysqld.sock

[mysql]

default-character-set           = utf8

[mysqldump]
quick
quote-names
max_allowed_packet              = 16M

[isamchk]
key_buffer                      = 16M
```