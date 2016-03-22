# [内存映射 IO](https://www.gnu.org/software/libc/manual/html_node/Memory_002dmapped-I_002fO.html#Memory_002dmapped-I_002fO)

在现代操作系统，可以把一个文件映射到内存。当这么做后，访问这个文件就如同访问一个数组。

这种方式比 `read()` 和 `write()` 高效的多，因为文件只有一部分区域被加载到内存。访问未被加载的区域，和页面故障的处理方式相同---内核把页在物理内存和磁盘文件之间移动，交换掉暂时不用的页，换入需要访问的页。

Since mmapped pages can be stored back to their file when physical memory is low, it is possible to mmap files orders of magnitude larger than both the physical memory and swap space. 唯一的限制是地址空间。在 32 位系统上，理论上的限制是 `4GB`，实际上这个限制会更小，因为一些区域会被保留作为他用。If the LFS interface is used the file size on 32-bit systems is not limited to 2GB (offsets are signed which reduces the addressable area of 4GB by half); the full 64-bit are available. 

内存映射以页为单位工作。因此，映射的地址必须是页对齐的，长度会被取整。确定一台机器的页大小，使用 `size_t page_size = (size_t) sysconf (_SC_PAGESIZE);`。

## API

###: #include &lt;sys/mman.h&gt;

```c
#include <sys/mman.h>
```

###: mmap()

```c
void * mmap(void *address, size_t length, int protect, int flags, int fd, off_t offset);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

`mmap()` 函数创建一个新的映射，连接到打开的文件 `fd`，文件范围是从 `offset` 字节到 `offset + length - 1` 字节。同时为指定的文件创建一个新的引用，关闭文件不会移除这个引用。

`address` 指定映射的起始地址，该地址之前的任何映射都会被移除。置为 `NULL` 表示由内核决定。你给出的这个地址可能会被替换掉，除非你指定了 `MAP_FIXED` 标志位。

`protect` 指定可被访问的权限，它是一个标志位（`|`）。包括：

* `PROT_READ` 可读
* `PROT_WRITE` 可写
* `PROT_EXEC` 可执行

> 注意：当只有写权限没有读权限时，大多数硬件不能支持；而且许多硬件也无法区分读权限和执行权限。因此，你应该把访问权限设定的宽泛些，比如：授予写权限时同时授予读权限，授予执行权限时同时授予读权限。

`flags` 指定映射的行为，它是一个标志位（`|`）。必须指定 `MAP_SHARED` 或 `MAP_PRIVATE` 中的一个。包括：

* `MAP_PRIVATE` 当向内存区域写入数据时，永远不写回到文件。代替的是，进程会执行复制，并且当物理内存低的时候，区域会被交换。其他进程看不到这些变化。

  由于私有映射会把数据复制到普通内存，当你指定了 `PROT_WRITE` 权限位时，你必须有足够的虚拟内存，来提供对内存区域的复制。

* `MAP_SHARED` 当向内存区域写入数据时，将其写回到文件。内存区域是共享的，当发生改变时，其他进程可以立刻看到。

  注意：写回到文件可能在任何时候发生。如果要确保立刻写回到文件，你需要调用 `msync()`。

* `MAP_FIXED` 强制系统使用指定的映射地址，如果不能执行则失败。不可移植，不鼓励使用！！！

* `MAP_ANONYMOUS` `MAP_ANON` 告诉内核，创建一个匿名映射，而不是连接到文件。`fd` 和 `offset` 会被忽略，并且内存区域被初始化为 `0`。，

  匿名映射，常用作内核扩展堆的原语。也常用在多任务之间共享数据。

  在一些系统上，分配大块内存时，使用匿名映射比用 `malloc()` 更高效。对于 GNU C 库这很容易，因为内置的 `malloc()` 在分配大块内存时会自动调用 `mmap()` 制造匿名映射。

  译注：映射到 */dev/null* 设备文件，也能享受到类似匿名映射的好处。毕竟匿名映射是 GNU C 独有的，可移植性不够好。

执行成功时，返回新映射的地址；出现错误时，返回 `MAP_FAILED`，并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EINVAL` 指定的 `address` 不可用，或者与指定的 `flags` 不一致。

* `EACCES` 指定的 `protect` 权限，不符合文件被打开时设定的访问权限。

* `ENOMEM` 没有足够的内存，或者进程不在地址空间。

* `ENODEV` 这个文件不支持内存映射。

* `ENOEXEC` 这个文件所在的文件系统不支持内存映射。

> 不是所有的文件描述符都可被映射。套接字、管道和大多数设备，它们只允许连续访问，不支持内存映射。另外，一些旧的内核可能也不支持内存映射。因此，你的程序中应该提供一个回调函数，以应对无法使用 `mmap()` 的情况。[→ 参看内存映射]()

###: mmap64()

```c
void * mmap64(void *address, size_t length, int protect, int flags, int fd, off64_t offset);
```

> `mmap64()` 函数类似 `pwrite()`。唯一的不同是：在 32 位系统，打开的文件使用“大文件模式”。在该模式下，文件的最大长度是 <code>2<sup>63</sup>bytes</code>，文件的偏移范围是 <code>-2<sup>63</sup></code> 到 <code>2<sup>63</sup></code>。并外，允许对文件的访问大于 `2GB`。文件描述符 `fd` 必须是用 `open64()`、`fopen64()`、`freopen64()` 打开的，否则会发生错误。

<span>

