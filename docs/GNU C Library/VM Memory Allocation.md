# [内存分配](https://www.gnu.org/software/libc/manual/html_node/Memory-Allocation.html#Memory-Allocation)

本节描述了普通程序如何管理他们的数据存储，包括著名的 `malloc()` 函数和一些为发烧友准备的 GNU C 库函数和 GNU 编译器工具。

## C 程序中的内存分配

通过 C 语言的变量，支持两种内存分配：

* **静态分配** 当你声明一个静态变量或全局变量时分配。每个静态变量或全局变量定义一块空间，其大小是固定的。这个空间在程序开始时分配（作为 `exec()` 操作的一部分），只分配一次，永远不会释放。

* **自动分配** 当你声明一个自动变量时分配，比如一个函数参数或者一个局部变量。当进入含有该声明的复合语句时，自动变量的空间被分配，当退出该复合语句时被释放。

  在 GNU C，自动分配的大小可以是复合表达式的结果值。在其他 C 实现中，它必须是一个常数。

第三种重要的内存分配是动态分配，不受 C 变量的支持，但是通过 GUN C 库函数可以做到。

* **动态分配**

  动态分配是一种技术，使程序在运行时确定存储的信息。你需要动态分配，它可以按你的意愿分配需要的尺寸，或者控制存在的时间，所有这些因素都很难在程序运行前获知。

  例如，你可能需要一块内存，来存储从输入文件中读取的一行。因为没有限制一行有多少字符，你必须动态地分配内存，并且在读取行时动态地增长。

  或者，你可能需要一块内存，来存储输入数据的每个记录或者描述。因为你不知道到底会有多少，每当你读取的时候，你必须分配一个新的内存块。

  当你使用动态分配时，对内存块的分配是一个显式的程序请求。当你要分配空间的时候，你调用一个函数或者宏，并指定空间大小。如果你想释放这个空间，你通过调用另一个函数或宏来完成。无论何时何地，你都可以这样做。

  动态分配不受 C 变量的支持，不存在存储类“dynamic”，而且永远不可能有一个 C 变量，其值是动态分配的空间。动态分配内存的唯一方式，是通过一个系统调用（这通常是 GNU C 库函数调用），而所分配的空间是通过指针引用。因为它不太方便，而且动态分配在实际操作中需要更多的计算时间，程序员一般只在静态分配或者自动分配无法完成任务时，才采用动态分配。

  举个例子，如果你想动态地分配一些空间来存储一个 `struct foobar`，你无法依靠声明类型 `struct foobar` 来获得内存空间。不过你可以声明一个指针类型 `struct foobar *` 的变量，并对其赋予内存空间的地址。然后，你可以使用操作符 `*` 和 `->` 来引用此内存空间的内容：

  ```c
  {
      struct foobar *ptr = (struct foobar *) malloc(sizeof(struct foobar));
      ptr->name = x;
      ptr->next = current_foobar;
      current_foobar = ptr;
  }
  ```

## 不受约束，愉快地分配  :)

最常用的动态分配工具是 `malloc()`，允许你随时随地分配内存空间。另一方面，`free()` 允许你随时随地释放内存空间。进程虚拟地址空间的图如下所示：

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

* `malloc()`

  我们对 `malloc()` 的实现非常干脆利落。首先扫描之前由 `free()` 释放的空闲内存列表，寻找尺寸 >= 要求的空闲内存。如果刚好相等，就把它直接返回给调用者。如果过大，那么切分这块内存，把尺寸相当的部分返回给调用者，把剩余的部分保留在空闲内存列表。

  如果在空闲内存列表中没有找到足够大的块，那么 `malloc()` 会调用 `sbrk()` 增加 program break 的位置，以分配更多的内存。为了减少 `sbrk()` 的调用次数，`malloc()` 并非严格按照所需要的字节数来分配内存空间，而是以虚拟内存页的倍数增加 program break，将超出部分置于空闲内存列表。

* `free()`

  当 `malloc()` 分配内存时，它会额外分配几个字节来存储一个整数，用来记录这块内存空间的大小。这个整数位于块的起始处，实际返回给调用者的地址恰好位于这个整数字节之后。

  ```?
       +-----------------------------------------------------------------+
       | 内存块大小(L) | 供调用者使用的内存                                  |
       +-----------------------------------------------------------------+
                     ^
                     malloc() 返回的地址
  ```

  一般情况下，`free()` 并不降低 program break 的位置，而是将这块内存添加到空闲内存列表中，供后续的内存分配。这么做有以下几个原因：

  * 释放的块通常位于堆的中间，降低 propram break 是不可能的。
  * 可以最大限度减少 `sbrk()` 的调用次数。
  * 多数情况下，降低 prgram break 的位置不会对分配大量内存的程序有帮助。

  将块置于空闲内存列表时，`free()` 使用块自身的空间来存放链表指针，将自身添加到列表中。

  ```?
       +------------------------------------------------------------------+
       | 内存块尺寸(L) | 前一空闲内存块地址 | 后一空闲内存块地址 | 剩余空闲内存   |
       +------------------------------------------------------------------+
                            空闲内存表中的内存块
  ```

  将相邻的空闲块合并为一块更大的空闲块，可以避免在空闲内存列表中包含大量的小块内存，导致内存空间太小，难以满足后续的内存申请。Glib C 的 `free()` 实现，在堆顶空闲内存＂足够＂大的时候，会调用 `sbrk()` 来降低 program break 的位置，减少了调用 `sbrk()` 的次数。（＂足够＂取决于 `malloc()` 函数行为的控制参数，`128 K` 为典型值）。

### 基础内存分配

####: #include &lt;stdlib.h&gt;

```c
#include <stdlib.h>
```

####: malloc()

```c
void *malloc(size_t size);
```

* Preliminary: | MT-Safe | AS-Unsafe lock | AC-Unsafe lock fd mem |

如果成功返回一个指针，指向新分配的内存块；如果失败返回一个空指针。

> 内存块的内容是不确定的！！！你必须自己对它初始化（或者调用 `calloc()` 初始化）。通常情况下，你会把返回值转换成想要操作的对象结构。在这里，我们写了一个例子，并且使用 `memset()` 把内存空间初始化为 `0`：
>
```c
struct foo *ptr = (struct foo *) malloc(sizeof(struct foo));
if (ptr == NULL) abort ();
memset (ptr, 0, sizeof(struct foo));
```

你可以把 `malloc()` 的返回值（不经过转换）存储到任何指针变量。因为在必要的时候，ISO C 会自动地把 `void *` 类型转换到另一种类型的指针。

> 记住，当为字符串分配空间时，`malloc()` 的参数必须是 `字符串的长度 + 1` ！！！ 这是因为字符串需要有一个尾部终止符 `'\0'`，它不会被计入长度。例子：
>
```c
char *ptr = (char *) malloc(length + 1);
```

如果没有更多的可用空间，`malloc()` 返回一个空指针。你应该在每次调用 `malloc()` 时都检查其返回值。写一个子程序，负责调用 `malloc()` 并在返回值是空指针时报告错误，是很有用处的。这个函数通常称为 `xmalloc()`：

```c
void *xmalloc(size_t size) {
    void *result = malloc (size);
    if (result == 0)
        fatal("virtual memory exhausted");
    return result;
}
```

<span>

```c
#include <stdlib.h>
#include <syslog.h>

void *xmalloc(size_t size) {
    void *result = malloc (size);
    if (result == 0) {
        syslog(LOG_ERR, "out of memory (malloc)");
        exit(EXIT_FAILURE);
    }
    return result;
}
```

这里有个使用 `malloc()` 的真实例子（通过 `xmalloc()`），函数 `savestring()` 把字符序列复制到新分配的内存空间：

```c
char *savestring(const char *ptr, size_t len){
    char *value = (char *) xmalloc(len + 1);
    value[len] = '\0';
    return (char *) memcpy(value, ptr, len);
}
```

