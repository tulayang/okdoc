# [访问目录](https://www.gnu.org/software/libc/manual/html_node/Accessing-Directories.html#Accessing-Directories)

本节描述的工具，可以使你读目录文件的内容。当你想在程序中列出目录项时，这会非常有用。

`opendir()` 函数打开一个目录流，它的成员是目录项。`fdopendir()` 函数和 `opendir()` 函数差不多，但是它能让你更精细的控制读目录。

`readdir()` 函数通过目录流检索目录项，并用 `struct dirent` 对象来表示它们。每个目录项的名字，存储在 `d_name` 字段中。

## 目录项

本小节描述了目录项的表示对象，当你通过目录流检索目录项时你会用到它。

###: #include &lt;dirent.h&gt;

```c
#include <dirent.h>
```
###: struct dirent

```c
struct dirent {
    ino_t          d_fileno;         // inode 编号
    unsigned char  d_type;           // 文件类型
    off_t          d_off;            // 目录偏移量
    unsigned short d_reclen;         // 记录长度
    ...
    char           d_name[];         // 目录项的名字
};
```

* Data Type

这个结构类型用于表示目录项的信息。它包含的字段有：

* `char d_name[]`

  文件名组件（跟随一个终止符）。这个字段是唯一一个可以在 POSIX 系统上可靠使用的。

* `ino_t d_fileno`

  inode 编号。如果要兼容 BSD，你可以用 `d_ino`。在 GNU/Linux 和大多数 POSIX 系统，`stat()` 函数返回的文件信息结构 `struct stat` 中的 `st_ino` 和 `d_fileno` 是相同的含义，它们都表示文件的 inode 编号。

* `unsigned char d_namlen`
  
  文件名的长度（不包含终止符）。这个字段是 BSD 扩展，定义符号 `_DIRENT_HAVE_D_NAMLEN` 以启用这个字段。

* `unsigned char d_type`
  
  文件类型（可能是未知的）。这个字段是 BSD 扩展，定义符号 `_DIRENT_HAVE_D_TYPE` 以启用这个字段。在系统启用 `d_type` 的情况下，`struct stat` 结构中的 `st_mode` 和 `d_type` 是相同的含义，它们都表示文件类型。

  其相关的常量值如下：

  * `DT_UNKNOWN` 未知类型---只有部分文件系统，完全支持返回具体的文件类型，其他的可能总是返回这个值
  * `DT_REG` 普通文件
  * `DT_DIR` 目录
  * `DT_FIFO` 命名管道，或 FIFO
  * `DT_SOCK` 本地域套接字
  * `DT_CHR` 字符设备
  * `DT_BLK` 块设备
  * `DT_LNK` 符号链接

`struct dirent` 未来可能会增加新的字段，字段的启用，总是通过在编译期定义符号名 `_DIRENT_HAVE_D_xxx`---xxx 是字段的名字。比如，启用字段 `d_reclen`，你应该定义符号 `_DIRENT_HAVE_D_RECLEN`。

当一个文件有多个名字时，每个名字是一个独立的目录项。如果多个目录项有相同的 `d_fileno`，则它们属于同一个文件。

###: IFTODT()

```c
int IFTODT(mode_t mode);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

返回 `mode` 对应的 `d_type` 值。

###: DTTOIF()

```c
mode_t DTTOIF(int dtype);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

返回 `dtype` 对应的 `st_mode` 值。      

###

## 打开、读取、关闭目录流

本小节描述了如何打开一个目录流，然后读取、关闭。

###: #include &lt;dirent.h&gt;

```c
#include <dirent.h>
```

###: DIR

```c
DIR
```

* Data Type

`DIR` 表示一个目录流。

一定不要直接对 `struct dirent` 或 `DIR` 分配内存，目录访问函数不支持这样做。你应该使用下面的函数，为你生成指针，作为对目录流的引用。

###: opendir()

```c
DIR *opendir(const char *dirname);
```

* Preliminary: | MT-Safe | AS-Unsafe heap | AC-Unsafe mem fd |
* Function

