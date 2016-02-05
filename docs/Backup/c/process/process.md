```
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
```

fork → exec → wait ↻
-------------------

```
pid_t fork(void)  ⇒ -1(errno) | 0(子进程) | pid(主进程)  // 拷贝一个新进程

/********************************** 使用文件接管子进程 **********************************/

int   execve(const char * filename, char const *argv, char const *envp)  ⇒  -1(errno) | ...
    
      • filename               // 文件路径
      • argv                   // 传递参数
      • envp                   // 传递环境变量

int   execl( const char *path, const char *arg, ...)
int   execlp(const char *file, const char *arg, ...)
int   execle(const char *path, const char *arg, ..., char * const envp[])
int   execv( const char *path, char *const argv[])
int   execvp(const char *file, char *const argv[])

/************************************************************************************/

pid_t getpid(void)                                   ⇒ 当前进程的标识符
pid_t getppid(void)                                  ⇒ 当前进程父进程的标识符

pid_t wait(int *status)                              ⇒ -1(errno) | pid  // 阻塞进程，直到有信号唤醒，如果调用时子进程已经结束，则立刻返回
pid_t waitpid(pid_t pid, int * status, int options)  ⇒ -1(errno) | pid  // 阻塞进程，直到有信号唤醒，如果调用时子进程已经结束，则立刻返回
```

