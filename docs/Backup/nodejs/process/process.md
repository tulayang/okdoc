```
Global.process
```

Exit Code

```
    0                        // 正常退出
    1                        // 未捕获的致命异常(Uncaught Fatal Exception)
    2                        // 未使用(Unused)
    3                        // 解析错误(Internal JavaScript Parse Error)
    4                        // 评估失败(Internal JavaScript Evaluation Failure)
    5                        // 致命错误(Fatal Error) 
    6                        // 未正确的异常处理(Non-function Internal Exception Handler)
    7                        // 异常处理函数运行时失败(Internal Exception Handler Run-Time Failure) 
    8                        // 未使用(Unused)
    9                        // 无效的参数(Invalid Argument)
   10                        // 运行时失败(Internal JavaScript Run-Time Failure)
   12                        // 无效的调试参数(Invalid Debug Argument)
> 128                        // 信号退出(Signal Exits)
```

Global.process 

```
• 'exit'              ()                  // 进程即将退出时触发
• 'uncaughtException' ()                  // 进程捕获到一个冒泡的异常时触发
• SIGNAL              ()                  // 进程收到一个信号时触发

process.stdin                             // 进程的标准输入对象，可读流
process.stdout                            // 进程的标准输出对象，可写流
process.stderr                            // 进程的标准错误对象，可写流 

process.argv                              // 获取进程启动时的命令行数组
process.execArgv                          // 获取进程启动时的命令行的node特殊命令数组
process.execPath                          // 获取进程的可执行文件路径
process.version                           // 获取编译时存储版本信息
process.versions                          // 获取 node 依赖包版本信息
process.config                            // 获取编译当前 node 配置选项
process.arch                              // 获取 CPU 架构信息
process.platform                          // 获取运行的平台 

process.pid                               // 获取进程的标识符
process.title                             // 获取、设置进程的名字
process.cwd()                             // 获取进程的当前工作目录
process.chdir(directory)                  // 改变进程的当前工作目录，若操作失败则抛出异常
process.env                               // 获取、设置用户环境对象
process.exitCode                          // 进程正常退出，或者process.exit()退出时，
                                          // 获取退出的错误

process.getgid()                          // 获取进程的用户组标识符
process.setgid(id)                        // 设置进程的用户组标识符

process.getuid()                          // 获取进程的用户标识符
process.setuid(id)                        // 设置进程的用户标识符

process.getgroups()                       // 获取进程的用户组列表
process.setgroups(groups)                 // 设置进程的用户组列表
process.initgroups(user, extra_group)     // 读取 /etc/group 并且初始化 group 分组访问列表

process.umask([mask])                     // 获取、设置进程的文件创建掩码
process.uptime()                          // 获取进程已经运行的秒数
process.hrtime()                          // 获取当前的高分辨时间  

process.memoryUsage()                     // 获取进程的内存使用状态
                                          // { rss: 4935680,
                                          //   heapTotal: 1826816,  堆申请内存
                                          //   heapUsed: 650472 }   堆使用内存

process.kill(pid, [signal])               // 向进程发送一个信号
process.abort()                           // 退出进程，并且创建一个核心文件
process.exit([code])                      // 终止进程，并返回 code
process.nextTick(callback)                // 异步一个函数

```