`opendir()` 打开一个目录流，并返回对目录流的引用。`dirname` 指定目录文件的名字。

如果执行失败，返回一个空指针，并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EACCES` 对指定的目录，没有读权限。

* `EMFILE` 进程打开的文件已达上限。

* `ENFILE` 文件系统当前不支持多个打开。

* `ENOMEM` 没有足够的可用内存。

`DIR` 类型基于文件描述符实现，`opendir()` 函数基于 `open()` 函数基础实现。当执行 `exec()` 产生子进程时，目录流和底层的文件描述符会被关闭。

###: fdopendir()

```c
DIR *fdopendir(int fd);
```

* Preliminary: | MT-Safe | AS-Unsafe heap | AC-Unsafe mem fd |
* Function

`fdopendir()` 函数和 `opendir()` 函数很相似，只不过它是指定一个文件描述符 `fd` 来创建目录流。

你必须确保文件描述符是和目录相关的，并且有读权限。

执行成功时，返回目录流的引用。当你在使用这个目录流的期间，一定不要关闭文件描述符 `fd`。 

执行失败时，返回一个空指针，并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 指定的 `fd` 不是有效的文件描述符。

* `ENOTDIR` 指定的 `fd` 不是和目录相关的。

* `EINVAL` 指定的 `fd` 没有读权限。

* `ENOMEM` 没有足够的可用内存。

###: dirfd()

```c
int dirfd(DIR *dirstream);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`dirfd()` 函数返回目录流的底层文件描述符。你可以一直使用这个描述符，直到调用 `closedir()` 关闭目录流。如果指定的目录流，其实现不是基于文件描述符的，返回 `-1`。

###: readdir()

```c
struct dirent *readdir(DIR *dirstream);
```

* Preliminary: | MT-Unsafe race:dirstream | AS-Unsafe lock | AC-Unsafe lock |
* Function

`readdir()` 读取目录项列表的下一个。通常返回一个指针，里面包含了文件的相关信息。

如果没有更多的目录项，或者执行失败时，返回一个空指针。执行失败时设置 `errno` 值。相关的 `errno` 值如下所示：

* `EBADF` 指定的 `dirstream` 不是有效的目录流。

> 可移植性注解：在一些系统，`readdir()` 可能不会返回 *.* 和 *..*，尽管它们是有效的文件名。

没有更多的目录项，和执行失败，都返回空指针。要区分它们，你必须在调用 `readdir()` 前把 `errno` 置为 `0`，在调用后检查 `errno` 值是否改变。

> 在 POSIX.1-2008 标准中，`readdir()` 是线程不安全的。在 GNU C 库的实现中，多线程调用 `readdir()` 访问不同的目录流是安全的，但是访问同一个流是不安全的。` readdir_r()` 函数是线程安全的，但是可移植性不好。推荐你使用 `readdir()`，当你在多线程访问同一个目录流时，使用锁。

###: readdir_r()

```c 
int readdir_r(DIR *dirstream, struct dirent *entry, struct dirent **result);
```

* Preliminary: | MT-Safe | AS-Unsafe lock | AC-Unsafe lock |
* Function

`readdir_r()` 是 `readdir()` 加强版，它在内部使用锁，以避免数据竞争。返回的目录项信息，存储在 `entry` 对象中。 

> 可移植性注解：推荐使用 `readdir()`，而不是 `readdir_r()`，有以下原因：

> * 在某些系统，它们没有定义 `NAME_MAX`，调用 `readdir_r()` 可能是不安全的，因为无法确定目录项的缓冲区长度。

> * 在某些系统，`readdir()` 不能读取过长的名字。否则，返回一个错误 `ENAMETOOLONG`。也许能成功返回，但是 `d_name` 字段可能是截断的。

> * POSIX-1.2008 没有规定 `readdir()` 是线程安全的。不过，在 GNU C 库的实现里，在不同的线程访问不同的目录流是安全的。当你想在不同的线程访问相同的目录流时，使用锁同步，就可以避免安全问题。

> * POSIX 在未来可能会废弃 `readdir_r()`，并且规定 `readdir()` 是 GNU C 库当前的安全状态。

