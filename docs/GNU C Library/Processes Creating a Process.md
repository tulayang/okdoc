# [创建进程](https://www.gnu.org/software/libc/manual/html_node/Creating-a-Process.html#Creating-a-Process)

`fork()` 函数是创建进程的原始函数。 

###: #include &lt;unistd.h&gt; 

```c
#include <unistd.h>
```

###: fork()

```c
pid_t fork(void);
```

* Preliminary: | MT-Safe | AS-Unsafe plugin | AC-Unsafe lock | 
* Function

`fork()` 函数创建一个新的进程。它的返回值有三种情况：

1. 返回值 == 0 - 位于新进程中
2. 返回值 > 0 - 位于调用进程中，返回值是新进程的进程号码
3. 返回值 == -1 - 位于调用进程中，创建新进程失败

相关的 `errno` 值如下所示：

* `EAGAIN` 没有足够的系统资源来创建新进程，或者用户已经有太多的进程。这个上限是由 `RLIMIT_NPROC` 决定的，你可以修改它。

* `ENOMEM` 系统没有足够的空间。

子进程和父进程不同：

* 子进程有自己唯一的进程号。

* 子进程的父进程号，是父进程的进程号。

* 子进程得到父进程的打开文件描述符的副本。之后，父进程改变文件描述符的属性，不会影响子进程的，反之亦然。然而，进程之间关联的文件描述符，共享文件位置。

* 子进程的处理器时间设置为 `0`。

* 子进程不继承父进程的文件锁。

* 子进程不继承父进程的警报信号。

* 子进程的信号集被清空。

###: vfork()

```c
pid_t vfork(void);
```

* Preliminary: | MT-Safe | AS-Unsafe plugin | AC-Unsafe lock |
* Function

`vfork()` 函数类似 `fork()` 函数，不过在一些系统上效率更高点。然而，它的使用很受限。