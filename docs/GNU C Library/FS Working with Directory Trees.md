# [目录树](https://www.gnu.org/software/libc/manual/html_node/Working-with-Directory-Trees.html#Working-with-Directory-Trees)

前面的章节介绍了如何操作目录流，以及检索目录项。有时候，把目录中的文件按照层级关系表现出来很有用处。X/Open 规范为此定义了两个函数。最初，这是由 System V 系统定义的。

## API

###: #include &lt;ftw.h&gt;

```c
#include <ftw.h>
```

###: __ftw_func_t

```c
int (*)(const char *, const struct stat *, int)
```

* Data Type

`__ftw_func_t` 是用来传递给 `ftw()` 的回调函数。第一个参数指向文件名。第二个参数是一个 `struct stat` 对象，用来填充文件信息。

第三个参数是标志位，可选的值如下：

* `FTW_F` The item is either a normal file or a file which does not fit into one of the following categories. This could be special files, sockets etc. 

* `FTW_D` 当前项是目录。

* `FTW_NS` The `stat` call failed and so the information pointed to by the second paramater is invalid. 

* `FTW_DNR` 当前项是目录，不能读。

* `FTW_SL` 当前项是符号链接。必须定义 `_XOPEN_EXTENDED` 符号才能启用此标志。

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，`__ftw_func_t` 实质上是 `__ftw64_func_t`，`struct stat` 实质上是 `struct stat64`。

> 对于 LFS 接口，GNU C 库定义了 64 位版本的操作函数。

###: __ftw64_func_t

```c
int (*)(const char *, const struct stat64 *, int)
```

* Data Type

`__ftw64_func_t` 类似 `__ftw_func_t`。

###: __nftw_func_t

```c
int (*)(const char *, const struct stat *, int, struct FTW *);
```

*  Data Type

前三个参数和 `__ftw_func_t` 相同。不过第三个参数增加了一些选项：

* `FTW_DP` 当前项是目录，并且所有的子目录已经被访问过。This flag is returned instead of `FTW_D` if the `FTW_DEPTH` flag is passed to nftw (see below). 

* `FTW_SLN` 当前项是过时的符号链接。它指向的文件不存在。

第四个参数指向一个结构，包含了一些附加信息。

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，`__nftw_func_t` 实质上是 `__nftw64_func_t`，`struct stat` 实质上是 `struct stat64`。

> 对于 LFS 接口，GNU C 库定义了 64 位版本的操作函数。

###: __nftw64_func_t

```c
int (*)(const char *, const struct stat64 *, int)
```

* Data Type

`__nftw64_func_t` 类似 `__nftw_func_t`。

###: struct FTW

```c
struct FTW
```

* Data Type

`struct FTW` 用来包含一个附加信息，以帮助遍历目录。字段有：

* `int base` 

* `int level`

###: ftw()

```c
int ftw(const char *filename, __ftw_func_t func, int descriptors);
```

* Preliminary: | MT-Safe | AS-Unsafe heap | AC-Unsafe mem fd |
* Function

###: ftw64()

```c
int ftw64(const char *filename, __ftw64_func_t func, int descriptors);
```

* Preliminary: | MT-Safe | AS-Unsafe heap | AC-Unsafe mem fd |
* Function

###: nftw()

```c
int nftw(const char *filename, __nftw_func_t func, int descriptors, int flag);
```

* Preliminary: | MT-Safe cwd | AS-Unsafe heap | AC-Unsafe mem fd cwd |
* Function

###: nftw64()

```c
int nftw64(const char *filename, __nftw64_func_t func, int descriptors, int flag);
```

* Preliminary: | MT-Safe cwd | AS-Unsafe heap | AC-Unsafe mem fd cwd |
* Function

