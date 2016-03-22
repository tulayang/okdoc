# [文件属性](https://www.gnu.org/software/libc/manual/html_node/File-Attributes.html#File-Attributes)

当你在 **shell** 发出 `$ ls -l filename` 命令时，它会为你报告文件的相关信息，包括：长度、属主、最后修改时间等等。这些信息，被称为文件属性。它们是和文件本身相关的，而不是和名字相关。

## 文件属性长啥样

当你读取文件的属性时，属性被放在一个结构体 `struct stat` 返回。本小节描述了这些属性的细节---名字、数据类型、表示什么意思。

###: #include &lt;sys/stat.h&gt; #include &lt;sys/types.h&gt;

```c
#include <sys/stat.h>
#include <sys/types.h>
```

文件属性使用的数据类型，一部分定义在 `<sys/stat.h>`，一部分定义在 `<sys/types.h>`。

###: struct stat

```c
struct stat
```

* Data Type

`struct stat` 用来包含文件属性的相关信息。它至少包括以下成员：

* `mode_t st_mode` 标志位，包含文件类型信息[→ 文件类型]()和访问权限[→ 访问权限]()。

* `ino_t st_ino` 文件编号（inode 编号），可以映射到文件的物理信息。

* `dev_t st_dev` 表示包含文件的设备。`st_ino` 和 `st_dev`，它们唯一地标识文件。不过，系统每次重启，`st_dev` 不一定是相同的。

* `nlink_t st_nlink` 硬链接数。每当有链接增加或删除，这个值都跟随加 `1` 或 减 `1`。如果这个值变为 `0`，文件会被彻底删除（如果有进程打开该文件，则删除被推迟，直到进程关闭该文件）。不会计算符号链接。

* `uid_t st_uid` 属主号。[→ 文件属主]()

* `gid_t st_gid` 组号。[→ 文件属主]()

* `off_t st_size` 对于普通文件，表示文件的字节长度。对于特殊设备，通常没有意义。对于符号链接，表示链接的文件名长度。

* `time_t st_atime` 上次访问时间。

* `unsigned long int st_atime_usec` 上次访问时间的小数部分。[→ 文件时间]()

* `time_t st_mtime` 上次修改内容的时间。

* `unsigned long int st_mtime_usec` 上次修改内容的时间的小数部分。

* `time_t st_ctime` 上次修改属性的时间。

* `unsigned long int st_ctime_usec` 上次修改属性的时间的小数部分。

* `blkcnt_t st_blocks` 文件占用的磁盘空间的块数，每个块是 `512bytes`。

  占用的块数，不是严格和文件长度成正比：文件系统可能使用一些块来做内部记录；文件可能含有“空洞”。

  你可以（近似的）判断文件是不是含有“空洞”：
  
  ```c
  (st.st_blocks * 512 < st.st_size)
  ```
  
  这个判断并不是非常完美，因为“空洞”比较小的情况可能会被判断比较大。对于实际的应用程序来说，这不是什么问题。

* `unsigned int st_blksize` 读写该文件的最佳（缓冲）块尺寸---以字节为单位。当你读写该文件时，你可以使用这个属性来指定缓冲区的大小。（它和 `st_blocks` 没啥关系，它是指缓冲区块，而不是磁盘块）。

> The Large File Support （LFS 大文件支持） 的扩展，使文件长度可以有 <code>2<sup>63</sup></code> 字节（哪怕是在 32 位系统）。这时候会需要 `struct stat64`。

###: struct stat64

```c
struct stat64
```

* Data Type

`struct stat64` 和 `struct stat` 有相同的成员，唯一的区别是 `st_ino`、`st_size`、`st_blocks` 的数据类型不同。

* `mode_t st_mode` 标志位，包含文件类型信息[→ 文件类型]()和访问权限[→ 访问权限]()。

* `ino64_t st_ino` 文件编号（inode 编号），可以映射到文件的物理信息。

* `dev_t st_dev` 表示包含文件的设备。`st_ino` 和 `st_dev`，它们唯一地标识文件。不过，系统每次重启，`st_dev` 不一定是相同的。

* `nlink_t st_nlink` 硬链接数。每当有链接增加或删除，这个值都跟随加 `1` 或 减 `1`。如果这个值变为 `0`，文件会被彻底删除（如果有进程打开该文件，则删除被推迟，直到进程关闭该文件）。不会计算符号链接。

* `uid_t st_uid` 属主号。[→ 文件属主]()

* `gid_t st_gid` 组号。[→ 文件属主]()

* `off64_t st_size` 对于普通文件，表示文件的字节长度。对于特殊设备，通常没有意义。对于符号链接，表示链接的文件名长度。

* `time_t st_atime` 上次访问时间。

* `unsigned long int st_atime_usec` 上次访问时间的小数部分。[→ 文件时间]()

