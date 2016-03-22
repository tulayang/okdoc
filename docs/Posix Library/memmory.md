
## 调整 program break

### brk() sbrk()

```
#include <unistd.h>
int   brk(void *end_data_segment)  
      // 设置 program break 的位置，成功返回 0，出错返回 -1 。
      // 由于虚拟内存以页为单位进行分配，实际会四舍五入到下一个页的边界处。当试图设置一个
      // 低于 program break 初始值的位置时，有可能会导致无法预知的行为。
void *sbrk(intptr_t increment)
      // 增加 program break 的位置，成功返回前一个 program break 的地址（即新分配内存的起始位置），
      // 出错返回 NULL。
      // sbrk(0) 将不做改变，当跟踪堆或者监视内存分配行为时，可能会用到。
```

## 在堆上分配和释放内存

### malloc() calloc()

```
#include <stdlib.h>

void *malloc(size_t size)            // 在堆上申请内存块，不初始化。采用字节对齐的方式，适配
                                     // 任何类型的 C 数据结构。在大多数架构，malloc() 是基于 
                                     // 8 字节（32 位系统）或者 16 字节（64 位系统）界 
                                     // 边来分配内存。成功返回分配的内存地址，出错返回 NULL 。

void *calloc(size_t n, size_t size)  // 在堆上申请内存块，将分配的区域全部用 0 初始化。
                                     // 成功返回分配的内存地址，出错返回 NULL 。
```

<span>

```
# include <stdio.h>
void *xmalloc(size_t size) {
    void *ptr = malloc(size);
    if (ptr == NULL) {
        perror("xmalloc");
        exit(EXIT_FAULURE);
    }
    return ptr;
}
```

<span>

```
struct Who { char *name };
struct Who *xiaoming = calloc(1000, sizeof(struct Who));
if (xiaoming == NULL)
    errExit("calloc");
```

### realloc()

```
#include <stdlib.h>
void *realloc(void *ptr, size_t size)  // 重新调整一块已分配内存的大小，如果增加了已分配内存块的大小，
                                       // 额外分配的字节不会被初始化。
                                       // 
                                       // realloc(ptr, 0); 等效于 free(ptr); malloc(0);
                                       //
                                       // 通常情况下，增大已分配内存时，relloc() 尝试合并在空闲内存
                                       // 表中紧随其后并且尺寸满足要求的内存块。如果原内存块位于堆
                                       // 顶部，realloc() 对堆空间扩展。如果位于堆中部，并且紧邻其
                                       // 后的空闲内存尺寸不足，realloc() 会分配一块新内存，将原有
                                       // 数据复制到新内存块。最后这种情况很常见，会占用大量 CPI 
                                       // 资源。一般情况下，避免调用 realloc() ！！！
                                       //
                                       // 成功返回分配的内存地址，出错返回 NULL 。
```

<span>

```
// 因为 realloc() 可能会改变内存块，对内存块的后续引用需要使用 realloc() 返回的地址
newptr = realloc(ptr, newsize);
if (newptr == NULL)
    errExit("realloc");
else
    ptr = newptr;
```

### memalign() posix_memalign()

```
#include <malloc.h>
void *memalign(size_t boundary, size_t size) 
      // 起始地址与 2 的整数次幂对齐，分配 size 内存。该特征对于某些应用非常有用

#include <stdlib.h>
int posix_memalign(void **memptr, size_t alignment, size_t size)
    // SUSv3 未纳入 memalign()，而是提供 posix_memalign()

```

### free()

```
#include <stdlib.h>
void  free(void *ptr)      // 释放动态分配的内存。如果 ptr 是一个空指针，那么什么也不做
```

## 匿名内存映射

### mmap() munmap()

```
#include <sys/mman.h>
void *mmap(void *start, size_t length, int port, int flags, int fd, off_t offset);
      // 成功返回内存地址，出错返回 NULL 。
int munmap(void *start, size_t length); 
      // 成功返回 0，出错返回 -1 。
```

<span>

```
// Linux 系统使用 MAP_ANONYMOUS 标记来创建一个匿名映射

void *p = mmap(NULL,                         // 不使用文件，把匿名映射放在任意地址上。
               512 * 1024,                   // 内存大小 512 KB。
               PORT_READ | PORT_WRITE,       // 内存可读，可写。
               MAP_ANONYMOUS | MAP_PRIVATE,  // 匿名，私有。
               -1,                           // ＂文件描述符＂（忽略）
               0);                           // ＂偏移量＂（忽略）
if (p == MAP_FAILED)
    errExit("mmap");
if (munmap(p, 512 * 1024) == -1)
    errExit("munmap");
```

<span>

```
// 其他的 UNIX 系统（比如 BSD），并没有 MAP_ANONYMOUS 标记位，而是通过映射到特殊设备
// 文件 /dev/zeor 实现类似的解决方案。设备文件 /dev/zeor 提供了和匿名内存完全相同的
// 语义，是一个包含全 0 的页的映射，采取写时复制方式，因此其行为和匿名存储器一致。这是一个
// 可移植的极佳方案（Linux 也支持）。

int fd = open("/dev/zero", O_RDWR);          // 可读，可写
if (fd == -1)
    errExit("open");                         
void *p = mmap(NULL,                         // 不使用文件，把匿名映射放在任意地址上。
               512 * 1024,                   // 内存大小 512 KB。
               PORT_READ | PORT_WRITE,       // 内存可读，可写。
               MAP_PRIVATE,                  // 私有。
               fd,                           // ＂文件描述符＂（映射到 /dev/zero）。
               0);                           // ＂偏移量＂。
if (p == MAP_FAILED)
    errExit("mmap");
if (munmap(p, 512 * 1024) == -1)
    errExit("munmap");

```