`malloc()` 分配给你的内存空间，保证是字节对齐的，因此它可以容纳任何类型的数据。在 GNU 系统，地址总是 `8` 的倍数（32位系统）或者 `16` 的倍数（64位系统）。更高的边界（如页边界）很少需要；在这种情况下，可以使用 `aligned_alloc()` 或 `posix_memalign()`。

> 注意，试图访问超过内存边界的数据，有可能破坏数据。如果你发现需要更大的内存块，使用 `realloc()` 重新调整内存块的大小。

相对于其他版本， the `malloc()` in the GNU C Library does not round up block sizes to powers of two, neither for large nor for small sizes。相邻的空闲块可以合并，不管它们的尺寸是多少。这使得内存分配不会出现著名的碎片问题。

> GNU C 库的 `malloc()`，在分配非常大的块时（比页还要大很多）会在内部调用 `mmap()`（匿名或通过 <span>*/dev/zero*）来分配内存。这样做有很大的优势：当这些块被释放时，它们被立刻返还到系统。因此，it cannot happen that a large chunk becomes “locked” in between smaller ones and even after calling free wastes memory. 可以通过 `mallopt()`，调整通过 `mmap()` 分配内存的尺寸阈值。也可以完全禁用在 `malloc()` 内部使用 `mmap()`。

####: realloc()

```c
void *realloc(void *ptr, size_t newsize);
```

* Preliminary: | MT-Safe | AS-Unsafe lock | AC-Unsafe lock fd mem |

`realloc()` 函数改变 `ptr` 指向的块大小，设为 `newsize`。

通常，当你分配内存块时，你不知道最终会需要多大的尺寸。例如，这个块可能是一个缓冲区，用来存储从文件读取的行；不管你最初把缓冲区设定的多长，你都有可能会遇到需要更长的空间来存储一行。你可以通过调用 `realloc()` 使块增长。

`realloc()` 会尝试合并紧随其后并且尺寸满足要求的空间。由于已分配的块后面的空间可能已被其他占用，这种情况下 `realloc()` 会分配一块新的内存空间，将原有数据复制到新块中。`realloc()` 返回值是新块的地址。如果块需要移动时，`realloc()` 就会复制旧块的内容。

<span>

> 如果你为 `ptr` 传递一个空指针，`realloc()` 的行为就像 `malloc（newsize）`。这看起来方便，但是要注意，旧的实现（在 ISO C 前）可能不支持这种行为，并且可能会崩溃。

和 `malloc()` 一样，`realloc()` 发现没有可用的存储空间可以使块增长时，会返回一个空指针。当发生这种情况时，原始的块不发生改变，它不会被修改或者重新安置。

通常，写一个子程序，负责调用 `realloc()` 并在失败时报告错误，是很有用处的。这个函数通常称为 `xrealloc()`：

```c
void *xrealloc(void *ptr, size_t size) {
    void *result = realloc(ptr, size);
    if (result == NULL)
        fatal("Virtual memory exhausted");
    return result;
}
```

你也可以使用 `realloc()` 使内存块变小。你这么的原因，仅仅是为了避免占用大量的内存空间（当只需要一点时）。为了使块变小，有时需要复制块，所以如果没有可用空间就会失败。

如果新的大小和为旧的大小相同，`realloc()` 什么也不做，返回已有的地址。

####: calloc()

```c
void *calloc(size_t count, size_t eltsize);
```

* Preliminary: | MT-Safe | AS-Unsafe lock | AC-Unsafe lock fd mem |

`calloc()` 函数分配内存并初始化为零。它分配一块足够长的内存，来容纳一组矢量元素，每个大小是 `eltsize`。其内容会被清 `0`。

你可以自己定义 `calloc()`，如下：

```c
void *calloc (size_t count, size_t eltsize) {
    size_t size = count * eltsize;
    void *result = malloc(size);
    if (result != 0)
        memset(result, 0, size);
    return result;
}
```

<span>

> 但总的来说，it is not guaranteed that calloc calls malloc internally。因此，如果一个应用程序不使用本库的函数实现，而是提供自己的 `malloc()` `realloc()` `free()`，那么也应该总是定义 `calloc()`。

### 释放内存

####: #inlucde &lt;stdlib.h&gt;

```c
#include <stdlib.h>
```

####: free()

```c
#include <stdlib.h>
void free(void *ptr);
```

* Preliminary: | MT-Safe | AS-Unsafe lock | AC-Unsafe lock fd mem |

当你不再需要动态分配的内存空间时，使用 `free()` 函数使该其变得可再次分配。

内存空间被释放后，它的内容就变成不可知的，不要期望在释放后从中找到任何数据。无论何时，当你想要保留数据时，在释放前复制里面的内容！！！下面是一个例子，描述了一个适当的方式来释放链中的所有块，以及它们指向的字符串：

```c
struct chain {
    struct chain *next;
    char *name;
}

void free_chain(struct chain *chain) {
    while (chain != 0) {
        struct chain *next = chain->next;
        free (chain->name);
        free (chain);
        chain = next;
    }
}
```

偶尔，`free()` 可以把内存返回给操作系统，使进程变小。但是，通常它所能做的只是在调用 `malloc()` 之后释放空间。与此同时，这个空间作为空闲列表的一部分，仍然存在你的程序中。

在程序结束时释放内存空间没有什么意义，因为程序的整个空间都在进程结束时返还给系统。

####: cfree()

```c
#include <stdlib.h>
void cfree(void *ptr);
```

* Preliminary: | MT-Safe | AS-Unsafe lock | AC-Unsafe lock fd mem |

`cfree()` 函数类似 `free()` 函数，它的存在是用来向后兼容 SunOS 系统；你应该使用 `free()`。

### 分配对齐的内存块

GNU 系统的 `malloc()` 或 `realloc()` 返回的块地址，总是 `8` 的倍数（32位系统）或者 `16` 的倍数（64位系统）。如果你需要一个块，它的地址是一个 `2` 的幂，使用 `aligned_alloc()` 或 `posix_memalign()`。

####: #include &lt;stdlib.h&gt;

```c
#include <stdlib.h>
```

####: aligned_alloc()

```c
void *aligned_alloc(size_t alignment, size_t size);
```

* Preliminary: | MT-Safe | AS-Unsafe lock | AC-Unsafe lock fd mem | 

`aligned_alloc()` 函数分配一个内存块，它的地址是 `alignment` 的倍数。`alignment` 必须是 `2` 的幂，`size` 必须是 `alignment` 的倍数。

`aligned_alloc()` 函数在出现错误时，返回空指针，并设置 `errno` 为以下值之一：

* `ENOMEM` 没有足够的可用内存。
* `EINVAL` `alignment` 不是 `2` 的幂。

> 这个函数是在 ISO C11 引入的，因此对于现代的非 POSIX 系统，可能比 `posix_memalign` 有更好的可移植性。

####: memalign()

```c
void *memalign(size_t boundary, size_t size);
```

* Preliminary: | MT-Safe | AS-Unsafe lock | AC-Unsafe lock fd mem |

`memalign()` 函数分配一个内存块，它的地址是 `boundary` 的倍数。`boundary` 必须是 `2` 的幂。`memalign()` 函数用来分配大块内存，返回基于 `boundary` 倍数的地址。

`memalign()` 函数在出现错误时，返回空指针，并设置 `errno` 为以下值之一：

* `ENOMEM` 没有足够的可用内存。
* `EINVAL` `boundary` 不是 `2` 的幂。

> `memalign()` 函数是过时的，应该用 `aligned_alloc()` 或 `posix_memalign()` 代替。

####: posix_memalign()

```c
int posix_memalign(void **memptr, size_t alignment, size_t size);
```

* Preliminary: | MT-Safe | AS-Unsafe lock | AC-Unsafe lock fd mem |

`posix_memalign()` 函数类似于 `memalign()` 函数，返回一块缓冲区，地址按照 `alignment` 的倍数对齐。但是它增加了一个要求：值必须是 `sizeof (void *) * (2 的幂)`。

