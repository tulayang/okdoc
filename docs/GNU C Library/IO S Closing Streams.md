# [关闭流](https://www.gnu.org/software/libc/manual/html_node/Closing-Streams.html#Closing-Streams)

当调用 `fclose()` 关闭流时，流和文件之间的连接也跟随关闭。一旦关闭流，你不能再对其执行任何操作。

当程序的 `main()` 函数返回，或者调用 `exit()` 终止程序，所有打开的流都会被自动关闭。如果你的程序是其它方式终止的，比如调用 `abort()` 终止、一个致命错误导致程序终止，打开的流可能不会被正确关闭。

###: #include &lt;stdio.h&gt;

```c
#include <stdio.h>
```

###: fclose()

```c
int *fclose(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe heap lock | AC-Unsafe mem fd |
* Function

`fclose()` 函数关闭流 `stream`。输出流立刻把缓冲区的数据写入内核缓冲区；输入流丢弃缓冲区的数据。执行成功返回 `0`；出错返回 `EOF`。

当你调用 `fclose()` 关闭输出流时，检查错误是非常重要的。比如，当你调用 `fclose()` 时，输出流会把数据写入到内核缓冲区，假如此时内核缓冲区也将数据写入到磁盘，但是磁盘满了，就会引发错误。甚至，在使用 NFS 文件系统时，就算缓冲区是空的，关闭流也可能引发错误。

###: fcloseall()

```c
int fcloseall(void);
```

* Preliminary: | MT-Unsafe race:streams | AS-Unsafe | AC-Safe | 

`fcloseall()` 函数关闭进程打开的所有流。输出流立刻把缓冲区的数据写入内核缓冲区；输入流丢弃缓冲区的数据。执行成功返回 `0`；出错返回 `EOF`。

这个函数只应该在特殊场景使用，比如，当出现错误时程序必须被中止。通常，你更应该使用 `flocse()` 单独的关闭流，而且 `fcloseall()` 也会关闭标准流。

> `fcloseall()` 函数是 GUN C 库的扩展。

