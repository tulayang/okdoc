# [文件描述符标志](https://www.gnu.org/software/libc/manual/html_node/Descriptor-Flags.html#Descriptor-Flags)

文件描述符标志，是一个文件描述符的杂项属性。这个标志是和特定文件描述符相关的，因此，当你复制文件描述符时，每个文件描述符有自己的标志集合。

当前，只有一个文件描述符标志：`FD_CLOEXEC`---当调用 `exec()` 执行新程序时，在新程序中关闭该文件描述符。

## API

###: #include &lt;fcntl.h&gt;

```c
#include <fcntl.h>
```

###: F_GETFD

```c
int F_GETFD
```

* Macro

`F_GETFD` 作为 `fcntl()` 函数的命令项使用，返回文件描述符标志。

`fcntl()` 在使用此命令项时，返回值通常是非负数。如果出错返回 `-1` 并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 指定的 `fd` 不是有效的文件描述符。

###: F_SETFD

```c
int F_SETFD
```

* Macro

`F_SETFD` 作为 `fcntl()` 函数的命令项使用，设置文件描述符标志---指定第三个参数作为新的标志。使用场景如下：

```c
fcntl(fd, F_SETFD, new_flags);
```

`fcntl()` 使用此命令项，成功时返回一个未指定的值，出错时返回 `-1` 并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 指定的 `fd` 不是有效的文件描述符。

###: FD_CLOEXEC

```c
int FD_CLOEXEC
```

* Macro

`FD_CLOEXEC` 是一个文件描述符标志，它可以指定：当调用 `exec()` 执行新程序时，在新程序中关闭该文件描述符。当分配一个文件描述符时（比如 `open` 或 `dup()`），新的文件描述符会清除这个标志。

如果你想修改文件描述符标志，应该先使用 `F_GETFD` 获取当前标志，然后使用 `F_SETFD` 修改标志。尽管当前实现只有一个标志，但是不要在程序中这样假定---你的程序可能会运行很多年，而这期间有可能会增加新的标志。例子：

```c
/* Set the FD_CLOEXEC flag of desc if value is nonzero,
   or clear the flag if value is 0.
   Return 0 on success, or -1 on error with errno set. */

int set_cloexec_flag (int desc, int value) {
    int oldflags = fcntl (desc, F_GETFD, 0);
    /* 如果读取标志失败，立刻返回错误代码 */
    if (oldflags < 0)
        return oldflags;
    /* 添加 FD_CLOEXEC */
    if (value != 0)
        oldflags |= FD_CLOEXEC;
    /* 删除 FD_CLOEXEC */
    else
        oldflags &= ~FD_CLOEXEC;
    /* 保存修改后的标志 */
    return fcntl (desc, F_SETFD, oldflags);
}
```