如果函数分配成功，通过 `memptr` 返回分配空间的地址，并且返回值是 `0`。否则该函数返回 `-1`，并设置 `errno` 为以下值之一：

* `ENOMEM` 没有足够的可用内存。
* `EINVAL` `alignment` 不是 `sizeof (void *) * (2 的幂)`。

> 这个函数是在 POSIX 1003.1d 引入的。尽管这个函数被 `aligned_alloc()` 取代了，但是对那些不支持 ISO C11 的旧版本 POSIX 系统，它的移植性更好。

####: valloc()

```c
void *valloc(size_t size);
```

* Preliminary: | MT-Unsafe init | AS-Unsafe init lock | AC-Unsafe init lock fd mem |

使用 `valloc()` 就像是用 `memalign()` 分配页大小的空间。它是这样实现的：

```c
void *valloc(size_t size) {
    return memalign(getpagesize(), size);
}
```

> `valloc()` 函数是过时的，应该用 `aligned_alloc()` 或 `posix_memalign()` 代替。

### malloc 调谐参数，更精细的分配

在动态分配内存时，你可以使用 `mallopt()` 函数调节一些参数。这个函数是通用 SVID/XPG 接口。

####: #include &lt;malloc.h&gt;

```c
#include <malloc.h>
```

####: mallopt()

```c
int mallopt(int param, int value);
```

* Preliminary: | MT-Unsafe init const:mallopt | AS-Unsafe init lock | AC-Unsafe init lock |

当调用 `mallopt()` 时，`param` 指定调谐参数，`value` 指定调谐参数的新值。`param` 可设置的调谐参数，定义在 `<malloc.h>`，如下所示：

* `M_MMAP_MAX` 当（在内部）通过 `mmap()` 分配内存时，可分配的最大尺寸。置为 `0` 则使用默认值。

* `M_MMAP_THRESHOLD` 所有大于这个值的内存分配，都（在内部）通过 `mmap()` 在堆外分配。这种方式可以确保这些块一旦被 `free()` 就立刻被返还给系统。注意，小于这个阈值的请求，仍然可能通过 `mmap()` 分配内存。

* `M_PERTURB` 如果非零，当分配（除了 `calloc()`）和释放时，内存块是否被值填充，依赖 `param` 的低序位。可以用来调试未初始化的堆内存或已释放的堆内存。请注意，此选项不能保证释放的块会有任何特定的值。它只能保证块被释放前内容被重写。

* `M_TOP_PAD` 这个参数决定了调用 `sbrk()` 时可从系统获得的额外内存数量。It also specifies the number of bytes to retain when shrinking the heap by calling sbrk with a negative argument. 这滞后了堆大小的改变，并且是必要的，这样可以避免过多的系统调用。

* `M_TRIM_THRESHOLD` This is the minimum size (in bytes) of the top-most, releasable chunk that will cause sbrk to be called with a negative argument in order to return memory to the system. 

### 堆的一致性检查

你可以通过调用 `mcheck()` 请求 `malloc()` 在执行时检查动态内存的一致性。这个函数是一个 GNU 扩展。

####: #include &lt;mcheck.h&gt;

```c
#include <mcheck.h>
```

####: mcheck()

```c
int mcheck(void (*abortfn)(enum mcheck_status status));
```

* Preliminary: | MT-Unsafe race:mcheck const:malloc(分配内存)_hooks | AS-Unsafe corrupt | AC-Unsafe corrupt |

调用 `mcheck()` 可以告诉 `malloc()` 执行临时的一致性检查。These will catch things such as writing past the end of a block that was allocated with malloc. 

`abortfn` 是一个回调函数，当发现不一致时被调用。如果你提供的是一个空指针，`mcheck()` 则使用默认函数打印一条消息并调用 `abort()` 函数。

一旦你已经调用 `malloc()` 分配了内存，再开始检查分配就晚了。在这种情况下 `mcheck()` 不会做任何事情，返回 `-1`；否则是 `0`。

为了安排尽可能早地调用 `mcheck()`，最简单的方式是当你用编译器链接程序时，加上 `-lmcheck` 选项；这样做你不需要修改源代码。此外，你可以使用一个调试器，在程序启动的时候插入一个 `mcheck()` 调用。例如，GDB 命令在程序启动时会自动调用 `mcheck()`：

```gdb
(gdb) break main
Breakpoint 1, main (argc=2, argv=0xbffff964) at whatever.c:10
(gdb) command 1
Type commands for when breakpoint 1 is hit, one per line.
End with a line saying just "end".
>call mcheck(0)
>continue
>end
(gdb) …
```

This will however only work if no initialization function of any object involved calls any of the `malloc()` functions since mcheck must be called before the first such function.

####: mprobe()

```c
enum mcheck_status mprobe(void *pointer);
```

* Preliminary: | MT-Unsafe race:mcheck const:malloc(分配内存)_hooks | AS-Unsafe corrupt | AC-Unsafe corrupt |

`mprobe()` 函数允许你显式地检查一个特定的块的一致性。你一定已经在程序启动的时候调用了 `mcheck()`，做了临时检查；调用 `mprobe()` 会请求一次额外的一致性检查。

`pointer` 必须是 `malloc()` 或 `realloc()` 返回的指针。`mprobe()` 返回一个值，表示什么不一致，如果有的话。

####: mcheck_status

```c
enum mcheck_status;
```

这个枚举类型描述了检查分配块时不一致的分类。以下是可能的值：

* `MCHECK_DISABLED` 在第一次分配前未调用 `mcheck()`。一致性检查无法完成。

* `MCHECK_OK` 未发现不一致。
 
* `MCHECK_HEAD` 这是块被修改前的数据。这通常发生在当一个数组索引或指针递减的过头时。

* `MCHECK_TAIL` 这是块被修改后的数据。这通常发生在当一个数组索引或指针递减的过头时。

* `MCHECK_FREE` 内存块已经被释放。

另一种在使用 `malloc()` `realloc()` `free()` 检查和防范错误的方法，是设置环境变量 `MALLOC_CHECK_`。当 `MALLOC_CHECK_` 被设置后，一个特殊的（低效率）实现被设计用来容许简单的错误，比如使用相同的参数重复调用 `free()`，or overruns of a single byte (off-by-one bugs)。并不是所有的错误都可以被容许，否则会导致内存泄露。如果 `MALLOC_CHECK_` 置为 `0`，检查到的任何堆损坏会被忽略；如果设置为 `1`，检查到的错误会被打印到标准错误；如果设置为 `2`，立刻调用 `abort()`。这会是有用的，因为不这样做后面可能会发生崩溃，到时候很难出来错误的真正原因。

`MALLOC_CHECK_` 存在一个问题：对于 SUID 或 SGID 二进制文件。它可能会被利用，因为它偏离正常程序的行为，会往标准错误描述符写入内容。因此，对 SUID 和 SUID 二进制文件，`MALLOC_CHECK_` 默认是禁用的。系统管理员可以添加一个文件 */etc/suid-debug* 再次启用（内容不重要，文件可以是空的）。

那么，`MALLOC_CHECK_` 和 `-lmcheck` 之间有什么区别呢？ `MALLOC_CHECK_` 和 `-lmcheck` 是正交关系。`-lmcheck` 的出现是为了向后兼容。`MALLOC_CHECK_` 和 `-lmcheck` 都发现相同的错误，但是使用 `MALLOC_CHECK_` 你不需要重新编译你的应用程序。

### 内存分配的挂钩

GNU C 库允许你修改 `malloc()` `realloc()` `free()` 的行为，这是通过指定适当的挂钩函数。例如，你可以使用这些挂钩来帮助你调试使用动态内存分配的程序。

####: #include &lt;malloc.h&gt;

```c
#include <malloc.h>
```

####: __malloc_hook

```c
__malloc_hook
```

这个变量的值是一个指向函数的指针，只要 `malloc()` 被调用，就会使用它。你应该定义这个函数看起来像 `malloc()`，就像这样：

```c
void *function(size_t size, const void *caller);
```

