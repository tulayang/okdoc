
## 打开文件 

### open() openat()

```
#include <fcntl.h>
int open(const char *pathname, int flags, [mode_t mode]); 
int openat(int fd, const char *pathname, int flags, [mode_t mode]);
    // 成功返回＂文件描述符＂，出错返回 -1
    // 
    // flags - 由 1 个或者多个标志位的按位或组合
    // 
    //   必须指定 5 个中的一个：
    // 
    //   ∘ O_RDONLY     -  只读打开
    //   ∘ O_WRONLY     -  只写打开
    //   ∘ O_RDWR       -  读写打开
    //   ∘ O_EXEC       -  只执行打开。当前操作系统未实现！ 
    //   ∘ O_SEARCH     -  只搜索打开（应用于目录）。当前操作系统未实现！ 
    // 
    //   以下是可选的：
    // 
    //   ∘ O_APPEND     -  每次写都追加到文件的尾端
    //   ∘ O_CLOEXEC    -  设置 close-on-exec，当 exec 时关闭相关＂文件描述符＂
    //   ∘ O_CREAT      -  文件不存在时创建，需要同时指定 mode
    //   ∘ O_TRUNC      -  如果文件已经存在，而且使用只写或者读－写成功打开，将其长度截断为 0
    //   ∘ O_DIRECTORY  -  如果 pathname 不是目录，则出错！
    //   ∘ O_EXCL       -  如果同时指定了 O_CREAT，而且文件已存在，则返回 -1，并且修改 errno！原子操作！
    //   ∘ O_NOCTTY     -  如果 pathname 是终端设备，不要把这个设备用作控制终端
    //   ∘ O_NOFOLLOW   -  如果 pathname 是符号链接，则出错！
    //   ∘ O_NONBLOCK   -  如果 pathname 是 FIFO，块特殊文件，字符特殊文件，以非阻塞方式打开文件
    //                     （如果没有数据可供读写, 立即返回进程）
    //   ∘ O_SYNC       -  同步磁盘，包括文件属性同步
    //   ∘ O_DSYNC      -  同步磁盘，不等待文件属性同步（Linux 中同 O_SYNC）
    //   ∘ O_RSYNC      -  同步磁盘，等待同一区域的写操作（Linux 中同 O_SYNC）
    //   ∘ O_FSYNC      -  等待写完成（仅 FreeBSD 和 Mac OS X）
    //   ∘ O_TTY_INIT   -  如果打开一个还未打开的终端设备，设置非标准 termios 参数值
    //   ∘ O_ASYNC      -  当文件可读／可写时，触发 SIGIO 信号，只能用于 FIFO，管道，Socket，终端，
    //                     不能用于普通文件（仅 Linux）
    // 
    // mode - 当创建新文件时，指定文件的访问权限
    // 
    //   ∘ S_IRWXU      -  所有者读，写，执行
    //   ∘ S_IRUSR      -  所有者读
    //   ∘ S_IWUSR      -  所有者写
    //   ∘ S_IXUSR      -  所有者执行
    // 
    //   ∘ S_IRWXG      -  组读，写，执行
    //   ∘ S_IRGRP      -  组读
    //   ∘ S_IWGRP      -  组写
    //   ∘ S_IXGRP      -  组执行
    // 
    //   ∘ S_IRWXO      -  其他人读，写，执行
    //   ∘ S_IROTH      -  其他人读
    //   ∘ S_IWOTH      -  其他人写
    //   ∘ S_IXOTH      -  其他人执行
```

`可能出现的错误 errno` ：

  错误号码  | 描述
-------|----
`EACCES`|文件权限不允许，或者文件不存在并且无法创建该文件。
`EISDIR`|文件是目录。
`EMFILE`|进程已打开的＂文件描述符＂数量，达到进程资源限制所设定的上限（`RLIMIT_NOFILE`）。
`ENFILE`|文件打开数量，达到系统允许的上限。
`ENOENT`|文件不存在并且未指定 `O_CREAT`，或者指定了 `O_CREAT` 但是 `pathname` 所在的目录不存在，或者<br />`pathname` 是符号链接并且指向的文件不存在。
`EROFS`|文件隶属于只读文件系统，调用者企图以写方式打开。
`ETXTBSY`|文件为可执行文件并且正在运行。

<span>

```
int fd = open("/home/king/foo", O_WRONLY | O_TRUNC);
if (fd == -1)
    errExit("open");
```

<span>

```
int fd = open("foo", O_WRONLY | O_CREATE | O_TRUNC, 
                     S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH); // 0664
if (fd == -1)
    errExit("open");
```

### create()

```
#include <fcntl.h>
int create(const char *pathname, mode_t mode); // 创建并打开一个文件，如果文件已经存在，则打开
                                        // 文件，并清空文件内容，将长度清 0。已很少使用，等效于：
                                        // open(pathname, O_WRONLY | O_CREAT | O_TRUNC, mode);
                                        // 成功返回＂文件描述符＂，出错返回 -1
```

