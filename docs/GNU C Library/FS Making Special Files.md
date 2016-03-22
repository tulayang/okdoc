# [创建特殊文件](https://www.gnu.org/software/libc/manual/html_node/Making-Special-Files.html#Making-Special-Files)

`mknod()` 函数是构建特殊文件的原型（比如设备文件）。GNU C 库包含了这个函数，以兼容 BSD。

## API

###: #include &lt;sys/stat.h&gt;

```c
#include <sys/stat.h>
```

###: mknod()

```c
int mknod(const char *filename, mode_t mode, dev_t dev);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`mknod()` 函数构建一个特殊的文件。`filename` 指定文件名；`mode` 指定文件模式，比如 `S_IFCHR` （字符设备文件）、`S_IFBLK` （块设备文件）[→ 文件类型]()； `dev` 指定相关的设备。

执行成功时返回 `0`；出错时返回 `-1` 并设置 `errno` 值。相关的 `errno` 值包括文件名错误 [→ 文件名错误](/docs/GNU C 标准库手册/FS Introduction.md)，以及下面的几项：

* `EPERM` 进程没有特权，只有超级用户才能创建特殊文件。

* `ENOSPC` 父目录满了，并且不能扩充。

* `EROFS` 所在的文件系统是只读的，父目录不能被修改。

* `EEXIST` 已经有一个 `filename`。如果你想指定 `filename`，先删除已经存在的。

