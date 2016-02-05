# [锁住页，防止页面故障](https://www.gnu.org/software/libc/manual/html_node/Locking-Pages.html#Locking-Pages)

你可以告诉内核：“连接”一个虚拟页到一个物理页，并一直保持这种状态。也就是说，不再对页进行交换，也不再产生页面故障。这被称为“锁住页”。

## 为什么锁页

内核进行页调度，在需要时将页从磁盘放入物理内存，当不再需要时撤回到磁盘交换空间。当进程访问的页没有被放入物理内存时，产生页面故障，内核挂起进程，把页从磁盘放入物理内存，和虚拟页“连接”。

通常，进程很少涉及到锁页。然而，一些特殊目的会需要锁页：

* **速度** 页面故障的处理，是由内核透明处理的。对于重视时间效率的进程，特别是实时进程，可能无法忍受页面故障引起的延迟（尽管非常小）。

  另外一个原因，可能是进程想要获取比其它进程更高的 CPU 使用权。

  在某些情况下，程序员可以确切的知道某些页驻留在物理内存可以更好的优化系统性能。在这种情况下，可以通过锁页达成。

* **隐私** 如果你在虚拟内存保留密码，当虚拟内存被“交换”时，密码也可能跟着被“交换”出去。如果一个密码被写入磁盘交换空间，在虚拟内存和真实的内存的密码被清除后，它可能仍然存在！

要意识到，当你锁定一个页时，同时也减少了可用的物理内存，这可能意味更多的页面故障---也就意味着系统运行得更慢。事实上，如果你锁定了足够多的内存，一些程序可能因为没有足够的内存而无法运行。

## 锁页的细节

一个内存锁是和一个虚拟页关联的，而不是一个物理页。规则是：如果一个物理页“连接”了至少一个锁页，就不产生页面故障。

内存锁不能堆叠。也就是说，如果你锁定了一个页，你不能再次锁定它，除非解锁页。

内存锁会一直存在，直到进程显式地解锁。（但是进程终止或者 `exec` 新的地址空间，锁会被清除）。

内存锁不能被子进程继承。（但要注意的是，在现代的 UNIX 系统中，`fork()` 后 `exec()` 前，父进程和子进程的虚拟地址空间是“连接”到同一个物理页的---写时复制，所以子进程可以享受到父进程内存锁的效果）。

因为它有影响其他进程的内力，所以只有超级用户才能锁页。任何进程都可以解锁自己的页。

该系统设置了一个进程可以有锁定的内存量和它可以专门为它的内存量。见资源限制。

内核对进程可以锁定的页数和可以使用的物理内存做了限制。

在 Linux，锁页可能并非是你想的那样。两个不共享的虚拟页也可以“连接”到同一个物理页。当内核获知两个虚拟页的数据完全相同时，它以效率的名义，把两个虚拟页“连接”到同一个物理页，甚至其中一个页被锁定也会这么做。

但是，当一个进程修改了一个页时，内核必须给它一个新的物理页，并且把数据复制过来。这就是著名的写时复制---页面故障。它会花费少量的时间，对物理页执行 IO 请求。

> 想要确保你的程序不产生写时复制，光靠锁住页是不够。最好是对它们执行下写操作（以便提前构建内存空间，而不是程序运行中间），除非你确定不会存在写操作。另外，想确保为你的栈预分配内存，进入一个作用域声明一个 C 原子变量，尺寸大于你需要的栈尺寸，随便给它赋值点什么，然后返回它所在的作用域。

## API

本节中的符号声明在 `<sys/mman.h>`。这些函数是由 POSIX.1b 定义的，但它们的可用性取决于你的内核。如果你的内核不支持这些函数，则它们仍然存在但总是失败。

> 可移植性注解：POSIX.1b 要求当 `mlock()` 和 `munlock()` 函数可用时，头文件 `<unistd.h>` 应该定义宏 `_POSIX_MEMLOCK_RANGE`，头文件 `<limits.h>` 应该定义宏 `PAGESIZE` 指定内存页的字节大小。当 `mlockall()` 和 `munlockall()` 函数可用时，头文件 `<unistd.h>` 应该定义宏 `_POSIX_MEMLOCK`。GNU C 库符合这个要求。

###: mlock()

```c
int mlock(const void *addr, size_t len);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

`mlock()` 锁定进程虚拟地址空间的页的范围。

这个范围从地址 `addr` 开始，`len` 字节长度。事实上，因为你必须锁定整个页，它包含了每个锁定页（可能有多个页）的一部分。

当函数成功时，每个页都被“连接”到一个物理页，并且一致保持这种状态。

当函数失败时，它不影响任何页面的锁状态。

如果函数成功，返回值为　`0`。否则是　`-1`，并设置 `errno`。相关的 `errno` 值：

* `ENOMEM`

  * 指定的范围里，有一部分没有在进程虚拟地址空间。
  * 进程可锁定的页数已达上限。

* `EPERM` 调用进程不是超级用户。

* `EINVAL` `len` 不是正数。

* `ENOSYS` 内核不支持 `mlock()`。

你可以用 `mlockall()` 锁定进程的所有内存。可以用 `munlock()` 或 `munlockall()` 解锁内存。

为了完全避免在 C 程序中出现页面错误，你必须使用 `mlockall()`。因为程序中一些隐藏的 C 代码，例如栈和自动变量，无法通过 `mlock()` 获得地址。

###: munlock()

```c
int munlock(const void *addr, size_t len);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

`munlock()` 解锁在范围中的页。它的类似 `mlock()`，除了失败时没有 `EPERM`。

###: mlockall()

```c
int mlockall(int flags);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

`mlockall()` 锁定进程虚拟内存地址空间的所有页，包括（也可以不包括）将来加入的页。这些页包括代码的、数据和堆栈段的，以及共享库的、用户空间内核数据的、共享内存的和内存映射文件的。

`flags` 是一个标志位，告诉 `mlockall()` 想要的锁模式：

* `MCL_CURRENT` 锁定进程虚拟地址空间中的当前存在的所有页。

* `MCL_FUTURE` 设置这样一个模式：将来任何添加到虚拟地址空间的页，从一出现就被锁定。通过 `exec()` 产生的进程，会清除这个模式。

当函数成功，并且指定 `MCL_CURRENT` 时，进程的所有页被“连接”到物理页，并一直保持这种状态。

When the process is in `MCL_FUTURE` mode because it successfully executed this function and specified `MCL_CURRENT`, any system call by the process that requires space be added to its virtual address space fails with `errno = ENOMEM` if locking the additional space would cause the process to exceed its locked page limit. In the case that the address space addition that can’t be accommodated is stack expansion, the stack expansion fails and the kernel sends a `SIGSEGV` signal to the process. 

当函数失败时，它不会影响当前页面的锁定状态，也不影响将来页的锁定模式。

如果函数成功，返回值为　`0`。否则是　`-1`，并设置 `errno`。相关的 `errno` 值：

* `ENOMEM`

  * 指定的范围里，有一部分没有在进程虚拟地址空间。
  * 进程可锁定的页数已达上限。

* `EPERM` 调用进程不是超级用户。

* `EINVAL` `len` 不是正数。

* `ENOSYS` 内核不支持 `mlockall()`。

###: munlockall()

```c
int munlockall(void);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Safe |

`munlockall()` 解锁进程虚拟地址空间的所有页，并且关闭 `MCL_FUTURE` 锁模式。

如果函数成功，返回值为　`0`。否则是　`-1`，并设置 `errno`。这个函数失败的唯一原因是：所有的函数和系统调用出现失败，其 `errno` 值是不确定的。

###
