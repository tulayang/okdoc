```
#include <stdlib.h>
```

Typedef
---------

```
• size_t           // usigned int，sizeof 的值
• wchar_t          // int, 宽字符常量大小
• div_t            // div() 返回的结构
• ldiv_t           // ldiv() 返回的结构
```

Define
--------

```
• NULL             // 空指针常量
• EXIT_FAILURE     // int，exit() 失败时返回的值
• EXIT_SUCCESS     # int，exit() 成功时返回的值
• RAND_MAX         // int，rand() 返回的最大值
• MB_CUR_MAX       // int，表示在多字节字符集中的最大字符数，不能大于 MB_LEN_MAX
```

stdlib.h
----------

1. 进程控制
   
       void  exit(int status)                                // 立即终止调用进程
                                                             // 任何该进程打开的文件描述符都会被关闭，
                                                             // 该进程的子进程由进程 1 继承，初始化，
                                                             // 且会向父进程发送一个 SIGCHLD 信号
       void  abort(void)                                     // 中止程序
       int   atexit(void (*f)(void))      ⇒ 非0  | 0         // 当程序正常终止时，调用指定的函数 f
       char *getenv(const char *name)     ⇒ NULL | 字符串     // 搜索 name 环境字符串
       int   system(const char *command)  ⇒ -1   | 命令状态   // 把 command 指定的命令名称或程序名称传给要被命令，处理器执行的主机环境，并在命令完成后返回

2. 内存分配

       void *calloc(size_t nums, size_t size)  ⇒ NULL | 内存地址  // 分配内存空间，初始化所分配的内存空间中的每一位为0
       void *malloc(size_t size)               ⇒ NULL | 内存地址  // 分配内存空间 
       void *realloc(void *p, size_t  size)    ⇒ NULL | 内存地址  // 尝试重新调整内存空间的大小
       void  free(void *p)                                       // 释放内存空间

3. 字符串转换

       double            atof   (const char *str)                        ⇒ 0.0 | 浮点数       // 字符串 -> 浮点数
       double            strtod (const char *str, char **endp)           ⇒ 0.0 | 浮点数       // 字符串 -> 浮点数，     endp: 剩余不能转换的字符串组                               
       int               atoi   (const char *str)                        ⇒ 0   | 整数         // 字符串 -> 整数
       long int          atol   (const char *str)                        ⇒ 0   | 长整数       // 字符串 -> 长整数
       long int          strtol (const char *str, char **endp, int base) ⇒ 0   | 长整数       // 字符串 -> 长整数，     endp: 剩余不能转换的字符串组
       unsigned long int strtoul(const char *str, char **endp, int base) ⇒ 0   | 无符号长整数  // 字符串 -> 无符号长整数，endp: 剩余不能转换的字符串组

4. 数组操作

       void *bsearch(const void *item, 
                     const void *array, 
                     size_t      length, 
                     size_t      size, 
                     int (*compar)(const void *, const void *))  ⇒ NULL | 地址  // 数组二分查找
                     
             • key          // 查找的元素地址，类型转换为 void*
             • base         // 数组的第一个对象地址，类型转换为 void*
             • length       // base 所指向的数组中元素的个数
             • size         // 数组中每个元素的大小，以字节为单位
             • compar       // 用来比较两个元素的函数

       void  qsort(void   *array, 
                   size_t  length, 
                   size_t  size, 
                   int (*compar)(const void *, const void *))    ⇒ NULL | 地址  // 数组排序

5. 算术

       int      abs(int x)                                              ⇒ 绝对值       // 求绝对值
       long int labs(long int x)                                        ⇒ 绝对值       // 求绝对值
       div_t    div(int numer, int denom)                               ⇒ 分子/分母    // 求分子/分母
       div_t    div(long int numer, long int denom)                     ⇒ 分子/分母    // 求分子/分母
       int      rand(void)                                              ⇒ 伪随机数     // 求 0 到 RAND_MAX 之间的伪随机数
       void     srand(unsigned int seed)                                              // 初始化随机数发生器
                time_t t;
                srand((unsigned)time(&t));
                int val = rand();
       int      mblen(const char *str, size_t length)                   ⇒ 字符长度     // 返回多字节字符的长度 
       size_t   mbstowcs(schar_t *pwcs, const char *str, size_t length) ⇒ 转换的字符数  // 字符串 str -> 数组 pwcs
       int      wctomb(char *str, wchar_t wchar)                        ⇒ 字节数       // 宽字符 wchar -> 多字节 str