## 在栈上分配内存

> `alloca()` 可以动态分配内存，不过不是在堆上，而是在栈上 。不需要调用 `free()` 来释放内存，也不能用 `realloc()` 调整内存尺寸。

### alloca()

```
#include <alloca.h>
void *alloca(size_t size)   // 成功返回在栈上已分配内存块的地址，出错返回 NULL
```

## 内存调试

> 程序可疑设置环境变量 `MALLOC_CHECK_`，开启存储系统中的高级调试功能。这个高级调试检查是以降低内存分配的效率为代价的，然而在开发的调试阶段非常有价值。

> ```
$ MALLOC_CHECK_=1 ./test  // 信息会被输出到标准错误 stderr
```

### makkinfo()

```
#include <malloc.h>
struct {
    int arena;      // malloc() 使用的数据段尺寸
    int orbdlks;    // 释放的块数量
    int smblks;     // 
    int hblks;      // 匿名映射数量
    int hblkhd;     // 匿名映射的尺寸
    int usmblks;    // 最大分配尺寸
    int fsmblks;    // 
    int uordblks;   // 
    int fordblks;   // 
    int keepcost;   // 
};
struct mallinfo mallinfo(void);  // 获取内存分配信息，Linux 特有
void malloc_stats(void);         // 打印内存分配信息，Linux 特有
```

## 内存操作

### memset()

```
#include <string.h>
void *memset(void *ptr, int c, size_t n);  // 把内存区域前 n 个字节设置为 c，返回 ptr 
                                           //
                                           // memset(ptr, '\0', 256); 常用来清零一块内存
```

### memcmp()

```
#include <string.h>
int memcmp(const void *s1, const void *s2, size_t n);  // 比较 s1 和 s2 前 n 个字节，
                                                       // 1. s1 == s2，返回 0
                                                       // 2. s1 <  s2，返回负数
                                                       // 3. s1 <  s2，返回正数
```

### memmove() memcpy()

```
#include <string.h>
void *memmove(void *dst, const void *src, size_t n); // 把 src 前 n 个字节复制到 dst，返回 dst 
                                                     // dst 和 src 可以重叠
void *memcpy(void *dst, const void *src, size_t n);  // 把 src 前 n 个字节复制到 dst，返回 dst
                                                     // dst 和 src 不能重叠，否则结果未定义，更快些
void *memccpy(void *dst, const void *src, int c, size_t n); // 和 memcpy 类似，但是在前 n 个字节中
                                                            // 找到 c 时，就停止拷贝。
                                                            // 返回指向 dst 中字节 c 的下一个字节，
                                                            // 如果没有找到 c，返回 NULL 。
         
```

### memcmp()

```
#include <string.h>
void *memchr(const void *s, int c, size_t n);  // 从 s 指向的区域开始的 n 个字节中查找 c，c 被转换
                                               // 为 unsigned char。如果没有找到 c 返回 NULL 。
```

## 内存锁定

### mlock() munlock()

```
#include <sys/mman.h>

int mlock(const void *addr, size_t len);  // 锁定从 addr 开始，长度 len 个字节的虚拟内存。addr 要求
                                          // 是页边界对齐的，包含 [addr, addr + len) 的所有物理页
                                          // 都会被锁定。成功返回 0， 出错返回 -1
                                          
int munlock(const void *addr, size_t len);// 解除从 addr 开始，长度 len 个字节的内存所在
                                          // 页面的锁定。成功返回 0， 出错返回 -1
                                          //
                                          // 内存锁定不会重叠，不管 mlock() mlockall() 锁定多
                                          // 少次，一次 munlock() munlockall() 即可解锁！！！
```

<span>

```
int ret = mlock(secret, strlen(secret));  // 锁定密码字符串
if (ret == -1)
    errExit("mlock");
```

### mlockall() munlockall()

```
#include <sys/mman.h>

int mlockall(int flags);  // 当前进程在物理内存中锁定它的全部地址空间。
                          //
                          // flags - 行为标志，大部分程序设置这两个值的按位或值
                          // MCL_CURRENT - 将所有已被映射的页面（包括栈、数据段和映射文件）锁定在
                          //               进程地址空间中
                          // MCL_FUTURE  - 将所有未来映射的页面也锁定到进程地址空间中
                          // 
                          // 成功时返回 0，出错返回 -1 

int munlockall(void);     // 解除当前进程的全部地址空间的锁定。
                          // 成功时返回 0，出错返回 -1
```

### mincore()

```
#include <unistd.h>
#include <sys/mman.h>
int mincore(void *start, size_t len, unsigned char *vec);
    // 确定一个给定范围内的内存是在物理内存中，还是被交换到了磁盘中，Linux 专有。
    // 成功时返回 0，出错返回 -1
```