* `time_t st_mtime` 上次修改内容的时间。

* `unsigned long int st_mtime_usec` 上次修改内容的时间的小数部分。

* `time_t st_ctime` 上次修改属性的时间。

* `unsigned long int st_ctime_usec` 上次修改属性的时间的小数部分。

* `blkcnt64_t st_blocks` 文件占用的磁盘空间的块数，每个块是 `512bytes`。

  占用的块数，不是严格和文件长度成正比：文件系统可能使用一些块来做内部记录；文件可能含有“空洞”。

  你可以（近似的）判断文件是不是含有“空洞”：
  
  ```c
  (st.st_blocks * 512 < st.st_size)
  ```
  
  这个判断并不是非常完美，因为“空洞”比较小的情况可能会被判断比较大。对于实际的应用程序来说，这不是什么问题。

* `unsigned int st_blksize` 读写该文件的最佳（缓冲）块尺寸---以字节为单位。当你读写该文件时，你可以使用这个属性来指定缓冲区的大小。（它和 `st_blocks` 没啥关系，它是指缓冲区块，而不是磁盘块）。

###: mode_t

```c
mode_t
```

* Data Type

`mode_t` 是一个整数类型，它是个标志位，表示访问权限。在 GNU C 库，它是个无符号类型，不窄于 `unsigned int`。

###: ino_t

```c
ino_t
```

* Data Type

`ino_t` 是一个无符号整数类型，表示文件编号（UNIX 术语也称为 inode 编号）。在 GNU C 库，它不窄于 `unsigned int`。

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，`ino_t` 被透明地替换为 `ino64_t`。

###: ino64_t

```c
ino64_t
```

* Data Type

`ino64_t` 是一个无符号整数类型，表示文件编号（UNIX 术语也称为 inode 编号），用于大文件模式。在 GNU C 库，它不窄于 `unsigned int`。

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，`ino_t` 被透明地替换为 `ino64_t`。

###: dev_t

```c
dev_t
```

* Data Type

`dev_t` 是一个算术类型，表示包含文件的设备号。在 GNU C 库，它是一个整数类型，不窄于 `int`。
  
###: nlink_t

```c
nlink_t
```

* Data Type

`nlink_t` 是一个整数类型，表示硬链接数。

###: blkcnt_t

```c
blkcnt_t
```

* Data Type

`blkcnt_t` 是一个有符号整数类型，表示块数。在 GNU C 库，它是一个整数类型，不窄于 `int`。

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，`blkcnt_t` 被透明地替换为 `blkcnt64_t`。

###: blkcnt64_t

```c
blkcnt64_t
```

* Data Type

`blkcnt64_t` 是一个有符号整数类型，表示块数，用于大文件模式。在 GNU C 库，它是一个整数类型，不窄于 `int`。

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，`blkcnt_t` 被透明地替换为 `blkcnt64_t`。   

###

## 如何读取文件属性

要查看文件属性，使用 `stat()`、`fstat()`、`lstat()`。它们返回一个 `struct stat` 对象。

###: #include &lt;sys/stat.h&gt;

```c
#include <sys/stat.h>
```

###: stat()

```c
int stat(const char *filename, struct stat *buf);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe | 
* Function

`stat()` 函数返回指定文件的属性。`filename` 是文件名，`buf` 是返回的属性对象。

如果 `filename` 是一个符号链接，返回的是链接指向的文件的属性。如果链接指向的文件不存在，则 `stat()` 失败并报告该错误。

执行成功返回 `0`，出错返回 `-1` 并设置 `errno` 值。相关的 `errno` 值包括文件名错误 [→ 文件名错误](/docs/GNU C 标准库手册/FS Introduction.md)，以及下面的几项：

* `ENOENT` 指定的文件不存在。

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，启用大文件模式，`stat()` 被透明地替换为 `stat64()`，
`struct stat` 被透明地替换为 `struct stat64`。

###: stat64()

```c
int stat64(const char *filename, struct stat64 *buf);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe | 
* Function

> `stat64()` 函数类似 `stat()` 函数。唯一的不同是：在 32 位系统，打开的文件使用“大文件模式”。在该模式下，文件的最大长度是 <code>2<sup>63</sup>bytes</code>，文件的偏移范围是 <code>-2<sup>63</sup></code> 到 <code>2<sup>63</sup></code>。

<span>

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，启用大文件模式，`stat()` 被透明地替换为 `stat64()`，
`struct stat` 被透明地替换为 `struct stat64`。

###: fstat()