`caller` 的值是当 `malloc()` 函数被调用时返回的栈地址。这个值可以让你跟踪程序的内存消耗。

####: __realloc_hook

```c
__realloc_hook
```

这个变量的值是一个指向函数的指针，只要 `realloc()` 被调用，就会使用它。你应该定义这个函数看起来像 `realloc()`，就像这样：

```c
void *function(void *ptr, size_t size, const void *caller);
```

`caller` 的值是当 `realloc()` 函数被调用时返回的栈地址。这个值可以让你跟踪程序的内存消耗。

####: __free_hook

```c
__free_hook
```

这个变量的值是一个指向函数的指针，只要 `free()` 被调用，就会使用它。你应该定义这个函数看起来像 `free()`，就像这样：

```c
void function(void *ptr, const void *caller);
```

`caller` 的值是当 `free()` 函数被调用时返回的栈地址。这个值可以让你跟踪程序的内存消耗。

####: __memalign_hook

```c
__memalign_hook
```

这个变量的值是一个指向函数的指针，只要 `aligned_alloc()`、`memalign()`、`posix_memalign()`、`valloc()` 被调用，就会使用它。你应该定义这个函数看起来像 `aligned_alloc()`，就像这样：

```c
void *function(size_t alignment, size_t size, const void *caller);
```

`caller` 的值是当 `aligned_alloc()`、`memalign()`、`posix_memalign()`、`valloc()` 函数被调用时，返回的栈地址。这个值可以让你跟踪程序的内存消耗。

You must make sure that the function you install as a hook for one of these functions does not call that function recursively without restoring the old value of the hook first! Otherwise, your program will get stuck in an infinite recursion. Before calling the function recursively, one should make sure to restore all the hooks to their previous value. When coming back from the recursive call, all the hooks should be resaved since a hook might modify itself. 

####: __malloc_initialize_hook

```c
__malloc_initialize_hook
```

这个变量的值是一个指向函数的指针，只要 `malloc()` 实现被初始化时，就会使用它。这是一个弱变量，所以它可以像下面这样被重写：

```c
void (*__malloc_initialize_hook)(void) = my_init_hook;
```

An issue to look out for is the time at which the malloc hook functions can be safely installed. If the hook functions call the malloc-related functions recursively, it is necessary that malloc has already properly initialized itself at the time when `__malloc_hook` etc. is assigned to. On the other hand, if the hook functions provide a complete malloc implementation of their own, it is vital that the hooks are assigned to before the very first malloc call has completed, because otherwise a chunk obtained from the ordinary, un-hooked malloc may later be handed to `__free_hook`, for example. 

In both cases, the problem can be solved by setting up the hooks from within a user-defined function pointed to by `__malloc_initialize_hook`—then the hooks will be set up safely at the right time. 

这里有一个例子展示了如何正确使用 `__malloc_hook` 和 `__free_hook`。它为 `malloc()` 和 `free()` 安装了一个函数，每次调用它们时打印信息。另外，我们同时假定程序中不会用到 `realloc()` 和 `memalign()`：

```c
/* Prototypes for __malloc_hook, __free_hook */
#include <malloc.h>

/* Prototypes for our hooks.  */
static void my_init_hook(void);
static void *my_malloc_hook(size_t, const void *);
static void my_free_hook(void*, const void *);

/* Override initializing hook from the C library. */
void (*__malloc_initialize_hook)(void) = my_init_hook;

static void my_init_hook(void) {
    old_malloc_hook = __malloc_hook;
    old_free_hook = __free_hook;
    __malloc_hook = my_malloc_hook;
    __free_hook = my_free_hook;
}

static void *my_malloc_hook(size_t size, const void *caller) {
    void *result;
    /* Restore all old hooks */
    __malloc_hook = old_malloc_hook;
    __free_hook = old_free_hook;
    /* Call recursively */
    result = malloc(size);
    /* Save underlying hooks */
    old_malloc_hook = __malloc_hook;
    old_free_hook = __free_hook;
    /* printf might call malloc, so protect it too. */
    printf ("malloc (%u) returns %p\n", (unsigned int) size, result);
    /* Restore our own hooks */
    __malloc_hook = my_malloc_hook;
    __free_hook = my_free_hook;
    return result;
}

static void my_free_hook(void *ptr, const void *caller) {
    /* Restore all old hooks */
    __malloc_hook = old_malloc_hook;
    __free_hook = old_free_hook;
    /* Call recursively */
    free(ptr);
    /* Save underlying hooks */
    old_malloc_hook = __malloc_hook;
    old_free_hook = __free_hook;
    /* printf might call free, so protect it too. */
    printf ("freed pointer %p\n", ptr);
    /* Restore our own hooks */
    __malloc_hook = my_malloc_hook;
    __free_hook = my_free_hook;
}

int main () {
    …
}
```

安装这样的挂钩后，`mcheck()` 函数与新挂钩一起工作。

> 译注：上面的英文和示例代码可以这样表示：
>
```c
__malloc_initialize_hook() // 在程序启动时会初始化 malloc()，调用此钩子。 
                           // 我们可以在这里配置一下需要的内容
>
malloc():                  // 当你在外部调用 malloc() 的时候
    my_malloc_hook():      // 转向你的挂钩
        rest hook default  // 把 malloc 的挂钩函数置为默认，原因看下面
        do some thing      // 你的自定义操作
        malloc()           // 内部再次执行 malloc()，这时候它会再去调用它的挂钩，
                           // 因为我们上边把它的挂钩恢复到默认了，所以它的挂钩什么
                           // 也不做，这样就不会产生无限递归地调用自己了，此时 
                           // 的 malloc() 按照默认行为分配内存
        rest hook my       // 把 malloc 的挂钩函数恢复为我们自己的，这样下次再次
                           // 调用 malloc()，仍然从我们的挂钩开始
                           //
                           // free 的挂钩也是相同道理
```

### 统计 malloc 内存分配

你可以通过 `mallinfo()` 函数获取动态内存分配的信息。这个函数及其相关的数据类型的声明在 `<malloc.h>`；它们是标准 SVID / XPG 版本的扩展。

####: #include &lt;malloc.h&gt;

```c
#include <malloc.h>
```

####: struct mallinfo

```c
struct mallinfo {
    int arena;     // 非 `mmap()` 分配的空间大小 （字节）
    int ordblks;   // 这是空闲块的数量（内存分配器从操作系统得到内存块，然后切分后以满足分配请求）
    int smblks;    // 这个字段未使用
    int hblks;     // 通过 `mmap()` 分配的块的数量
    int hblkhd;    // 通过 `mmap()` 分配的空间大小 （字节）
    int usmblks;   // 这个字段未使用
    int fsmblks;   // 这个字段未使用
    int uordblks;  // 分配的空间总大小 （字节）
    int fordblks;  // 空闲的空间总大小 （字节）
    int keepcost;  // Top-most, releasable space （字节）
};
```

####: mallinfo()

```c
struct mallinfo mallinfo(void);
```

这个函数返回当前动态内存的使用情况，该信息用 `struct mallinfo` 填充。

## 调试分配

对于不使用 GC （垃圾收集器） 的编程语言，有个很麻烦的任务就是查找内存泄露。长时间运行的程序必须保证：动态分配的对象在其生命周期结束时被释放了。如果没有这么做，系统早晚会被耗尽内存。

在 GNU C 库中提供了一些简单的方法，用来发现这样的泄露，并找到所在的位置。要做到这一点，你的应用程序必须设定一个环境变量，以调试模式启动。如果不启用调试模式，对程序没有性能损耗（启用了就有损耗咯，所以，发布的时候去掉调试模式）。

### 如何安装追踪功能？

####: #include &lt;mcheck.h&gt;

```c
#include <mcheck.h>
```

####: mtrace()

```c
void mtrace(void);
```

* Preliminary: | MT-Unsafe env race:mtrace const:malloc_hooks init | AS-Unsafe init heap corrupt lock | AC-Unsafe init corrupt lock fd mem |

