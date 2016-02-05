# [什么是工作目录](https://www.gnu.org/software/libc/manual/html_node/Working-Directory.html#Working-Directory)

每个进程都和一个目录相关，这个目录称为当前工作目录，或者你也可以简单的称呼为工作目录。工作目录用来解析相对文件名（相对路径）。

当你登录，开始会话后，你的工作目录被设置到主目录。主目录记录在系统用户数据库中，连同你的登录账户。你可以使用 `getpwuid()` 或 `getpwnam()` 函数查找任何用户的主目录[→ 用户数据库]()。

用户可以改变他们的工作目录，使用 **shell** 命令 `$ cd` 即可轻松的完成。本节描述的函数，是检查和改变工作目录的原始函数，许多命令和程序都是基于它们工作的。

## API

###: #include &lt;unistd.h&gt;

```c
#include <unistd.h>
```

###: getcwd()

```c
char *getcwd(char *buffer, size_t size);
```

* Preliminary: | MT-Safe | AS-Unsafe heap | AC-Unsafe mem fd |
* Function

`getcwd()` 函数获取工作目录，工作目录用绝对文件名表示，存储在 `buffer` 参数中。

`getcwd()` 函数的 GNU C 库版本，也允许你将 `buffer` 置为空指针。这样，`getcwd()` 函数会自动分配一个缓冲区，类似 `malloc()`。如果 `size` 大于 `0`，分配的缓冲区就是 `size` 长度；否则，分配的缓冲区就是结果值的长度。

执行成功时返回 `buffer`；失败时返回一个空指针，并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EINVAL` 指定的 `size` 是 `0`，并且 `buffer` 不是空指针。

* `ERANGE` 指定的 `size` 比工作目录的长度小。你需要分配一个大点的缓冲区。

* `EACCES` 缺少读或查找文件名组件的权限。

你完全可以自己实现 `getcwd(NULL, 0)`：

```c
char *gnu_getcwd() {
    size_t size = 100;

    for (;;) {
        char *buffer = (char *) xmalloc(size);
        if (getcwd(buffer, size) == buffer)
            return buffer;
        free(buffer);
        if (errno != ERANGE)
            return 0;
        size *= 2;
    }
}
```

###: getwd()

```c
char *getwd(char *buffer);
```

* Preliminary: | MT-Safe | AS-Unsafe heap i18n | AC-Unsafe mem fd |
* Function

`getwd()` 函数类似 `getcwd()` 函数，但是不能把 `buffer` 置为空指针。GNU C 库提供 `getwd()` 函数，只是为了向后兼容 BSD。

`buffer` 参数应该是一个指向数组的指针，长度至少是 `
PATH_MAX`[→ 文件限制]()。

###: chdir()

```c
int chdir(const char *filename);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`chdir()` 函数修改进程的工作目录。

执行成功时返回 `0`，出错时返回 `-1` 并设置 `errno` 值。相关的 `errno` 值和文件名错误相同[→ 文件名错误](/docs/GNU C 标准库手册/IO Overview.md#user-content-7)。

###: fchdir()

```c
int fchdir(int fd);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`fchdir()` 函数修改进程的工作目录，将其置为文件描述符所在的目录。

执行成功时返回 `0`，出错时返回 `-1` 并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EACCES` 缺少读目录的权限。

* `EBADF` 指定的 `fd` 不是有效的文件描述符。

* `ENOTDIR` 指定的 `fd` 关联的不是目录。

* `EINTR` 函数调用被一个信号中断。

* `EIO` 捕捉到 IO 错误。