```c
int fstat(int fd, struct stat *buf);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe | 
* Function

`fstat()` 函数类似 `stat()` 函数，除了传递的是文件描述符。

执行成功返回 `0`，出错返回 `-1` 并设置 `errno` 值。相关的 `errno` 值包括文件名错误 [→ 文件名错误](/docs/GNU C 标准库手册/FS Introduction.md)，以及下面的几项：

* `ENOENT` 指定的 `fd` 不是有效的文件描述符。

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，启用大文件模式，`fstat()` 被透明地替换为 `fstat64()`，
`struct stat` 被透明地替换为 `struct stat64`。

###: fstat64()

```c
int fstat64(int fd, struct stat64 *buf);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe | 
* Function

> `fstat64()` 函数类似 `fstat()` 函数。唯一的不同是：在 32 位系统，打开的文件使用“大文件模式”。在该模式下，文件的最大长度是 <code>2<sup>63</sup>bytes</code>，文件的偏移范围是 <code>-2<sup>63</sup></code> 到 <code>2<sup>63</sup></code>。文件描述符必须是通过 `open64()` 或 `creat64()` 创建。

<span>

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，启用大文件模式，`fstat()` 被透明地替换为 `fstat64()`，
`struct stat` 被透明地替换为 `struct stat64`。

###: lstat()

```c
int lstat(const char *filename, struct stat *buf);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe | 
* Function

`lstat()` 函数类似 `stat()` 函数。如果 `filename` 是符号链接，它返回的是符号链接自身的属性，而非指向的文件；
否则，和 `stat()` 相同。

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，启用大文件模式，`lstat()` 被透明地替换为 `lstat64()`，
`struct stat` 被透明地替换为 `struct stat64`。

###: lstat64()

```c
int lstat64(const char *filename struct stat64 *buf);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe | 
* Function

> `lstat64()` 函数类似 `lstat()` 函数。唯一的不同是：在 32 位系统，打开的文件使用“大文件模式”。在该模式下，文件的最大长度是 <code>2<sup>63</sup>bytes</code>，文件的偏移范围是 <code>-2<sup>63</sup></code> 到 <code>2<sup>63</sup></code>。

<span>

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，启用大文件模式，`lstat()` 被透明地替换为 `lstat64()`，
`struct stat` 被透明地替换为 `struct stat64`。   

###

## 文件类型（码）

存储在 `st_mode` 字段的值，包含两个信息：文件类型（码）和访问权限（位）。本小节只描述文件类型，当你了解之后，你会知道如何区分：普通文件、目录、符号链接、套接字等等。

###: #include &lt;sys/stat.h&gt;

```c
#include <sys/stat.h>
```

###: S_ISCHR()

```c
int S_ISCHR(mode_t m)
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Macro

如果是字符设备，返回 `非 0` -- 真。

###: S_ISBLK()

```c
int S_ISBLK(mode_t m)
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Macro

如果是块设备，返回 `非 0` -- 真。

###: S_ISDIR()

```c
int S_ISDIR(mode_t m)
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Macro

如果是目录，返回 `非 0` -- 真。

###: S_ISREG()

```c
int S_ISREG(mode_t m)
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Macro

如果是普通文件，返回 `非 0` -- 真。

###: S_ISFIFO()

```c
int S_ISFIFO(mode_t m)
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Macro

如果是 FIFO 或管道，返回 `非 0` -- 真。

###: S_ISLNK()

```c
int S_ISLNK(mode_t m)
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Macro

如果是符号链接，返回 `非 0` -- 真。

###: S_ISSOCK()

```c
int S_ISSOCK(mode_t m)
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Macro

如果是套接字，返回 `非 0` -- 真。

###: S_IFMT

```c
int S_IFMT
```

* Macro

> 为了兼容 BSD，还提供了一些非 POSIX 方法，用来判断文件类型。这个方法是：和 `S_IFMT` 按位与，从而提取出文件类型码，然后和定义的常量进程比较。

`S_IFMT` 是一个位掩码，用来提取模式值的文件类型码。

```c
S_ISCHR(mode)
```

等价于

```c
((mode & S_IFMT) == S_IFCHR)
```

文件类型码，其相关的符号如下所示：

* `S_IFCHR` 字符设备
* `S_IFBLK` 块设备
* `S_IFDIR` 目录
* `S_IFREG` 普通文件
* `S_IFLNK` 符号链接
* `S_IFIFO` FIFO 或管道
* `S_IFSOCK` 套接字

--------------------------------------

POSIX.1b 标准增加了一些对象，它们被实现为文件系统的对象。有消息队列、信号、共享内存对象。同时增加了它们对应的文件类型。要区分它们，必须使用下面的宏。

###: S_TYPEISMQ()

```c
int S_TYPEISMQ(struct stat *s)
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Macro

如果是消息队列对象，返回 `非 0` -- 真。

###: S_TYPEISSEM()

```c
int S_TYPEISSEM(struct stat *s)
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Macro

如果是信号对象，返回 `非 0` -- 真。

###: S_TYPEISSHM()

```c
int S_TYPEISSHM(struct stat *s)
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Macro