当调用 `mtrace()` 函数时，它查找一个名叫 `MALLOC_TRACE` 的环境变量。这个变量应该包含一个有效的文件名。当前用户必须有写访问权限。如果文件已存在，则截断。如果这个环境变量没有被设置，或者它不是一个有效的文件名，那么 `mtrace()` 什么都不做。另外，如果应用程序安装配置了 SUID 或者 SGID，`mtrace()` 也同样什么都不做。

如果指定的文件被成功打开，`mtrace()` 会为 `malloc()`、`realloc()`、`free()` 安装特殊的处理程序（参看挂钩函数）。从那时起，所有这些函数的调用都会被追踪，并且写入到文件。当然了，这会产生性能损耗，所以，在你发布程序的时候不应该启用追踪。

这个函数是 GNU 扩展，通常在其他系统上不可用。

####: muntrace()

```c
void muntrace(void);
```

* Preliminary: | MT-Unsafe race:mtrace const:malloc(分配内存)_hooks locale | AS-Unsafe corrupt heap | AC-Unsafe corrupt mem lock fd |

`muntrace()` 可以在调用 `mtrace()` 后使用，用来启用追踪 `malloc()` 调用。如果没有（成功）调用 `mtrace()`，`muntrace()` 什么也不做。

另外，它卸载为 `malloc()`、`realloc()`、`free()` 安装的处理程序，然后关闭追踪文件。不再有任何的追踪，程序也不再有性能损耗。

这个函数是 GNU 扩展，通常在其他系统上不可用。

### 程序示例摘录

尽管追踪功能不影响程序的运行时行为，但是在所有程序调用 `mtrace()` 并不是一个好主意。Just imagine that you debug a program using mtrace and all other programs used in the debugging session also trace their malloc calls. 所有程序的输出文件都会是相同的，因此不能用了。所以，你应该只在编译调试的时候调用 `mtrace()`。一个程序可以这样开始：

```c
#include <mcheck.h>
     
int main (int argc, char *argv[]) {
#ifdef DEBUGGING
    mtrace ();
#endif
    ...
}
```

作为一种需要，你可能想在程序的整个运行时追踪调用。那么，你可以随时随地调用 `muntrace()` 停止追踪。甚至，调用 `mtrace()` 重新启动追踪也是可以的。不过，这可能会产生不可靠的结果，since there may be calls of the functions which are not called。请注意，不仅应用程序使用追踪函数，库（包括 C 库本身）也使用这些函数。

最后一点，为什么在程序终止前调用 `muntrace()` 不是好主意。只有在程序通过 `main()` 返回或者调用 `exit()` 时，（程序使用的 GNU C）库才被通知程序结束，在此之前不能释放它们使用的内存。

所以，最好的方法是，在程序中把 `mtrace()` 作为第一个函数调用，并且永远不调用 `muntrace()`。这样，可以追踪到程序中几乎所有的 malloc 函数族。(except those calls which are executed by constructors of the program or used libraries). 【译注：说的不清不楚，反正你就这么做吧】

### 一些或多或少的好主意

下面的程序，你懂的。这个程序准备了调试，并在所有的调试会话中都运行良好。但一旦去掉调试模式进行启动，错误就出来了。一个典型的例子是内存泄漏，只有当我们关闭调试时才会出现。这段程序如下所示：

```c
#include <mcheck.h>
#include <signal.h>

static void enable (int sig) {
    mtrace();
    signal(SIGUSR1, enable);
}

static void disable (int sig) {
    muntrace();
    signal(SIGUSR2, disable);
}

int main (int argc, char *argv[]) {
    ...

    signal(SIGUSR1, enable);
    signal(SIGUSR2, disable);

    ...
}
```

如果用户想的话，他/她可以通过设置环境变量 `MALLOC_TRACE` 启动程序，来开始内存调试。在第一次收到信号前当然不会有问题，但是一旦收到信号内存泄露就出现了。

### 使用 mtrace 打印追踪结果

如果你看一下追踪文件，它看起来会类似于：

```?
= Start
[0x8048209] - 0x8064cc8
[0x8048209] - 0x8064ce0
[0x8048209] - 0x8064cf8
[0x80481eb] + 0x8064c48 0x14
[0x80481eb] + 0x8064c60 0x14
[0x80481eb] + 0x8064c78 0x14
[0x80481eb] + 0x8064c90 0x14
= End
```

这些数据意味着什么并不重要，因为追踪文件并不是设计为可供人类阅读的。取而代之的是，在 GNU C 库有个工具，可以解释追踪内容并且以用户友好的方式输出消息。这个工具称为 **mtrace**（事实上这是一个 Perl 脚本），它需要一个或两个参数。在任何一种情况，都必须指定追踪输出的文件名。追踪文件名前是一个可选的参数--追踪的程序名。

```sh
$ mtrace app error.log
No memory leaks.
```

在这个例子中，程序 app 正在运行，并且产生追踪文件 error.log。**mtrace** 打印消息，表示没有内存泄露。如果我们在程序中调用 `mtrace()`，则会得到不同的输出：

```?
$ mtrace error.log
- 0x08064cc8 Free 2 was never alloc'd 0x8048209
- 0x08064ce0 Free 3 was never alloc'd 0x8048209
- 0x08064cf8 Free 4 was never alloc'd 0x8048209

Memory not freed:
-----------------
  Address     Size     Caller
0x08064c48     0x14  at 0x80481eb
0x08064c60     0x14  at 0x80481eb
0x08064c78     0x14  at 0x80481eb
0x08064c90     0x14  at 0x80481eb
```

我们只给 **mtrace** 提供了一个参数，所以它没有办法找到出现问题的地址。我们可以做的更好：

```?
$ mtrace app error.log
- 0x08064cc8 Free 2 was never alloc'd /home/drepper/tst.c:39
- 0x08064ce0 Free 3 was never alloc'd /home/drepper/tst.c:39
- 0x08064cf8 Free 4 was never alloc'd /home/drepper/tst.c:39

Memory not freed:
-----------------
  Address     Size     Caller
0x08064c48     0x14  at /home/drepper/tst.c:33
0x08064c60     0x14  at /home/drepper/tst.c:33
0x08064c78     0x14  at /home/drepper/tst.c:33
0x08064c90     0x14  at /home/drepper/tst.c:33
```

突然间，输出带来了更多的快感，我们可以立即看出是哪里出现了问题。

解释上面的输出并不复杂。有两个不同的错误被发现了。首先，`free()` 调用的参数指针，不是分配函数返回的指针。这通常是一个非常糟糕的问题，前三行显示了这个问题。这种情况的出现非常罕见，但是一旦出现就很容易导致程序崩溃。

更难检查的另一情况是内存泄漏。正如上面显示的 “Memory not freed”，在 /home/drepper/tst.c 源文件中有四次没有正确地释放内存。这是否会引起真正的问题，还有待进一步调查。

> 调试步骤
>
```sh
> $ gcc app.c -o app -g              # 编译源代码，开启调试模式
> $ export MALLOC_TRACE=error.log    # 设置环境变量 MALLOC_TRACE，指定输出文件
> $ ./app                            # 运行程序
> $ mtrace app error.log             # 打印追踪信息
```

## 内存池

obstack 是一个内存池，它包含一个对象栈。你可以创建任意数量的独立的 obstack，然后在指定的 obstack 中分配对象。对于每一个 obstack，最后一个被分配的对象，必须第一个被释放（要不怎么叫栈呢）。不同的 obstack 之间不受影响，它们是独立的。

除了释放顺序的限制之外，obstack 是完全通用的：一个 obstack 可以包含任意数量的任意大小的对象。它们是用宏实现的，因此，只要对象不是很大，分配通常都会很快。而且，每个对象唯一的空间开销，是对象之间为了边界对齐所花费的字节填充。

> 译注：obstack 有点像面向对象的 Object，但是要底层和精致多了。Nim 语言中的 `seq[T]` 跟它很类似。

### 创建 obstack

####: #include &lt;obstack.h&gt;

```c
#include <obstack.h>
```

####: struct obstack

```c
struct obstack;
```

