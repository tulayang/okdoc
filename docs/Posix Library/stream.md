

## 流定向

### fwide()

```
#include <stdio.h>
#include <wchar.h>
int fwide(FILE *fp, int mode);  // 流是宽定向，返回正值；
                                // 流是字节定向，返回负值；
                                // 流是未定向，返回 0
                                //
                                // mode 
                                //
                                //   ∘ 正值，尝试设置流是宽定向
                                //   ∘ 负值，尝试设置流是字节定向
                                //   ∘ 0，不设置流定向，返回标识该流定向的值
```

## 流缓冲区

### setvbuf() setbuf() setbuffer()

```
#include <stdio.h>

<_G_config.h>#define _G_BUFSIZ 8192 
<libio.h>    #define _IO_BUFSIZ _G_BUFSIZ
#ifndef BUFSIZ
# define BUFSIZ _IO_BUFSIZ
#endif

int  setvbuf(FILE *restrict fp, char *restrict buf, int mode, size_t size);
     // 成功返回 0，出错返回 - 1
     // 
     // mode - 缓冲模式
     // 
     //   ∘ _IOFBF  -  块缓冲
     //   ∘ _IOLBF  -  行缓冲
     //   ∘ _IONBF  -  无缓冲，忽略 buf 和 size

void setbuf(FILE *restrict fp, char *restrict buf);  
     // 成功返回 0，出错返回 - 1
     // 构建在 setvbuf 之上，相当于 setvbuf(fp, buf, buf == NULL ? _IONBF : _IOFBF, BUFSIZ);
     // 要么是无缓冲（buf = NULL），要么是块缓冲或者行缓冲-终端设备（此时 buf 大小必须为 BUFSIZ）！！！

#define _BSD_SOURCE
void setbuffer(FILE *restrict fp, char *restrict buf, size_t size);  
     // 成功返回 0，出错返回 - 1
     // SUSv3 未定义，但大多数 UNIX 实现都支持
     // 构建在 setvbuf 之上，相当于 setvbuf(fp, buf, buf == NULL ? _IONBF : _IOFBF, size);
     // 要么是无缓冲（buf = NULL），要么是块缓冲或者行缓冲-终端设备（此时 buf 大小为 size）
```

## 冲洗标准 IO 缓冲区

### fflush()

```
#include <stdio.h>
int flush(FILE *fp);    // 成功返回 0，出错返回 -1
                        // 如果 fp = NULL，冲洗所有的 stdio 缓冲区！！！
```

## 打开流

### fopen() freopen() fdopen()

```
#include <stdio.h>

FILE *fopen(const char *restrict pathname, const char *restrict type);
      // 成功返回文件指针，出错返回 NULL
      // 打开路径名指定的文件

FILE *freopen(const char *restrict pathname, const char *restrict type, FILE *restrict fp);
      // 成功返回文件指针，出错返回 NULL
      // 在一个指定的流上打开一个指定的文件，如果流已经打开，先关闭流。一般用于将一个指定的文件打开为
      // 一个预定义的流：标准输入、标准输出、标准错误

FILE *dopen(int fd, const char *type);
      // 成功返回文件指针，出错返回 NULL
      // 使用一个＂文件描述符号码＂，转换为一个流。常用于不能用标准 IO 函数 fopen 打开的
      // 特殊文件，比如管道、套接字等等
      // 
      // type - 打开模式
      //
      //   ∘ "r"   -  只读，必须存在
      //   ∘ "r+"  -  读写，必须存在
      //   ∘ "w"   -  只写，存在清0，不存在新建
      //   ∘ "w+"  -  读写，存在清0，不存在新建
      //   ∘ "a"   -  追加写，不存在新建
      //   ∘ "a+"  -  追加读写，不存在新建
```

## 关闭流

### fclose()

```
#include <stdio.h>
int fclose(FILE *fp);  // 成功返回 0，出错返回 -1
```

## 读流

### clearerr() ferror() feof()

```
#include <stdio.h>
void clearerr(FILE * fp);  // 清除错误标志
int ferror(FILE *fp);      // 出错？条件为真返回非 0，否则返回 0
int feof(FILE *fp);        // 尾端？条件为真返回非 0，否则返回 0
```

### fgetc() getc() getchar()

```
#include <stdio.h> 
int fgetc(FILE *fp);    // 成功返回下一个字符，到达文件尾或者出错返回 EOF
int getc(FILE *fp);     // fgetc() 的宏定义，成功返回下一个字符，到达文件尾或者出错返回 EOF
int getchar(void);      // 等同于 getc(stdin)，成功返回下一个字符，到达文件尾或者出错返回 EOF
```

<span>