如果是共享内存对象，返回 `非 0` -- 真。   

###

## 属主和组

每个文件都有一个属主，属主是在系统中注册的用户。每个文件也有一个组。属主通常表示文件的作者，其主要目的是访问控制。

当创建一个新文件时，它的属主被设定为创建进程的有效用户号；它的组号被设定为创建进程的有效组号，或者父目录的组号---依赖当时的文件系统。当你访问远程文件系统时，这个规则由远程文件系统决定，而不是你所在的系统。

你可以使用 `chown()` 更改文件的属主和组。它是 **shell** 命令 `chown` 和 `chgrp` 的原型。

###: #include &lt;unistd.h&gt;

```c
#include <unistd.h>
```

###: chown()

```c
int chown(const char *filename, uid_t owner, gid_t group);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`chown()` 函数更改指定文件 `filename` 的属主和组。

在某些系统，更改属主，会清除 set-user-ID 和 set-group-ID 权限位。（这是因为：这些权限位可能不适合新的属主）。其他的权限位不会改变。

执行成功返回 `0`，出错返回 `-1` 并设置 `errno` 值。相关的 `errno` 值包括文件名错误 [→ 文件名错误](/docs/GNU C 标准库手册/FS Introduction.md)，以及下面的几项：

* `EPERM` 进程没有更改权限。

  只有特权用户或属主，可以更改组。在大多数文件系统，只有特权用户，可以更改属主；在个别文件系统，属主也可以更改属主。当你访问一个远程文件系统时，由远程文件系统决定。

* `EROFS` 所在的文件系统是只读的。

###: fchown()

```c
int fchown(int fd, uid_t owner, gid_t group);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function 

`fchown()` 函数类似 `chown()` 函数，除了指定参数是文件描述符 `fd`。

执行成功返回 `0`，出错返回 `-1` 并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 指定的 `fd` 不是有效的文件描述符。

* `EINVAL` 指定的 `fd` 是和管道或套接字相关的，不是普通文件。

* `EPERM` 进程没有更改权限。

  只有特权用户或属主，可以更改组。在大多数文件系统，只有特权用户，可以更改属主；在个别文件系统，属主也可以更改属主。当你访问一个远程文件系统时，由远程文件系统决定。

* `EROFS` 所在的文件系统是只读的。    

###

## 访问权限（位）

文件属性存储的 `st_mode` 字段，包含两个信息：文件类型（码）和访问权限（位）。本小节只描述访问权限位，它控制着能否读写文件。

> 在大多数系统，这些权限位的常量值是相同的，但是这并不可靠。不要在程序中直接写数字值！请使用权限位的符号，它们可移植性更好，并且更可读。

###: #include &lt;sys/stat.h&gt;

```c
#include <sys/stat.h>
```

###: S_IRUSR S_IREAD

```c
S_IRUSR
S_IREAD
```

* Macro

属主可读。在许多系统，这个位是 `0400`。`S_IREAD` 是过时的，主要用于兼容 BSD。

###: S_IWUSR S_IWRITE

```c
S_IWUSR
S_IREAD
```

* Macro

属主可写。在许多系统，这个位是 `0200`。`S_IWRITE` 是过时的，主要用于兼容 BSD。

###: S_IXUSR S_IEXEC

```c
S_IXUSR
S_IEXEC
```

* Macro

属主可执行或可搜索。在许多系统，这个位是 `0100`。`S_IEXEC` 是过时的，主要用于兼容 BSD。

###: S_IRWXU

```c
S_IRWXU
```

* Macro

等价于 `(S_IRUSR | S_IWUSR | S_IXUSR)`。

###: S_IRGRP

```c
S_IRGRP
```

* Macro

组可读。在许多系统，这个位是 `040`。

###: S_IWGRP

```c
S_IWGRP
```

* Macro

组可写。在许多系统，这个位是 `020`。

###: S_IXGRP

```c
S_IXGRP
```

* Macro

组可执行。在许多系统，这个位是 `010`。

###: S_IRWXG

```c
S_IRWXG
```

* Macro

等价于 `(S_IRGRP | S_IWGRP | S_IXGRP)`。

###: S_IROTH

```c
S_IROTH
```

* Macro

其他用户可读。在许多系统，这个位是 `04`。

###: S_IWOTH

```c
S_IWOTH
```

* Macro

其他用户可写。在许多系统，这个位是 `02`。

###: S_IXOTH

```c
S_IXOTH
```

* Macro

其他用户可执行。在许多系统，这个位是 `01`。


###: S_IRWXO

```c
S_IRWXO
```

* Macro

等价于 `(S_IROTH | S_IWOTH | S_IXOTH)`。

###: S_ISUID

```c
S_ISUID
```

* Macro

这是个执行位，表示 set-user-ID。在许多系统，这个位是 `04000`。

###: S_ISGID

