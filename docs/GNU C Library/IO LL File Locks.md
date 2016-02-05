# [文件锁](https://www.gnu.org/software/libc/manual/html_node/File-Locks.html#File-Locks)

这个章节描述了和进程相关的记录锁，它们是另一种不同于[→ 打开文件描述锁](/docs/Nice codes/Open file description locks.md)的记录锁。
当第一个进程正在读或写文件的某个部分时，使用记录锁可以阻止其它进程修改同一文件区。记录锁也可以称为“字节范围锁”，因为它锁定的只是文件中的一个区域（也可能是整个文件）。

## 概述

考虑这样一个应用程序，它可以被多个不同的用户同时运行，并且会把状态信息记录到一个日志文件中。这个程序可能是一个游戏，用文件来保存高分。也可能是一个记录账单的计费系统。

当这个程序同时存在多个副本（实例）时，把记录写入文件会导致文件的内容变得混乱。然而，你可以通过在写操作开始前设定一个写锁，来避免这种问题发生。

### 读锁和写锁

`fcntl()` 系统调用支持对记录锁的设置，以阻止多个协同工作的程序在同一时刻访问同一文件的相同部分。当获取锁时，使用一个 `struct flock` 指定锁的种类和位置。这个数据类型声明在头文件 `<fcntl.h>` 。

写锁是独占的，锁住文件指定的部分，赋予进程独占的写访问权。当一个进程持有写锁时，其它的进程不能锁住该文件的指定部分。

读锁是共享的，锁住文件指定的部分，阻止其它进程请求写锁。然而，其它进程可以请求读锁。

`read()` 和 `write()` 系统调用并不会检查进程是否持有锁。如果你想实现一个多个进程共享的文件锁协议，你的应用程序必须显式调用 `fcntl()` （在适当的地方）请求锁和清除锁。

### 记录锁是和进程关联的

锁是和进程关联的。对一个给定文件的每个字节，一个进程只能有一种类型的锁。只要此文件的任何描述符被该进程关闭时，该进程对此文件持有的所有锁就会被释放，哪怕这些锁是通过（此文件）其它仍然打开着的描述符获取的。同样，当该进程退出时锁也会被释放，并且不会被 `fork()` 创建的子进程继承。

### 兼容性

<table>
<tr>
  <th class="ta-c" style="min-width:110px">锁</th>
  <th class="ta-c" style="min-width:90px">SUS</th>
  <th class="ta-c" style="min-width:110px">FreeBSD 8.0</th>
  <th class="ta-c" style="min-width:110px">Linux 3.2.0</th>
  <th class="ta-c" style="min-width:150px">Mac OS X 10.6.8</th>
  <th class="ta-c" style="min-width:100px">Solaris 10</th>
</tr>
<tr>
  <td class="ta-l">建议性</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
</tr>
<tr>
  <td class="ta-l">强制性</td>
  <td class="ta-c"></td>
  <td class="ta-c"></td>
  <td class="ta-c">•</td>
  <td class="ta-c"></td>
  <td class="ta-c">•</td>
</tr>
<tr>
  <td class="ta-l">fcntl()</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
</tr>
<tr>
  <td class="ta-l">lockf()</td>
  <td class="ta-c">XSI</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
</tr>
<tr>
  <td class="ta-l">flock()</td>
  <td class="ta-c"></td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
</tr>
</table>

### 锁住文件区域

在设置或者释放文件上的一把锁时，系统按要求组合或者分裂相邻区。比如，如果第 100~199 字节是加锁的区域，需要解锁第 150 字节，则内核将维持两把锁，一把用于第 100~149 字节，一把用于 151~199 字节。

~~~?
                  ××××××××××××××××××××××××××××××××      
                  ×            加锁区             ×       
                  ××××××××××××××××××××××××××××××××  
                  100                           199        

                  ××××××××××××××××××××××××××××××××      
                  ×  第一加锁区  ×   ×  第二加锁区  ×       
                  ××××××××××××××××××××××××××××××××  
                  100          149 150          199   
~~~ 

假定我们又对第 150 字节加锁，那么系统将会再把 3 个相邻的加锁区合并成一个区（第 100~199 字节）。   

###

## API

###: #include &lt;fcntl.h&gt;

~~~c
#include <fcntl.h>
~~~ 

###: struct flock

~~~c
struct flock {
    short l_type;    // 锁的种类
                     //   * F_RDLCK  -  读锁，多个进程在给定的字节上可以有一把共享的读锁
                     //   * F_WRLCK  -  写锁，在给定的字节上只能有一个进程有一把独占的写锁
                     //   * F_UNLCK  -  解锁一个字节区域
    short l_whence;  // 锁区域的偏移标志位： 
                     //   * SEEK_SET  -  起始位置
                     //   * SEEK_CUR  -  当前位置
                     //   * SEEK_END  -  文件尾端
    off_t l_start;   // 锁区域的偏移值
    off_t l_len;     // 锁区域的长度，0 表示直到文件尾端
    pid_t l_pid;     // 持有锁的进程号码
};
~~~

