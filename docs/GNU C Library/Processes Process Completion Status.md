# [进程结束状态](https://www.gnu.org/software/libc/manual/html_node/Process-Completion-Status.html#Process-Completion-Status)

如果子进程退出的状态值是 `0`，那么 `waitpid()`、`wait()` 获取的值也是 `0`。你可以用本节描述的宏测试获取的状态值。

###: #include &lt;sys/wait.h&gt; 

```c
#include <sys/wait.h>
```

###: WIFEXITED()

```
int WIFEXITED(int status);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Macro

如果 `status` 表示子进程通过 `exit()` 或 `_exit()` 退出，返回 `非 0`。

###: WEXITSTATUS()

```
int WEXITSTATUS(int status);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Macro

如果 `WIFEXITED()` 返回 `非 0`，`WEXITSTATUS()` 返回退出状态值的低 8 位。

###: WIFSIGNALED()

```
int WIFSIGNALED(int status);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Macro

如果 `status` 表示子进程收到一个未处理的信号而终止，返回 `非 0`。

###: WTERMSIG()

```
int WTERMSIG(int status);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Macro

如果 `WIFSIGNALED()` 返回 `非 0`，`WTERMSIG()` 返回终止子进程的信号数字。

###: WCOREDUMP()

```
int WCOREDUMP(int status);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Macro

如果 `status` 表示子进程终止并产生核心转储，返回 `非 0`。

###: WIFSTOPPED()

```
int WIFSTOPPED(int status);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Macro

如果 `status` 表示子进程收到一个停止信号而停止（可以恢复），返回 `非 0`。

###: WSTOPSIG()

```
int WSTOPSIG(int status);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Macro

如果 `WIFSTOPPED()` 返回 `非 0`，`WSTOPSIG()` 返回停止子进程的信号数字。