```c
S_ISGID
```

* Macro

这是个执行位，表示 set-group-ID。在许多系统，这个位是 `04000`。

###: S_ISVTX

```c
S_ISVTX
```

* Macro

这是个粘着位。在许多系统，这个位是 `01000`。

粘着位，可以赋予目录一个权限，使目录里的文件只能由文件属主删除---你必须有目录的写权限，并且是文件的属主，才能删除文件。有一种情况除外：目录的属主可以删除里面的任何文件，不管文件的属主是谁。*/tmp* 目录正是这样设定的，任何人可以创建新文件，以及删除自己的文件，但是不能删除别人的文件。

最初，可执行文件的粘着位会修改系统的交换策略。通常，当程序终止时，它的页被立刻释放，并且可以重新使用。如果可执行文件设置了粘着位，内核会继续保留程序的页一段时间，好像程序仍然在运行似的。现代的操作系统已经不使用了。当程序终止时，它的页总是保留，直到缺少可用内存。当程序下一次运行时，它的页可能仍然在内核中。

对于部分现代的操作系统，粘着位对可执行文件已经没有意义，你不能对目录之外的设置粘着位。如果你这么做，`chmod()` 调用会失败，错误代码是 `EFTYPE`。

一些系统（特别是 SynOS），粘着位还有一个用处。如果非可执行文件设置了粘着位，它会有这样的作用：绝对不缓存此文件的页。这个功能，主要是用在 NFS 服务器---使用无盘客户机。这样做的目的是：把文件的页缓存到客户端内存。

> 可移植性注解：粘着位只能在 BSD 派生的系统上使用。因此，必须定义 `_GNU_SOURCE` 符号以启用粘着位。   


###

## 当你访问文件时，权限是如何被确定的

上面我们说到，内核如何确定一个文件的访问权限：通过进程的有效用户号和有效组号、辅助组号、属主、组和权限位。

如果进程的有效用户号和文件的属主匹配，那么进程可以获得属主对应的权限。同样地，如果进程的有效组号或辅助组号和文件的组匹配，那么进程可以获得组对应的权限。否则，进程获得其他用户对应的权限。

特权用户，比如 **root**，可以访问任何文件，不管权限位是什么。执行文件比较特殊---对于特权用户，至少设置了一个执行位，才能执行该文件。

## 设置访问权限

创建文件的原型函数（比如 `open()`、`mkdir()`），有一个 `mode` 参数，用于指定新文件的访问权限。实际创建之前，`mode` 会被进程的文件创建掩码 `umask` 修改。

`umask` 用来屏蔽掉设定的部分权限位。比如，当进程创建文件，`mode` 设置了所有的权限时，文件创建掩码可以帮你屏蔽掉你不想给予的权限。

更改文件的权限，使用 `chmod()` 函数。它指定权限位，并且忽略文件创建掩码。

通常，用户通过 **shell** 登录时，把文件创建掩码初始化为某个值（可以使用 `umask` 命令）。它会被所有的子进程继承。通常，应用程序不需要担心文件创建掩码。它会自动做它应该做的事。

当你的程序需要创建文件，并且想绕开 `umask` 时，最简单的方式是：调用 `open()` 打开文件后，调用 `fchmod()` 更改权限。事实上，文件创建掩码通常只在 **shell** 使用（通过 `umask()` 函数）。

###: #include &lt;sys/stat.h&gt;

```c
#include <sys/stat.h>
```

###: umask()

```c
mode_t umask(mode_t mask);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`umask()` 函数设置当前进程的文件创建掩码，返回之前的文件创建掩码。

这个有个例子，设定掩码，使其不屏蔽任何权限位：

```c
mode_t read_umask(void) {
    mode_t mask = umask(0);
    umask(mask);
    return mask;
}
```

###: chmod()

```c
int chmod(const char *filename, mode_t mode);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`chmod()` 函数设置指定文件 `filename` 的访问权限位 `mode`。

如果 `filename` 是个符号链接，`chmod()` 更改其链接的文件的权限，而不是符号链接本身。

执行成功返回 `0`，出错返回 `-1` 并设置 `errno` 值。相关的 `errno` 值包括文件名错误 [→ 文件名错误](/docs/GNU C 标准库手册/FS Introduction.md)，以及下面的几项：

* `ENOENT` 指定的 `filename` 不存在。

* `EPERM` 进程没有更改权限。

  只有特权用户或属主（根据进程的有效用户号），可以更改。

* `EROFS` 所在的文件系统是只读的。

* `EFTYPE` 指定的 `mode` 是 `S_ISVTX` --- 粘着位，但是 `filename` 不是目录。

###: fchmod()

