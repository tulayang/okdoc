Http_load
----------

	$ wget http://acme.com/software/http_load/http_load-14aug2014.tar.gz
    
    $ http_load -f 100000 -p 1000 -r 1000 url.md
    
      • -fetches  -f  ## 总访问次数
      • -parallel -p  ## 并发的用户进程数
      • -rate     -r  ## 每秒的访问频率
      • -seconds  -s  ## 总访问时间

      ## 100000 fetches, 1000 max parallel, 1.2e+06 bytes, in 6.89317 seconds
      ## 12 mean bytes/connection
      ## 14507.1 fetches/sec, 174085 bytes/sec
      ## msecs/connect: 20.6755 mean, 3005.52 max, 0.02 min
      ## msecs/first-response: 27.6761 mean, 258.712 max, 0.216 min
      ## HTTP response codes:
      ##   code 200 -- 100000


Siege (测试工具)
-------------

     $ siege -c 1000 -r 100 http://127.0.0.1:8000
     $ siege -c 1000 -t 100 http://127.0.0.1:8000

       • c                                           // 连接数
       • r                                           // 每个连接重复次数
       • t                                           // 总计时间（s） 


Test Result (测试结果)
-------------------

1. Nodejs Cluster

       Transactions:               100000 hits       // 完成传输次数
       Availability:               100.00 %          // 传输成功率
       Elapsed time:               128.13 secs       // 总共使用时间
       Data transferred:           106.91 MB         // 共传输数据
       Response time:                0.64 secs       // 平均响应时间
       Transaction rate:           780.46 trans/sec  // 平均每秒完成传输次数
       Throughput:                   0.83 MB/sec     // 平均每秒传输数据
       Concurrency:                498.16            // 实际最高并发连接数
       Successful transactions:    100000            // 成功传输次数
       Failed transactions:             0            // 失败传输次数
       Longest transaction:          2.53            // 每次传输所花最长时间
       Shortest transaction:         0.00            // 每次传输所花最短时间 

2. Nginx Cluster （无压缩、无连接转发绑定）

       Transactions:               100000 hits       // 完成传输次数
       Availability:               100.00 %          // 传输成功率
       Elapsed time:               140.18 secs       // 总共使用时间
       Data transferred:           106.91 MB         // 共传输数据
       Response time:                0.04 secs       // 平均响应时间
       Transaction rate:           713.37 trans/sec  // 平均每秒完成传输次数
       Throughput:                   0.76 MB/sec     // 平均每秒传输数据
       Concurrency:                 26.01            // 实际最高并发连接数
       Successful transactions:    100000            // 成功传输次数
       Failed transactions:             0            // 失败传输次数
       Longest transaction:          2.62            // 每次传输所花最长时间
       Shortest transaction:         0.00            // 每次传输所花最短时间 

Nodejs Cluster (测试代码)
----------------------

1. cluster.js

       var Cluster = require('cluster'),
           Os = require('os');

       if (Cluster.isMaster) {
           for (var i = 0; i < Os.cpus().length; i++) {
               Cluster.fork();
           }
           Cluster.on('exit', function(worker, code, signal) {
               console.log('Worker ' + worker.process.pid + ' offline.');
           });
       } else {
           require('./server');
       }

2. server.js

       var Http = require('http'),
           Mysql = require('mysql'),
           mcli = Mysql.createPool({
               "host"               : "127.0.0.1",
               "port"               : 8080,
               "user"               : "root",
               "password"           : "",
               "database"           : "box",
               "connectionLimit"    : 10,
               "multipleStatements" : true
           }),
           query = [
               'select',
               '    t.task_id,',
               '    t.pubdate,',
               '    t.keyword,',
               '    t.views,',
               '    t.finished,',
               '    t.locked,',
               '    l.lockdate',
               'from       tasks       as t',
               'left  join locked_tasks as l on t.task_id = l.task_id',
               'where t.pubber_name = \'lili\'',
           ].join('\n');

       Http.createServer(function(req, res) {
           mcli.query(query, function (err, replies) {
               console.log('----------------------------- Request %d.', process.pid);
               res.writeHead(200, {'content-type':'application/json'});
               res.end(JSON.stringify(replies));
           });
       }).listen(8000, function () {
           console.log('Server %d online.', process.pid);
       });
