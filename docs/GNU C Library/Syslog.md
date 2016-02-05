
# [使用 syslog 记录消息](https://www.gnu.org/software/libc/manual/html_node/Syslog.html#Syslog)

许多系统有一个称为 syslog 的工具。它允许程序向管理员提交消息，而且可以配置成多样的提交方式。比如直接在控制台打印、用邮件发送给某个人，或者记录到一个日志文件作为备案。

## 概述

系统管理员需要对付大量不同分类的消息，这些消息都是来自各个子系统。比如：FTP 服务器在有连接请求时可能想要报告，内核遇到磁盘失败时可能想报告硬件故障，DNS 服务器可能想定期报告自己的监控状态。

这些消息，其中的一部分需要立刻通知管理员。当然，也可能不是管理员，而是主要负责相关事务的系统管理者。其它的一些消息可能只需要记录下来，以备将来查找问题。还有一些消息可能只是一些自动化程序的信息提取，用来生成月报。

### 系统支持

为了对付这么多消息，从 4.2 BSD 开始，提供一个称为 syslog 的工具来简化消息记录。所有从 BSD 派生的系统都支持该系统记录。Single UNIX Specification XSI 扩展包括了 syslog 函数。

### 组织结构

通常，它通过一个名为 **syslogd** 的守护进程来完成具体工作的。**syslogd** 通过名为 */dev/log* 的 UNIX domain 套接字监听消息请求。它的配置文件通常是 */etc/syslog.conf* 。其组织结构如下：

![syslog](/images/nicecodes/demo_daemon_syslog.png)

syslog 还能处理其它系统的消息。这是通过监听 UDP 端口（默认 534）来完成的。

syslog 可以处理来自内核的消息。不过内核的消息不是通过 */dev/log*，代替的是，另一个守护进程（有时称为 **klogd**）通过 */dev/klog* 来完成。

syslog 甚至能处理 **syslogd** 或者 **klogd** 运行之前内核发出的消息。比如，Linux 内核启动时会在一个消息循环中保存启动消息，之后 **klogd** 启动时这些启动消息往往还存在。假设 **klogd** 启动的时候 **syslogd** 已经运行了，**klogd** 会作为中介把这些启动消息传送给 **syslogd**。

### 写入消息的方式

1. 内核例程调用 `log()` 函数，通过设备 */dev/klog* 写入消息。
2. 用户进程调用 `syslog()` 函数，通过设备 */dev/log* 写入消息。
3. 通过 UDP 端口 514 发送网络消息。

### 一些比较流行的消息处理方式

* 写入系统控制台
* 用邮件发送给用户
* 写入日志文件
* 传送给其它守护进程
* 丢弃

### 消息分类

为了把消息分类处理，syslog 需要进程在提交消息时指定两个分类消息标记：

* facility

  标明谁提交消息。已经定义了一些可提交的设施。常见的有内核、邮件系统、FTP 服务器。

* priority

  设定消息内容的重要程度（优先级）。一些已定义的优先级例子：debug（调试）、informational（信息）、warning（警告）、critical（临界消息）。

  Warning: This terminology is not universal. Some people use “level” to refer to the priority and “priority” to refer to the combination of facility and priority. A Linux kernel has a concept of a message “level,” which corresponds both to a Syslog priority and to a Syslog facility/priority (It can be both because the facility code for the kernel is zero, and that makes priority and facility/priority the same value). 

### syslog-ng 和 rsyslog 工具

syslog-ng 和 rsyslog 是 syslog 的进化版本，它们提供 syslog 的基础功能并且提供了额外的扩展功能。比如支持正则表达式，提供更多的过滤选择，支持把消息转发到多种目的地，等等。本章节在此只简单介绍下 rsyslog，如果你使用较新的 RedHat 或者 Ubuntu 系统的话，可能默认就是 rsyslog。