```
#include <stdio.h>

int main(int argc, char *argv[]) {
    char str[1024];        
    char *s = &str[0];     // char *s = str;
    *(s++) = 97;           // *s++ = 97;
    *(s++) = 98;           // *s++ = 98;
    *(s++) = 99;           // *s++ = 99;
    *(s++) = '\0';         // *s++ = '\0';
    printf("%s\n", str);   // => "abc\0"
}
```

<span>

```
char str[BUFFSIZ];
char *s = str;            // &str[0]
int c;

s = str;
for (;;) {
    if ()
    c = fgetc(fp);
    if (ferror(fp))       // 出错
        errExit("getc");
    if (feof(fp))         // 尾端
        break;
    if ((char)c == d)     // 特定字符
        break;
    *(s++) = c;
}
*s = '\0';                // 尾端追加 '\0'
```

### fgets() gets()

```
#include <stdio.h>

char *fgets(char *restrict buf, int nbytes, FILE *restrict fp);
      // 成功返回 buf，到达文件尾或者出错返回 NULL
      // 从流读取 nbytes - 1 个字节，并保存到 buf，读完最后一个字节时，缓冲区中填入空字符 '\0'。
      // 当读到 EOF 或者换行符时，会结束读。（如果读到换行符，把 '\n' 填入 buf）。
      

char *gets(char *restrict buf);
      // 成功返回 buf，到达文件尾或者出错返回 NULL
      // 不推荐使用，容易引起缓冲区溢出。等同于 fgets(buf, sizeof(buf), stdin)，
      
// POSIX 在 <limits.h> 定义了宏 LINE_MAX，限制能够处理的输入行的最大长度。（Linux 的 C 函数库没有这样
// 的限制，行可以是任意长度，无需担心行大小的限制。可移植程序可以使用 LINE_MAX 保证安全）。
```

### fread()

```
#include <stdio.h>
size_t fread(void *restrict ptr, size_t size, size_t n, FILE *restrict fp); 
       // 成功返回读的个数，出错或者尾端返回比 n 小的数
```

<span>

```
// 读一个数组
float data[64];
if(fread(&data[2], sizeof(float), 4, fp) != 4)
    errExit("fread");
```

<span>

```
// 读一个结构
struct {
  int id;
  char name[NAMESIZE];
} data;
if (fread(&data, sizeof(data), 1, fp) != 1)
    errExit("fread");
```

## 写流

### fputc() putc() putchar() ungetc()

```
#include <stdio.h> 
int fputc(int c, FILE *fp);    // 成功返回 c，出错返回 EOF
int putc(int c, FILE *fp);     // fputc() 的宏定义，成功返回 c，出错返回 EOF
int putchar(int c);            // 等同于 putc(c, stdout)。成功返回 c，出错返回 EOF
int ungetc(int c, FILE *fp);   // 将字符压回流。成功返回 c，出错返回 EOF
```

### fputs() puts()

```
#include <stdio.h>
char *fputs(const char *restrict str, FILE *restrict fp);
      // 成功返回非负值，出错返回 EOF
      // 将一个以 null 字节终止的字符串，写到指定的流（尾端的 null 终止符不写出）。字符串并不需要将
      // 换行符作为最后一个非 null 字节。（通常 null 字节前是一个换行符，但并不要求总是如此）
char *puts(char *restrict str);
      // 等同于 fputs(str, stdout)，成功返回非负值，出错返回 EOF
``` 

### fwrite()

```
#include <stdio.h>
size_t fwrite(const void *restrict ptr, size_t size, size_t n, FILE *restrict fp); 
       // 成功返回写的个数，失败返回比 n 小的数
```

<span>


```
// 写一个数组
float data[10];
if(fwrite(&data[2], sizeof(float), 4, fp) != 4)
    errExit("fwrite");
```

<span>

```
// 写一个结构
struct {
  int id;
  char name[NAMESIZE];
} data;

if (fwrite(&data, sizeof(data), 1, fp) != 1)
    errExit("fwrite");
```

## 流偏移量

### fseek() rewind() ftell() 

```
#include <stdio.h>
int  fseek(FILE *fp, long offset, int origin);  
                                       // 设置＂偏移量＂。成功返回 0，出错返回 -1
                                       // 
                                       // offset - 偏移值
                                       // 
                                       // origin - 偏移模式
                                       //   
                                       //   ∘ SEEK_CUR  -  从当前位置开始计算 = 当前值 + offset
                                       //   ∘ SEEK_SET  -  从文件起始开始计算 = 0 + offset
                                       //   ∘ SEEK_END  -  从文件尾端开始计算 = 文件长度 + offset 
void rewind(FILE *fp);                         // 设置＂偏移量＂到文件的起始位置
long ftell(FILE *fp);                          // 获取＂当前偏移量＂
                                               // 成功返回＂当前偏移量＂，出错返回 -1L
```

### fsetpos() fgetpos()

