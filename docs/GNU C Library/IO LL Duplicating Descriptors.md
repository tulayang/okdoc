# [复制文件描述符](https://www.gnu.org/software/libc/manual/html_node/Duplicating-Descriptors.html#Duplicating-Descriptors)

你可以复制一个文件描述符，或者分配另一个新的文件描述符并连接到同一个打开文件。复制的文件描述符，共享文件位置，有共同的文件状态标志[→ 文件状态标志](/docs/GNU C 标准库手册/IO LL File Status Flags.md)，但是每一个有自己独立的文件描述符标志[→ 文件描述符标志](/docs/GNU C 标准库手册/IO LL File descriptor flags.md)。

复制文件描述符的主要用处，是实现输入或输出的重定向：也就是说，使文件或管道通过相关的文件描述符进行通信。

你可以使用 `fcntl()` 函数并制定 `F_DUPFD` 命令执行这个操作，也可以通过 `dup()`、`dup2()` 函数执行这个操作。

## API

###: #include &lt;unistd.h&gt;

```c
#include <unistd.h>
```

###: dup()

```c
int dup(int oldfd);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

复制文件描述符 `oldfd`，生成新的文件描述符。等价于 `fcntl (oldfd, F_DUPFD, 0)`。

###: dup2()

```c
int dup2(int oldfd, int newfd);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

复制文件描述符 `oldfd`，生成新的文件描述符 `newfd`。

如果 `oldfd` 是一个无效的文件描述符，`dup2()` 什么也不做。

如果 `oldfd` 是有效的文件描述符，并且和 `newfd` 相同，那么 `dup2()` 直接返回 `oldfd`。

如果 `oldfd` 是有效的文件描述符，并且和 `newfd` 不同，那么 `dup2()` 等价于：

```c
close(newfd);
fcntl(oldfd, F_DUPFD, newfd);
```

然而，`dup2()` 以原子的方式执行这个过程。

###: F_DUPFD

```c
int F_DUPFD
```

这个宏作为 `fcntl()` 的命令项使用，复制指定的文件描述符。使用场景如下：

```c
fcntl(oldfd, F_DUPFD, newfd);
```

`newfd` 是一个 `int` 类型，指定新的文件描述符应该大于等于 `newfd`。

`fcntl()` 在使用此命令项时，返回值通常是新的文件描述符。如果出错返回 `-1` 并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 指定的 `oldfd` 不是有效的文件描述符。

* `EINVAL` 指定的 `newfd` 不是有效的文件描述符。

* `EMFILE` 没有更多的文件描述符可用---你的程序已经使用了最大数量。在 BSD 和 GNU，最大数是由资源限制控制的，可以通过 `RLIMIT_NOFILE()` 修改[→ 资源限制]()。

这里有个例子，演示了如何使用 `dup2()` 重定向标准流：

```c
pid = fork ();
if (pid == 0) {
    char *filename;
    char *program;
    int file;
    …
    file = TEMP_FAILURE_RETRY(open(filename, O_RDONLY));
    dup2(file, STDIN_FILENO);
    TEMP_FAILURE_RETRY(close(file));
    execv(program, NULL);
}
```



