
## 进程号码

### getpid() getppid()

```
#include <unistd.h>
pid_t getpid(void)     // 返回当前进程的＂进程号码＂
pid_t getppid(void)    // 返回当前进程的＂父进程号码＂
```

## 创建新进程

### fork()

```
#include <unistd.h>
pid_t fork(void);    // 创建新的进程，返回两次，有 3 种情况：
                     // 1. 返回值 ==  0 - 位于新进程中
                     // 2. 返回值 >   0 - 位于调用进程中，返回值是新进程的进程号码
                     // 3. 返回值 == -1 - 位于调用进程中，创建新进程失败：
                     //    ∘ 当前的进程数量超出＂系统限制＂
                     //    ∘ 当前的进程数量超出＂对此用户的限制＂
                     //    ∘ 内核内存不足
```

<span>

```
#include <stdio.h>
#include <stdlib.h>

#define MAX_COUNT 200

void doChild(void); 
void doParent(void);

void main(void) {
    pid_t pid = fork();

    switch (pid) {
    case -1:
        perror("Counld not fork");
        exit(1);
    case 0:
        doChild();
        exit(0);
    default:
        doParent();
    }
}

void doChild(void) {
    int i;
    for (i = 1; i <= MAX_COUNT; i++)
        printf("This line is from child, value = %d\n", i);
    printf("*** Child process is done ***\n");
}

void doParent(void) {
    int i;
    for (i = 1; i <= MAX_COUNT; i++)
        printf("This line is from parent, value = %d\n", i);
    printf("*** Parent is done ***\n");
}
```