obstack 通过一个结构类型 `struct obstack` 表示。这个结构的大小是固定的，很小。它记录了 obstack 的状态，以及如何查找对象已分配的空间。它不包含对象本身（只是个状态记录，对象本体被“封装”了）。你不应该尝试直接访问这个结构的成员，而应该使用它的接口函数。

你可以直接声明一个 `struct obstack` 变量作为 obstack 使用；另外，你也可以动态地分配 obstack 。动态分配允许你拥有数量可变的对象栈。

所有 obstack 的接口函数，都要求指定 obstack 实例。你可以对其传递一个指针 `struct obstack *`。（就是对象引用）。

obstack 分配的对象，被打包成大块。`struct obstack` 指向该串起来的大块。 

> obstack 库会自动管理内存块的分配。通常，你只需要提供一个分配函数（直接或者间接地调用 `malloc()`），以及一个释放函数。【所谓构造器和析构器，但是更精巧】

### 准备使用 obstack

你的每个使用 obstack 的源文件都应该导入头文件 `<obstack.h>`。

此外，如果源文件想调用宏 `obstack_init()`，那么必须声明或定义两个函数或者宏，obstack 库需要调用它们：一个是 `obstack_chunk_alloc()`，用来给对象分配内存空间；另一个是 `obstack_chunk_free()`，用于释放对象的内存空间。

通常，你可以像下面这样用宏定义：

```c
#define obstack_chunk_alloc xmalloc
#define obstack_chunk_free  free 
```

尽管使用 obstack 得到的内存空间实际上是来自 `malloc()`，但是通常使用 obstack 更快（比起大量的 `malloc()`）。它通过分配大块内存，减少了 `malloc()` 调用。

####: obstack_init()

```c
int obstack_init(struct obstack *obstack-ptr);
```

* Preliminary: | MT-Safe race:obstack-ptr | AS-Safe | AC-Safe mem |

初始化 obstack，它担负着为对象分配内存空间的任务。这个函数会调用 `obstack_chunk_alloc()` 函数。如果内存分配失败，会调用 `obstack_alloc_failed_handler()` 函数。`obstack_init()` 总是返回 `1`。

> 兼容性注意：之前的版本，在 `obstack_init()` 出错时返回 `0`。

这里有两个例子，演示了如何初始化 obstack：

1. obstack 作为静态变量：

   ```c
   static struct obstack myobstack;
   ...
   obstack_init(&myobstack);
   ```

2. obstack 通过动态分配：

   ```c
   struct obstack *myobstack_ptr = (struct obstack *) xmalloc(sizeof (struct obstack));

   obstack_init(myobstack_ptr);
   ```

####: obstack_alloc_failed_handler

```c
obstack_alloc_failed_handler
```

这个变量的值是一个指向函数的指针，当 `obstack_chunk_alloc()` 分配内存失败时被调用。默认操作是打印一条消息并且中止。你应该提供一个函数，调用 `exit()` 或 `longjmp()`，并且不返回：

```c
void my_obstack_alloc_failed(void)
...
obstack_alloc_failed_handler = &my_obstack_alloc_failed;
```

### 为对象分配内存空间

使用 obstack 为一个对象分配内存空间，最直接的方式是调用 `obstack_alloc()`，这几乎就像调用 `malloc()`。

####: obstack_alloc()

```c
void *obstack_alloc(struct obstack *obstack-ptr, int size);
```

* Preliminary: | MT-Safe race:obstack-ptr | AS-Safe | AC-Unsafe corrupt mem |

这个函数分配一块未初始化的空间，并且返回空间的地址。这里 `obstack-ptr` 指定担负分配任务的 obstack。每个 obstack 函数或者宏都会要求你指定一个 obstack 指针作为第一个参数。

如果需要分配一块新的内存，这个函数就会调用 `obstack_chunk_alloc()`。如果它在调用 `obstack_chunk_alloc()` 失败时，就会调用 `obstack_alloc_failed_handler()`。

举个例子，这有个函数，它分配一块内存来拷贝一个字符串：

```c
struct obstack string_obstack;
     
char *copystring(char *string) {
    size_t len = strlen(string) + 1;
    char *s = (char *) obstack_alloc(&string_obstack, len);
    memcpy(s, string, len);
    return s;
}
```

####: obstack_copy()

```c
void * obstack_copy(struct obstack *obstack-ptr, void *address, int size);
```

* Preliminary: | MT-Safe race:obstack-ptr | AS-Safe | AC-Unsafe corrupt mem |

这个函数分配一块内存空间，并把 `address` 中的数据拷贝到内存空间中，总字节数是 `size`。

如果需要分配一块新的内存，这个函数就会调用 `obstack_chunk_alloc()`。如果它在调用 `obstack_chunk_alloc()` 失败时，就会调用 `obstack_alloc_failed_handler()`。

####: obstack_copy0()

```c
void * obstack_copy0(struct obstack *obstack-ptr, void *address, int size);
```

* Preliminary: | MT-Safe race:obstack-ptr | AS-Safe | AC-Unsafe corrupt mem |

类似 `obstack_copy()`，但是附加了一个额外字节，该字节是一个空字符，并且不会被计算在 `size` 之内。

对于拷贝字符序列并保留终止符，`obstack_copy0()` 是一个非常方便的选择：

```c
char *obstack_savestring(char *addr, int size) {
    return obstack_copy0(&myobstack, addr, size);
}
```

### 释放对象的内存空间

释放 obstack 分配的对象，可以调用 `obstack_free()` 函数。Since the obstack is a stack of objects, freeing one object automatically frees all other objects allocated more recently in the same obstack. 

####: obstack_free()

```c
void obstack_free(struct obstack *obstack-ptr, void *object);
```

* Preliminary: | MT-Safe race:obstack-ptr | AS-Safe | AC-Unsafe corrupt |

如果 `object` 是一个空指针，该 obstack 分配的所有对象都会被释放。否则，`object` 必须是该 obstack 已分配的对象的地址。然后 `object` 被释放，连同它在该 obstack 中存储的状态。

请注意，如果 `object` 是一个空指针，其结果是一个未初始化的 obstack。

如果想释放 obstack 的所有对象，但是保留 obstack 本身以作进一步的分配，可以使用第一个对象的地址调用 `obstack_free()`：

```c
obstack_free (obstack_ptr, first_object_allocated_ptr);
```

> 还记得吧，obstack 中的对象是组合成块的。当一个块的所有对象被释放后，obstack 库会自动释放这个块。然后其他的分配请求，又可以使用这个块的空间了。

### 编译器和  obstack API

obstack 的接口可能被定义为函数也可能被定义为宏，取决于编译器。obstack 工具可以在所有的 C 编译器工作，包括 ISO C 和传统的 C，但是如果你计划使用非 GNU C 编译器就要当心了。

如果你使用的是过时的非 ISO C 编译器，所有 obstack “函数”实际上只会被定义为宏。你可以像函数一样调用这些宏，但不能用其他方式使用它们（例如，你不能获取它们的地址）。

调用宏需要特别的预防措施：第一个操作数（obstack 指针）不可以包含任何副作用，因为它可能会被多次计算。例如，如果你写成：

```c
obstack_alloc(get_obstack(), 4);
```

你会发现 `get_obstack()` 可能会被多次调用。如果你使用 `*obstack_list_ptr++` 作为 obstack 指针参数，你会得到非常奇怪的结果（因为递增）。

在 ISO C 编译器，每个函数都有一个宏定义和一个函数定义。函数定义，是用来获取函数地址的。默认情况下，一个普通调用会使用宏定义，但是你可以通过括号包裹函数名来要求函数定义，如下所示：

```c
char *x;
void *(*funcp)();
/* Use the macro.  */
x = (char *) obstack_alloc(obptr, size);
/* Call the function.  */
x = (char *) (obstack_alloc)(obptr, size);
/* Take the address of the function.  */
funcp = obstack_alloc;
```

> 警告：当你使用宏时，你必须注意避免在第一个操作数中存在副作用，即使是用 ISO C 编译器。

