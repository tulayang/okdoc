```
#include <stdio.h>
```

stdin & stdout & stderr
----------------------

```
int   fscanf(FILE *stream, const char *format, ...)       ⇒ 负数（errno）      | 字节数     // 读取一段格式化数据
int   scanf(const char *format, ...)                      ⇒ 负数（errno）      | 字节数     // 从标准输入读取一段格式化数据
int   sscanf(const char *str, const char *format, ...)    ⇒ 负数（errno）      | 字节数     // 读取一段格式化数据到字符串
int   fgetc(FILE *stream)                                 ⇒ EOF（文件尾，失败） | 字符       // 读取一个字符，并把游标向下移动，无符号 char 强制转换为 int
int   getc(FILE *stream)                                  ⇒ EOF（文件尾，失败） | 字符       // 读取一个字符，并把游标向下移动，fgetc() 的宏定义
int   getchar(void)                                       ⇒ EOF（文件尾，失败） | 字符       // 从标准输入读取一个字符，getc(stdin) 的宏定义
char *fgets(char *str, int size, FILE *stream)            ⇒ NULL（errno）     | 字符串地址  // 读取一行，并把游标向下移动
char *gets(char *str)                                     ⇒ NULL（errno）     | 字符串地址  // 从标准输入读取一段字符串，fgets() 的宏定义

int   fprintf(FILE *stream, const char *format, ...)      ⇒ 负数（errno） | 字节数          // 写入一段格式化数据
int   printf(const char *format, ...)                     ⇒ 负数（errno） | 字节数          // 写入一段格式化数据到标准输出 stdout
int   sprintf(char *str, const char *format, ...)         ⇒ 负数（errno） | 字节数          // 写入一段格式化数据到字符串
int   fputc(int c, FILE *stream)                          ⇒ EOF（errno） | 字节数          // 写入一个字符，并把游标向下移动，int 强制转换为无符号 char
int   putc(int c, FILE *stream)                           ⇒ EOF（errno） | 字节数          // 写入一个字符，并把游标向下移动 ，fputc() 的宏定义
int   putchar(int c)                                      ⇒ EOF（errno） | 字节数          // 写入一个字符到标准输出 stdout ，putc(c, stdout) 的宏定义
int   fputs(const char *str, FILE *stream)                ⇒ EOF（errno） | 字符数          // 写入一个字符串，并把游标向下移动
int   puts(const char *str)                               ⇒ EOF（errno） | 字符数          // 写入一个字符串到标准输出 stdout ，fputs(str, stdout) 的宏定义
int   ungetc(int c, FILE *stream)                         ⇒ EOF（errno） | 字符数          // 把一个字符推入到指定的流，这个字符是下一个被读取到的字符
```