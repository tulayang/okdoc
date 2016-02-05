# 如何编写守护进程

守护进程（daemon）是生存周期特别长的一种进程。它们常常在系统引导时启动，并且仅在系统关闭时才终止。因为它们没有控制终端，所以我们称它们运行在后台。没有控制终端，可以确保内核永远不会为守护进程自动生成任何作业控制信号或者终端相关的信号（比如 `SIGINT`、`SIGTSTP` 和 `SIGHUP`）。

大多数标准的守护进程都是作为特权进程运行。此外，因为守护进程没有控制终端，我们需要知道：当出现错误时守护进程应该如何报告。

## 内核守护进程

UNIX 系统有大量的守护进程，来执行日常任务。让我们先来看一些常用的系统守护进程，了解它们是如何与进程组、控制终端和会话关联的。在此，我们必须学习一个系统命令：

```sh
$ ps [options]  # 显示当前系统中的进程信息
                # 
                # options - 选项
                # 
                #   ∘ -a            --  显示有控制终端的进程信息
                #   ∘ -x            --  显示没有控制终端的进程信息
                #   ∘ -j            --  显示与作业有关的进程信息
                #                       （进程号码、进程组号码、会话号码和控制终端）
                #   ∘ -A -e         --  显示所有的进程信息
                #   ∘ -p <pid>      --  显示特定进程号的进程
                #   ∘ -s <session>  --  显示特定会话号的进程
                #   ∘ -u <uid>      --  显示有效用户号码的进程
                #   ∘ -U <uid>      --  显示真实用户号码的进程
                #   ∘ -g <group>    --  显示有效组的进程
                #   ∘ -G <gid>      --  显示真实组的进程
                #   ∘ ............. --  ..............
```

在 shell 命令行中输入 `ps` 命令，输出大致是：

```?
$ ps -axj
PPID   PID  PGID   SID TTY      TPGID STAT   UID   TIME COMMAND
   0     1     1     1 ?           -1 Ss       0   0:00 /sbin/init
   0     2     0     0 ?           -1 S        0   0:00 [kthreadd]
   2     3     0     0 ?           -1 S        0   0:00 [ksoftirqd/0]
   2     4     0     0 ?           -1 S        0   0:00 [kworker/0:0]
   2     5     0     0 ?           -1 S<       0   0:00 [kworker/0:0H]
   2     7     0     0 ?           -1 S        0   0:02 [rcu_sched]
   2     8     0     0 ?           -1 S        0   0:02 [rcuos/0]
   2     9     0     0 ?           -1 S        0   0:02 [rcuos/1]
   2    10     0     0 ?           -1 S        0   0:00 [rcu_bh]
   2    11     0     0 ?           -1 S        0   0:00 [rcuob/0]
   2    12     0     0 ?           -1 S        0   0:00 [rcuob/1]
   2    13     0     0 ?           -1 S        0   0:00 [migration/0]
   2    14     0     0 ?           -1 S        0   0:00 [watchdog/0]
   2    15     0     0 ?           -1 S        0   0:00 [watchdog/1]
   1  1008  1008  1008 ?           -1 Ss       0   0:00 /usr/local/okdoc/bin/okdocd --options x
2382  2389  2389  2389 pts/9     5100 Ss    1000   0:00 bash
```

在列出的进程信息中，内核守护进程的名字出现在 **[]** 中。父进程号码是 `0` 的进程通常是内核进程，它们作为系统引导过程的一部分来启动。（**init** 是个例外，因为它是内核在引导期间作为用户级命令来启动的）。内核进程是特殊的进程，通常存在系统的整个生命期中。它们以超级用户特权运行，没有控制终端，没有命令行。

进程号码 `1` 通常是 **init**。

### Unix 内核守护进程

* **syslogd** 用来在其它程序中以日志的方式记录系统消息，这些消息可以在控制台打印，也可以写入到文件。

* **inted** 互联网超级服务器守护进程，监听指定的 TCP/IP 端口的网络连接，并且分派适当的服务器程序来处理这些连接。

* **nfsd** **lockd** **rpcid** 提供网络文件系统（NFS）的支持。

* **cron** 在指定的日期和时间执行命令。许多系统管理任务，就是通过它定期执行相关程序来处理的。

* **cupsd** 是一个后台打印进程，它处理系统的打印请求。

* **sshd** 安全 shell 守护进程，允许远程主机使用安全的通信协议登录系统。

### Linux 内核守护进程

* **kthreadd** Linux 系统的特殊内核进程，用来创建其它内核进程，所以它常常作为其它内核进程的父进程。