```c
int fchmod(int fd, mode_t mode);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`fchmod()` 函数类似 `chmod()` 函数，除了指定文件描述符 `fd`。

执行成功返回 `0`，出错返回 `-1` 并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 指定的 `fd` 不是有效的文件描述符。

* `EINVAL` 指定的 `fd` 是和管道或套接字相关的，不是普通文件。

* `EPERM` 进程没有更改权限。

  只有特权用户或属主（根据进程的有效用户号），可以更改。

* `EROFS` 所在的文件系统是只读的。   

###

## 测试：是否对文件有访问权限？

可执行文件有一个 setuid 位，当启动文件时，进程的有效用户号被设置为可执行文件的属主。你可以使用 `setuid()` 或 `setgid()` 修改进程的有效用户号或组号。这样，程序就可以持有对应用户的权限---可以访问一些特殊的文件。然而，我们可能不想让程序的权限被肆无忌惮地利用---我们想要限制一下。

在程序读写一个文件前，我们可以检查下进程的实际用户---而不是有效用户，看看他是否有读、写、执行权限。调用 `access()` 函数就可以做到，它检查进程的实际用户号，而不是有效用户号。

###: #include &lt;unistd.h&gt;

```c
#include <unistd.h>
```

###: access()

```c
int access(const char *filename, int how);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`access()` 函数检查进程是否对指定的文件 `filename` 有访问权限 `how`。`how` 是标志位，可以是 `R_OK`、`W_OK`、`X_OK` 的按位或，也可以是 `F_OK`。

`access()` 的权限检查，使用的是进程的实际用户号和组号，而不是有效号。在一些场景，你的程序可能会调用 `setuid()` 或 `setgid()` 更改进程的用户号或组号（实际号 ---> 有效号），`access()` 可以给出执行程序的实际用户信息。

如果进程有指定的访问权限，返回 `0`；否则返回 `-1`。（也就是说，如果访问被拒绝，返回 `true`）。出错时也会返回 `-1` 并设置 `errno` 值。相关的 `errno` 值包括文件名错误 [→ 文件名错误](/docs/GNU C 标准库手册/FS Introduction.md)，以及下面的几项：

* `EACCES` 指定的 `how` 被拒绝。

* `ENOENT` 指定的 `filename` 不存在。

* `EROFS` 所在的文件系统是只读的。

###: R_OK

```c
int R_OK
```

* Macro

测试是否可读。

###: W_OK

```c
int W_OK
```

* Macro

测试是否可写。

###: X_OK

```c
int X_OK
```

* Macro

测试是否可执行或可搜索。

###: F_OK

```c
int F_OK
```

* Macro

测试文件是否存在。  

###

## 时间戳

每个文件有三个时间戳：上次访问时间、上次内容修改时间、上次属性修改时间，分别对应 `struct stat` 的 `st_atime`、`st_mtime`、`st_ctime` 字段。

所有这些时间是基于日历时间格式（`time_t`，定义在 `<time.h>`）[→ 日历时间]()。

读文件会更新它的上次访问时间，写文件会更新它的上次内容修改时间。当创建一个新文件时，其三个时间戳被设定为当时时间。另外，父目录的上次内容修改时间和上次属性修改时间也同时被更新为当时时间。

调用 `link()` 为文件添加一个新名字，会更新文件的上次属性修改时间，以及（新名字的）父目录的上次内容修改时间和上次属性修改时间。调用 `unlink()`、`remove()`、`rmdir()` 删除一个名字时，这些字段也同样受到影响。调用 `rename()` 重命名，只影响相关父目录的上次内容修改时间和上次属性修改时间---文件本身的属性不改变。

改变文件属性（比如 `chmod()`）会更新文件的上次属性修改时间。

你也可以调用 `utime()` 修改文件的时间戳---除了上次修改属性时间。

###: #include &lt;utime.h&gt;

```c
#include <utime.h>
```

###: struct utimbuf

```c
struct utimbuf
```

* Data Type

`struct utimbuf` 由 `utime()` 函数使用，指定新的上次访问时间和上次内容修改时间。包含以下两个字段：

* `time_t actime` 指定上次访问时间。

* `time_t modtime` 指定上次内容修改时间。

###: utime()

