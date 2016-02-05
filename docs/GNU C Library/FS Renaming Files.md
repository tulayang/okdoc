# [重命名文件](https://www.gnu.org/software/libc/manual/html_node/Renaming-Files.html#Renaming-Files)	

你可以使用 `rename()` 重命名文件。

## API

###: #include &lt;stdio.h&gt;

```c
#include <stdio.h>
```

###: rename()

```c
int rename(const char *oldname, const char *newname);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`rename()` 函数重命名文件，`oldname` 变成 `newname`。`oldname` 和 `newname` 必须位于同一个文件系统。

有个情况非常特殊：`oldname` 和 `newname` 在调用 `rename()` 前是同一个文件的名字。比较一致的做法是：调用 `rename()` 会删除 `oldname`。但是，POSIX 规定 `rename()` 什么也不做，并且报告成功---这有点矛盾。我们不确定你的操作系统会如何处理。

如果 `oldname` 是目录，那么 `newname` 不能存在，或者 `newname` 是一个空目录。在后面的情况，空目录会被删除。当调用 `rename()` 时，`newname` 绝对不能是 `oldname` 的子目录。

`rename()` 一个很有用的特性是：重命名是一个原子操作。假如系统在重命名过程中崩溃，有可能两个名字都存在;并且，如果 `newname` 存在，它总是完整可用的。

执行成功返回 `0`，出错返回 `-1` 并设置 `errno` 值。相关的 `errno` 值包括文件名错误 [→ 文件名错误](/docs/GNU C 标准库手册/FS Introduction.md)，以及下面的几项：

* `EACCES` 对 `oldname` 所在的目录或 `newname` 所在的目录没有写权限;或者 `oldname` 和 `newname` 是目录，对它们没有写权限。

* `EBUSY` `oldname` 或 `newname` 正被系统使用，你不能删除它。比如文件名是文件系统的根目录。

* `ENOENT` 文件名不存在。

* `ENOTEMPTY` `EEXIST` 目录 `newname` 不是空的。这两个错误代码是相同的，有些系统用一个，有些系统用另一个。GNU/Linux 和 GNU/Hurd 总是用 `ENOTEMPTY`。

* `EINVAL` `newname` 是 `oldname` 的子目录。

* `EISDIR` `newname` 是目录，但是 `oldname` 不是目录。

* `EMLINK` `newname` 的父目录已经有太多的目录项。

* `ENOENT` `oldname` 不存在。

* `ENOSPC` `newname` 的父目录没有更多的空间添加目录项，而且文件系统没有空间可以扩充。

* `EROFS` 所在文件系统是只读的。

* `EXDEV` `oldname` 和 `newname` 位于不同的文件系统。 