* **bdflush** 脏页冲洗内核进程。内核维护着可用内存的最小阈值，当到达最低点时通过 `wakeup_bdflush()` 唤醒该守护进程，将脏数据冲洗到磁盘。它以缓冲为单位冲洗数据。

* **kupdated** 脏页冲洗内核进程。它会定期地将脏数据冲洗到磁盘，以减少系统故障时数据丢失。

* **pdflush** 脏页冲洗内核进程。因为 bdflush 是单线程的，在处理繁重的冲洗任务时，无法利用多核的优势。在 2.6 版本开始，推出了多线程的 pdflush，以提供更高效的冲洗能力。它以页为单位冲洗数据，每次冲洗都必定是页的倍数。

###

## 守护进程的编写规则

要成为一个守护进程，程序需要执行下面的步骤：

1. 执行 `fork()`，之后父进程退出，子进程继续执行。（守护进程变为 **init** 的子进程）。这样做有两个原因：

   * 如果守护进程是作为 shell 命令启动的，父进程终止会让 shell 认为这条命令已经执行完毕，显示一个提示并且把子进程留在后台继续运行。

   * 确保子进程不是一个进程组首进程，这是后面开启新会话的必备条件。因为它从父进程继承进程组号码，并且有自己的唯一进程号码，而进程号码和继承的进程组号码是不同的。

2. 子进程调用 `setsid()`开启一个新会话，并且释放和控制终端的所有联系。

3. 之后，如果守护进程永远不打开任何终端设备，那么不必担心守护进程重新获取控制终端；如果守护进程可能会打开一个终端设备，那么必须确保这个设备不会成为控制终端。可以用如下两种方式实现：

   * 在任何可能涉及到终端设备的 `open()` 调用中指定 `O_NOCTTY` 标志位。

   * 另外，更简单的，在调用 `setsid()` 之后执行第二次 `fork()`，让父进程退出子进程继续执行。这样可以确保子进程不是会话首进程，根据 System V 的控制终端获取规则，这个进程永远不能重新获取控制终端。

     > 在遵循 BSD 规则的实现中，一个进程要获取控制终端，只能通过显式地调用 `ioctl(fd, TIOCSCTTY)`。因此第二次 `fork()` 调用对获取控制终端没有任何影响，但是多一个 `fork()` 调用没有什么坏处。

4. 清除进程的 umask （通常置为 `0`）以确保当守护进程创建文件和目录时拥有需要的权限。

5. 修改进程的当前工作目录，通常设为根目录 */*。这么做是必要的，因为守护进程通常会一直运行直到系统关闭，如果守护进程的当前工作目录在不包含 */* 的文件系统，那么该文件系统无法卸载。或者，将工作目录设为指定的位置，并在此位置执行全部工作。比如 **cron** 把工作目录设在 */var/spool/cron*。

6. 关闭从父进程继承来的所有打开的文件描述符。（有时守护进程可能需要保持继承的文件描述符打开，因此这一步是可选的或者是可变更的）。因为守护进程丢失了控制终端并且运行在后台，让其保持文件描述符 `0` `1` `2` 打开没有什么意义，因为它们都是指向控制终端的。此外，我们无法卸载长时间运行的守护进程所在的文件系统。因此，通常的做法是关闭所有不用的打开的文件描述符，因为它们是有限的资源。

   > 可以使用 `open_max()` 或 `getrlimit()` 来判定文件描述符的最大值，并关闭直到该值的所有描述符。

7. 关闭了文件描述符 `0` `1` `2` 后，打开 */dev/null*，调用 `dup2()` （或类似的函数） 将这些文件描述符指向这个设备。这么做有两个原因：

   * 确保守护进程在调用基于这些文件描述符执行 I/O 库函数时不会出现意外的失败。

   * 防止守护进程后面使用描述符 `1` 或者 `2` 打开一个文件。

   > */dev/null* 是一个虚拟设备，它在写入数据时总是丢弃，读取数据时总是返回 `EOF` 。当我们想要删除一个 shell 的标准输入或者标准输出时，可以将它们重定向到该设备文件。   
   
###

## 实现守护进程函数

GNU C 提供了一个非标准的 `daemon()` 函数，调用时将程序变成一个守护进程。下面我们来实现这个守护进程函数。

###: int daemon()

```c
int daemon(int nochdir, int noclose);
```

<span>

