# [临时文件](https://www.gnu.org/software/libc/manual/html_node/Temporary-Files.html#Temporary-Files)

如果你需要使用临时文件，可以调用 `tmpfile()` 创建一个；或者调用 `tmpnam()`、`tmpnam_r()` （更佳） 制作一个临时文件名，然后调用 `open()` 打开它。

`tempnam()` 函数类似 `tmpnam()` 函数，但是允许你选择临时目录，以及配置文件名。重要的是：`tempnam()` 是可重入的，而 `tmpnam()` 则不是。

## API

###: #include &lt;stdio.h&gt;

```c
#include <stdio.h>
```

###: tmpfile()

```c
FILE *tmpfile(void);
```

* Preliminary: | MT-Safe | AS-Unsafe heap lock | AC-Unsafe mem fd lock |
* Function

`tmpfile()` 函数创建一个临时文件，采用更新模式---如同指定 `wb+` 调用 `fopen()`。当关闭文件或进程终止时，此临时文件被自动删除。（在一部分 ISO C 系统，如果进程异常终止，删除可能会失败）。

这个函数是可重入的。

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，`tmpfile()` 函数实质上是 `tmpfile64()` 函数。也就是说，使用 64 位文件长度和文件偏移，透明地替换掉 API。

###: tmpfile64()

```c
FILE * tmpfile64(void);
```

* Preliminary: | MT-Safe | AS-Unsafe heap lock | AC-Unsafe mem fd lock |
* Function

> `tmpfile64()` 函数类似 `tmpfile()` 函数。唯一的不同是：在 32 位系统，打开的文件使用“大文件模式”。在该模式下，文件的最大长度是 <code>2<sup>63</sup>bytes</code>，文件的偏移范围是 <code>-2<sup>63</sup></code> 到 <code>2<sup>63</sup></code>。

<span>

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，`tmpfile()` 函数实质上是 `tmpfile64()` 函数。也就是说，使用 64 位文件长度和文件偏移，透明地替换掉 API。

###: tmpnam()

```c
char *tmpnam(char *result);
```

* Preliminary: | MT-Unsafe race:tmpnam/!result | AS-Unsafe | AC-Safe |
* Function

`tmpnam()` 函数构建并返回一个有效的文件名，该文件名是唯一的，并且和已存在的文件没有关联。如果 `result` 是一个空指针，则在内部创建一个静态字符串，将字符串返回；后续的调用可能会修改这个字符串，因此，这个函数是不可重入的。如果 `result` 不是空指针，那么应该将其设定为一个指针，指向一个长度至少为 `L_tmpnam` 的字符数组，结果值会被写入 `result`。

如果调用 `tmpnam()` 多次，并且没有移除之前创建的文件，那么有可能会失败。这是因为，临时文件名字的数量是有限制的。如果 `tmpnam()` 失败，返回一个空指针。

警告：在名字被构建后到文件被创建期间，其他进程可能使用 `tmpnam()` 创建了一个同名文件，这会导致安全漏洞。我们无法预测生成的名字是什么，但是当打开文件时，你应该指定 `O_EXCL` 标志位。使用 `tmpfile()` 或 `mkstemp()` 是较为安全的方式，可以避免这个漏洞。

###: tmpnam_r()

```c
char *tmpnam_r(char *result);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |
* Function

`tmpnam_r()` 函数和 `tmpnam()` 函数几乎完全相同，除了指定 `result` 是一个空指针时，它返回一个空指针。

这能确保 `tmpnam_r()` 是完全可重入的。

警告：`tmpnam_r()` 和 `tmpnam()` 存在同样的漏洞问题。

###: L_tmpnam

```c
int L_tmpnam
```

* Macro

`L_tmpnam` 是一个整数常量。在你调用 `tmpnam()` 时，需要设定 `result` 缓冲区的长度，以便可以容纳临时文件名。你设定的缓冲区长度应该至少是 `L_tmpnam`，以容纳所有可能的长度。

###: TMP_MAX

```c
int TMP_MAX
```

* Macro

在你调用 `tmpnam()` 时，生成的名字数量是有限的。`TMP_MAX` 设定了你最多可以获得多少个名字。你可以依赖这个常量，来决定可以同时创建多少个临时文件。

基于 GNU C 库的系统，你能同时创建非常多的临时文件，甚至在你耗尽所有的磁盘空间之前，你都达不到上限。别的一些系统，有一个固定的上限值，不会小于 `25`。

###: tempnam()

```c
char * tempnam(const char *dir, const char *prefix);
```

* Preliminary: | MT-Safe env | AS-Unsafe heap | AC-Unsafe mem |
* Function

`tempnam()` 函数生成一个唯一的临时文件名。如果 `prefix` 不是空指针，使用该字符串最多 5 个字符，作为文件名的前缀。返回值是由 `malloc()` 分配的字符串，因此，当你不再使用时调用 `free()` 将其释放。

因为字符串是动态分配的，所以 `tempnam()` 是可重入的。

临时文件的目录前缀，是通过下列规则来确定的（这些目录必须存在并且可写）：

* 环境变量 `TMPDIR` （如果定义了的话）。基于安全原因，只有非 SUID 或 SUID 不可用的程序中发生。
* `dir` 值（如果不是空指针）
* `P_tmpdir` 值
* */tmp* 目录

`tempnam()` 函数的存在是为了兼容 SVID。

警告：`tempnam()` 和 `tmpnam()` 存在同样的漏洞问题。

###: P_tmpdir

```c
char * P_tmpdir
```

* Macro

`P_tmpdir` 是临时文件父目录的默认名字。

在旧的 Unix 系统，没有上面描述的函数，而是使用 `mktemp()` 和 `mkstemp()`。这两个函数工作方式是通过修改你传入的模板字符串。最后六个字符必须是 `XXXXXX`。这六个字符会被一个唯一的文件名替换。通常模板字符串类似 `/tmp/prefixXXXXXX`。

> 译注：以下省去以下过时函数的细节，请参考官方文档了解详情：

> `char * mktemp(char *template);`

> `int mkstemp(char *template);`

> `char *mkdtemp(char *template);` -- 来自 OpenBSD
        