通常，`readdir_r()` 返回 `0` 并设置 `*result` 指向 `entry`。如果没有更多的目录项，或者执行失败，设置 `*result` 为一个空指针，并且返回 `非 0` 错误代码（同时设置 `errno` 值为该错误代码）。

让我们来瞧瞧 `struct dirent` 类型。单纯的给 `readdir_r()` 传递一个指针是不够的：有些系统定义的 `d_name` 字段不是很长，这时候，你得自己增加空间来存放目录项的名字 --- `d_name` 的长度至少是 `NAME_MAX + 1`。例子：

```c
union {
    struct dirent d;
    char b[offsetof(struct dirent, d_name) + NAME_MAX + 1];
} u;

if (readdir_r(dir, &u.d, &res) == 0)
    …
```

> 译注：这个例子似乎说明 `d_name` 一定是 `struct dirent` 的最后一个字段。

###: readdir64()

```c
struct dirent64 *readdir64(DIR *dirstream);
```

* Preliminary: | MT-Unsafe race:dirstream | AS-Unsafe lock | AC-Unsafe lock |
* Function

`readdir64()` 函数类似 `readdir()` 函数，除了返回的指针是 `struct dirent64` 类型。`struct dirent64` 的一些数据成员可能和 `struct dirent6` 的尺寸不同（比如 `d_ino`），以允许操作大文件系统。

###: readdir64_r()

```c
int readdir64_r(DIR *dirstream, struct dirent64 *entry, struct dirent64 **result);
```

* Preliminary: | MT-Safe | AS-Unsafe lock | AC-Unsafe lock |
* Function

`readdir64_r()` 函数类似 `readdir_r()` 函数，除了存储的对象是 `struct dirent64` 类型。`struct dirent64` 的一些数据成员可能和 `struct dirent` 的尺寸不同（比如 `d_ino`），以允许操作大文件系统。

###: closedir()

```c
int closedir(DIR *dirstream);
```

* Preliminary: | MT-Safe | AS-Unsafe heap lock/hurd | AC-Unsafe mem fd lock/hurd |
* Function

`closedir()` 关闭指定的目录流。成功返回 `0`，失败返回 `-1` 并设置 `errno ` 值。相关的 `errno` 值如下所示：

* `EBADF` 指定的 `dirstream` 不是有效的目录流。   

###

## 例子：列出目录项

这儿有个简单的例子，打印工作目录的文件名字：

```c
#include <stdio.h>
#include <sys/types.h>
#include <dirent.h>

int main(void) {
    DIR *dp;
    struct dirent *ep;

    dp = opendir("./");
    if (dp != NULL) {
        while (ep = readdir (dp))
            puts(ep->d_name);
        (void)closedir(dp);
    }
    else
        perror("Couldn't open the directory");

    return 0;
}
```

打印的名字顺序是随机的。你可能想要按字母排序，往下看看扫描函数（得到你想要的）。

## 随机访问目录流

###: #include &lt;dirent.h&gt;

```c
#include <dirent.h>
```

###: rewinddir()

```c
void rewinddir(DIR *dirstream);
```

* Preliminary: | MT-Safe | AS-Unsafe lock | AC-Unsafe lock |
* Function

`rewinddir()` 函数重置目录流，当你再次调用 `readdir()` 时将从第一个目录项重新开始。如果添加了新的文件，或者删除了文件，都会被计入，因为它在内部调用 `opendir()` 重新打开。

###: telldir()

```c
long int telldir(DIR *dirstream);
```

* Preliminary: | MT-Safe | AS-Unsafe heap/bsd lock/bsd | AC-Unsafe mem/bsd lock/bsd |
* Function

`telldir()` 函数返回目录流的文件位置。你可以使用 `seekdir()` 操纵这个值，把目录流重定位到该位置。

###: seekdir()

```c
void seekdir(DIR *dirstream, long int pos);
```

* Preliminary: | MT-Safe | AS-Unsafe heap/bsd lock/bsd | AC-Unsafe mem/bsd lock/bsd |
* Function

