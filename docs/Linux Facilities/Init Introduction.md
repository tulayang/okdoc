
init (1) 进程是根进程，所有进程的祖先进程。

```
启动内核 --> /sbin/init(runlevel) --> .init 进程 --> init.d --> ln rc{level}.d
```

/etc/rc0.d，rc1.d，rc2.d，rc3.d，rc4.d，rc5.d，rc6.d，rcS.d<br />runlevel (操作系统当前运行的功能级别)： 

* 0 - 停止 （千万不要把 initdefault 设置为 0）  
* 1 - 单用户模式
* 2 - 多用户，没有 NFS
* 3 - 完全多用户模式(标准的运行级)
* 4 - 没有用到  
* 5 - X11 （xwindow) 
* 6 - 重新启动 （千万不要把 initdefault 设置为 6）

## 守护进程

### daemon

where: /sbin/start-stop-daemon

`start-stop-daemon --start --quiet --umask 007 --pidfile $PIDFILE --chuid king:king --exec $DAEMON`

### script

1. 编写脚本 /etc/init.d/mysql，修改属性 `$ sudo chmod x mysql`

2. 查看当前系统的启动级别 `$ runlevel`，创建符号链接

   * `$ ln -s /etc/init.d/mysql /etc/rc{level}.d/S20mysql` 
   * `$ update-rc.d mysql start 98 2 .`

3. 删除符号链接

   * `$ unlink -s /etc/rc{level}.d/S20mysql`
   * `$ update-rc.d -f s10 remove`

### command

    setsid firefox > /dev/null &
    setsid gnome-terminal 
           -x bash -c 
           "cd /usr/local/nim; echo a123456 | sudo -S git pull; ./koch boot -d:release"

## Upstart SysVInit

Upstart 的运作完全是基于工作和事件的。传统的 Linux 系统初始化是基于运行级别的，即 SysVInit。

有四个状态会引起 init 进程发送相应的事件，表明该工作的相应变化：

* Starting
* Started
* Stopping
* Stopped

而其它的状态变化不会发出事件。

![Upstart Job 的状态机](http://www.ibm.com/developerworks/cn/linux/1407_liuming_init2/image003.jpg)

### Upstart 启动过程

系统上电后运行 GRUB 载入内核。内核执行硬件初始化和内核自身初始化。在内核初始化的最后，内核将启动 pid 为 1 的 init 进程，即 UpStart 进程。

Upstart 进程在执行了一些自身的初始化工作后，立即发出"startup"事件。上图中用红色方框加红色箭头表示事件，可以在左上方看到"startup"事件。

所有依赖于"startup"事件的工作被触发，其中最重要的是 mountall。mountall 任务负责挂载系统中需要使用的文件系统，完成相应工作后，mountall 任务会发出以下事件：local-filesystem，virtual-filesystem，all-swaps，

其中 virtual-filesystem 事件触发 udev 任务开始工作。任务 udev 触发 upstart-udev-bridge 的工作。Upstart-udev-bridge 会发出 net-device-up IFACE=lo 事件，表示本地回环 IP 网络已经准备就绪。同时，任务 mountall 继续执行，最终会发出 filesystem 事件。

此时，任务 rc-sysinit 会被触发，因为 rc-sysinit 的 start on 条件如下：

```
start on filesystem and net-device-up IFACE=lo
```

任务 rc-sysinit 调用 telinit。Telinit 任务会发出 runlevel 事件，触发执行/etc/init/rc.conf。

rc.conf 执行/etc/rc$.d/目录下的所有脚本，和 SysVInit 非常类似。

![系统启动过程](http://www.ibm.com/developerworks/cn/linux/1407_liuming_init2/image004.png)

### Upstart 命令

作为系统管理员，一个重要的职责就是管理系统服务。比如系统服务的监控，启动，停止和配置。UpStart 提供了一系列的命令来完成这些工作。其中的核心是initctl，这是一个带子命令风格的命令行工具。

比如可以用 initctl list 来查看所有工作的概况：

```
$initctl list
alsa-mixer-save stop/waiting
avahi-daemon start/running, process 690
mountall-net stop/waiting
rc stop/waiting
rsyslog start/running, process 482
screen-cleanup stop/waiting
tty4 start/running, process 859
udev start/running, process 334
upstart-udev-bridge start/running, process 304
ureadahead-other stop/waiting
```

第一列是工作名，比如 rsyslog。第二列是工作的目标。第三列是工作的状态。

此外还可以用 initctl stop 停止一个正在运行的工作；用 initctl start 开始一个工作；还可以用 initctl status 来查看一个工作的状态；initctl restart 重启一个工作；initctl reload 可以让一个正在运行的服务重新载入配置文件。这些命令和传统的 service 命令十分相似。

service 命令和 initctl 命令对照表：

Service 命令 	| UpStart initctl 命令
----------------|---------------------
service start 	| initctl start
service stop 	| initctl stop
service restart | initctl restart
service reload 	| initctl reload 

很多情况下管理员并不喜欢子命令风格，因为需要手动键入的字符太多。UpStart 还提供了一些快捷命令来简化 initctl，实际上这些命令只是在内部调用相应的 initctl 命令。比如 reload，restart，start，stop 等等。启动一个服务可以简单地调用

```
start <job>
```

这和执行 initctl start <job>是一样的效果。

一些命令是为了兼容其它系统(主要是 sysvinit)，比如显示 runlevel 用/sbin/runlevel 命令：

```
$runlevel
N 2
```

这个输出说明当前系统的运行级别为 2。而且系统没有之前的运行级别，也就是说在系统上电启动进入预定运行级别之后没有再修改过运行级别。

那么如何修改系统上电之后的默认运行级别呢？

在 Upstart 系统中，需要修改/etc/init/rc-sysinti.conf 中的 DEFAULT_RUNLEVEL 这个参数，以便修改默认启动运行级别。这一点和 sysvinit 的习惯有所不同，大家需要格外留意。

还有一些随 UpStart 发布的小工具，用来帮助开发 UpStart 或者诊断 UpStart 的问题。比如 init-checkconf 和 upstart-monitor

还可以使用 initctl 的 emit 命令从命令行发送一个事件。

```
#initctl emit <event>
```

UpStart 的设计比 SysVInit 更加先进。多数 Linux 发行版上已经不再使用 SysVInit，一部分发行版采用了 UpStart，比如 Ubuntu；而另外一些比如 Fedora，采用了一种被称为 systemd 的 init 系统。