rsyslog 号称提供了高性能、强安全性和模块化设计，自称是消息日志的瑞士军刀 （[官方文档](http://www.rsyslog.com/doc)）。它是作为 **syslogd** 的透明替代者运行的，守护进程是 **rsyslogd**，遵照守护进程的管理惯例 `$ sudo service rsyslog {action}`，其中 {action} 分别是 start、stop、restart、status、force-reload、... 

rsyslog 的配置文件是 */etc/rsyslog.conf*，*/etc/rsyslog.d/50-default.conf* 则定义了默认规则（包括消息存储路径）。存储的每条消息按照行保存，举例：

```log
Dec 12 22:44:19 king-PC dnsmasq[2008]: using nameserver 192.168.0.1#53
```

rsyslog 的功能结构图如下所示：

![功能结构](/images/nicecodes/syslog_rsyslog_sheme.png)

### logger 命令

**logger** 是一个操作 syslog 调用的控制台命令，通过它提供的命令参数，用户可以在 shell 直接操作 syslog。通过 `$ logger --help` 查看该命令的详细介绍。

### 如何操作

GNU C 库提供了向 syslog 提交消息的函数。它们通过路径 */dev/log* 的套接字写入消息。GNU C 库提供的这些函数，只能用在同一个系统上的进程提交消息给 syslog。想要在其它系统上的进程提交消息给（本系统的） syslog，需要通过连接（本系统的） syslog UDP 端口来发送网络消息。

###

## API

###: #include &lt;syslog.h&gt;

```c
#include <syslog.h>
```

###: openlog()

```c
void openlog(const char *ident, int options, int facility);
```

* MT-Safe | AS-Unsafe lock | AC-Unsafe lock fd

打开或者重新打开并连接 syslog。如果调用 `syslog()` 前没有调用 `openlog()`，`syslog()` 内部会自动调用 `openlog()`，并使用默认的源名字和配置选项。  

`ident` 指定消息源，通常设为程序名字。如果置为 `NULL`，则源名字会被设定为程序名字，即 `argv[0]`。

注意，syslog 例程内部只复制该字符串指针的引用（出于性能考虑，不会复制该字符串）。只要程序后面继续调用 `syslog()`，就要确保不会修改该字符串指针。如果你想改变源名字，必须再次调用 `openlog()`；重写该字符串指针是非线程安全的。 

如果你调用了 `openlog()`，那么在该字符串指针被释放前必须调用 `closelog()`。例子：

```c
void shared_library_function(void) {
    openlog("mylibrary", option, priority);
    syslog(LOG_INFO, "shared library has been invoked");
    closelog();
}
```

如果你没有调用 `closelog()`，那么就祈祷应用程序不会发生崩溃吧。

`options` 配置选项，标志位 (OR)：

options | 描述
------| ----
LOG_PERROR  |  如果开启，syslog 在每次提交消息时同时打印到标准错误。【可移植：Solaris 不可用】
LOG_CONS    |  如果开启，syslog 在提交消息失败时会打印到系统控制台 */dev/console*。
LOG_PID     |  如果开启，syslog 在每次提交消息时插入进程的号码。
LOG_ODELAY  |  连接到 syslog 的操作会被推迟，直到提交第一条消息。默认行为，无需指定。    
LOG_NDELAY  |  如果开启，则不推迟，而是立刻打开到 syslog 的连接（即 */dev/log* 域套接字）。对于需要精确控制何时分配连接文件描述符的程序很有帮助。【可移植：在早期的系统，这个位的值刚好是相反的】
LOG_NOWAIT  |  在一些通过创建子进程提交消息的程序，调用者创建并等待（`wait()`）子进程时需要使用 `LOG_NOWAIT`，这样 `syslog()` 就不会等待已被调用者销毁的子进程。在 Linux 上，`LOG_WAIT` 不起任何作用，因为提交消息时不会创建子进程。

`openlog()` 是否打开到 *dev/log* 的套接字，依赖 `options` 选项。如果这么做了，它会尝试以流套接字的方式打开并连接该路径；如果不这么做，它会尝试以数据报套接字的方式打开并连接该路径。这个套接字具备 close-on-exec，因此当进程执行 `exec` 时内核会关闭它。

`facility` 指定消息源的类型，syslog 将对不同的源进行不同的处理。如果不调用 `openlog()`，或者将其置为 `0`，则调用 `syslog()` 时，可以将 `facility` 作为 `priority` 参数的一部分进行说明。

> Single UNIX Specification v3 只定义了所有参数的一个子集。 

调用 `syslog()` 将会提交一条消息，其 `priority` 参数是 `facility` 和 `level` 的组合。它们的值如下所示（`0` 表示默认值，即 `LOG_USER`）：

facility     | SUSv3 |               描述   
------------ | ----- |   --------------------------------------------------
LOG_AUTH     |   ✔   |   安全和验证消息（比如 **su**）               
LOG_AUTHPRIV |       |   私有的安全和验证消息，当需要将含有密码和敏感信息的消息记录到和 `LOG_AUTH` 不同的位置时，很有用 
LOG_CRON     |   ✔   |   来自 **cron** 和 **at** 守护进程的消息          
LOG_DAEMON   |   ✔   |   来自其它系统守护进程的消息                   
LOG_FTP      |       |   来自 FTP 守护进程的消息（比如 **ftpd**）
LOG_KERN     |   ✔   |   内核消息（用户进程无法提交此类消息）          
LOG_LOCAL0~7 |   ✔   |   保留，本地使用                            
LOG_LPR      |   ✔   |   来自行打印机系统的消息（比如 **lpr**、**lpd**、**lpc**） 
LOG_MAIL     |   ✔   |   来自邮件系统的消息                        
LOG_NEWS     |   ✔   |   与 Usenet 网络新闻相关的消息              
LOG_SYSLOG   |       |   来自 **syslogd** 守护进程的消息 
LOG_USER     |   ✔   |   来自用户进程的消息（默认值）               
LOG_UUCP     |   ✔   |   来自 UUCP 系统的消息      

level      |                 描述
---------  |     ----------------------------------
LOG_EMERG  |     紧急或令人恐慌的情况（系统不可用）  
LOG_ALERT  |     需要立即处理的情况（比如破坏了系统数据库）   
LOG_CRIT   |     关键情况（比如磁盘发生错误）
LOG_ERR    |     常规错误情况
LOG_WARNING|     警告
LOG_NOTICE |     可能需要特殊处理的普通情况
LOG_INFO   |     情报性消息
LOG_DEBUG  |     调试消息

If a Syslog connection is already open when you call openlog, openlog “reopens” the connection. Reopening is like opening except that if you specify zero for the default facility code, the default facility code simply remains unchanged and if you specify LOG_NDELAY and the socket is already open and connected, openlog just leaves it that way.


###: syslog()

```c
void syslog(int priority, const char *format, ...);
```

* MT-Safe env locale | AS-Unsafe corrupt heap lock dlopen | AC-Unsafe corrupt lock mem fd 

提交消息到 syslog，是基于把消息写入 UNIX domain socket */dev/log* 完成的。如果调用 `syslog()` 前没有调用 `openlog()`，它内部会自动调用 `openlog()` 并设定默认参数。

`priority` 是 `facility` 和 `level` 参数的组合，详情参照 `openlog()` 文档说明。

`format` 是格式化字符串以及响应的参数，类似 `printf()` 中的参数。不同的是，这里的字符串不需要在尾部包含一个换行字符；此外，可以包含双字符序列 `%m`，在调用的时候会与当前 `errno` 值对应的错误字符串替换（等价于 `strerror(errno)`）。例子：

```c
openlog(argv[0], LOG_PID | LOG_CONS | LOG_NOWAIT, LOG_LOCAL0);
syslog(LOG_ERR, "Bad argument: %s", argv[1]);  // 默认使用 `facility = LOG_LOCAL0`
syslog(LOG_USER | LOG_INFO, "Exiting");        // 显式指定 `facility = LOG_USER` （覆盖）
```

<span>

```c
警告！！！

syslog(priority, user_string);

上面的例子，直接写入用户提供的字符串，会面临格式字符串攻击！！！从安全角度，这种攻击可能极具破坏性。应该将上面的代码重写为下面这样：

syslog(priority, "%s", user_string);
```

除了 `syslog()`，很多平台还提供其变体 `vsyslog(int priority, const char *format, va_list args)`。但是 Single UNIX Specification 并没有包含，使用的时候可能需要定义额外的符号。比如，在 FreeBSD 中定义 `__BSD_VISIBLE`，在 Linux 中定义 `__USE_BSD`。

大多数 syslog 实现将消息短时间放入队列中，如果此段时间有重复消息到达，那么 **syslogd** 守护进程不会把它写到日志文件，而是简单的打印一条消息：“上一条消息重复了 N 次”。

###: closelog()

```c
void closelog(void);
```

* MT-Safe | AS-Unsafe lock | AC-Unsafe lock fd

关闭当前到 syslog 的连接，释放分配到 */dev/log* 的套接字描述符。`closelog()` 不会冲洗任何缓冲。此外，调用 `openlog()` 重打开到 syslog 的连接时不需要先调用 `closelog()`。`openlog()` 会自动的关闭连接并重新打开。

如果你在为 syslog 写一个共享库，那么在调用 `openlog()` 之后，应该调用 `closelog()` 释放相应的资源。

> 守护进程通常会持续保持和系统日志的连接状态，所以常常省略对 `closelog()` 的调用。

###: setlogmask()

```c
int setlogmask(int maskpri);
```

* MT-Unsafe race:LogMask | AS-Unsafe | AC-Safe

设置消息的过滤掩码。如果程序没有调用 `setlogmask()`，那么 syslog 不会忽略任何提交。设置过滤掩码有点类似 syslog 配置文件的作用。但是 syslog 配置文件是使 syslog 丢弃接收到的特定消息，而过滤掩码则是不发送特定消息到 syslog。

设置过滤掩码后，如果提交的消息其 `level` 不在当前掩码设置中，它就会被丢弃。宏 `LOG_MASK()` （SUSv3 定义） 会将 `level` 值转换为合适的值传递给 `setlogmask()`。例子：

```c
setlogmask(LOG_MASK(LOG_EMERG) | LOG_MASK(LOG_ALERT) | 
           LOG_MASK(LOG_CRIT)  | LOG_MASK(LOG_ERR));
```

注意：设置过滤掩码，和连接 syslog 是两个完全独立的操作。

###