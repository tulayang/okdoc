# [流，从错误中恢复](https://www.gnu.org/software/libc/manual/html_node/Error-Recovery.html#Error-Recovery)

你可以显式地调用 `clearerr()` 清除流的错误标志和 end-of-file 标志。

注意：单纯清除错误标志，然后重新操作流，这是不正确的。因为，写失败时，上一次的冲洗可能已经把缓冲区的一些数据提交到内核缓冲区，而一些缓冲区数据可能已经被丢弃。仅仅重新操作可能会导致数据丢失或者数据重复。

读失败时，重新读可能把文件指针留在不适当的位置。这两种情况，你都应该在重新操作前先找到可知的位置。

大部分发生的错误都是不可逆的---第二次尝试操作，总是以同样的结果再次失败。因此，放弃重新操作，并且把错误报告给用户，通常是最好的选择。

有一种情况除外，那就是 `EINTR`---信号中断。你可以安装信号处理器，并指定 `SA_RESTART`，在信号中断时重新操作。

此外，对一个流内部的文件描述符设置非阻塞，也是非常不明智的。

###: #include &lt;stdio.h&gt;

```c
#include <stdio.h>
```

###: clearerr()

```c
void clearerr(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Unsafe lock |
* Function

`clearerr()` 函数清除流 `stream` 的 错误标志和 end-of-file 标志。

###: clearerr_unlocked()

```c
void clearerr_unlocked(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Unsafe lock |
* Function

`clearerr_unlocked()` 函数类似 `clearerr()` 函数，但是不再内部锁定流。

> `clearerr_unclocked()` 函数是一个 GNU 扩展。

