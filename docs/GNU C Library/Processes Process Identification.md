# [进程标识](https://www.gnu.org/software/libc/manual/html_node/Process-Identification.html#Process-Identification)

进程号由数据类型 `pid_t` 表示。你可以使用 `getpid()` 获取进程的进程号。`getppid()` 获取父进程的进程号。 

###: #include &lt;unistd.h&gt; #include &lt;sys/types.h&gt;

```c
#include <unistd.h>
#include <sys/types.h>
```

###: pid_t

```c
pid_t
```

* Data Type

`pid_t` 是一个有符号整数类型，表示进程号。在 GNU C 库，它是一个 `int`。

###: getpid()

```c
pid_t getpid(void);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`getpid()` 函数返回当前进程的进程号。

###: getppid()

```c
pid_t getppid(void);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`getppid()` 函数返回当前进程的父进程的进程号。