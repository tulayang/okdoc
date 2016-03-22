# [运行一条命令](https://www.gnu.org/software/libc/manual/html_node/Running-a-Command.html#Running-a-Command)

运行程序的最简单方式是使用 `system()` 函数。这个函数会自动完成运行子程序的所有工作，但是你无法对其有更多的控制：在子程序终止前，除了等待，也只能等待。

###: #include &lt;stdlib.h&gt;

```c
#include <stdlib.h>
```

###: system()

```c
int system(const char *command);
```

* Preliminary: | MT-Safe | AS-Unsafe plugin heap lock | AC-Unsafe lock mem |
* Function

`system()` 函数执行命令 `command` --- 作为一个 **shell** 命令。在 GNU C 库，总是使用默认的 **shell** sh 来运行命令。此外，它会搜索 `PATH` 目录，查找要运行的可执行文件。如果不能创建 **shell** 进程，返回 `-1`；否则，返回 **shell** 进程的状态。

如果指定 `command` 是一个空指针，并且返回 `0` 表示命令处理器不可用。

> 可移植性注解：有些 C 实现可能不支持命令处理器，但是却没有明说。调用 `system (NULL);`，如果返回 `非 0`，表示命令处理器可用。

<span>
 
> 对于多线程程序，`system()` 函数是一个“取消点”。如果线程在 `system()` 被调用时，分配了一些资源（比如内存、文件描述符、信号或者其它），有可能会产生问题。如果该线程被取消了，这些资源仍然会继续存在，直到程序结束。要避免这种情况，应该通过取消处理器保护 `system()` 调用。

`popen()` 和 `pclose()` 函数与 `system()` 函数关系密切。