<span>

> 如果你使用 GNU C 编译器，这种预防就没有必要了，因为 GNU C 对宏定义提供了语言扩展，使得每个参数的计算只有一次。【有点卫生宏的意思】

### 生长的对象

因为 obstack 的内存块是按顺序使用的，所以一步一步构建一个对象是可能的，每次添加一个或者多个字节到对象的末端。有了这个技术，你就不需要知道到底需要给对象填入多少数据才能完成它的需求。我们称这种技术为生长的对象。在本节中描述了如何将数据添加到生长对象。

当你开始增长一个对象，你不需要做任何特殊的事情。使用一个函数将数据添加到对象时，会自动启动生长。然而，当对象完成生长时，则必须显式地说明。可以通过 `obstack_finish()` 函数完成。

因此，除非对象完成构建，否则无法获知对象最终的真实地址。在那之前，这总是可能的：由于添加了大量的数据，对象必须被拷贝到新的内存块。

当 obstack 用作生长对象时，你不能把它用来分配普通的对象。如果你尝试这样做，已经添加到生长对象的空间会变成其他对象的一部分。

####: obstack_blank()

```c
void obstack_blank(struct obstack *obstack-ptr, int size);
```

* Preliminary: | MT-Safe race:obstack-ptr | AS-Safe | AC-Unsafe corrupt mem |

这是最基础的添加生长对象的函数，它添加的空间不会被初始化。

####: obstack_grow()

```c
void obstack_grow(struct obstack *obstack-ptr, void *data, int size);
```

* Preliminary: | MT-Safe race:obstack-ptr | AS-Safe | AC-Unsafe corrupt mem |

添加一块初始化的空间，并且拷贝 `data` 的数据，总字节数是 `size`。

####: obstack_grow0()

```c
void obstack_grow0(struct obstack *obstack-ptr, void *data, int size);
```

* Preliminary: | MT-Safe race:obstack-ptr | AS-Safe | AC-Unsafe corrupt mem |

类似 `obstack_grow`，但是附加了一个额外字节，该字节是一个空字符，并且不会被计算在 `size` 之内。

####: obstack_1grow()

```c
void obstack_1grow(struct obstack *obstack-ptr, char c);
```

* Preliminary: | MT-Safe race:obstack-ptr | AS-Safe | AC-Unsafe corrupt mem | 

这个函数每次向生长对象添加一个字符。

####: obstack_ptr_grow()

```c
void obstack_ptr_grow(struct obstack *obstack-ptr, void *data);
```

* Preliminary: | MT-Safe race:obstack-ptr | AS-Safe | AC-Unsafe corrupt mem |

这个函数每次向生长对象添加一个指针。

####: obstack_int_grow()

```c
void bstack_int_grow(struct obstack *obstack-ptr, int data);
```

* Preliminary: | MT-Safe race:obstack-ptr | AS-Safe | AC-Unsafe corrupt mem |

这个函数每次向生长对象添加一个 `int` 值。

####: obstack_finish()

```c
void *obstack_finish(struct obstack *obstack-ptr);
```

* Preliminary: | MT-Safe race:obstack-ptr | AS-Safe | AC-Unsafe corrupt |

当你完成了生长对象，使用 `obstack_finish()` 函数关闭它的生长并返回最终的地址。一旦你已经完成了这个对象，这个 obstack 就可以用于普通分配，或者用来制作另一个生长对象。

如同 `obstack_alloc()` 的条件，这个函数可以返回空指针。

####: obstack_object_size()

```c
void obstack_object_size(struct obstack *obstack-ptr);
```

当你通过生长构建一个对象时，你可能想知道它有多大了。这个函数返回生长对象的当前大小，以字节为单位。记得在完成这个对象前，调用这个函数。否则，`obstack_object_size()` 会返回 `0`。

如果你已经开始生长一个对象，并想要取消它，你应该先完成它，然后释放它，像这样：

```c
obstack_free(obstack_ptr, obstack_finish(obstack_ptr));
```

如果传入的不是生长对象，将没有任何作用。

你可以在调用 `obstack_blank()` 时传入负的 `size`，使当前对象更小。只是不要设为 `0`，如果你这样做不知道会发生什么。

### 快速生长的对象

在构建生长对象时，需要经常地检查当前的块是否还有足够的空间来存放新的数据，这带来了额外的性能损耗。如果你构建对象时频繁地增长，这个损耗就比较明显了。

你可以通过特殊的“快速生长”函数减少损耗，它们在增长时不会执行检查。为了有一个健壮的程序，你必须自己做检查。如果你只是在每次把数据添加到对象时执行（自己的）检查，那等于无用功，因为这些正是普通生长函数做的。但是如果你的检查更少，或者更有效率，那么你就可以使程序更快。想知道怎么做，请往下看。

####: obstack_room()

```c
int obstack_room(struct obstack *obstack-ptr);
```

* Preliminary: | MT-Safe race:obstack-ptr | AS-Safe | AC-Safe |

这个函数返回当前可以安全地添加到生长对象的字节数。这些字节数是当前块的可用空间。当你知道了可用空间的大小，你就可以用下面的快速生长函数往对象添加数据。

####: obstack_1grow_fast()

```c
void obstack_1grow_fast(struct obstack *obstack-ptr, char c);
```

* Preliminary: | MT-Safe race:obstack-ptr | AS-Safe | AC-Unsafe corrupt mem |

这个函数每次向生长对象添加一个字符。

####: obstack_ptr_grow_fast()

```c
void obstack_ptr_grow_fast(struct obstack *obstack-ptr, void *data);
```

* Preliminary: | MT-Safe race:obstack-ptr | AS-Safe | AC-Safe |

这个函数每次向生长对象添加一个指针。

####: obstack_int_grow_fast()

```c
void obstack_int_grow_fast(struct obstack *obstack-ptr, int data);
```

* Preliminary: | MT-Safe race:obstack-ptr | AS-Safe | AC-Safe |

这个函数每次向生长对象添加一个 `int` 值。

####: obstack_blank_fast()

```c
void obstack_blank_fast(struct obstack *obstack-ptr, int size);
```

* Preliminary: | MT-Safe race:obstack-ptr | AS-Safe | AC-Safe |

这个函数每次向生长对象添加 `size` 字节，它们没有被初始化。

当你调用 `obstack_room()` 检查空间但是没有你想要的足够空间时，使用这些快速生长函数是不安全的。这时候，请使用普通生长函数。很快的，这会把对象拷贝到新块（旧的块已经放不下了），然后你就能获得足量的可用空间了（使用快速生长函数）。

所以，每当你用了一个普通生长函数，就调用 `obstack_room()` 检查是否有足量的可用空间。一旦对象被拷贝到一个新块，会再次获得大量可用的空间，所以程序能够开始使用快速生长函数。

这里就是一个例子：

```c
void add_string (struct obstack *obstack, const char *ptr, int len) {
    while (len > 0) {
        int room = obstack_room(obstack);
        if (room == 0) {
            /* Not enough room. Add one character slowly,
               which may copy to a new chunk and make room. */
            obstack_1grow(obstack, *ptr++);
            len--;
        } else {
            if (room > len)
                room = len;
            /* Add fast as much as we have room for. */
            len -= room;
            while (room-- > 0)
                obstack_1grow_fast(obstack, *ptr++);
        }
    }
}
```

### obstack 的状态

这里的函数可以用来查看 obstack 的状态。你可以在对象正在增长的时候，调用这些函数来获取信息。

####: obstack_base()

```c
void *obstack_base(struct obstack *obstack-ptr);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Safe |

这个函数返回当前生长对象开始的地址。如果你完成了这个对象，返回的就是最终地址。如果你使对象增大了，它的地址可能会改变！

如果没有对象在增长，这个地址表示你的下一个对象将在哪里开始分配。

####: obstack_next_free()

```c
void *obstack_next_free(struct obstack *obstack-ptr);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Safe |

