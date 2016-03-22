# [符号链接](https://www.gnu.org/software/libc/manual/html_node/Symbolic-Links.html#Symbolic-Links)

符号链接，本质上是一个指针，指向另一个文件名。当对目录创建硬链接、以及通过硬链接访问文件时，需要超级用户权限;符号链接不需要这些限制。你可以创建一个无效的符号链接，它指向的文件名，是一个不存在的文件（打开这个链接会失败，直到该指向的文件被创建）。此外，如果符号链接指向一个存在的文件，之后删除这个文件，该符号链接仍然指向原有的文件名，尽管该文件名对应的文件不存在。	

符号链接，可以跨越不同的文件系统。每个符号链接有自己的 inode 和数据块。比起硬链接，符号链接带来更多的开销，因为解析符号链接需要解析两个文件：符号链接本身和链接指向的文件。

## API 

###: #include &lt;sys/param.h&gt;

```c
#include <sys/param.h>
```

###: MAXSYMLINKS

```c
int MAXSYMLINKS
```

* Macro

指定符号链接的上限。

###: #include &lt;unistd.h&gt;

```c
#include <unistd.h>
```

###: symlink()

```c
int symlink(const char *oldname, const char *newname);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`symlink()` 函数创建一个新的符号链接。`oldname` 指定已有的文件名，`newname` 指定新的文件名。

执行成功返回 `0`；出错返回 `-1` 并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EEXIST` 名字 `newname` 已经存在了。如果你想替换，必须先将其删除。

* `EROFS` 名字 `newname` 位于只读的文件系统。

* `ENOSPC` 目录或文件系统包含的链接数满了，不能再扩充。

* `EIO` 当尝试读写文件系统时，出现硬件错误。

###: readlink()

```c
ssize_t readlink(const char *filename, char *buffer, size_t size);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`readlink()` 函数读取符号链接 `filename` 的内容，将其存储到 `buffer`。

执行成功返回读取的字节数；出错返回 `-1` 并设置 `errno` 值。相关的 `errno` 值包含在文件名错误[文件名错误]()，以及下面的两项：

* `EINVAL` 指定的 `filename` 不是一个有效的符号链接。

* `EIO` 当尝试读写文件系统时，出现硬件错误。

例子：

```c
char *readlink_malloc(const char *filename) {
    int size = 100;
    char *buffer = NULL;

    for (;;) {
        buffer = (char *) xrealloc(buffer, size);
        int nchars = readlink(filename, buffer, size);
        if (nchars < 0) {
            free(buffer);
            return NULL;
        }
        if (nchars < size)
            return buffer;
        size *= 2;
    }
}
```

###: #include &lt;stdlib.h&gt;

```c
#include <stdlib.h>
```

###: canonicalize_file_name()

```c
char *canonicalize_file_name(const char *name);
```

* Preliminary: | MT-Safe | AS-Unsafe heap | AC-Unsafe mem fd |
* Function

`canonicalize_file_name()` 函数返回相对路径名 `name` 的绝对路径名。`name` 不能包含 .、..，不能包含重复的 /，也不能包含符号链接。返回值存储在 `malloc()` 分配的内存空间！如果返回值不再需要，你应该使用 `free()` 将其释放！

如果出现错误，返回一个空指针，并设置 `errno` 值。相关的 `errno` 值如下所示：	 

* `ENAMETOOLONG` 返回值太长了。这个错误，只会在部分系统中出现，它们要求文件名长度有上限。

* `EACCES` 路径名组件中，有的不可读。

* `ENOENT` 路径名组件中，有的不存在。 

* `ELOOP` More than `MAXSYMLINKS` many symlinks have been followed

> `canonicalize_file_name()` 函数是一个 GNU 扩展，声明在头文件 `<stdlib.h>`。

###: realpath()

```c
char *realpath(const char *restrict name, char *restrict resolved);
```

* Preliminary: | MT-Safe | AS-Unsafe heap | AC-Unsafe mem fd | 
* Function

当指定 `resolved = NULL` 时，`realpath()` 函数等同于 `canonicalize_file_name()` 函数。函数为结果值分配缓冲区，并将其作为一个指针返回。你可以指定 `resolved` 为一个缓冲区，结果值会被存储在 `resolved`，并返回其指针。在有些系统，文件名长度有上限---定义在 `PATH_MAX`，则 `resolved` 的长度至少是 `PATH_MAX`。对于文件名长度没有上限的系统，你只应该把 `resolved` 指定为 `NULL`。

如果 `realpath()` 执行失败，返回一个空指针，并设置 `errno` 值。当你已经指定 `resolved` 是一个缓冲区时，如果 `errno` 值是 `EACCES` 或 `ENOENT`，`resolved` 可能会存储了部分路径。

> `realpath()` 函数是一个 UNIX 标准，声明在头文件 `<stdlib.h>`。