![fork](http://i.stack.imgur.com/aMlk0.jpg)

### exec()

```
#include <unistd.h>
int execve(const char *pathname, char *const argv[], char *const env[]); 
int execle(const char *pathname, const *char arg, ..., /* (char *)NULL, char *const env[]*/); 
int execvp(const char *filename, char *const argv[]);                                     
int execlp(const char *filename, const *char arg, ..., /* (char *)NULL */);                  
int execv (const char *pathname, char *const argv[])                     
int execl (const char *pathname, const *char arg, ..., /* (char *)NULL */);                  

    // 成功不返回，失败返回 -1
    // pathname - 可执行文件的路径名，可以是绝对路径，也可以是相对进程当前工作目录的相对路径
    // argv     - 传入的命令行参数
    // env      - 新程序的环境列表
```

<span>

```
int flags = fcntl(STDOUT_FILENO, F_GETFD);
if (flags == -1)
    errExit("fcntl F_GETFD");
flags |= FD_CLOEXC;                              // close-on-exec
if (fcntl(STDOUT_FILENO, F_SETFD, flags) == -1)
    errExit("fcntl F_SETFD");
execlp("ls", "ls", "-l", argv[0], (char *)NULL);
errExit("execlp");
```

<span>

```
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>

#define MAX_COUNT 200

void doChild(char **argv); 
void doParent(void);

void main(int argc, char **argv) {
    pid_t pid = fork();

    switch (pid) {
    case -1:
        perror("Counld not fork");
        exit(1);
    case 0:
        doChild(argv);
        exit(0);
    default:
        doParent();
    }

    int status;
    pid = wait(&status);
    printf("*** Parent detects process %d is done ***\n", pid);
    printf("*** Parent exits ***\n");
    exit(0);
}

void doChild(char **argv) {
    execvp(argv[1], NULL);
    printf("*** Child process is done ***\n");
}

void doParent(void) {
    printf("*** Parent is done ***\n");
}
```

![exec](http://cdn-ak.f.st-hatena.com/images/fotolife/t/takahirox/20110320/20110320214903.png)

## 应答子进程

### signal() sigaction()

```
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>

#define MAX_COUNT 200

void catchChild(int sigNumber);
void doChild(void); 
void doParent(void);

void main(void) {
    signal(SIGCHLD, catchChild);
    pid_t pid = fork();

    switch (pid) {
    case -1:
        perror("Counld not fork");
        exit(1);
    case 0:
        doChild();
        exit(0);
    default:
        doParent();
    }

    sleep(1);
    printf("*** Parent exits ***\n");
    exit(0);
}

void catchChild(int sigNumber) {
    int childStatus;
    pid_t pid = wait(&childStatus);
    printf("*** Parent detects process %d is done ***\n", pid);
}

void doChild(void) {
    printf("*** Child process is done ***\n");
}

void doParent(void) {
    printf("*** Parent is done ***\n");
}
```

<span>

```
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>

#define MAX_COUNT 200

void catchChild(int sigNumber);
void doChild(void); 
void doParent(void);

void main(void) {
    struct sigaction action;
    struct sigaction oaction;
    action.sa_flags = 0;
    action.sa_handler = catchChild;
    sigaction(SIGCHLD, &action, &oaction);
    pid_t pid = fork();

    switch (pid) {
    case -1:
        perror("Counld not fork");
        exit(1);
    case 0:
        doChild();
        exit(0);
    default:
        doParent();
    }

    sleep(1);
    printf("*** Parent exits ***\n");
    exit(0);
}

void catchChild(int sigNumber) {
    int childStatus;
    pid_t pid = wait(&childStatus);
    printf("*** Parent detects process %d is done ***\n", pid);
}

void doChild(void) {
    printf("*** Child process is done ***\n");
}

void doParent(void) {
    printf("*** Parent is done ***\n");
}
```

### wait() waitpid() waitid()

```
#include <sys/wait.h>
pid_t wait(int *status);                             
      // 应答子进程的简单方法，成功返回＂进程号码＂，出错返回 0 | -1。当调用这个函数时，有以下可能：
      // 1.进程中没有子进程，立刻返回 `-1`，将 `errno` 置为 `ECHILD`
      // 2.进程中的子进程已经退出，并且是＂僵尸＂状态，立刻应答并返回，取得子进程状态（通过参数）
      // 3.进程中的子进程都在运行，立刻阻塞，直到有一个子进程退出或者收到一个 `SIGCHILD` 信号时返回，
      //   取得子进程状态（通过参数）

pid_t waitpid(pid_t pid, int *status, int options);  
      // 可以设置更动态的参数，成功返回＂进程号码＂，出错返回 0 | -1
      //
      // pid - 指定的进程号码，可能情况： 
      // 1.pid >   0 - 等待＂进程号码 = pid＂的子进程
      // 2.pid ==  0 - 等待同一个进程组的任意子进程
      // 3.pid <  -1 - 等待＂进程组号码 = |pid|＂的任意子进程
      // 4.pid == -1 - 等待任意子进程
      //
      // options - 可以包含 0 个或多个标志：
      // ⋅ WUNTRACED  - 除了返回终止子进程信息外，还返回因信号而停止的子进程信息
      // ⋅ WCONTINUED - 返回因收到 SIGCONT 信号而恢复执行的已停止子进程的状态信息
      // ⋅ WNOHANG    - 如果指定的子进程未发生状态改变，立刻返回 0，而不是阻塞（非阻塞）

struct siginfo_t {
    si_code;   // CLD_EXITED    - 子进程通过 _exit() 终止
               // CLD_KILLED    - 子进程因为信号强制退出
               // CLD_STOPPED   - 子进程因为信号停止
               // CLD_CONTINUED - 子进程因为信号恢复
    si_pid;    // 进程号码
    si_signo;  // 信号号码，总是 SIGCHLD
    si_status; // 退出状态
    si_uid;    // 实际用户号码
};
int   waitid(idtyoe_t idtype, id_t id, siginfo_t *infop, int options); 
      // idtype - 行为标志位
      // ⋅ P_PID      - 等待“进程号码 = id”的子进程
      // ⋅ P_GID      - 等待“进程组号码 = id”的任意子进程
      // ⋅ P_ALL      - 等待任意子进程（忽略 id）
      //
      // infop - 返回内核填写的信息
      // 
      // options - 配置标志位
      // ⋅ WEXITED    - 调用进程会等待结束的子进程
      // ⋅ WSTOPPED   - 调用进程会等待因收到信号而停止的子进程
      // ⋅ WCONTINUED - 调用进程会等待因收到信号而恢复的子进程
      // ⋅ WNOHANG    - 调用进程不会阻塞，如果子进程没有结束、停止或者继续执行，立刻返回 
      // ⋅ WNOWAIT    - 调用进程不会删除响应子进程的僵尸状态，在将来可能会继续等待处理
``` 

<span>

```
for (;;) {
    if ((child = wait(NULL)) == -1) {
        if (errno == ECHILD) {
            printf("No more children.\n");
            exit(EXIT_SUCCESS);
        } else {
            errExit("wait");
        }
    }
    num++;
    // do something
}
```

<span>

```
siginfo_t info;
// ...
memset(&info, 0, sozeof(siginfo_t));
if (waitid(idtype, id, &info, options | WNOHANG) == -1) 
    errExit("waitid");
if (info.si_pid == 0)
    printf("No children changed state");
else
    printf("A child changed");
```

对于返回的状态值 `status`，定义了一组宏用于分析：

```
int WIFEXITED(status);       // 如果子进程正常结束，返回真
int WIFSIGNALED(status);     // 如果子进程因收到信号而强制结束，返回真
int WIFSTOPPED(status);      // 如果子进程因收到信号而结束，返回真
int WIFCONTINUED(status);    // 如果子进程因收到 SIGCONT 信号而恢复执行，返回真
```

## 终止进程

### exit() _exit() _Exit()

```
#include <stdlib.h>
void exit(int status);
     // 终止进程，同时执行一些基本的关闭步骤，然后调用 _exit() 通知内核终止这个进程。关闭步骤有：
     // 1. 调用 atexit() 或者 on_exit() 注册的函数
     // 2. 清空所有已打开的标准 IO 流
     // 3. 删除由 tmpfile() 创建的所有临时文件

void _Exit(int status);

#include <unistd.h>
void _exit(int status);
     // 终止进程，同时清理进程所创建的所有资源，包括但不限于：分配的内存，打开的文件记录，System V 信号量
     // status:
     // ⋅ EXIT_SUCCESS - 成功
     // ⋅ EXIT_FAILURE - 失败

```

### atexit()

```
#include <stdlib.h>
int atexit(void (*func)(void));  // 注册退出处理程序
                                 // 按照 ISO C 规定，一个进程可以登记至多 32 个函数，这些函数
                                 // 由 exit 自动调用。调用的顺序，和登记的顺序正好相反。同一
                                 // 函数如登记多次，也会被调用多次。
```

## 环境变量

### getenv() putenv() setenv() unsetenv()

```
#include <stdlib.h>
char *getenv(const char *name)   
      // 返回环境值，没有返回 NULL。
int   putenv(char *string)       
      // 修改环境值，string: "name=value"。成功返回 0，失败返回 -1。
int   setenv(const char *name, const char *value, int overwrite)
      // 修改环境值。成功返回 0，失败返回 -1。
int   unsetenv(const char *name)
      // 删除环境值。成功返回 0，失败返回 -1。
```

### setjmp() longjmp()

```
#include <setjmp.h>
int  setjmp (jmp_buf env)           // 初始化调用时返回 0，通过 longjmp 调用时返回非 0
void longjmp(jmp_buf env, int val)
```

<span>

```
#include <setjmp.h>
#include <stdio.h>

static jmp_buf env;
static void f1(int argc);
static void f2(void);

int main(int argc, char *argv[]) {
    switch (setjmp(env)) {  
    case 0:
        printf("Calling f1() after initial setjmp()\n");
        f1(argc);  // 永远不返回
        break;
    case 1:
        printf("Jumped back from f1()\n");
        break;
    case 2:
        printf("Jumped back from f2()\n");
        break;
    }
}

void f1(int argc) {
    if (argc == 1)
        longjmp(env, 1);
    f2();
}

void f2(void) {
    longjmp(env, 2);
}
```

## 进程组和会话

### getpgrp() getpgid() setpgid()

```
#include <unistd.h>

pid_t getpgrp(void);                 // 返回当前进程的＂进程组号码＂
pid_t getpgid(pid_t pid);            // 返回特定进程的＂进程组号码＂，出错返回 -1
                                     // 如果 pid 是 0，返回当前进程的＂进程组号码＂，
                                     // getpgid(0) -- getpgrp()

int setpgid(pid_t pid, pid_t pgid);  // 设置特定进程的＂进程组号码＂，成功返回 ０，出错返回 -1
                                     // 如果 pid  == 0    - 设置当前进程的＂进程组号码＂
                                     // 如果 pid  == pgid - 特定进程变成＂进程组首进程＂
                                     // 如果 pgid == 0    - 特定进程变成＂进程组首进程＂
                                     //
                                     // 1. pid 进程必须是调用进程或者其子进程（没有调用过 exec()）
                                     // 2. pid 进程不能是＂会话首进程＂
                                     // 3. 如果 pgid 已经存在，必须与调用进程在同一个会话
                                     // 4. pgid 必须 >= 0
                                     //
                                     // 大多数作业控制 shell 中，是在 fork() 后调用这个函数，在
                                     // 父进程中设置子进程的＂进程组号码＂，同时在子进程设置自己的
                                     // ＂进程组号码＂。这两个调用有一个是冗余的，如果不这么做，
                                     // `fork()` 后，父进程子进程运行的先后次序不确定，
                                     // 容易发生组成员身份的条件竞争。  
```

### getsid() setsid()

```
#include <unistd.h>
pid_t getsid(pid_t pid);  // 返回特定进程的＂会话首进程号码＂，出错返回 -1
                          // 如果 pid == 0，返回当前进程的＂会话首进程号码＂
pid_t setsid(void);       // 使当前进程创建一个新会话，并成为＂会话首进程＂，同时创建一个进程组，
                          // 成为＂进程组首进程＂。成功返回＂会话首进程号码＂，出错返回 -1
                          //
                          // 如果当前进程不是＂进程组首进程＂：
                          // 1.当前进程变成新会话的＂会话首进程＂，此时该进程是新会话中的唯一进程
                          // 2.当前进程成为新进程组的＂进程组首进程＂，新＂进程组号码＂是当前进程
                          //   的＂进程号码＂
                          // 3.当前进程没有控制终端
                          //
                          // 如果当前进程是＂进程组首进程＂，会出错。为了保证不出现这种情况，通常
                          // 采用：调用 `fork()`，然后终止父进程，子进程继续。因为子进程继承了父进程
                          // 的＂进程组号码＂，但是＂进程号码＂则是新分配的，两者不可能相等，保证了
                          // 子进程不是已有进程组的首进程。

```

<span>

```
pid_t pid = fork();
if (pid == -1) 
    errExit("fork");
if (pid > 0)
    exit(EXIT_SUCCESS);
if (setsid() == -1)       // 子进程 
    errExit("setsid");
```

## 守护进程

### daemon()

```
#include <unistd.h>
int daemon(int nochdir, int noclose);  // 创建守护进程，成功返回 0，出错返回 -1
                                       // 如果 nochdir != 0，不更改工作目录，通常设为 0
                                       // 如果 noclose != 0，不关闭所有打开的＂文件描述符号码＂
                                       // ，通常设为 0
```

## 用户和组

### getuid() getgid() geteuid() getegid()

```
#include <unistd.h>
uid_t getuid(void);       // 返回当前进程的＂实际用户号码＂
uid_t getgid(void);       // 返回当前进程的＂实际组号码＂
uid_t geteuid(void);      // 返回当前进程的＂有效用户号码＂
uid_t getegid(void);      // 返回当前进程的＂有效组号码＂
```

### setuid() setgid()

```
#include <unistd.h>
int setuid(uid_t uid);  
int setgid(gid_t gid);  
    // 成功返回 0，出错返回 -1
    // 1.非特权进程调用时，只能修改进程的＂有效号码＂，并且只能将＂有效号码＂修改为＂实际号码＂
    //   或者＂保留号码＂的值。否则，将触发 `EPERM` 错误
    // 2.特权进程调用时，会将＂实际号码＂、＂有效号码＂和＂保留号码＂同时修改为 uid。这个操作
    //   是单向的，一旦以此方式修改，所有特权将丢失
```

<span>

```
if (setuid(getuid()) == -1)    // => ＂实际用户号码＂，将会放弃特权
    errExit("setuid");
```

### seteuid() setegid()

```
#include <unistd.h>
int seteuid(uid_t uid);  
int setegid(gid_t gid); 
    // 成功返回 0，出错返回 -1
    // 1.非特权进程调用时，只能修改进程的＂有效号码＂，并且只能将＂有效号码＂修改为＂实际号码＂
    //   或者＂保留号码＂的值。
    // 2.特权进程调用时，只能修改进程的＂有效号码＂为任意值。如果 uid > 0，那么修改后此进程
    //   将不再有特权，但可以根据规则 1 来恢复特权（＂保留号码＂仍然保存着原有的＂有效号码＂）
```

<span>

```
euid = geteuid();             // 保存＂有效用户号码＂
if (seteuid(getuid()) == -1)  // 修改＂有效用户号码＂为＂实际用户号码＂
    errExit("seteuid");
if (seteuid(euid) == -1)      // 恢复＂有效用户号码＂（规则允许）
    errExit("seteuid");
```

### setreuid() setregid()

```
#include <unistd.h>
int setreuid(uid_t ruid, uid_t euid); 
int setregid(gid_t rgid, gid_t egid);  
    // 成功返回 0，失败返回 -1
    // 1.非特权进程调用时，只能修改＂实际号码＂和＂有效号码＂，并且只能将＂实际号码＂修改为＂实际号码＂
    //   或者＂有效号码＂的值，只能将＂有效号码＂修改为＂实际号码＂、＂有效号码＂或者＂保留号码＂
    // 2.特权进程调用时，只能修改＂实际号码＂和＂有效号码＂为任意值
    // 3.不管进程是否拥有特权，满足下列条件之一，就能修改＂保留号码＂为（新的）＂有效号码＂：
    //   ∘ ruid != -1
    //   ∘ euid != 系统调用之前的＂实际号码＂
```

### getgroups() setgroups() initgroups()

```
#include <unistd.h>
int getgroups(int gidsetsize, gid_t grouplist[]);  
    // 获取＂附属组号码＂。将进程所属用户的各＂附属组号码＂，填写到 grouplist，填写的
    // 最大个数是 gidsetsize。如果 gidsetsize 为 0，只返回个数，不填充 grouplist 。
    // 成功返回填写＂附属组号码＂的个数，出错返回 -1

#include <grp.h>  // on Linux
#include <unistd.h>  // on FreeBSD，Mac OS X，Solaris
int setgroups(size_t gidsetsize, const gid_t *grouplist);  
    // 超级用户调用，修改＂附属组号码＂。成功返回 0，出错返回 -1。gidsetsize <= NGROUPS_MAX

#include <grp.h>  // on Linux，Solaris
#include <unistd.h>  // on FreeBSD，Mac OS X
int initgroups(const char *username, gid_t basegid);  
    // 超级用户调用。成功返回 0，出错返回 -1
```

### getlogin()

```
#include <unistd.h>
char *getlogin(void);     // 返回当前进程的＂用户登录名＂，出错返回 NULL
```

## 口令文件

### getpwuid() getpwnam() getpwent() setpwend() endpwend()


```
#include <pwd.h>

struct passwd *getpwuid(uid_t uid);         // 返回口令文件的一条记录。成功返回记录，出错返回 NULL
struct passwd *getpwnam(const char *name);  // 返回口令文件的一条记录。成功返回记录，出错返回 NULL

struct passwd *getpwent(void);              // 打开口令文件，逐行扫描。成功返回记录，出错返回 NULL
void setpwend(void);                        // 重返口令文件起始处
void endpwent(void);                        // 关闭口令文件
                                            //
                                            // 基本 POSIX.1 没有定义这些函数，但是可预期所有 UNIX 
                                            // 实现都提供这些函数。当调用 getpwent() 时，自动
                                            // 打开 /etc/passwd，逐条返回记录，当不再有记录或者
                                            // 出错时，返回 NULL。可以调用 endpwent() 将文件
                                            // 关闭。对 /etc/passwd 扫描到中途时，可以调用 
                                            // setpwend() 重返文件起始处
                                            //
                                            // struct passwd 是函数内部的静态变量，每次调用都会
                                            // 被重写。因此，getpwuid() getpwnam() getpwent() 
                                            // 是不可重入的
 
```

<span>

```
struct passwd *pwd;
while ((pwd = getpwent()) != NULL)
    printf("%-8s %5ld\n", pwd->pw_name, (long)pwd->pw_uid);
endpwend();
```

## 阴影口令文件

### getspnam() getspent() setspent() endspent()

```
#include <shadow.h>
struct spwd *getspnam(const char *name);  // 返回阴影口令文件的一条记录。成功返回记录，出错返回 NULL
struct spwd *getspent(void);              // 打开阴影口令文件，逐行扫描。成功返回记录，出错返回 NULL
void setspent(void);                      // 重返阴影口令文件起始处
void endspent(void);                      // 关闭阴影口令文件
```

### crypt()

```
#define _XOPEN_SOURCE
#include <unistd.h>
char *crypt(const char *key, const char *salt);
      // 加密口令，采用单向加密算法。接受一个最长 8 字符的密钥，使用加密算法（DES）的一种变体。
      // salt 指向一个 2 字符的字符串，扰动（改变） DES 算法，使密码难以破解。如果成功，返回
      // 一个 13 字符的静态分配的字符串，即为加密密码。失败返回 NULL 。在 Linux 中使用 crypt()
      // ，编译中加入 -lcrypt 选项
```

## 组文件和组阴影口令文件

### getgrgid() getgrnam() getgrent() setgrend() endgrent()

```
#include <grp.h>

struct group *getgrgid(gid_t gid);         // 返回组文件的一条记录。成功返回记录，出错返回 NULL
struct group *getgrnam(const char *name);  // 返回组文件的一条记录。成功返回记录，出错返回 NULL

struct passwd *getgrent(void);             // 打开组文件，逐行扫描。成功返回记录，出错返回 NULL
void setgrend(void);                       // 重返组文件起始处
void endgrent(void);                       // 关闭组文件
```
