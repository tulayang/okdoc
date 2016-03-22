# [删除文件](https://www.gnu.org/software/libc/manual/html_node/Deleting-Files.html#Deleting-Files)

你可以使用 `unlink()` 或 `remove()` 删除文件。

删除，实际上只删除文件名。如果被删除的名字是唯一的文件名，那么文件会被彻底删除（如果有进程打开了这个文件，删除会被延迟，直到进程关闭文件）。如果文件还有其它的名字，那么文件会继续存在。

## API

###: #include &lt;unistd.h&gt;

```c
#include <unistd.h>
```

###: unlink()

```c
int unlink(const char *filename);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`unlink()` 函数删除指定的文件名 `filename`。

执行成功返回 `0`，出错返回 `-1` 并设置 `errno` 值。相关的 `errno` 值包括文件名错误 [→ 文件名错误](/docs/GNU C 标准库手册/FS Introduction.md)，以及下面的几项：

* `EACCES` 对文件名所在的目录没有写权限;或者目录有粘着位，你不是文件的属主。

* `EBUSY` 文件名正被系统使用，你不能删除它。比如文件名是文件系统的根目录。

* `ENOENT` 文件名不存在。

* `EPERM` 在某些系统，`unlink()` 不能用来删除目录名，或者只有特权用户才能删除目录名。避免这个问题，可以使用 `rmdir()` 删除目录名。（在 GNU/Linux 和 GNU/Hurd 系统，你无法通过 `unlink()` 删除目录名）。

* `EROFS` 文件名的目录位于一个只读文件系统，你不能修改它。

###: rmdir()

```c
int rmdir(const char *filename);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`rmdir()` 函数删除指定的文件名 `filename`，它必须是一个空目录---只能包含 *.* 和 *..* 目录项。

执行成功返回 `0`，出错返回 `-1` 并设置 `errno` 值。相关的 `errno` 值和 `unlink()` 相同，以及下面的：

* `ENOTEMPTY` `EEXIST` 目录不是空的。这两个错误代码是相同的，有些系统用一个，有些系统用另一个。GNU/Linux 和 GNU/Hurd 总是用 `ENOTEMPTY`。

###: #include &lt;stdio.h&gt;

```c
#include <stdio.h>
```

###: remove()

```c
int remove(const char *filename);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

> `remove()` 函数是一个 ISO C 标准定义的函数。它类似：`unlink()`，可以删除文件名; `rmdir()`，可以删除空目录。声明在头文件 `<stdlib.h>`。



