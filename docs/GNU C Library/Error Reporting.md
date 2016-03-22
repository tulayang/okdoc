# [错误报告](https://www.gnu.org/software/libc/manual/html_node/Error-Reporting.html#Error-Reporting)

GNU C 库的许多函数，会检测和报告错误条件。有时候，你的程序需要对这些错误条件进行检查。例如，当你打开输入文件时，应该验证这个文件是否已经正确打开，如果调用库函数失败，就应该打印错误消息或采取其他适当行动。

本章介绍了错误报告是如何工作的。你的程序应该包含头文件 `<errno.h>` 来引入此工具。

## 检查错误

大多数库函数会返回一个特殊值，说明它们失败了。特殊值通常为 `-1`、空指针、或一个常数如 `EOF`。但这个返回值只是告诉你有错误发生了，要查出到底发生了什么错误，你需要看看变量 `errno` 的值，它存储了错误代码。这个变量声明在头文件 `<errno.h>`。

###: errno

```c
volatile int errno;
```

变量 `errno` 表示系统的错误号码，你可以改变它的值。

因为 `errno` 被声明为 `volatile`，所以它可以被信号触发器异步修改；参看 [Defining Handlers](https://www.gnu.org/software/libc/manual/html_node/Defining-Handlers.html#Defining-Handlers)。不过，一个编写规范的信号触发器会保存和恢复 `errno` 值，所以通常你不需要担心这种情况，除了要编写一个信号触发器。

在程序启动时 `errno` 的值被置为 `0`。许多库函数在遇到某些错误时将其修改为非零值，而执行成功时则不会修改 `errno`。因此，对一次成功的调用来说，`errno` 的值没有参考意义。

许多库函数在调用其他的库函数失败时，都可能修改 `errno` 为非零值。你应该假定任何库函数返回一个错误时都可能会修改 `errno`。

> 可移植性注解：ISO C 指定 `errno` 为“可修改的左值”而不是一个变量，允许它被作为一个宏来实现。例如，它的扩展可能是一个函数调用，类似 `__errno_location（）`。事实上，这正是它在 GNU / Linux 和 GNU / Hurd 系统上的实现。The GNU C Library, on each system, does whatever is right for the particular system.

有一些库函数，像 `sqrt()` 和 `atan()`，在出错时返回一个完全合法的值，但是也修改 `errno`。对于这些函数，如果你想检查是否出现错误，建议的方法是：调用函数之前把 `errno` 置为 `0`，调用之后检查 `errno` 的值。

所有的错误代码都有符号名字，它们作为宏被定义在 `<errno.h>`。以 “E” 开始，后面是大写字母或者数字。参看[保留名字](https://www.gnu.org/software/libc/manual/html_node/Reserved-Names.html#Reserved-Names)。

错误代码的值都是正整数，并且不相同，但有一个例外：`EWOULDBLOCK` 和 `EAGAIN` 是相同的。由于值不同，你可以把它们作为 `switch` 语句的标签，不过 `EWOULDBLOCK` 和 `EAGAIN` 应该作为一种情况考虑。此外，你的程序不应该对这些符号常量的实际值作出任何其他的假设。

`errno` 的值不一定完全符合这些宏，因为一些库函数可能会在其他情况下返回自己独有的错误代码。本手册列出的值，可以保证是库函数有意义的值。

除了 GNU / Hurd 系统，几乎任何系统调用，在把一个无效的指针作为实参时都会返回 `EFAULT`，因为这只可能是由于你的程序存在 bug 引起的错误。另外它不会发生在 GNU / Hurd 系统上，我们为了节省空间没有设定 `EFAULT`。

在一些 UNIX 系统中，许多系统调用也可以返回 `EFAULT`：当给定实参作为指针入栈，并且内核捕捉其在栈的引用失败时。如果发生这种情况，你应该尝试使用静态或动态分配的内存，而不是依赖栈内存。

###

## 错误代码

```?
E2BIG           -  Argument list too long (POSIX.1)
EACCES          -  Permission denied (POSIX.1)
EADDRINUSE      -  Address already in use (POSIX.1)
EADDRNOTAVAIL   -  Address not available (POSIX.1)
EAFNOSUPPORT    -  Address family not supported (POSIX.1)
EAGAIN          -  Resource  temporarily unavailable (may be the
                   same value as EWOULDBLOCK) (POSIX.1)
EALREADY        -  Connection already in progress (POSIX.1)
EBADE           -  Invalid exchange
EBADF           -  Bad file descriptor (POSIX.1)
EBADFD          -  File descriptor in bad state
EBADMSG         -  Bad message (POSIX.1)
EBADR           -  Invalid request descriptor
EBADRQC         -  Invalid request code
EBADSLT         -  Invalid slot
EBUSY           -  Device or resource busy (POSIX.1)
ECANCELED       -  Operation canceled (POSIX.1)
ECHILD          -  No child processes (POSIX.1)
ECHRNG          -  Channel number out of range
ECOMM           -  Communication error on send
ECONNABORTED    -  Connection aborted (POSIX.1)
ECONNREFUSED    -  Connection refused (POSIX.1)
ECONNRESET      -  Connection reset (POSIX.1)
EDEADLK         -  Resource deadlock avoided (POSIX.1)
EDEADLOCK       -  Synonym for EDEADLK
EDESTADDRREQ    -  Destination address required (POSIX.1)
EDOM            -  Mathematics argument out of domain  of  func‐
                   tion (POSIX.1, C99)
EDQUOT          -  Disk quota exceeded (POSIX.1)
EEXIST          -  File exists (POSIX.1)
EFAULT          -  Bad address (POSIX.1)
EFBIG           -  File too large (POSIX.1)
EHOSTDOWN       -  Host is down
EHOSTUNREACH    -  Host is unreachable (POSIX.1)
EIDRM           -  Identifier removed (POSIX.1)
EILSEQ          -  Illegal byte sequence (POSIX.1, C99)
EINPROGRESS     -  Operation in progress (POSIX.1)
EINTR           -  Interrupted function call (POSIX.1); see sig‐
                   nal(7).
EINVAL          -  Invalid argument (POSIX.1)
EIO             -  Input/output error (POSIX.1)
EISCONN         -  Socket is connected (POSIX.1)
EISDIR          -  Is a directory (POSIX.1)
EISNAM          -  Is a named type file
EKEYEXPIRED     -  Key has expired
EKEYREJECTED    -  Key was rejected by service
EKEYREVOKED     -  Key has been revoked
EL2HLT          -  Level 2 halted
EL2NSYNC        -  Level 2 not synchronized
EL3HLT          -  Level 3 halted
EL3RST          -  Level 3 halted
ELIBACC         -  Cannot access a needed shared library
ELIBBAD         -  Accessing a corrupted shared library
ELIBMAX         -  Attempting  to  link  in  too   many   shared
                   libraries
ELIBSCN         -  lib section in a.out corrupted
ELIBEXEC        -  Cannot exec a shared library directly
ELOOP           -  Too many levels of symbolic links (POSIX.1)
EMEDIUMTYPE     -  -  Wrong medium type
EMFILE          -  Too many open files (POSIX.1)
EMLINK          -  Too many links (POSIX.1)
EMSGSIZE        -  Message too long (POSIX.1)
EMULTIHOP       -  Multihop attempted (POSIX.1)
ENAMETOOLONG    -  Filename too long (POSIX.1)
ENETDOWN        -  Network is down (POSIX.1)
ENETRESET       -  Connection aborted by network (POSIX.1)
ENETUNREACH     -  Network unreachable (POSIX.1)
ENFILE          -  Too many open files in system (POSIX.1)
ENOBUFS         -  No   buffer  space  available  (POSIX.1  (XSI
                   STREAMS option))
ENODATA         -  No message is available on  the  STREAM  head
                   read queue (POSIX.1)
ENODEV          -  No such device (POSIX.1)
ENOENT          -  No such file or directory (POSIX.1)
ENOEXEC         -  Exec format error (POSIX.1)
ENOKEY          -  Required key not available
ENOLCK          -  No locks available (POSIX.1)
ENOLINK         -  Link has been severed (POSIX.1)
ENOMEDIUM       -  No medium found
ENOMEM          -  Not enough space (POSIX.1)
ENOMSG          -  No message of the desired type (POSIX.1)
ENONET          -  Machine is not on the network
ENOPKG          -  Package not installed
ENOPROTOOPT     -  Protocol not available (POSIX.1)
ENOSPC          -  No space left on device (POSIX.1)
ENOSR           -  No  STREAM  resources  (POSIX.1  (XSI STREAMS
                   option))
ENOSTR          -  Not a STREAM (POSIX.1 (XSI STREAMS option))
ENOSYS          -  Function not implemented (POSIX.1)
ENOTBLK         -  Block device required
ENOTCONN        -  The socket is not connected (POSIX.1)
ENOTDIR         -  Not a directory (POSIX.1)
ENOTEMPTY       -  Directory not empty (POSIX.1)
ENOTSOCK        -  Not a socket (POSIX.1)
ENOTSUP         -  Operation not supported (POSIX.1)
ENOTTY          -  Inappropriate I/O control operation (POSIX.1)
ENOTUNIQ        -  Name not unique on network
ENXIO           -  No such device or address (POSIX.1)
EOPNOTSUPP      -  Operation not supported on socket (POSIX.1)
                   (ENOTSUP and EOPNOTSUPP have the  same  value
                   on  Linux,  but  according  to  POSIX.1 these
                   error values should be distinct.)
EOVERFLOW       -  Value too large to be  stored  in  data  type
                   (POSIX.1)
EPERM           -  Operation not permitted (POSIX.1)
EPFNOSUPPORT    -  Protocol family not supported
EPIPE           -  Broken pipe (POSIX.1)
EPROTO          -  Protocol error (POSIX.1)
EPROTONOSUPPORT -  Protocol not supported (POSIX.1)
EPROTOTYPE      -  Protocol wrong type for socket (POSIX.1)
ERANGE          -  Result too large (POSIX.1, C99)
EREMCHG         -  Remote address changed
EREMOTE         -  Object is remote
EREMOTEIO       -  Remote I/O error
ERESTART        -  Interrupted system call should be restarted
EROFS           -  Read-only filesystem (POSIX.1)
ESHUTDOWN       -  Cannot send after transport endpoint shutdown
ESPIPE          -  Invalid seek (POSIX.1)
ESOCKTNOSUPPORT -  Socket type not supported
ESRCH           -  No such process (POSIX.1)
ESTALE          -  Stale file handle (POSIX.1)
                   This  error  can  occur for NFS and for other
                   filesystems
ESTRPIPE        -  Streams pipe error
ETIME           -  Timer expired (POSIX.1 (XSI STREAMS option))
                   (POSIX.1 says "STREAM ioctl(2) timeout")
ETIMEDOUT       -  Connection timed out (POSIX.1)
ETXTBSY         -  Text file busy (POSIX.1)
EUCLEAN         -  Structure needs cleaning
EUNATCH         -  Protocol driver not attached
EUSERS          -  Too many users
EWOULDBLOCK     -  Operation would block (may be same  value  as
                   EAGAIN) (POSIX.1)
EXDEV           -  Improper link (POSIX.1)
EXFULL          -  Exchange full
```

## 错误消息

GUN C 库设计了几个函数和变量，它们可以帮助你的程序方便地报告错误消息。

函数 `stderror()` 和 `perror()` 给出一个错误代码的标准错误消息，变量 `program_invocation_short_name` 给出出现错误的程序名称。

`error()` 和 `error_at_line()` 是首选的错误报告函数，它们使程序员编写的应用程序遵循 GNU 编码标准。GNU C 库还包含了用在 BSD 系统的错误报告函数。这些函数声明在 `<err.h>`。通常，不建议使用这些函数。它们被包含进来，只是为了提供兼容性。


###: #include &lt;errno.h&gt;

```c
#include <errno.h>
``` 

###: strerror()

```c
#include <string.h>
char *strerror(int errnum);
```

* Preliminary: | MT-Unsafe race:strerror | AS-Unsafe heap i18n | AC-Unsafe mem | 

把 `errnum` 参数指定的错误代码，映射到一个描述性的错误消息字符串。返回值是指向该字符串的指针。

`errnum` 的值通常来自变量 `errno`。

千万不要修改 `strerror()` 返回的字符串！！！如果你随后再次调用 `strerror()`，这个字符串可能被改写。（不过可以保证的是，没有其它库函数会调用 `strerror()`）

###: strerror_r()

```c
#include <string.h>
char *strerror_r(int errnum, char *buf, size_t n);
```

* Preliminary: | MT-Safe | AS-Unsafe i18n | AC-Unsafe |

`strerror_r()` 类似 `strerror()`，但是返回的错误消息首先存储在一块静态分配的缓冲区中，该缓冲区被进程中的所有线程共享，之后当前线程返回一个私有拷贝。

最多 `n` 个字符被写入（包括空字节），由用户选择足够大的缓冲区。

在多线程程序中应该总是使用这个函数，因为它可以确保返回的字符串只属于当前线程。

###: perror()

```c
#include <stdio.h>
void perror(const char *message);
```

* Preliminary: | MT-Safe race:stderr | AS-Unsafe corrupt i18n heap lock | AC-Unsafe corrupt lock mem fd |

这个函数打印一个错误消息到标准错误流；参看[标准流](https://www.gnu.org/software/libc/manual/html_node/Standard-Streams.html#Standard-Streams)。标准错误的定向不会被改变。

当你调用 `perror()` 时，无论是指定一个空指针还是空字符串，`perror()` 只是打印 `errno` 对应的错误消息，并加上一个换行。

如果你提供一个非空的消息参数，`perror()` 把它作为前缀输出，并增加一个冒号和一个空格字符。

`strerror()` 和 `perror()` 对任何给定的错误代码产生完全相同的消息，具体的消息内容因系统而异。在 GNU C 库中，消息相当短，没有多行消息或嵌入式的换行；每一个错误消息以大写字母开头，不包括任何终止符号。

> 在遇到系统调用失败时，许多不读取终端输入的程序被设计为退出。按照惯例，这种程序产生的错误消息，应该以程序的名字开始，不包含目录名。你可以通过变量 `program_invocation_short_name` 找到名字，完整的文件名存储在变量 `program_invocation_name`。

###: program_invocation_name

```c
#include <errno.h>
char *program_invocation_name;
```

这个变量的值是用来获取当前进程中运行的程序的名称。它和 `argv[0]`相同。请注意，这并不一定是有用的文件名；通常它不包含任何目录名称。

这个变量是一个 GNU 扩展。

###: program_invocation_short_name

```c
#include <errno.h>
char *program_invocation_short_name;
```

这个变量的值是用来获取当前进程中运行的程序的名称，不包含目录名。这个变量是一个 GNU 扩展。

库初始化代码在调用 `main()` 之前设置了这两个变量。

> 可移植性注解：如果你想让你的程序与非 GNU 库工作，你必须自己保存 `main()` 的参数 `argv[0]`，然后去掉目录名。我们加入这些扩展，只是为了便于编写独立的错误报告。

下面是一个示例，演示如何正确处理打开文件失败。函数 `open_sesame()` 试图打开指定的文件并读取，如果成功就返回一个流。如果因为某些原因不能打开文件，`fopen()` 库函数返回一个空指针。在这种情况下，`open_sesame()` 使用 `strerror()` 函数来构建适当的错误消息，并终止程序。此外，如果我们打算把错误代码传递给 `strerror()` 前要调用一些其他库函数，我们必须将 `errno` 的值 保存在一个局部变量中，因为其他库函数可能会覆盖 `errno`。

```c
#define _GNU_SOURCE

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

FILE *open_sesame (char *name) {
    FILE *stream;

    errno = 0;
    stream = fopen (name, "r");
    if (stream == NULL) {
        fprintf (stderr, "%s: Couldn't open file %s; %s
",
                 program_invocation_short_name, name, strerror (errno));
        exit (EXIT_FAILURE);
    }
    else
        return stream;
}
```

使用 `perror()` 的优点是，比较方便，可在所有支持 ISO C 的系统实施。但往往生成的文本不是想要的，并且没有办法扩展或者修改。GNU 编码标准，例如，requires error messages to be preceded by the program name and programs which read some input files should provide information about the input file name and the line number in case an error is encountered while reading the file. For these occasions there are two functions available which are widely used throughout the GNU project. These functions are declared in error.h. 

###: error()

```c
#include <errno.h>
void error(int status, int errnum, const char *format, …);
```

* Preliminary: | MT-Safe locale | AS-Unsafe corrupt heap i18n | AC-Safe | 

在程序执行过程中，可以使用 `error()` 函数来报告一般性问题。`format` 参数是一个格式字符串，就像 `printf()` 函数。类似 `perror()`，`error()` 也能以文本形式报告错误代码。但不同于 `perror()`，`errno` 的值是显式传递给函数的。This eliminates the problem mentioned above that the error reporting function must be called immediately after the function causing the error since otherwise errno might have a different value. 

`error()` 首先打印程序名称。如果应用程序定义了一个全局变量 `error_print_progname` 并且将其指向一个函数，这个函数会被调用来打印程序名称。否则，会使用全局变量 `program_name` 字符串的值。程序名之后跟随一个冒号和一个空格，然后依次是由格式字符串产生的输出。如果 `errnum` 参数是非零，冒号和空格后输出格式字符串，其次为错误代码对应的错误消息。在任何情况下输出以一个换行终止。

输出被定向到标准错误流。If the stderr wasn’t oriented before the call it will be narrow-oriented afterwards. 

该函数会返回，除非 `status` 参数是一个非零的值。在这种情况下，函数将调用 `exit()`，并把 `status` 作为参数，并且永远不返回。如果 `error()` 返回，全局变量 `error_message_count` 递增 `1`,以跟踪错误报告数。

###: error_at_line()

```c
void error_at_line(int status, int errnum, const char *fname, unsigned int lineno, const char *format, …);
```

* Preliminary: | MT-Unsafe race:error_at_line/error_one_per_line locale | AS-Unsafe corrupt heap i18n | AC-Unsafe corrupt/error_one_per_line |

`error_at_line()` 函数非常类似 `error()` 函数，唯一的区别是额外的参数 `fname` 和 `lineno`。除了程序名称和附加字符串文本之间的内容不同外，其他参数的处理和 `error()` 都是相同的。

程序名后跟随一个冒号，其次是文件名，另一个冒号，和 `lineno` 的值。

这个额外的输出，主要是用来定位当前输入文件的错误（类似编程语言源代码文件）。

如果全局变量 `error_one_per_line` 被置为非零值，`error_at_line` 可以避免对同一文件和行打印连续消息。Repetition which are not directly following each other are not caught. 

和 `error()` 一样，如果 `status` 是 `0` 则返回。否则调用 `exit()`，并把 `status` 作为参数，并且永远不返回。如果返回，全局变量 `error_message_count` 递增 `1`,以跟踪错误报告数。

如上面所提到的，`error()` 和 `error_at_line()` 函数可以通过定义一个名为 `error_print_progname` 的变量来定制消息。

###: error_print_progname

```c
void (*error_print_progname)(void);
```

如果 `error_print_progname` 变量被定义为一个非零值，它所指向的函数会被 `error()` 和 `error_at_line()` 调用。它被用来打印程序名称，或者做类似的有用的事情。

这个函数会打印到标准错误流，必须能够处理任何定向的流。

这个变量是全局的，并且被所有线程共享。

###: error_message_count

```c
unsigned int error_message_count;
```

当 `error()` 或者 `error_at_line()` 被调用并返回时， `error_message_count` 变量就增加 `1`。这个变量是全局的，并且被所有线程共享。

###: error_one_per_line

```c
int error_one_per_line;
```

`error_one_per_line` 变量只影响 `error_at_line()`。通常情况下，`error_at_line()` 函数对每一次调用都会创建输出。如果 `error_one_per_line` 被置为非零值，那么 `error_at_line()` 会保持跟踪最后一个文件的名称和行号，以用于错误报告，以及避免直接从文件中提取错误。这个变量是全局的，并且被所有线程共享。

程序读取一些输入文件发生错误时，错误报告会类似这样：

```c
{
    char *line = NULL;
    size_t len = 0;
    unsigned int lineno = 0;

    error_message_count = 0;
    while (! feof_unlocked (fp)) {
        ssize_t n = getline (&line, &len, fp);
        if (n <= 0)
            /* End of file or error.  */
            break;
        ++lineno;

        /* Process the line.  */
        …

        if (Detect error in line)
            error_at_line (0, errval, filename, lineno,
                           "some error text %s", some_variable);
    }

    if (error_message_count != 0)
        error (EXIT_FAILURE, 0, "%u errors found", error_message_count);
}
```

###: warn()

```c
void warn(const char *format, …);
```

* Preliminary: | MT-Safe locale | AS-Unsafe corrupt heap i18n | AC-Unsafe corrupt lock mem |

`warn()` 函数大致等价于：

```c
error(0, errno, format, the parameters);
```

except that the global variables error respects and modifies are not used. 

###: vwarn()

```c
void vwarn(const char *format, va_list ap);
```

* Preliminary: | MT-Safe locale | AS-Unsafe corrupt heap i18n | AC-Unsafe corrupt lock mem |

`vwarn()` 函数类似 `warn()` 函数，除了格式化参数不同。

###: warnx()

```c
void warnx(const char *format, …);
```

* Preliminary: | MT-Safe locale | AS-Unsafe corrupt heap | AC-Unsafe corrupt lock mem |

`warnx()` 函数大致等价于：

```c
error(0, 0, format, the parameters);
```

except that the global variables error respects and modifies are not used. 

###: vwarnx()

```c
void vwarnx(const char *format, va_list ap);
```

* Preliminary: | MT-Safe locale | AS-Unsafe corrupt heap | AC-Unsafe corrupt lock mem |

`vwarnx()` 函数类似 `warnx()` 函数，除了格式化参数不同。

###: err()

```c
void err(int status, const char *format, …);
```

* Preliminary: | MT-Safe locale | AS-Unsafe corrupt heap | AC-Unsafe corrupt lock mem |

`err()` 函数大致等价于：

```c
error(status, errno, format, the parameters);
```

except that the global variables error respects and modifies are not used and that the program is exited even if status is zero. 

###: verr()

```c
void err(int status, const char *format, va_list ap);
```

* Preliminary: | MT-Safe locale | AS-Unsafe corrupt heap | AC-Unsafe corrupt lock mem |

`verr()` 函数类似 `err()` 函数，除了格式化参数不同。

###: errx()

```c
void errx(int status, const char *format, ...);
```

* Preliminary: | MT-Safe locale | AS-Unsafe corrupt heap | AC-Unsafe corrupt lock mem |

`errx()` 函数大致等价于：

```c
error(status, 0, format, the parameters);
```

except that the global variables error respects and modifies are not used and that the program is exited even if status is zero. The difference to err is that no error number string is printed. 

###: verrx()

```c
void verrx(int status, const char *format, va_list ap);
```

* Preliminary: | MT-Safe locale | AS-Unsafe corrupt heap | AC-Unsafe corrupt lock mem |

`verrx()` 函数类似 `errx()` 函数，除了格式化参数不同。

###