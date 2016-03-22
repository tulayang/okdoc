```
//include <signal.h>
```

Typedef
----------

```
sig_atomic_t     // 整数类型，在信号处理程序中作为变量使用
```

Define
----------

```
SIG_DFL          // 默认的信号处理程序
SIG_ERR          // 信号错误
SIG_IGN          // 忽视信号

SIGABRT          // 程序异常终止
SIGFPE           // 算术运算出错，如除数为 0 或溢出
SIGILL           // 非法函数映象，如非法指令
SIGINT           // 中断信号，如 ctrl-C
SIGSEGV          // 非法访问存储器，如访问不存在的内存单元
SIGTERM          // 发送给本程序的终止请求信号
```

<span>

```
void (*signal(int sig, void (*func)(int)))(int)  // 设置一个函数来处理信号

     signal(SIGINT, handler);   
     while(1) {
         printf("开始休眠一秒钟...\n");
         sleep(1);
     }

     void handler(int signum) {
         printf("捕获信号 %d，跳出...\n", signum);
         exit(1);
     }

int raise(int sig)  // 促使生成信号 sig
```