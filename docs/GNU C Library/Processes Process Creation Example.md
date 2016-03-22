# [进程创建例子](https://www.gnu.org/software/libc/manual/html_node/Process-Creation-Example.html#Process-Creation-Example)

这儿有个例子，它非常类似内置的 `system()` 函数。它执行命令参数，如同 `$ sh -c command`：

```c
#include <stddef.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

/*  定义执行命令的 shell 程序  */
#define SHELL "/bin/sh"

int my_system(const char *command) {
    int status;
    pid_t pid;

    pid = fork();
    if (pid == 0) {
        /*  这里是子进程，执行 shell 命令  */
        execl(SHELL, SHELL, "-c", command, NULL);
        _exit(EXIT_FAILURE);
    } else if (pid < 0) {
        /*  fork 失败，报告错误  */
        status = -1;
    } else {
        /*  这里是父进程，等待子进程完成  */
        if (waitpid(pid, &status, 0) != pid) {
            status = -1;
        }
    }
    return status;
}
```

有两点需要注意。

记住，提供给程序的参数 `argv` --- 类似 `main()`，第一个应该是程序的可执行文件名。这就是为什么，调用 `execl()` 时，传入 `SHELL` --- 可执行文件名。

当 `execl()` 执行成功时不会返回。如果失败了，你必须确保终止子进程。

我们在这里使用了 `_exit`，调用 `exit()` 会彻底冲洗流缓冲区（比如 `stdout`），而 `_exit()` 则避免这么做。这些流的缓冲区可能包含从父进程复制的数据，子进程调用 `exit()` 会导致输出两次数据。