## 关闭文件

### close()

```
#include <unistd.h>
int close(int fd);    // 成功返回 0，出错返回 -1
```

## 读文件

### read()

```
#include <unistd.h>
ssize_t read(int fd, void *buf, size_t nbytes);  // 成功返回读字节数，
                                                 // 如果到达文件尾返回 0，出错返回 -1
```

<span>

```
// 读取所有字节
ssize_t ret;
for (;;) {
    if (nbytes <= 0)
        break;
    ret = read(fd, buf, nbytes);
    if (ret == -1) {
        if (errno == EINTR) 
            continue;
        perror("read");
        break;
    }
    if (ret == 0)
        break;
    buf += ret;    // 移动缓冲区的＂偏移量＂
    nbytes -= ret; // 剩余要读的字节数
}
```

<span>

```
// 非阻塞读
char buf[BUFFSIZ];
ssize_t nr;

start:
nr = read(fd, buf, BUFFSIZ);
if (nr == -1) {
    if (errno == EINTR)
        goto start;   
    if (errno == EAGAIN)  // errno == EWOULDBLOCK
        // 稍后重新调用
    else
        perror("read");
}
```

## 写文件

### write()

```
#include <unistd.h>
ssize_t write(int fd, const void *buf, size_t nbytes);  // 成功返回写字节数，出错返回 -1
```

<span>

```
// 写入所有数据
ssize_t ret, nr;
for (;;) {
    if (nbytes <= 0)
        break;
    ret = write(fd, buf, nbytes);
    if (ret == -1) {
        if (errno == EINTR)
            continue;
        perror("write");
        break;
    }
    buf += ret;     // 移动缓冲区的＂偏移量＂。
    nbytes -= ret;  // 剩余要写的字节数。
}
```

## 文件偏移量

### lseek()

```
#include <unistd.h>
off_t lseek(int fd, off_t offset, int origin);  
      // 成功返回＂新的偏移量＂，出错返回 -1
      // 有些平台允许＂偏移量＂是负值，因此，应该测试返回值是否 -1，避免测试返回值 <0
      // 
      // offset - 偏移值
      // 
      // origin - 起点
      // 
      //   ∘ SEEK_CUR  -  从当前位置开始计算 = 当前值 + offset
      //   ∘ SEEK_END  -  从文件尾端开始计算 = 文件长度 + offset
      //   ∘ SEEK_SET  -  从文件起始开始计算 = 0 + offset
```

<span>

```
off_t pos = lseek(fd, (off_t) 0, SEEK_CUR);  // 获取文件的＂当前偏移量＂。
```

<span>

```
off_t pos = lseek(fd, (off_t) 1825, SEEK_SET);
if (pos == (off_t) -1)
    errExit("lseek");
```

## 文件截断

### ftruncate() truncate()

```
#include <unistd.h>
int truncate(const char *pathname, off_t length);  // 成功返回 0，出错返回 -1
int ftruncate(int fd, off_t length);               // 成功返回 0，出错返回 -1
```

## 复制文件描述符

### dup() dup2()

```
#include <unistd.h>

int dup(int fd);             // 成功返回＂新文件描述符＂，出错返回 -1
                             // 返回的＂新文件描述符＂，一定是当前可用文件描述符的最小数值

int dup2(int fd, int fd2);   // 成功返回＂新文件描述符＂，出错返回 -1
                             // 可以用 fd2 指定＂新文件描述符＂，如果 fd2 已经打开，先将 fd2 关闭。
                             //
                             //   1.fd2 == fd ，则返回 fd2，而不关闭它
                             //   2.fd2 != fd ，清除 fd2 的 close-on-exec，这样 fd2
                             //                 在进程调用 exec() 时是打开状态
```

<span>

```
int fd_stdin = dup(STDIN_FILENO);   // 复制标准输入的文件表，作为备份
dup2(fd, STDIN_FILENO);             // 将 STDIN_FILENO 重定向到 fd
// use fd
dup2(fd_stdin, STDIN_FILENO);       // 将 STDIN_FILENO 重定向到备份的 fd_stdin，恢复标准输入

```

## 同步 

### fsync() fdatasync() sync()

```
#inclue <unistd.h>
int  fsync(int fd)     // 同步，立刻把 fd 的脏数据（数据部分和文件属性）写到磁盘。成功返回 0，出错返回 -1
int  fdatasync(int fd) // 同步，立刻把 fd 的脏数据（数据部分）写到磁盘。成功返回 0，出错返回 -1
void sync(void)        // 同步，立刻把所有的脏数据（数据部分和文件属性）写到磁盘
```

## 文件属性

