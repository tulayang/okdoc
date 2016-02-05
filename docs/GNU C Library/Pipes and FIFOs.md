# [管道和命名管道](https://www.gnu.org/software/libc/manual/html_node/Pipes-and-FIFOs.html#Pipes-and-FIFOs)

管道是进程间通信的一种机制，一个进程通过管道写入数据，另一个进程通过管道读取。数据流动，遵循先进先出的顺序。 The pipe has no name; it is created for one use and both ends must be inherited from the single process which created the pipe。

命名管道类似管道，但是通过文件连接进程，它是有名字的。进程通过名字打开命名管道，然后进行通信。

当一个进程通过管道或命名管道读时，如果没有进程写入数据，那么会阻塞；如果没有数据可以继续读取，那么返回 end-of-file （其他进程可能关闭了文件描述符，或者退出）。

当一个进程通过管道或命名管道写时，如果没有进程读走数据，那么缓冲区会被填满，并生成 `SIGPIPE` 信号。如果设置了信号处理，那么继续写会返回 `-1`，引发错误 `EPIPE`；否则，则会阻塞直到数据被读走。

管道和命名管道都不支持文件定位，读写操作是顺序执行的。

## 创建管道

创建管道的原语是 `pipe()` 函数，它同时生成读端和写端。管道对单个进程并没有什么鸟用。常用的情况是这样：一个进程创建管道，然后 `fork()` 一个或多个子进程，子进程继承管道，这些进程间通过管道通信。

###: #include &lt;unistd.h&gt;

```c
#include <unistd.h>
```

###: pipe()

```c
int pipe(int fds[2]);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe fd |
* Function

`pipe()` 函数创建一个管道，生成两个文件描述符到 `fds`，一个可读 `fds[0]`，一个可写 `fds[1]`。

执行成功返回 `0`；出错返回 `-1` 并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EMFILE` 进程已达打开文件数上限。

* `ENFILE` 系统已达打开文件数上限。

例子：

```c


#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

/* 从管道读取字符，兵输出到标准输出 */

void read_from_pipe (int file) {
    FILE *stream;
    int c;
    stream = fdopen(file, "r");
    while ((c = fgetc(stream)) != EOF) {
        putchar(c);
    }
    fclose(stream);
}

/* 向管道随便写点什么 */

void write_to_pipe(int file) {
    FILE *stream;
    stream = fdopen(file, "w");
    fprintf(stream, "hello, world!\n");
    fprintf(stream, "goodbye, world!\n");
    fclose(stream);
}

int main(void) {
    pid_t pid;
    int mypipe[2];

    /* 创建管道 */
    if (pipe(mypipe)) {
        fprintf(stderr, "Pipe failed.\n");
        return EXIT_FAILURE;
    }

    /* 创建子进程 */
    pid = fork ();
    if (pid == (pid_t)0) {
        /* 此乃子进程。关闭管道的读端。 */
        close (mypipe[1]);
        read_from_pipe (mypipe[0]);
        return EXIT_SUCCESS;
    } else if (pid < (pid_t)0) {
        /* 创建子进程失败 */
        fprintf (stderr, "Fork failed.\n");
        return EXIT_FAILURE;
    } else {
        /* 此乃父进程。关闭管道的写端。 */
        close(mypipe[0]);
        write_to_pipe(mypipe[1]);
        return EXIT_SUCCESS;
    }
}
```

###

## 管道直通车

通常，管道用在进程间发送数据或接收数据。其过程常常是这样一套组合拳：`pipe()` 创建管道，`fork()` 创建子进程、`dup2()` 重定向子进程标准输入或标准输出到管道、`exec()` 加载新程序。`popen()` 和 `pclose()` 函数提供了简便的方法。

使用 `popen()` 和 `pclose()` 的优势是更简单，缺点是失去了灵活性。

###: #include &lt;unistd.h&gt;

```c
#include <unistd.h>
```

###: popen()

```c
FILE *popen(const char *command, const char *mode);
```

* Preliminary: | MT-Safe | AS-Unsafe heap corrupt | AC-Unsafe corrupt lock fd mem |
* Function

`popen()` 函数和 `system()` 函数有很亲密的关系。它执行 **shell** 命令 `command`，将其作为子进程。此外，它创建管道，用来和子进程通信。

如果指定 `mode = "r"`，你可以通过流读取数据，该数据来自子进程的标准输出。子进程的标准输入继承自父进程。

同样的，如果指定 `mode = "w"`，你可以通过流写入数据，子进程通过标准输入读取这些数据。子进程的标准输出继承自父进程。

执行成功返回流；出错返回空指针。

###: pclose()

```c
int pclose(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe heap plugin corrupt lock | AC-Unsafe corrupt lock fd mem |
* Function

`pclose()` 函数用来关闭 `popen()` 创建的流。它会等待子进程终止并返回状态值。

例子：

```c


#include <stdio.h>
#include <stdlib.h>

void write_data(FILE * stream) {
    int i;
    for (i = 0; i < 100; i++) {
        fprintf(stream, "%d\n", i);
    }
    if (ferror(stream)) {
        fprintf(stderr, "Output to stream failed.\n");
        exit(EXIT_FAILURE);
    }
}

int main(void) {
    FILE *output;

    output = popen("more", "w");
    if (!output) {
        fprintf (stderr, "incorrect parameters or too many files.\n");
        return EXIT_FAILURE;
    }
    write_data(output);
    if (pclose(output) != 0) {
        fprintf (stderr, "Could not run more or other error.\n");
    }
    return EXIT_SUCCESS;
}
```

###

## 命名管道

和管道不同，命名管道通过文件通信。

当你指定一个文件创建命名管道，任何进程都可以打开这个文件读写，如同读写普通文件。不过，你需要在两端同时打开这个文件，才能进行通信。一个进程打开管道读，如果没有其他进程打开同样的管道写，则会一直阻塞。

###: #include &lt;sys/stat.h.h&gt;

```c
#include <sys/stat.h.h>
```

###: mkfifo()

```c
int mkfifo(const char *filename, mode_t mode);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`mkfifo()` 函数指定文件名 `filename`，创建一个命名管道。`mode` 指定访问权限。

执行成功返回 `0`；出错返回 `-1` 并设置 `errno` 值。相关的 `errno` 值包括文件名错误 [→ 文件名错误](/docs/GNU C 标准库手册/IO Overview.md#user-content-7)，以及下面的几项：

* `EEXIST` 指定的命名管道已经存在。

* `ENOSPC` 父目录或文件系统不能被扩充。

* `EROFS` 父目录位于只读文件系统。

###

## 管道原子性

如果写入管道的数据小于 `PIPE_BUF`，那么读或写管道数据是原子的。原子的意思是，数据传输感觉像是一个整体进行的，不会受到其他操作的影响。

但是，如果读或写的数据大于 `PIPE_BUF`，那么操作可能不是原子的。

