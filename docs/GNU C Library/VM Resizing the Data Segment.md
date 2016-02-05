# [内存分配器](https://www.gnu.org/software/libc/manual/html_node/Resizing-the-Data-Segment.html#Resizing-the-Data-Segment)

本节描述的函数，你不会经常用到。它们是 GNU C 库的内存分配器所使用的非常底层的函数。进程虚拟地址空间的结构如下所示：

```?
                          +---------------+
                          | Kernel        | 映射到进程虚拟内存，但程序无法访问
               0xC0000000 +---------------+
                          | argv, environ |
                          +---------------+
                          | Stack       ↓ | 
             Top of Stack +...............+
                          |               |
                          |               | 
            Program Break +...............+
                          |               |
                          | Heap        ↑ |
                          |               |
                          +---------------+
                          | Uninitialized |
                          +---------------+
                          | Initialized   | 
                          +---------------+
                          | Text          | 
               0x08048000 +---------------+
               0x00000000 +---------------+
```

改变堆的大小（即分配或释放内存），其实就像命令内核改变进程的 program break 位置一样简单。

最初，program break 正好位于未初始化数据段末尾之后。在 program break 的位置抬升后，程序可以访问新分配区域内的任何内存，而此时物理内存页尚未分配。内核会在进程首次试图访问这些虚拟内存地址时，自动分配新的物理内存页。

###: #include &lt;unistd.h&gt;

```c
#include <unistd.h>
```

###: brk()

```c
int brk(void *end_data_segment);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

`brk()` 设置 program break 的位置。由于虚拟内存以页为单位进行分配，实际会四舍五入到下一个页的边界处。当试图设置一个低于 program break 初始值的位置时，有可能会导致无法预知的行为。成功返回 0；出错返回 -1，并设置 `errno`：

* `ENOMEM` 该请求会导致数据重叠，或者超出进程可分配的内存限制。

###: sbrk()

```c
void *sbrk(ptrdiff_t increment);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

它的作用和 `brk()` 类似。增加 program break 的位置，成功返回前一个 program break 的地址（即新分配内存的起始位置），出错返回 NULL。sbrk(0) 将不做改变，当跟踪堆或者监视内存分配行为时，可能会用到。