> 系统调用 `fcntl()` 可以改变已经打开文件的属性，主要有以下 5 种功能：
>
* cmd = `F_DUPFD` `F_DUPFD_CLIEXEC`　- 复制一个已有的＂文件描述符＂
* cmd = `F_GETFD` `F_SETFD` - 获取和设置＂文件描述符标志＂（比如 close-on-exec）
* cmd = `F_GETFL` `F_SETFL` - 获取和设置＂文件状态标志＂（比如 `O_RDONLY` `O_NONBLOCK`）
* cmd = `F_GETOWN` `F_SETOWN` - 获取和设置＂异步 IO 所有权＂
* cmd = `F_GETLK` `F_SETLK` `F_SETLKW` - 获取和设置＂记录锁＂

### fcntl()

```
#include <fcntl.h>
int fcntl(int fd, int cmd, [int arg]);    
    
    // 成功返回 cmd 依赖值，出错返回 -1。
    // 
    // cmd - 命令
    // 
    //   ∘ F_DUPFD          -  复制＂文件描述符号码 fd＂，＂新文件描述符号码＂作为函数值。是
    //                         ＂尚未打开的文件描述符号码＂中 >= arg 的最小值。与 fd 共享同一＂文件表＂
    //                         记录，但是有自己独立的＂文件描述符标志＂，并且其 FD_CLOEXEC
    //                         （close-on-exec 标志）被清除。
    //   ∘ F_DUPFD_CLOEXEC  -  复制＂文件描述符号码 fd＂，＂新文件描述符号码＂作为函数值，同时设置 
    //                         FD_CLOEXEC （close-on-exec 标志）。
    ／／
    //   ∘ F_GETFD          -  返回＂文件描述符号码 fd＂的＂文件描述符标志＂。当前只定义了一个
    //                         ＂文件描述符标志＂ FD_CLOEXEC （close-on-exec 标志）。
    //   ∘ F_SETFD          -  设置＂文件描述符号码 fd＂的＂文件描述符标志＂。当前只定义了一个
    //                         ＂文件描述符标志＂ FD_CLOEXEC （close-on-exec 标志）。
    ／／
    //   ∘ F_GETFL          -  返回＂文件描述符号码 fd＂的＂文件状态标志＂（open() 描述了
    //                         ＂文件状态标志＂）。因为历史原因，O_RDONLY O_WRONLY O_RDWR
    //                         O_EXEC O_SEARCH 并不是各占 1 位（前 3 个分别是 0 1 2），
    //                         没法直接用二进制 & 比较，需要用 & O_ACCMODE 取得访问方式位，再进行比较。
    //   ∘ F_SETFL          -  设置＂文件描述符号码 fd＂的＂文件状态标志＂。可以更改的标志：
    //                         O_APPEND O_NONBLOCK O_SYNC O_DSYNC O_RSYNC O_FSYNC O_ASYNC。
    ／／
    //   ∘ F_GETOWN         -  返回当前接收 SIGIO SIGURG 信号的＂进程号码＂或者＂进程组号码＂。
    //   ∘ F_SETOWN         -  设置接收 SIGIO SIGURG 信号的＂进程号码＂或者＂进程组号码＂。
    // 
    // arg - 当使用 F_DUPFD F_DUPFD_CLOEXEC F_SETFD F_SETFL F_SETOWN 时，作为传递的值
```

<span>

```
int val = fcntl(fd, F_GETFL);
if (val == -1)
    errExit("fcntl");
switch (val & O_ACCMODE) { 
case O_RDONLY:
    printf("read only");
    break;
case O_WRONLY:
    printf("write only");
    break;
case O_RDWR:
    printf("read write");
    break;
default:
    errExit("unknown access mode");
}

if (val & O_APPEND)
    printf("append");
if (val & O_NONBLOCK)
    printf("nonblocking");
if (val & O_SYNC)
    printf("synchronous writes");

// 使用功能测试宏 _POSIX_C_SOURCE，排除 POSIX，测试 FreeBSD 和 Mac OS X
#if !defined(_POSIX_C_SOURCE) && defined(O_FSYNC) && (O_FSYNC != O_SYNC) 
    if (val & O_FSYNC)
        printf("synchronous writes");
#endif
```

<span>

```
void setFl(int fd, int flags) {
    int val = fcntl(fd, G_GETFL);
    if (val) < 0
        errExit("fcntl G_GETFL");
    val |= flags;
    if (fcntl(fd, F_SETFL, val) < 0)
        errExit("fnctl F_SETFL");
}

setFl(STDOUT_FILENO, O_SYNC);  // 每次写都要等待，直到数据已写到磁盘上
                               // 对于数据库系统，需要使用 O_SYNC，确保 write 时数据确实写到了磁盘上
```

<span>

```
val &= ~flags;   // 使　val 与 flags 的反码进行与运算
```

## 终端设备

### ioctl()

```
#include <unistd.h>     // System V
#include <sys/ioctl.h>  // BSD，Linux
int ioctl(int fd, int request, ...);  // 成功返回值依赖参数，出错返回 -1．
```