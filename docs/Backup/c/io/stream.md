```
#include <stdio.h>
#include <sys/socket.h>
```

Define
-------

```
size_t               // 无符号整数，sizeof() 计算尺寸
fpos_t               // 存储文件中游标的对象
FILE                 // 存储文件流信息的对象

NULL                 // 空指针常量
BUFSIZ               // 整数， setbuf() 使用的缓冲区大小
EOF                  // 负整数，到达文件尾端
FOPEN_MAX            // 整数，系统可以同时打开的文件数量
FILENAME_MAX         // 整数，可以存储的文件名的最大长度，如果实现没有任何限制，则该值应为推荐的最大值
L_tmpnam             // 整数，可以存储的由 tmpnam() 创建的临时文件名的最大长度
TMP_MAX              // 整数，tmpnam() 生成的独特文件名的最大数量

_IOFBF               // 表达式，setvbuf()
_IOLBF
_IONBF

SEEK_CUR             // 整数，fseek() 游标模式
SEEK_END
SEEK_SET

stderr               // 指向 FILE 类型的指针，分别对应于标准错误、标准输入和标准输出流
stdin
stdout
```

fopen → fseek → fread → fwrite → flush → fclose
-------------------------------------------------

```
FILE  *fopen(const char *filename, const char *mode)                        ⇒  NULL（errno） | FILE *  // 打开一个流

       • filename
       • mode
         ∘ "r"          // 只读，必须存在
         ∘ "r+"         // 读写，必须存在
         ∘ "w"          // 只写，存在清0，不存在新建
         ∘ "w+"         // 读写，存在清0，不存在新建
         ∘ "a"          // 附加，存在末尾开始，不存在新建
         ∘ "a+"         // 附加，存在末尾开始，不存在新建

FILE  *freopen(const char *filename, const char *mode, FILE *stream)       ⇒  NULL（errno） | FILE *  // 关闭一个文件，并打开一个流 

int    fclose(FILE *stream)                                                ⇒  EOF（errno） | 0        // 关闭流
int    fcloseall(void)                                                     ⇒  0                      // 关闭流 (所有的)

size_t fread(void *data, size_t size, size_t length, FILE *stream)         ⇒  -1(errno) | 0(尾部) | 实际读取的字节数 
size_t fwrite(const void *data, size_t size, size_t length, FILE *stream)  ⇒  -1(errno) | 实际写入的字节数

int    fsetpos(FILE *stream, const fpos_t *pos)                            ⇒ !0（errno） | 0          // 设置游标
long   ftell(FILE *stream)                                                 ⇒ -1L（errno） | 位置       // 获取游标
int    fgetpos(FILE *stream, fpos_t *pos)                                  ⇒ 非0（errno） | 0          // 获取游标当前位置
int    fseek(FILE *stream, long offset, int origin)                        ⇒ -1（errno） | 0          // 设置游标
    
       • offset          // 位移
       • whence          // 模式
         ∘ SEEK_SET      // 从文件开头
         ∘ SEEK_END      // 从文件尾端
         ∘ SEEK_CUR      // 从当前的位置

int    fflush(FILE *stream)                                                ⇒ EOF（errno） | 0         // 刷新缓冲区，立刻把用户缓冲区数据写入内核缓冲区
void   setbuf(FILE *stream, char *buffer)                                                            // 设置用户缓冲区，至少为 BUFSIZ 字节
int    setvbuf(FILE *stream, char *buffer, int mode, size_t size)          ⇒ 非0（errno） | 0         // 设置用户缓冲区                                                    

       • buffer          // 分配给用户的缓冲区，长度至少为 BUFSIZ 字节，
                         // 如果设置为 NULL，自动分配一个指定大小的缓冲 
       • mode
         ∘ _IONBF        // 块缓冲：以块的整数倍刷新缓冲
         ∘ _IOLBF        // 行缓冲：当遇到换行时刷新缓冲区，一般用于屏幕输出
         ∘ _IOFBF        // 无缓冲：不使用缓冲。buffer 和 size 参数被忽略。
       • size            // 缓冲的大小，单位字节

int   feof(FILE *stream)                                                   ⇒ 非0（末尾） | 0          // 检查到达文件流尾端
int   ferror(FILE *stream)                                                 ⇒ 非0（标识符错误） | 0     // 检查标识符错误
void  clearerr(FILE *stream)                                                                        // 清除给定流 stream 的文件结束和错误标识符
void  perror(const char *str)                                                                       // 把一个描述性错误消息输出到标准错误 stderr
```