```
#include <stdio.h>
int  fsetpos(FILE *fp, const fpos_t *pos);              // 设置＂偏移量＂，相当于 
                                                        // fseek(fp, pos, SEEK_SET); 
                                                        // 成功返回 0，出错返回 -1
int  fgetpos(FILE *restrict fp, fpos_t *restrict pos);  // 获取＂当前偏移量＂
                                                        // 成功返回 0，出错返回 -1
```

## 获取文件描述符

> 某些情况下，获得指定流的文件描述符是很方便的。通常，不建议混合使用标准 IO 调用和系统调用！！！

### fileno()

```
#include <stdio.h>
int fileno(FILE *fp);  // 成功返回流相关的＂文件描述符号码＂，出错返回 -1
```

## 线程安全

### flockfile() funlockfile()

```
#include <stdio.h>
void flockfile(FILE *fp);     // 等待流 fp 被解锁，然后增加自己的锁计数器，获得锁。该函数的
                              // 执行线程成为流的持有者，并返回
void funlockfile(FILE *fp);   // 减少流 fp 关联的锁计数，如果计数值为 0 ，当前线程放弃对该
                              // 流的持有权，另一个线程可以获得该锁 
                              //
                              // 这些调用可以嵌套。单个线程可以执行多次 flockfile()，直到
                              // 该线程执行相同数量的 funlickfile() 后，该流才会被解锁
                              // 
int  ftrylockfile(FILE *fp);  // 1.如果流 fp 当前已经加锁，则立刻返回一个非 0 值
                              // 2.如果流 fp 当前没有加锁，该线程获得锁，增加锁计数值，成
                              //   为流 fp 的持有者，并返回 0
```

<span>

```
flock(fp);

fputs("List of treasure:", fp);
fputs("    (1) 500 gold coins", fp);
fputs("    (2) Wonderfully ornate dishware", fp);

funlockfile(fp);
```

## 格式化输出和输入

> ...

### printf() fprintf() dprintf() sprintf() snprintf()

```
#include <stdio.h>
int printf(const char *restrict format, ...);
    // 将数据写到标准输出。成功返回输出字符数，出错返回负值
int fprintf(FILE *restrict fp, const char *restrict format, ...);
    // 将数据写到指定流。成功返回输出字符数，出错返回负值
int dprintf(int fd, const char *restrict format, ...);
    // 将数据写到＂文件描述符号码＂。成功返回输出字符数，出错返回负值
int sprintf(char *restrict buf, const char *restrict format, ...);
    // 将数据放入数组 buf，自动在尾端加入 null 字节（但是不包含在返回值中）。可能会造成缓冲区溢出
    // 成功返回存入数组的字符数，出错返回负值
int snprintf(char *restrict buf, size_t n, const char *restrict format, ...);
    // 将数据放入数组 buf，自动在尾端加入 null 字节（但是不包含在返回值中）。为了解决 sprintf 缓冲区溢出
    // 成功返回存入数组的字符数，出错返回负值
```

### scanf() fscanf() sscanf()

```
#include <stdio.h>
int scanf(const char *restrict format, ...);
int fscanf(FILE *restrict fp, const char *restrict format, ...);
int sscanf(const char *restrict buf, const char *restrict format, ...);
```

## 唯一路径名和临时文件

> `tmpnam()` 可以生成一个与现有文件名不同的有效路径名字符串。每次调用时，都产生一个不同的路径名，最多调用次数是 `TMP_MAX` （定义在 `<stdio.h>`）。 

> `tmpfile()` 创建一个临时二进制文件，在关闭该文件或者程序结束时将自动删除该文件。

### tmpnam() tmpfile()

```
#include <stdio.h>

# define L_tmpnam 20
# define TMP_MAX  238328
# 

char *tmpnam(char *ptr);  // 1.如果 ptr 是 NULL，生成的路径名存放在一个静态区，返回该静态区的地址。
                          //   后续调用 tmpnam() 会重写该静态区。
                          // 2.如果 ptr 不是 NULL，则 ptr 必须是指向长度至少是 L_tmpnam 
                          //   （定义在 stdio.h>） 字节的数组，返回 ptr。

FILE *tmpfile(void);      // 成功返回文件流，出错返回 NULL
```

<span>

```
# define MAXLINE 4096

char name[L_tmpnam], line[MAXLINE];
FILE *fp;

printf("%s", tmpnam(L_tmpnam));

tmpnam(name);
printf("%s", name);

fp = tmpfile();                              // 创建临时文件
if (fp == NULL)
    errExit("tmpfile");
fputs("Hello world!\n");                     // 写入流
rewind(fp);                                  // 设置流＂偏移量＂到起始位置
if (fgets(line, sizeof(line), fp) == NULL)   // 读取流
    errExit("fgets");
fputs(line, stdout);                         // 写入标准输出流
```
