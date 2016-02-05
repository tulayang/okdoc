# [进程结束](https://www.gnu.org/software/libc/manual/html_node/Process-Completion.html#Process-Completion)

一旦创建了一个新进程，其就成为调用进程的子进程。当一个进程正常或者异常结束时，内核就向其父进程发送 `SIGCHLD` 信号。子进程结束是一个异步事件，可以在父进程运行的任何时候发生，所以这种信号由内核向父进程发送异步通知。父进程可以选择忽略该信号，也可以提供一个信号处理函数。

有两种可能存在的情况：父进程先于子进程退出，子进程先于父进程退出。

* 当子进程退出时，并不立刻清空进程表，而是向父进程发送一个信号 `SIGCHLD`。父进程需要对此应答，然后系统会完全清除子进程。假设父进程没有应答，或者应答之前子进程退出，子进程会被系统设置为＂僵尸＂状态，释放子进程的大部分资源，在＂内核进程表＂中保留子进程的状态记录，包括子进程号码，终止状态，资源使用数据等信息。如果＂僵尸进程＂过多，会导致＂内核进程表＂塞满，无法创建新的进程。

* 当一个父进程退出时，如果有几个子进程仍在运行，这些子进程会变成＂孤儿进程＂。＂孤儿进程＂会立刻被 **init** 进程接管，作为其父进程。**init** 进程能够确保这些子进程在退出时不会变为＂僵尸进程＂，因为 **init** 进程总是应答子进程的退出。

###: #include &lt;sys/wait.h&gt; 

```c
#include <sys/wait.h>
```

###: WAIT_ANY

```
int WAIT_ANY
```

* Macro

`WAIT_ANY` 值是 `-1`，指定 `waitpid()` 应该返回任何子进程的状态信息。

###: WAIT_MYPGRP

```
int WAIT_MYPGRP
```

* Macro

`WAIT_MYPGRP` 值是 `0`，指定 `waitpid()` 应该返回调用进程的进程组中任何子进程的状态信息。

###: WNOHANG

```
int WNOHANG
```

* Macro

`WNOHANG` 指定 `waitpid()` 非阻塞，如果没有子进程状态信息可用，立刻返回。

###: WUNTRACED

```
int WUNTRACED
```

* Macro

`WUNTRACED` specifies that `waitpid()` should report the status of any child processes that have been stopped as well as those that have terminated

###: waitpid()

```c
pid_t waitpid(pid_t pid, int *status-ptr, int options);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`waitpid()` 函数用来请求一个子进程 `pid` 的状态信息，存储到 `*status-ptr` --- 如果是一个空指针则不存储。通常，调用进程会阻塞，直到子进程终止并返回状态信息。

指定 `pid` 为其他值有特殊意义。`-1` 或 `WAIT_ANY` 请求任何子进程的状态信息；`0` 或 `WAIT_MYPGRP` 请求调用进程的进程组中任何子进程的状态信息；其他负值请求进程组号是其绝对值的任何子进程的状态信息。

如果有子进程的状态信息立刻可用，那么函数会立刻返回。如果多余一个子进程的状态信息可用，那么随机选中其中一个，并立刻返回。要获取其他子进程的状态信息，你必须再次调用 `waitpid()`。

`options` 是一个位掩码，它的值应该是 `WNOHANG`、`WUNTRACED` 的按位或。你可以使用 `WNOHANG` 指定父进程不阻塞；使用 `WUNTRACED` to request status information from stopped processes as well as processes that have terminated。

返回值通常是被报告的子进程的进程号。当指定 `WNOHANG` 非阻塞，并且没有子进程可以报告时，返回 `0`。

如果 `pid` 是一个子进程号，那么忽略其他子进程，只请求 `pid` 的状态信息---一直阻塞等待该子进程。因此，在这种情况下，如果同时指定 `WNOHANG` 而该子进程不能立刻报告，那么立刻返回 `0`。

执行失败返回 `-1` 并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EINTR` 操作被一个信号中断。

* `ECHILD` 没有子进程可以等待，或者指定的 `pid` 不是调用进程的子进程。

* `EINVAL` 指定的 `options` 是无效值。

> 对于多线程程序，`waitpid()` 函数是一个“取消点”。如果线程在 `waitpid()` 被调用时，分配了一些资源（比如内存、文件描述符、信号或者其它），有可能会产生问题。如果该线程被取消了，这些资源仍然会继续存在，直到程序结束。要避免这种情况，应该通过取消处理器保护 `waitpid()` 调用。

###: wait()

```c
pid_t wait(int *status-ptr);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`wait()` 函数是一个简化版本的 `waitpid()` 函数，用来请求任何子进程的状态信息。

```c
wait(&status);
```

等价于

```c
waitpid(-1, &status, 0);
```

> 对于多线程程序，`wait()` 函数是一个“取消点”。如果线程在 `wait()` 被调用时，分配了一些资源（比如内存、文件描述符、信号或者其它），有可能会产生问题。如果该线程被取消了，这些资源仍然会继续存在，直到程序结束。要避免这种情况，应该通过取消处理器保护 `wait()` 调用。

###: wait4()

```c
pid_t wait4(pid_t pid, int *status-ptr, int options, struct rusage *usage);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

如果 `usage` 是一个空指针，`wait4()` 函数等价于 `waitpid (pid, status-ptr, options)`。

如果 `usage` 不是空指针，`wait4()` 把子进程使用的资源存储到 `*usage`。

> `wait4()` 函数是一个 BSD 扩展。

### 例子 

这儿有个例子，演示了如何使用 `waitpid()` 获取所有子进程终止的状态信息，非阻塞模式。这个函数是为 `SIGCHLD` 信号设计的信号处理器，表示至少一个子进程终止：

```c
void sigchld_handler(int signum) {
    int pid, status, serrno;
    serrno = errno;
    for (;;) {
        pid = waitpid(WAIT_ANY, &status, WNOHANG);
        if (pid < 0) {
            perror("waitpid");
            break;
        }
        if (pid == 0) {
            break;
        }
        notice_termination(pid, status);
      }
    errno = serrno;
}
```