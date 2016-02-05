# [什么是流](https://www.gnu.org/software/libc/manual/html_node/Streams.html#Streams)

本章节描述如何创建流，然后通过流执行输入输出。

流是一个抽象，用于文件、设备、进程通信的高层概念。基于历史原因，C 语言用 `FILE` 表示流，而不是 `stream`。由于许多库使用 `FILE *` 处理流操作，有时也用术语 “文件指针” 指代 “流”。自然，这导致很多 C 语言的书中产生许多混乱。在我们的文档里，我们会小心翼翼地使用术语 “文件” 和 “流”，尽可能的贴近技术场景。

`FILE` 类型定义在头文件 `<stdio.h>`。

## API

###: #include &lt;stdio.h&gt;

```c
#include <stdio.h>
```

###: FILE

```c
FILE
```

* Data Type

`FILE` 表示一个流对象，包含了相关的内部信息，比如文件位置、缓冲区。流也有错误码和 end-of-file，通过 `ferror()` 和 `feof()` 来判断。

`FILE` 由相关的库函数在内部分配和管理。不要自己创建 `FILE` 对象，让库去做。你应该引用 `FILE *`，并且调用库函数完成具体的操作。