> 当源代码通过 `_FILE_OFFSET_BITS == 64` 编译时，`mmap()` 函数实质上执行 `mmap64()` 函数。也就是说，扩展 API 使用 64 位文件长度和文件偏移，透明地替换掉旧的 API。 

###: munmap()

```c
int munmap(void *addr, size_t length);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

`munmap()` 函数移除任何从 `addr` 到 `addr + length` 的内存映射。` length` 应该是映射的长度。

通过一条命令移除多个映射，是安全的，即便包含的范围不是映射空间。只移除已存在映射的一部分也是可以的。不过，移除是以整个页为单位的。如果 `length` 不是页的倍数，它会被取整。

成功时返回 `0`，出错时返回 `-1` 并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EINVAL` 指定的内存范围超出了映射的范围，或者不是页对齐的。

###: msync()

```c
int msync(void *address, size_t length, int flags);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

当使用共享映射时，在映射被取消前，内核会在任意时间把区域的数据写回文件。想要确保数据确实被写到文件，就需要 `msync()`。

`msync()` 操作 `address` 到 `address + length` 的区域。它可被用在一个或多个映射的一部分，但是给出的范围不应该包含未映射的空间。

`flags` 是一个选项标志位：

* `MS_SYNC ` 指定数据确实被写到磁盘。通常 `msync()` 只保证数据被写到内核缓冲区。

* `MS_ASYNC` 告诉 `msync()` 开始同步，但是不等待它完成。

执行成功时返回 `0`，出错时返回 `-1` 并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EINVAL` 指定的区域无效，或者 `flags` 无效。

* `EFAULT` 指定的区域不存在内存映射。

###: mremap()

```c
void * mremap(void *address, size_t length, size_t new_length, int flag);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe | 

`mremap()` 函数用来修改已存在内存映射的尺寸。`address` 和 `length` 必须完全覆盖一个映射。返回一个新的映射，长度是 `new_length`，和旧的映射特征相同。

`flags` 只有一个选项：`MREMAP_MAYMOVE`。如果被指定，内核可能移除已存在的映射，然后创建一个新的映射。

执行成功时返回新映射的地址，出错返回一个空指针并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EINVAL` 指定的地址不正确。

* `EFAULT` 指定的区域不存在映射，或者覆盖了两个或更多个映射。

* `EAGAIN` 指定的区域已经被页锁定，如果扩充它，会超出进程锁页的上限。

* `ENOMEM` 指定的区域是私有可写的，虚拟内存不足以执行复制。另外，如果没有指定 `MREMAP_MAYMOVE`，扩充会与另一个映射冲突（重叠）的时候也会出现。

> 这个函数只对少数系统有效。除了一些优化目的外，你不应该用这个函数。

###: madvise()

```c
int madvise(void *addr, size_t length, int advice);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

`madvise()` 函数通过 `advice` 向内核提供内存映射的一些细节，该映射从 `addr` 开始，长度是 `length` 字节。

`advice` 有效的 BSD 值是：

* `MADV_NORMAL` 指定的区域不应该受到特殊待遇。

* `MADV_RANDOM` 通过随机页引用访问指定的区域。每次页面故障，内核应该移动最小的页数。

* `MADV_SEQUENTIAL` 通过顺序页引用访问指定的区域。内核可能会执行预读，以期望随后到来的更多访问。

* `MADV_WILLNEED` The region will be needed. The pages within this region may be pre-faulted in by the kernel. 

* `MADV_DONTNEED` The region is no longer needed. The kernel may free these pages, causing any changes to the pages to be lost, as well as swapped out pages to be discarded.

POSIX 定义的名字不一样，但是意义相同：

* `POSIX_MADV_NORMAL` === `MADV_NORMAL`

* `POSIX_MADV_RANDOM` === `MADV_RANDOM`

* `POSIX_MADV_SEQUENTIAL` === `MADV_SEQUENTIAL`

* `POSIX_MADV_WILLNEED` === `MADV_WILLNEED`

* `POSIX_MADV_DONTNEED` === `MADV_DONTNEED`

执行成功时返回 `0`，出错时返回 `-1` 并设置 `errno` 值。相关的 `errno` 值如下所示：

* `EINVAL` 指定的区域无效，或者 `advice` 无效。

* `EFAULT` 指定的区域不存在内存映射。

###: shm_open()

```c
int shm_open(const char *name, int oflag, mode_t mode);
```

* Preliminary: | MT-Safe locale | AS-Unsafe init heap lock | AC-Unsafe lock mem fd |

`shm_open()` 函数返回一个文件描述符，它可以被用来通过 `mmap()` 制作内存映射。不相关的进程，可以通过指定相同的 `name` 创建或打开已存在的共享内存对象。

`name` 指定要被打开的共享内存对象。在 GNU C 库，它必须是小于 `NAME_MAX` 的字符串，包含一个可选的 '/'。

`oflag` 和 `mode` 参数和 `open()` 函数中的相同。

执行成功时返回文件描述符，出错时返回 `-1` 并设置 `errno` 值。

> 译注：`shm_open()` 使用的文件位于目录 */dev/shm/* 下。

###: shm_unlink()

```c
int shm_unlink(const char *name);
```

* Preliminary: | MT-Safe locale | AS-Unsafe init heap lock | AC-Unsafe lock mem fd |

`shm_unlink()` 函数和 `shm_open()` 函数执行相反的操作：移除之前 `shm_open()` 函数创建的对象，它们的 `name` 相同。

执行成功时返回 `0`，出错时返回 `-1` 并设置 `errno` 值。