```c
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>

int daemon(int nochdir, int noclose) {  
/* 成功返回 0，出错返回 -1 */
    int maxfd, fd;

    switch (fork()) {                    /* 转为后台运行 */
    case -1: return -1;
    case 0: break;
    default: _exit(EXIT_SUCCESS);       
    }

    if (setsid() == -1)                  /* 开启新会话，释放和控制终端的所有联系 */
        return -1;

    switch (fork()) {                    /* 确保进程不再是会话组长 */
    case -1: return -1;
    case 0: break;
    default: _exit(EXIT_SUCCESS);
    }

    umask(0);                            /* 清除 umask */

    if (!nochdir)          
        if (chdir("/") == -1)            /* 修改当前工作目录 */
            return -1;

    if (!noclose) {                     
        maxfd = sysconf(_SC_OPEN_MAX);
        if (maxfd == -1)
            return -1;
        for (fd = 0; fd < maxfd; fd++)
            close(fd);                   /* 关闭所有打开的文件描述符 */

        fd = open("/dev/null", O_RDWR);  /* 并把 0 1 2 重定向到 /dev/null */
        if (fd == -1)
            return -1;
        if (dup2(fd, STDIN_FILENO) != STDIN_FILENO)
            return -1;
        if (dup2(fd, STDOUT_FILENO) != STDOUT_FILENO)
            return -1;
        if (dup2(fd, STDERR_FILENO) != STDERR_FILENO)
            return -1;
    }

    return 0;                            /* 作为守护进程运行 */
}
```

###: proc daemon()

```nim
proc daemon*(nochdir = false, noclose = false)
```

<span>

```nim
import posix, os

when not defined(windows):
    import posix

    proc daemon*(nochdir = false, noclose = false) =
        case fork()                             # 转为后台运行
        of -1: raiseOsError(osLastError())
        of 0: discard
        else: quit(QuitSuccess)

        if setsid() == -1:                       # 开启新会话，释放和控制终端的所有联系
            raiseOsError(osLastError())

        case fork()                              # 确保进程不再是会话组长
        of -1: raiseOsError(osLastError())
        of 0: discard
        else: quit(QuitSuccess)

        discard umask(0);                        # 清除 umask

        if not nochdir:            
            if chdir("/") == -1:                 # 修改当前工作目录
                raiseOsError(osLastError())

        if not noclose:                    
            let maxfd = sysconf(SC_OPEN_MAX)
            if maxfd == -1: 
                raiseOsError(osLastError())
            for fd in 0..maxfd:
                discard close(cint(fd)) == -1    # 关闭所有打开的文件描述符

            let fd = open("/dev/null", O_RDWR);  # 并把 0 1 2 重定向到 /dev/null

            if dup2(fd, STDIN_FILENO) != STDIN_FILENO:
                raiseOsError(osLastError())
            if dup2(fd, STDOUT_FILENO) != STDOUT_FILENO:
                raiseOsError(osLastError())
            if dup2(fd, STDERR_FILENO) != STDERR_FILENO:
                raiseOsError(osLastError())
```

###

## 使用 syslog 记录守护进程的消息

当守护进程运行时，一个最大的问题就是显示消息。因为守护进程没有控制终端，无法像其它程序那样将消息打印到标准输出或者标准错误！因此，在守护进程中，记录消息最有效的方式就是写入文件，然后直接查看这个文件。然而，对于系统管理者来讲，为每一个守护进程创建并管理一个单独的消息文件很烦人。

从 4.2 BSD 开始，提供一个称为 [syslog](/docs/GNU C 标准库手册/Syslog.md) 的工具用来简化消息记录。所有从 BSD 派生的系统都支持该工具。

## 实现单实例守护进程

有些守护进程，为了确保对数据访问的安全，会实现为运行时只能存在一个实例。比如，一个守护进程需要访问文件系统，并且经常写入数据，多个实例同时运行就会造成写入的混乱。

[file locks](/docs/GNU C 标准库手册/File Locks.md) 可以为此提供一个互斥机制。当守护进程启动时创建一个关联的文件（名字一般是 {program name}.pid），并在该文件上加上一把写锁，之后企图再次启动该守护进程新的副本实例时都会失败。而在守护进程结束时，这把锁会自动清除。

###: int running()

```c
int running(const char *pathname, int mod);
```

<span>

```c
#include <stdio.h>
#include <fcntl.h>
#include <string.h>

int running(const char *pathname, int mod) { 
    int fd;
    char buf[16];

    fd = open(pathname, O_RDWR | O_CREAT, mod);
    if (fd == -1) {
        syslog(LOG_ERR, "can't open %s: %s", pathname, strerror(errno));
        exit(ExitFailure);
    }
    if (lockfile(fd) == -1) {
        if (errno == EACCES || errno == EAGAIN) {
            close(fd);
            return 1;
        }
        syslog(LOG_ERR, "can't lock %s: %s", pathname, strerror(errno));
        exit(ExitFailure);
    }
    ftruncate(fd, 0);
    sprintf(buf, "%ld", (long)getpid());
    write(fd, buf, strlen(buf)+1);
    return 0;
}
```

