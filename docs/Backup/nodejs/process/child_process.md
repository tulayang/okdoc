```
import Child from 'child_process';
```
<span>

```
Child.spawn(command, [args], [options])        // 使用给定的命令发布一个子进程，返回 ChildProcess
      
      • command : String // 命令
      • args    : Array  // 命令参数
      • options {
            cwd       : String         // 子进程的当前的工作目录
            stdio     : Array | String // 子进程 stdio 配置
            customFds : Array          // 子进程 stdio 使用的文件描述符
            env       : Object         // 环境变量的键值对
            detached  : Boolean        // 子进程将会变成一个进程组的领导者
            uid       : Number         // 用户进程标识符
            gid       : Number         // 用户组标识符
        }  

Child.exec(command, [options], 
           callback(err, stdout, stderr))      // 使用给定的命令发布一个子进程，返回 ChildProcess

      • command : String // 命令
      • args    : Array  // 命令参数
      • options {
            cwd        : String         // 子进程的当前的工作目录
            env        : Object         // 环境变量的键值对
            encoding   : String         // 编码，default='utf8'
            shell      : String         // shell，default='/bin/sh'
            timeout    : Number         // 超时时间，default=0
            maxBuffer  : Number         // 最大缓冲，default=200*1024
            killSignal : String         // 结束信号，default='SIGTERM'
        }

      • stdout : Buffer
      • stderr : Buffer

Child.execFile(filename, args, options, 
               callback(err, stdout, stderr))  // 使用给定的文件发布一个子进程，返回 ChildProcess
      
      • filename : String // 文件路径
      • args     : Array  // 命令参数
      • options {
            cwd        : String         // 子进程的当前的工作目录
            env        : Object         // 环境变量的键值对
            encoding   : String         // 编码，default='utf8'
            timeout    : Number         // 超时时间，default=0
            maxBuffer  : Number         // 最大缓冲，default=200*1024
            killSignal : String         // 结束信号，default='SIGTERM'
        }

      • stdout : Buffer
      • stderr : Buffer

Child.fork(filename, [args], [options])        // 使用给定的文件派生一个子进程，返回 ChildProcess

      • filename : String // 文件路径
      • args     : Array  // 命令参数
      • options {
            cwd        : String         // 子进程的当前的工作目录
            env        : Object         // 环境变量的键值对
            encoding   : String         // 编码，default='utf8'
            execPath   : String         // 创建子进程的可执行文件路径
        }
```

ChildProcess.ChildProcess (子进程)
------------------------------------

```
• 'error'      (error)                   // 子进程错误时触发
• 'exit'       (code, signal)            // 子进程退出时触发
• 'close'      (code, signal)            // 子进程的所有 stdio 流被终止时触发
• 'disconnect' ()                        // 子进程或父进程断开连接时断开
• 'message'    (message, object)         // 通过.send()发送的信息时触发

child.stdin                              // 子进程的标准输入对象，可读流
child.stdout                             // 子进程的标准输出对象，可写流
child.stderr                             // 子进程的标准错误对象，可写流 

child.pid                                // 获取子进程的标识符

child.kill([signal])                     // 向子进程发送一个信号
child.send(message, [object])            // 向子进程发送消息数据

      • message : String // 消息类型
      • object  : Object // 关联对象

child.disconnect()                       // 关闭父进程与子进程的 IPC 通信连接，
                                         // 让子进程非常优雅的退出，
                                         // 'disconnect' 事件同时在父进程和子进程内触发
```