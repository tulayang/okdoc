```
import cluster from 'cluster';
```
cluster (集群对象)
---------------------

```
• 'fork'       (worker)                  // 派生一个工作进程时触发
• 'online'     (worker)                  // 收到一个上线消息时触发
• 'listening'  (worker, address)         // 收到一个开始监听消息时触发
• 'disconnect' (worker)                  // 收到一个断开连接消息时触发
• 'exit'       (worker, code, signal)    // 收到一个退出消息时触发
• 'setup'      (worker)                  // 当 .setupMaster() 函数被执行时触发

cluster.schedulingPolicy                 // 获取、设置集群调度策略
                                         // SCHED_RR | SCHED_NONE 
cluster.settings                         // 获取配置
cluster.isMaster                         // 当前进程是主进程？
cluster.isWorker                         // 当前进程是工作进程？

cluster.setupMaster([settings])          // 更改缺省的 fork 行为

        • settings {
              exec   : String  // 工作进程文件的路径，default=__filename
              args   : Array   // 传给工作进程的字符串参数，default=process.argv.slice(2)
              silent : Boolean // 是否将输出发送到父进程的 stdio，default=false
          }

cluster.fork([env])                      // 派生一个工作进程，返回 Worker
cluster.disconnect([callback()])         // 所有的工作进程优雅地结束，所有的内部处理器都会被关闭
cluster.worker                           // 在工作进程窗口时，获取当前工作进程对象
cluster.workers                          // 在主进程窗口时，获取所有的工作进程对象哈希表，主键 id
```

cluster.Worker (工作进程)
-------------------------

```
• 'message'    (message, object)         // 通过.send()发送的信息时触发
• 'online'     ()                        // 工作进程上线时触发
• 'listening'  (address)                 // 工作进程开始监听时触发
• 'disconnect' ()                        // 工作进程断开连接时断开
• 'exit'       (code, signal)            // 工作进程退出时触发
• 'error'      (err)                     // 工作进程错误时触发 

worker.id                                // 获取工作进程的标识符
worker.process                           // 获取工作进程的进程对象

worker.isDead()                          // 工作进程宕掉？
worker.isConnected()                     // 工作进程正在连接？

worker.suicide                           // ？

worker.kill([signal='SIGTERM'])          // 向工作进程发送一个信号
worker.send(message, [object])           // 向工作进程发送消息数据

       • message : String // 消息类型
       • object  : Object // 关联对象

worker.disconnect()                      // 关闭工作进程与其他进程的 IPC 通信连接
```