这个函数返回当前块的的第一个空闲字节的地址。它是当前生长对象已用空间的尾端。如果没有对象在增长，`obstack_next_free()` 返回和 `obstack_base()` 相同的值。

####: obstack_object_size()

```c
void *obstack_object_size(struct obstack *obstack-ptr);
```

* Preliminary: | MT-Safe race:obstack-ptr | AS-Safe | AC-Safe | 

这个函数返回当前生长对象已用空间的大小。等价于：

```c
obstack_next_free(obstack-ptr) - obstack_base(obstack-ptr);
```

### obstack 的数据对齐

每个 obstack 都有对齐的边界。每个在 obstack 分配的对象，自动地从一个地址开始，这个地址是指定边界的倍数。默认情况下，边界是对齐的，以便对象可以容纳任何类型的数据。

####: obstack_alignment_mask()

```c
int obstack_alignment_mask(struct obstack *obstack-ptr);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

这个函数的返回值是位掩码，这个掩码的主要作用是影响 obstack 对象的对齐规则。a bit that is 1 indicates that the corresponding bit in the address of an object should be 0. The mask value should be one less than a power of 2; the effect is that all object addresses are multiples of that power of 2. 这个掩码的默认值，是一个允许对象对齐的值：例如，如果掩码值是 `3`，任何类型的数据可存储的地址就是 `4` 的倍数。掩码值是 `0`，表示对象可存储的地址是 `1` 的倍数（也就是说，不再对齐对象）。

我们对 `obstack_alignment_mask()` 宏做了扩展，它可以是左值，因此你可以通过赋值改变掩码。例如：

```c
obstack_alignment_mask(obstack_ptr) = 0;
```

上面的例子关闭了指定的 obstack 的对齐处理。

注意，修改掩码只能对后来分配的对象或者准备完成的对象产生影响。如果你没有在增长对象，你可以调用 `obstack_finish()` 以便立刻受到掩码修改的影响。这会完成一个 `0` 长度的对象，并且对下一个对象做适当对齐。

### obstack 块

obstack 的工作机制，是用大块来存放各个对象空间。块通常是 `4096B`，除非你指定了一个不同的块大小。块大小包括 `8B` 的开销，它们并不用于存储对象。当需要存储更大的对象时，会分配更大的块。

obstack 库调用 `obstack_chunk_alloc()` 函数来分配块，你必须定义这个函数。当你已经释放了块内所有的对象时，这个块就不再需要了，obstack 库会调用 `obstack_chunk_free()` 函数释放这个块，你也必须定义这个函数。

这两个必须定义（宏）或声明（函数）在每个使用 `obstack_init()`的源文件。通常被定义为这样的宏：

```c 
#define obstack_chunk_alloc malloc
#define obstack_chunk_free  free
```

请注意，这些都是简单的宏（没有参数）。带参数的宏定义不能工作！对于 `obstack_chunk_alloc()` 和 `obstack_chunk_free()`，这么设定是必需的。

如果你使用 `malloc()` 分配块，块大小应该是 `2的幂`。默认的块大小是 `4096B`，因为它足够长，可以满足许多典型的请求；另一方面，又不够短，可能会浪费过多的内存。

####: obstack_chunk_size()

```c
int obstack_chunk_size(struct obstack *obstack-ptr);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe | 

这个宏返回指定的 obstack 的块大小。

这个宏被扩展为左值，你可以通过赋值指定一个新的块大小。这样做不会影响已分配的块，但会改变将来分配的块的大小（还记得吗，生长对象的块是随着数据增长而产生变化的：当放不下数据时，就分配更大的块，并把数据复制过去，释放旧有的块）。如果你用来缩小块的大小，基本没什么意义；但是增加块的大小，对于分配许多对象，尺寸够大的情况，则能带来可观的性能改善（减少复制和再分配）。这里是一个例子：

```c
if (obstack_chunk_size(obstack_ptr) < new-chunk-size)
    obstack_chunk_size(obstack_ptr) = new-chunk-size;
```

## 可自动释放的存储

`alloca()` 函数支持一种半动态分配：动态分配，自动释放。

使用 `alloca()` 分配块是一个显式的操作，你可以分配任意数量的块，并在在运行时计算块的大小。但是当你退出 `alloca()` 所在的函数空间时，所有的块会被自动释放。

###: #inlcude &lt;stdlib.h&gt;

```c
#include <stdlib.h>
```

###: alloca()

```c
void *alloca(size_t size);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

返回值是分配内存块的地址，内存是在栈上分配的。

不要使用在函数调用的参数中使用 `alloca()`，你会得到不可预知的结果，因为 `alloca()` 分配的栈空间只会出现在函数实参所在的空间。举一个例子，要避免 `foo(x, alloca(4), y)`。

这里是一个例子，打开一个文件名，并返回一个文件描述符：

```c
int open2(char *str1, char *str2, int flags, int mode){
    char *name = (char *) alloca(strlen(str1) + strlen(str2) + 1);
    stpcpy(stpcpy(name, str1), str2);
    return open(name, flags, mode);
}
```

这个例子，使用 `malloc()` 和 `free()` 得到同样的结果：

```c
int open2(char *str1, char *str2, int flags, int mode){
    char *name = (char *) malloc(strlen(str1) + strlen(str2) + 1);
    int desc;
    if (name == 0)
        fatal("virtual memory exceeded");
    stpcpy(stpcpy(name, str1), str2);
    desc = open(name, flags, mode);
    free(name);
    return desc;
}
```

你可以看到，`alloca()` 更加简单。

### alloca 的优点

`alloca()` 比 `malloc()` 的优势在于：

* 使用 `alloca()` 浪费的空间非常小，很快。（它是 GNU C 编译器的开源代码）

* 由于 `alloca()` 没有对不同大小的块建立单独的池，任何大小的分配过的空间都可被重用。`alloca()`　不会引起内存碎片。

* 使用 `longjmp()` 在外部退出，会自动释放通过 `alloca()` 分配的内存。这是使用 `alloca()` 的最重要的原因。

  为了说明这一点，假设你有一个函数 `open_or_report_error()` 返回一个描述符，类似 `open()`，如果它成功了就返回，但如果失败则不返回到调用者。如果文件无法打开，它打印一条错误消息，并且使用 `longjump()` 跳出到程序的命令级别：

```c
int　open2(char *str1, char *str2, int flags, int mode){
    char *name = (char *) alloca(strlen(str1) + strlen(str2) + 1);
    stpcpy(stpcpy(name, str1), str2);
    return open_or_report_error(name, flags, mode);
}
```

由于 `alloca()` 的工作方式，它分配的内存甚至会在遇到错误时被自动释放。

相比之下，第二种 `open2()` 的实现会存在内存泄漏的问题。

### alloca 的缺点

`alloca()` 比 `malloc()` 的缺点在于：

* 如果你试着分配超出机器可以提供的内存，你无法得到一个清晰的错误消息。相反，你得到一个致命的信号，像是“你调用了一个无限递归”、“可能是一个段错误”。

* 一些非 GNU 系统不支持 `alloca()`，所以它的可移植性较差。然而，用 Ｃ 编写的一个慢点的 `alloca()` 模拟，可以弥补这个问题。

### GNU C 可变大小的数组

在 GNU C 中，你可以用可变大小的数组代替 `alloca()`。如下所示：

```c
int open2(char *str1, char *str2, int flags, int mode) {
    char name[strlen(str1) + strlen(str2) + 1];
    stpcpy(stpcpy(name, str1), str2);
    return open(name, flags, mode);
}
```

但是 `alloca()`1 并不总是等价于一个可变大小的数组，有几个原因：

* 一个可变大小的数组的空间，是在所在作用域结束时释放。`alloca()` 分配的空间则是直到函数结束才被释放。

* 循环中使用 `alloca()` 是可能的，每次迭代分配一个额外的块。对于可变大小的数组，这是不可能的。

注意：如果你在一个函数中混合使用 `alloca()` 和可变大小的数组，退出可变大小数组的作用域，会释放所有 `alloca()` 分配的块。
