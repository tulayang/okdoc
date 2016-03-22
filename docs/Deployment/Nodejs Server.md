部署 Node.js 集群 (PM2)
------------------------

* 负载均衡
* 守护进程
* 自动重启动

安装

    $ npm install -g pm2@latest
    $ pm2 update

参数文件 home/username/.pm2

    home/username/.pm2
    home/username/.pm2/logs
    home/username/.pm2/pids
    home/username/.pm2/pm2.log
    home/username/.pm2/pm2.pid
    home/username/.pm2/rpc.sock
    home/username/.pm2/pub.sock
    home/username/.pm2/conf.js

命令行 

    $ pm2 list                              // 显示所有进程状态
    $ pm2 status                            // 显示所有进程状态
    $ pm2 logs [appname]                    // 显示日志

          --raw
          --lines 6
          --timestamp "HH:mm:ss"

    $ pm2 monit                             // 显示内存
    $ pm2 flush                             // 清除日志

    $ pm2 startup                           // 开机自启动，自动检测平台 (生成 init 脚本)
    $ pm2 startup [platform]                // 开机自启动，设置平台
      
      • platform: ubuntu | centos  | redhat | 
                  gentoo | systemd | darwin | amazon

    $ pm2 save                              // 保存开机自启动

    $ pm2 start app.js             
    $ pm2 start app.js                      // 启动服务
          --max-memory-restart 100M         // 最大内存 100M
          -i max                            // 有效 CPU 最大 
          --watch                           // 文件改动时重启动
    $ pm2 start   app.es                    // 启动服务 (ECMAScript 6 需要 .es 扩展名)
    $ pm2 restart appname | pid | all       // 重启进程
    $ pm2 delete  appname | pid | all       // 删除进程 
    $ pm2 stop    appname | pid | all       // 停止进程
    $ pm2 stop    --wathch 0                // 停止监测文件改动
    $ pm2 reload all                        // 0 秒停机重加载进程
    $ pm2 reloadLogs                        // 重加载所有日志

config.js
     
    {
        "name"               : "node-app",
        "cwd"                : "/srv/node-app/current",
        "args"               : ["--toto=heya coco", "-d", "1"],
        "script"             : "bin/app.js",
        "node_args"          : ["--harmony", " --max-stack-size=102400000"],
        "log_date_format"    : "YYYY-MM-DD HH:mm Z",
        "error_file"         : "/var/log/node-app/node-app.stderr.log",
        "out_file"           : "log/node-app.stdout.log",
        "pid_file"           : "pids/node-geo-api.pid",
        "instances"          : 6, //or 0 => 'max'
        "min_uptime"         : "200s", // 200 seconds, defaults to 1000
        "max_restarts"       : 10, // defaults to 15
        "max_memory_restart" : "1M", // 1 megabytes, e.g.: "2G", "10M", "100K", 1024 the default unit is byte.
        "cron_restart"       : "1 0 * * *",
        "watch"              : ["server", "client"],
        "ignore_watch"       : ["[\\/\\\\]\\./", "node_modules"],
        "merge_logs"         : true,
        "exec_interpreter"   : "node",
        "exec_mode"          : "fork",
        "autorestart"        : false, // enable/disable automatic restart when an app crashes or exits
        "vizion"             : false, // enable/disable vizion features (versioning control)
        "env"                : {
          "NODE_ENV"         : "production",
          "AWESOME_SERVICE_API_TOKEN": "xxx"
    }
