# [BSD 版本的进程应答函数](https://www.gnu.org/software/libc/manual/html_node/BSD-Wait-Functions.html#BSD-Wait-Functions)

GNU C 库也提供了一些内容，以兼容 BSD Unix。BSD 使用 `union wait` 数据类型表示状态值，而不是 `int`。这两种表示是可互换的，它们表述相同的位模式。GNU C 库定义了 `WEXITSTATUS()` 宏，它也可以接受 `union wait` 作为参数；同时 `wait()` 函数也能使用 `union wait *` 替代 `int *`。

###: #include &lt;sys/wait.h&gt; 

```c
#include <sys/wait.h>
```

###: union wait

```
union wait;
```

* Data Type

`union wait` 表示程序的终止状态值。它由下列成员：

* `int w_termsig;` 它的值和 `WTERMSIG()` 相同。

* `int w_coredump;` 它的值和 `WCOREDUMP()` 相同。

* `int w_retcode;` 它的值和 `WEXITSTATUS()` 相同。

* `int w_stopsig;` 它的值和 `WSTOPSIG()` 相同。   

不要直接访问这些成员，使用对应的宏来访问。

###: wait3()

```
pid_t wait3(union wait *status-ptr, int options, struct rusage *usage);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Macro

如果 `usage` 是一个空指针，`wait3()` 等价于 `waitpid (-1, status-ptr, options)`。

否则，`wait3()` 把子进程使用的资源存储到 `*rusage`（只有终止时，停止不可以）。

