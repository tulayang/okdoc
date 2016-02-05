# [ioctl 控制输入输出的行为](https://www.gnu.org/software/libc/manual/html_node/IOCTLs.html#IOCTLs)

对大多数设备，有许多特殊的操作：

* 改变终端的字符字体
* 告诉磁带系统倒带或快进
* 弹出磁盘
* 使用 CD-ROM 播放音乐
* 维护网络路由表

它们需要特殊的处理。你可以通过 `ioctl()` 函数指定设备的特殊操作。

## API

###: #include &lt;sys/ioctl.h&gt;

```c
#include <sys/ioctl.h>
```

###: ioctl()

```c
int ioctl(int fd, int command, …);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`ioctl()` 函数对文件描述符 `fd` 执行 `command` 指定的通用 IO 操作。有些命令需要提供附加的参数。这些附加参数及其对应的返回值和错误，与 `command` 相关。

On some systems, IOCTLs used by different devices share the same numbers. Thus, although use of an inappropriate IOCTL usually only produces an error, you should not attempt to use device-specific IOCTLs on an unknown device. 

Most IOCTLs are OS-specific and/or only used in special system utilities, and are thus beyond the scope of this document. [→ 带外数据]()

> `ioctl()` 已被许多系统实现。

```c
int ret = ioctl(socket, SIOCATMARK, &atmark);
if (ret < 0)
    perror ("ioctl");
```