```c
int utime(const char *filename, const struct utimbuf *times);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`utime()` 函数修改指定文件 `filename` 的上次访问时间和上次内容修改时间。

如果 `times` 是一个空指针，上次访问时间和上次内容修改时间被修改为当前时间。否则，修改为 `times` 指定的字段值。

无论 `times`是否是空指针，上次属性修改时间都被修改为当前时间。

成功时返回 `0`；出错时也会返回 `-1` 并设置 `errno` 值。相关的 `errno` 值包括文件名错误 [→ 文件名错误](/docs/GNU C 标准库手册/FS Introduction.md)，以及下面的几项：

* `EACCES` 如果 `times` 是一个空指针，你必须是文件属主，或者对文件有写权限，或者是特权用户。

* `ENOENT` 指定的 `filename` 不存在。

* `EPERM` 如果 `times` 不是一个空指针，你必须是文件属主，或者是特权用户。

* `EROFS` 所在的文件系统是只读的。

这三个时间戳有一个对应的微秒扩展，可以增强其分辨率。扩展的字段分别是 `st_atime_usec`、`st_mtime_usec`、`and st_ctime_usec`，每个值在 `0` 到 `999,999`。它们是基于 `struct timeval` [→ 高分辨率日历时间]()。

###: #include &lt;sys/time.h&gt;

```c
#include <sys/time.h>
```

###: utimes()

```c
int utimes(const char *filename, const struct timeval tvp[2]);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`utimes()` 函数类似 `utime()` 函数，除了指定的时间是微秒。上次访问时间定义在 `tvp[0]`，上次内容修改时间定义在 `tvp[1]`。如果 tvp 是空指针，则修改为当前时间。

这个函数来自 BSD。返回值和错误参看 `utime()`。

###: lutimes()

```c
int lutimes(const char *filename, const struct timeval tvp[2]);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`lutimes()` 函数类似 `utimes()` 函数，但是对于符号链接文件，只会修改链接本身的时间戳（类似 `lstat()`），而 `utime()` 和 `utimes()` 则是修改链接的文件的时间戳。

这个函数来自 BSD，并非所有平台都支持（如果不支持，返回 `ENOSYS`）。返回值和错误参看 `utime()`。

###: futimes()

```c
int futimes(int fd, const struct timeval tvp[2]);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`futimes` 函数类似 `utimes()` 函数，除了指定文件描述符 `fd`。

这个函数来自 BSD。并非所有平台都支持（如果不支持，返回 `ENOSYS`）。

成功返回 `0`；出错返回 `-1` 并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EACCES` 如果 `times` 是一个空指针，你必须是文件属主，或者对文件有写权限，或者是特权用户。

* `EBADF` 指定的 `fd` 不是有效的文件描述符。

* `EPERM` 如果 `times` 不是一个空指针，你必须是文件属主，或者是特权用户。

* `EROFS` 所在的文件系统是只读的。   

###

## 文件长度

通常文件长度是自动维护的。文件从 `0` 开始，当写入时自动扩充。调用 `open()`、`fopen()` 把文件变为空的也是可行的。

不管怎样，有时候需要调整文件长度。调用 `truncate()`、`ftruncate()` 可以完成，它们是由 BSD Unix 引入的，后来被加入 POSIX.1。

一些操作系统允许你通过这些函数来制造“空洞”。当使用内存映射时，这很有用。

对非普通文件调用 `truncate()`、`ftruncate()` 会产生未知结果。在某些系统，什么都不做，只是返回成功。

###: #include &lt;unistd.h&gt;

```c
#include <unistd.h>
```

###: truncate()

```c
int truncate(const char *filename, off_t length);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`truncate()` 函数修改指定文件 `filename` 的长度。如果 `length` 小于之前的长度，后面的数据会被丢掉。如果 `length` 大于之前的长度，会在尾部扩充“空洞”---不过，有的系统不支持“空洞”，它们会保持长度未改变。

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，采用大文件模式，`truncate()` 函数实质上是 `truncate64()`，`off_t` 实质上是 `off64_t`。

成功时返回 `0`；出错时也会返回 `-1` 并设置 `errno` 值。相关的 `errno` 值包括文件名错误 [→ 文件名错误](/docs/GNU C 标准库手册/FS Introduction.md)，以及下面的几项：

* `EACCES` 指定的 `filename` 是目录或者不可写。

* `EINVAL` 指定的 `length` 是负数。

* `EFBIG` 文件长度已达系统上限。

* `EIO` 当执行 IO 时，出现硬件错误。

* `EPERM` 指定的 `filename` 是追加类型或不可变类型。

* `EINTR` 操作被一个信号中断。

###: truncate64()

```c
int truncate64(const char *name, off64_t length);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

> `truncate64()` 函数类似 `truncate()` 函数。唯一的不同是：在 32 位系统，打开的文件使用“大文件模式”。在该模式下，文件的最大长度是 <code>2<sup>63</sup>bytes</code>，文件的偏移范围是 <code>-2<sup>63</sup></code> 到 <code>2<sup>63</sup></code>。
<span>

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，`truncate()` 函数实质上是 `truncate64()` 函数，`off_t` 实质上是 `off64_t`。也就是说，使用 64 位文件长度和文件偏移，透明地替换掉旧的 API。 

###: ftruncate()

```c
int ftruncate(int fd, off_t length);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function 

`ftruncate()` 函数类似 `truncate()` 函数，除了指定文件描述符 `fd`。文件必须是写打开。

POSIX 标准并未规定 `length` 大于之前长度的情况。一些系统可能会用“空洞”扩充，一些系统则不会。因此，使用 `ftruncate()` 来增长文件长度是不可移植的。

