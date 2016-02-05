# [创建目录](https://www.gnu.org/software/libc/manual/html_node/Creating-Directories.html#Creating-Directories)

你可以使用 `mkdir()` 创建目录。

## API

###: #include &lt;sys/stat.h&gt;

```c
#include <sys/stat.h>
```

###: mkdir()

```c
int mkdir(const char *filename, mode_t mode);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`rename()` 函数创建一个新的、空的目录，名字是 `filename`。

`mode` 参数指定新目录的访问权限。[→ 访问权限]()

执行成功返回 `0`，出错返回 `-1` 并设置 `errno` 值。相关的 `errno` 值包括文件名错误 [→ 文件名错误](/docs/GNU C 标准库手册/FS Introduction.md)，以及下面的几项：

* `EACCES` 对 `filename` 所在的目录没有写权限。

* `EEXIST` `filename` 已经存在。

* `EMLINK` 父目录已经有太多的目录项。设计良好的文件系统不会报告这个错误，因为它们允许无限多的目录项，直到磁盘被塞满。然而，有些系统就说不定了，你最好注意着点。

* `ENOSPC` 文件系统没有足够的空间（创建新目录）。

* `EROFS` 父目录所在的文件系统是只读的。