这个结构体用来在调用 `fcntl()` 函数时描述记录锁的设定。

###: fcntl()

~~~c
int fcntl(int fd, int cmd, .../*struct flock *flockptr*/);
~~~

#### cmd

* F_GETLK

  表示返回一把锁的信息。这个命令需要第三个参数是一个 `struct flock *`：

  ~~~c
  fcntl (filedes, F_GETLK, lockp);
  ~~~

  1. 如果已经持有锁，锁信息会重写到 `*lockp`。如果你想同时查找读锁和写锁，指定 `F_WRLCK` 锁类型；如果只想查找读锁，指定 `F_RDLCK` 锁类型。

    在 `lockp` 参数指定的文件区域可能有多个锁，但是 `fcntl` 只返回它们中的一个。同时 `lockp` 的 `l_whence` 被置为 `SEEK_SET`，`l_start` 和 `l_len` 被置为锁定的区域。  

  2. 如果没有持有锁，`lockp` 只有一个变化，把 `l_type` 置为 `F_UNLCK`。

  `fcntl()` 出现错误时返回 `-1`，同时设置 `errno` 值：

  * `EBADF` 字段参数无效。
  * `EINVAL` 参数 `lockp` 指定的参数无效，或者指定的文件不支持锁。 

* F_SETLK

  表示设置或者清除一把锁。这个命令需要第三个参数是一个 `struct flock *`：

  ~~~c
  fcntl (filedes, F_GETLK, lockp);
  ~~~

  1. 如果已经持有锁，旧的锁会被新的锁替换。指定 `F_UNLCK` 可以清除锁。

  2. 如果锁不能被设置，`fcntl()` 立刻返回 `-1`。这个函数不会阻塞等待其它进程释放锁。如果 `fcntl()` 成功，`fcntl()` 返回 `非 -1`。

  下面是出错时可能的 `errno` 值：

  * `EAGAIN` `EACCES` 表示无法设置锁，因为它会被已经存在的锁阻塞。在这种情况，一些系统使用 `EAGAIN`，另外一些系统使用 `EACCES`，你的程序应该同时检查它们。

  * `EBADF` 设值的字段参数无效；或者你请求的是读锁，但是字段没有打开读访问权；或者你请求的是写锁，但是字段没有打开写访问权。

  * `EINVAL` 参数 `lockp` 没有指定有效的锁信息，或者定的文件不支持锁。

  * `ENOLCK` 系统已经耗尽锁资源；已经打开太多的锁。设计优良的文件系统不会报告这个错误，因为它们没有锁限制。然而，你必须考虑到这种情况，尤其是通过网络访问另一台机器的文件系统时。

* F_SETLKW

  表示设置或者清除一把锁。这个命令需要第三个参数是一个 `struct flock *`，类似 `F_SETLK`，但是会阻塞直到请求被接受。

  `fcntl()` 的返回值和 `errno` 值同 `F_SETLK`，不过增加了几个额外的：

  * `EINTR` 当阻塞时被信号中断。

  * `EDEADLK` 指定的文件区域被另一个进程锁定了，同时另一个进程正在等待请求锁定本进程正锁定的区域，这会造成死锁。系统并不能保证一定会发现这个情况，但是一旦发现了它能通知你。

###: lockReg 自定义工具

~~~c
int lockReg(int fd, int cmd, int type, off_t offset,  int whence, off_t len) {
    struct flock lock;
    lock.l_type   = type;
    lock.l_whence = whence;
    lock.l_start  = offset;
    lock.l_len    = len;
    return fcntl(fd, cmd, &lock);
}

#define readLock(fd, offset, whence, len)                           \
    lockReg((fd), F_SETLK, F_RDLCK, (offset), (whence), (len))
#define readwLock(fd, offset, whence, len)                          \
    lockReg((fd), F_SETLKW, F_RDLCK, (offset), (whence), (len))
#define writeLock(fd, offset, whence, len)                          \
    lockReg((fd), F_SETLK, F_WRLCK, (offset), (whence), (len))
#define writewLock(fd, offset, whence, len)                         \
    lockReg((fd), F_SETLK, F_WRLCK, (offset), (whence), (len))
#define unlock(fd, offset, whence, len)                             \
    lockReg((fd), F_SETLK, F_UNLCK, (offset), (whence), (len))

pid_t lockTest(int fd, int type, off_t offset,  int whence, off_t len) {
    struct flock lock;
    lock.l_type   = type;
    lock.l_whence = whence;
    lock.l_start  = offset;
    lock.l_len    = len;
    if (fcntl(fd, F_GETLK, &lock) == -1)
        errExit("fcntl");
    if (lock.l_type == F_UNLCK)
        return 0;
    return lock.l_pid;
}

#define isReadLockable(fd, offset, whence, len)                     \
    (lockTest((fd), F_RDLCK, (offset), (whence), (len)) == 0)
#define isWriteLockable(fd, offset, whence, len)                    \
    (lockTest((fd), F_WRLCK, (offset), (whence), (len)) == 0)
~~~