`seekdir()` 函数设置目录流的文件位置。`pos` 必须是之前 `telldir()` 返回的值。关闭、重新打开目录流，都会使 `telldir()` 返回的值不再有效。

###

## 扫描目录

本小节描述了几个扫描目录的高层接口，允许你过滤目录项，并对它们排序。

###: scandir()

```c
int scandir(const char *dir, struct dirent ***namelist, int (*selector)(const struct dirent *), int (*cmp)(const struct dirent **, const struct dirent **));
```

* Preliminary: | MT-Safe | AS-Unsafe heap | AC-Unsafe mem fd |
* Function

`scandir()` 函数扫描 `dir` 目录的内容。`*namelist` 是一个指针，指向一个 `struct dirent` 数组，描述了所有选定的目录项（它使用 `malloc()` 分配空间）。`selector`是个过滤函数，允许你只扫描特定的目录项---当返回 `非 0` 时，选定该目录项。`cmp` 是一个排序函数，允许你对所有选定的目录项进行排序。

执行成功时，返回 `*namelist` 存储的目录项个数。执行失败时，返回 `-1` 并设置 `errno` 值。

> 为了方便程序员，我们实现了 `alphasort()` 和 `versionsort()`。你可以直接用在 `scandir()` 函数。

###: alphasort()

```c
int alphasort(const struct dirent **a, const struct dirent **b);
```

* Preliminary: | MT-Safe locale | AS-Unsafe heap | AC-Unsafe mem |
* Function

`alphasort()` 函数是一个比较函数，返回值如下：

* `a > b` => `>0`
* `a == b` => `0`
* `a < b` => `<0`

###: versionsort()

```c
int versionsort(const struct dirent **a, const struct dirent **b);
```

* Preliminary: | MT-Safe locale | AS-Safe | AC-Safe |
* Function

`versionsort()` 函数类似 `alphasort()` 函数，但是内部使用 `strverscmp()` 函数。

###: scandir64()

```c
int scandir64(const char *dir, struct dirent64 ***namelist, int (*selector)(const struct dirent64 *), int (*cmp)(const struct dirent64 **, const struct dirent64 **));
```

* Preliminary: | MT-Safe | AS-Unsafe heap | AC-Unsafe mem fd |
* Function

`scandir64()` 函数类似 `scandir()` 函数，除了目录项是 `struct dirent64` 类型。`struct dirent64` 的一些数据成员可能和 `struct dirent` 的尺寸不同（比如 `d_ino`），以允许操作大文件系统。

> 不要混合使用 `scandir()` 和 `scandir64()`。

<span>

> 为了方便程序员，我们实现了 `alphasort64()` 和 `versionsort64()`。你可以直接用在 `scandir64()` 函数。

###: alphasort64()

```c
int alphasort64(const struct dirent64 **a, const struct dirent64 **b);
```

* Preliminary: | MT-Safe locale | AS-Unsafe heap | AC-Unsafe mem |
* Function

`alphasort64()` 函数类似 `alphasort()` 函数，除了目录项是 `struct dirent64` 类型---允许操作大文件系统。

###: versionsort64()

```c
int versionsort64(const struct dirent64 **a, const struct dirent64 **b);
```

* Preliminary: | MT-Safe locale | AS-Safe | AC-Safe |
* Function

`versionsort64()` 函数类似 `versionsort()` 函数，除了目录项是 `struct dirent64` 类型---允许操作大文件系统。

###

## 例子：列出目录项 II

这儿有个简单的例子，打印工作目录的文件名字。另外，它还过滤了部分目录项，并对结果排序：

```c
#include <stdio.h>
#include <dirent.h>

static int selector(const struct dirent *unused) {
    return 1;
}

int main(void) {
    struct dirent **eps;
    int n;

    n = scandir("./", &eps, selector, alphasort);
    if (n >= 0) {
        int cnt;
        for (cnt = 0; cnt < n; ++cnt)
            puts(eps[cnt]->d_name);
    }
    else
        perror("Couldn't open the directory");

    return 0;
}
```

