# [执行程序](https://www.gnu.org/software/libc/manual/html_node/Executing-a-File.html#Executing-a-File)

`exec()` 实际上是多个函数，它们都用来执行新的程序。它们通常不返回，因为执行新的程序使得当前执行的程序完全消失。如果返回 `-1`，表示失败了。相关的 `errno` 值包括文件名错误 [→ 文件名错误](/docs/GNU C 标准库手册/IO Overview.md#user-content-7)，以及下面的几项：

* `E2BIG` 新程序的参数列表和环境变量列表的总大小大于 `ARG_MAX` 字节。

* `ENOEXEC` 指定的 `filename` 不是有效的可执行文件。

* `ENOMEM` 没有更多的存储空间来执行文件。

如果新文件被成功执行，会更新文件的上次访问时间。

执行新的程序，会彻底替换内存的内容。不过一部分进程的属性不会改变：

* 进程号和父进程的进程号

* 作为会话和进程组的成员

* 真实用户号和真实组号，以及辅助组号

* 未处理的警报

* 当前工作目录和根目录

* 文件创建掩码

* 进程信号掩码

* 未处理的信号

* 进程的处理器时间

如果可执行文件的 set-user-ID 和 set-group-ID 位被设定，会影响进程的有效用户号和有效组号。

执行前被镜像忽略的信号，执行后同样被新镜像忽略。其他的信号被置为默认值。

执行前被镜像打开的文件描述符，执行后会保留在新镜像，除非该描述符的文件描述符标志是 `FD_CLOEXEC`。保留下来的描述符，继承所有执行前的属性，包括文件锁。

流，则不能通过 `exec()` 保留。新镜像没有流，除了重新创建。

###: #include &lt;unistd.h&gt; 

```c
#include <unistd.h>
```

###: execv()

```c
int execv(const char *filename, char *const argv[]);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`execv()` 函数执行文件 `filename` --- 作为一个新的进程镜像。

`argv` 是一个字符串（没有终止符）数组，提供新程序 `main()` 函数的 `argv` 参数。按照约定，第一个参数是程序的文件名---不包含目录名。

新进程镜像的环境变量，使用当前进程镜像的 `environ` 变量。

###: execl()

```c
int execl(const char *filename, const char *arg0, …);
```

* Preliminary: | MT-Safe | AS-Unsafe heap | AC-Unsafe mem |
* Function

`execl()` 函数类似 `execv()` 函数，但是，通过可变参数指定 `argv` 参数，最后一个可变参数必须是空指针。

###: execve()

```c
int execve(const char *filename, char *const argv[], char *const env[]);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`execve()` 函数类似 `execv()` 函数，但是，允许你指定新程序的环境变量---字符串（没有终止符）数组，必须和 `environ` 变量有相同的格式。

###: execle()

```c
int execle(const char *filename, const char *arg0, …, char *const env[]);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`execle()` 函数类似 `execl()` 函数，但是，允许你指定新程序的环境变量---字符串（没有终止符）数组，必须和 `environ` 变量有相同的格式。

###: execvp()

```c
int execvp(const char *filename, char *const argv[]);
```

* Preliminary: | MT-Safe env | AS-Unsafe heap | AC-Unsafe mem |
* Function

`execvp()` 函数类似 `execv()` 函数，但是，它会搜索 `PATH` 目录查找可执行文件 `filename`。

`system()` 函数使用这个函数来查找并执行文件名。

###: execlp()

```c
int execlp(const char *filename, const char *arg0, …);
```

* Preliminary: | MT-Safe env | AS-Unsafe heap | AC-Unsafe mem |
* Function

`exelcp()` 函数类似 `execl()` 函数，但是，它会搜索 `PATH` 目录查找可执行文件 `filename`。