`ftruncate()` 配合 `mmap()` 特别有用。因为映射区域必须是固定长度，不能通过写扩充文件长度。代替的是，用户应该自己扩充文件长度，并且使用新的长度重新映射。例子：

```c
int fd;
void *start;
size_t len;

int add(off_t at, void *block, size_t size) {
    size_t ps, ns;
    void *np;
    if (at + size > len) {
        /* Resize the file and remap.  */
        ps = sysconf(_SC_PAGESIZE);
        ns = (at + size + ps - 1) & ~(ps - 1);
        if (ftruncate(fd, ns) < 0) {
            return -1;
        }
        np = mmap(NULL, ns, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
        if (np == MAP_FAILED) {
            return -1;
        }
        start = np;
        len = ns;
    }
    memcpy((char *) start + at, block, size);
    return 0;
}
```

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，`ftruncate()` 函数实质上是 `ftruncate64()` 函数，`off_t` 实质上是 `off64_t`。也就是说，使用 64 位文件长度和文件偏移，透明地替换掉旧的 API。  

成功时返回 `0`；出错时返回 `-1` 并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 指定的 `fd` 不是有效的文件描述符。

* `EACCES` 指定的 `fd` 是目录或者不可写。

* `EINVAL` 指定的 `length` 是负数。

* `EFBIG` 文件长度已达系统上限。

* `EIO` 当执行 IO 时，出现硬件错误。

* `EPERM` 指定的 `fd` 是追加类型或不可变类型。

* `EINTR` 操作被一个信号中断。

###: ftruncate64()

```c
int ftruncate64 (int fd, off64_t length);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

> `ftruncate64()` 函数类似 `ftruncate()` 函数。唯一的不同是：在 32 位系统，打开的文件使用“大文件模式”。在该模式下，文件的最大长度是 <code>2<sup>63</sup>bytes</code>，文件的偏移范围是 <code>-2<sup>63</sup></code> 到 <code>2<sup>63</sup></code>。
<span>

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，`ftruncate()` 函数实质上是 `ftruncate64()` 函数，`off_t` 实质上是 `off64_t`。也就是说，使用 64 位文件长度和文件偏移，透明地替换掉旧的 API。   

###

## 存储预分配

大多数文件系统，支持用不连续的方式分配大文件：文本被拆分成片段，然后按顺序被分配，不过这些片段可以在磁盘上分散。文件系统通常会避免拆分，因为这样会降低性能，但是如果文件逐渐地增大长度，除了拆分没有更好的做法。另外，许多文件系统支持用“空洞”扩充文件---这些“空洞”不占用字节，也不会分配。当“空洞”被数据填充后，拆分也会随之发生。

显式地为文件尚未写的部分分配存储---预分配，可以帮助系统避免拆分。此外，如果预分配失败，可以早点报告 the out-of-disk error， often without filling up the entire disk。然而，由于存在重复删除数据、写时复制、文件压缩，预分配可能无法有效防止之后出现 the out-of-disk-space error。

###: #include &lt;unistd.h&gt;

```c
#include <unistd.h>
```

###: posix_fallocate()

```c
int posix_fallocate(int fd, off_t offset, off_t length);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`posix_fallocate()` 函数为指定的文件 `fd` 分配后备存储，从 `offset` 字节开始。如果必要的话，文件长度被增长到 `length + offset`。

`fd` 必须是一个普通文件，可写，否则返回 `EBADF` 错误。如果磁盘空间不足以满足分配，返回 `ENOSPC` 错误。

注意：如果 `fallocate()` 不可用（因为所在的系统不支持），`posix_fallocate()` 会仿真需要的操作，会有以下缺点：

* 比较低效，因为所有涉及到的文件系统块需要被检查，并且可能被重写。而支持 `fallocate()` 的文件系统，可以在内部直接检查，并且直接填充“空洞”。

* 如果另一个线程或进程修改同一个分配域，会存在条件竞争。

* 如果 `fd` 是通过 `O_APPEND` 打开的，分配可能会引起失败。

* If `length` is zero, `ftruncate()` is used to increase the file size as requested, without allocating file system blocks. There is a race condition which means that ftruncate can accidentally truncate the file if it has been extended concurrently. 

在 Linux 系统，如果应用程序不能通过仿真得到好处，或者仿真是有破坏的，应用程序可以使用 Linux 特有的 `fallocate()` 函数，设定标志位为 `0`。如果文件系统不支持预分配，`fallocate()` 不会执行仿真操作，而是返回 `EOPNOTSUPP` 错误。

###: posix_fallocate64()

```c
int posix_fallocate64(int fd, off64_t length, off64_t offset);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`posix_fallocate64()` 函数是 `posix_fallocate()` 函数的 64 位版本。

###