###: proc running()

```nim
proc running*(pathname: string, mod: cint): bool
```

<span>

```nim
import posix

proc lockfile(fd: cint): cint =
    var lock = Tflock(l_type: cshort(F_WRLCK),
                      l_whence: cshort(SEEK_SET),
                      l_start: Off(0),
                      l_len: Off(0)) 
    fcntl(fd, F_SETLK, addr(lock))

proc running*(pathname: string, mod: cint): bool =
    let fd = open(cstring(pathname), O_RDWR or O_CREAT, mod)
    if fd == -1:
        # TODO: 
        # let error = "can't open " & pathname & ": " & getCurrentExceptionMsg()
        # syslog(LOG_ERR, cstring(error))
        quit(QuitFailure)
    if lockfile(fd) == -1:
        if cint(osLastError()) in {EACCES, EAGAIN}:
            discard close(fd)
            return true
        # TODO: 
        # let error = "can't lock " & pathname & ": " & getCurrentExceptionMsg()
        # syslog(LOG_ERR, cstring(error))
        quit(QuitFailure)
    discard ftruncate(fd, Off(0))
    var spid = $getpid()
    discard write(fd, cstring(spid), len(spid))
    false

const LockFile = "/var/run/okdocd/okdocd.pid"
let   LockMode = S_IRUSR or S_IWUSR or S_IRGRP or S_IROTH
```

###

## 一个守护进程程序 

/home/king/nim/okdoc/okdocd.nim -> /home/king/nim/okdoc/bin/okdocd：

```nim
discard daemon(cint(0), cint(0))

if running():
    # TODO: 
    # let error = "daemon already running"
    # syslog(LOG_ERR, cstring(error))
    quit(QuitFailure)

# TODO:
# sigaction SIGHUP SIGTERM

while true:
    sleep(1000)
```

## 编写守护进程的自启动脚本

步骤如下：

1. 查看系统运行级别

       $ runlevel
       N 2

2. 添加自启动脚本，赋予权限

       $ sudo cp /home/king/nim/okdoc/startup.sh /etc/init.d/okdoc
       $ sudo chmod 755 /etc/init.d/okdoc

3. 添加符号链接，更新启动优先级

       $ update-rc.d okdoc start 98 2 3 4 5 . stop 98 0 1 6 .

4. 删除启动脚本
       
       $ update-rc.d -f s10 remove

脚本 /home/king/nim/okdoc/startup.sh -> /etc/init.d/okdoc：

```sh
#! /bin/sh
### BEGIN INIT INFO
# Provides:          okdocd
# Required-Start:    $syslog $remote_fs
# Required-Stop:     $syslog $remote_fs
# Should-Start:      $local_fs
# Should-Stop:       $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Markdown files server.    
# Description:       Markdown files server. 
### END INIT INFO

# Author: Wang Tong <iwangtongi@163.com>

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
NAME=okdoc
DAEMON=/home/king/Nutstore/okdoc/bin/okdocd
DAEMON_ARGS="--options args"
RUNDIR=/var/run/okdocd
PIDFILE=$RUNDIR/okdocd.pid
INITSCRIPT=/etc/init.d/$NAME

if [ ! -x "$DAEMON" ]
then
    echo "$DAEMON not exits"
    exit 1
fi

[ -r /etc/default/$NAME ] && . /etc/default/$NAME

. /lib/lsb/init-functions

set -e

case "$1" in
    start)
        echo -n "Starting $NAME: "
        mkdir -p $RUNDIR
        touch $PIDFILE
        chown king:king $RUNDIR $PIDFILE
        chmod 755 $RUNDIR

        if start-stop-daemon --start --quiet --pidfile $PIDFILE --exec $DAEMON -- $DAEMON_ARGS
        then
            echo "OK"
            log_end_msg 0 || true
        else
            echo "failed"
            log_end_msg 1 || true
        fi
        ;;
    stop)
        echo -n "Stopping $NAME: "
        if start-stop-daemon --stop --quiet --pidfile $PIDFILE --exec $DAEMON
        then
            echo "OK"
        else
            echo "failed"
        fi
        rm -f $PIDFILE
        sleep 1
        ;;
    restart|force-reload)
        ${0} stop
        ${0} start
        ;;
    status)
        echo -n "$NAME is "
        if start-stop-daemon --stop --quiet --signal 0 --exec $DAEMON --pidfile $PIDFILE
        then
            echo "running"
        else
            echo "not running"
            exit 1
        fi
    ;;
    *)
        echo "Usage: $INITSCRIPT {start|stop|restart|force-reload|status}" >&2
        exit 1
        ;;
esac

exit 0
```
