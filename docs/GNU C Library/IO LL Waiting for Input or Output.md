# [select 多路复用](https://www.gnu.org/software/libc/manual/html_node/Waiting-for-I_002fO.html#Waiting-for-I_002fO)

Sometimes a program needs to accept input on multiple input channels whenever input arrives. 比如，一些工作站的某些设备，像数字化平板电脑、功能按钮盒、仪表盘等等，它们通过异步串行接口连接，需要一个设计良好的用户接口：只要有输入到达任何设备都能立刻做出响应。另一个例子是，作为一个服务器，通过管道或套接字与其他进程通信。

你无法利用 `read()` 达到这一目的，因为它会阻塞程序，直到指定的文件描述符有输入可用---其他通道到来的输入无法唤醒它。你可以设置非阻塞模式，并且用循环的方式轮询每个文件描述符，但是这非常低效。

一个更好的解决方案是使用 `select()`。它会阻塞程序，直到指定的文件描述符集合中有输入或输出可用，或者直到一个指定的过期时间。这个工具声明在头文件 `<sys/select.h>`。

`select()` 函数通过一个 `fd_set` 对象指定文件描述符集合。

## API

###: #include &lt;sys/select.h&gt;

```c
#include <sys/select.h>
```

###: fd_set

```c
typedef struct {
#ifdef __USE_XOPEN
    __fd_mask fds_bits[__FD_SETSIZE / __NFDBITS];
# define __FDS_BITS(set) ((set)->fds_bits)
#else
    __fd_mask __fds_bits[__FD_SETSIZE / __NFDBITS];
# define __FDS_BITS(set) ((set)->__fds_bits)
#endif
} fd_set;
```

`fd_set` 数据类型指定文件描述符集合。通常它是一个位数组。

###: FD_SETSIZE

```c
int FD_SETSIZE
// example: 
//     #define FD_SETSIZE 1024
```

指定 `fd_set` 对象可以保存的文件描述符的最大号码。On systems with a fixed maximum number, `FD_SETSIZE` is at least that number. On some systems, including GNU, there is no absolute limit on the number of descriptors open, but this macro still has a constant value which controls the number of bits in an `fd_set`; if you get a file descriptor with a value as high as `FD_SETSIZE`, you cannot put that descriptor into an `fd_set`. 

###: FD_ZERO

```c
void FD_ZERO(fd_set *set)
```

* Preliminary: | MT-Safe race:set | AS-Safe | AC-Safe |

初始化文件描述符集合，将其置为空的集合。

###: FD_SET()

```c
void FD_SET(int fd, fd_set *set)
```

* Preliminary: | MT-Safe race:set | AS-Safe | AC-Safe |

向文件描述符集合添加一个文件描述符。

`fd` 参数不能有副作用，否则它可能会被多次计算。

###: FD_CLR()

```c
void FD_CLR(int fd, fd_set *set)
```

* Preliminary: | MT-Safe race:set | AS-Safe | AC-Safe |

从文件描述符集合删除一个指定的文件描述符。

`fd` 参数不能有副作用，否则它可能会被多次计算。

###: FD_ISSET()

```c
int FD_ISSET(int fd, const fd_set *set)
```

* Preliminary: | MT-Safe race:set | AS-Safe | AC-Safe |

如果指定的文件描述符在集合中，返回 `非 0`；否则，返回 `0`.

`fd` 参数不能有副作用，否则它可能会被多次计算。

###: select()

```c
int select(int nfds, fd_set *read-fds, fd_set *write-fds, fd_set *except-fds, struct timeval *timeout);
```

* Preliminary: | MT-Safe race:read-fds race:write-fds race:except-fds | AS-Safe | AC-Safe |

`select()` 函数阻塞进程，直到指定的文件描述符集合中有活动，或者直到指定的过期时间。

`read-fds` 指定可读的文件描述符，`write-fds` 指定可写的文件描述符，`except-fds` 指定存在异常的文件描述符。你可以将其中任何一个设为空指针，之后就不会出现在检测条件中。

以下列举了一些上述输入输出到来的情况：

* 对于一个文件描述符，当对其调用 `read()` 不会阻塞时
* 对于一个服务器套接字，当对其调用 `accept()` 不会阻塞时
* 对于一个客户端套接字，当其连接完全建立时

“Exceptional conditions” does not mean errors—errors are reported immediately when an erroneous system call is executed, and do not constitute a state of the descriptor. Rather, they include conditions such as the presence of an urgent message on a socket.

`nfds` 指定待检查的文件描述符的最大号码，通常将其设定为 `FD_SETSIZE`。

`timeout` 指定等待的过期时间。如果设定为空指针，则会一直阻塞，直到有活动出现。否则，你应该提供一个`struct timeval` 超时时间[→ 日历时间]()。

通常，`select()` 返回集合中活动的文件描述符数。同时，每个描述符集合都会被重写。因此，在 `select()` 返回后，想知道文件描述符 `desc` 是否有输入，调用 `FD_ISSET(desc, read-fds)`。

如果 `select()` 超时，它会返回 `0`。

任何信号都会导致 `select()` 立刻返回。因此，如果你的程序中使用了信号，你的 `select()` 就会存在被中断的可能。当 `select()` 返回时，你应该检查是否是 `EINTR` 错误引起的；如果确实是这样，重新执行 `select()`。

如果 `select()` 执行错误，它会返回 `-1` 并设置 `errno` 值，但是不修改文件描述符集合。 相关的 `errno` 值如下所示：

* `EBADF` 指定的文件描述符集合中，存在无效的文件描述符。

* `EINTR` 被一个信号中断。

* `EINVAL` 指定的 `timeout` 无效，其中的字段值是负数或者太大了。

> 可移植性注解：`select()` 函数是 BSD Unix 特性。

这儿有一个例子，演示了如何使用 `select()` 设定超时时间，以及读取文件：

```c
#include <errno.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/time.h>

int input_timeout(int filedes, unsigned int seconds) {
    fd_set set;
    struct timeval timeout;

    /* Initialize the file descriptor set. */
    FD_ZERO(&set);
    FD_SET(filedes, &set);

    /* Initialize the timeout data structure. */
    timeout.tv_sec = seconds;
    timeout.tv_usec = 0;

    /* select returns 0 if timeout, 1 if input available, -1 if error. */
    return TEMP_FAILURE_RETRY(select(FD_SETSIZE,
                                     &set, NULL, NULL,
                                     &timeout));
}

int main (void) {
    fprintf(stderr, "select returned %d.", 
            input_timeout(STDIN_FILENO, 5));
    return 0;
}
```

