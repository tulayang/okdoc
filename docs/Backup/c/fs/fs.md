```
#include <stdio.h>
#include <sys/stat.h>
```

fs
---

```
int   mkdir(const char *pathname, mode_t mode)            ⇒ -1（errno） | 0            // 创建目录
int   create(const char *filename, mode_t mode)           ⇒ -1(errno) | fd            // 创建文件，生成描述符

int   remove(const char *filename)                        ⇒ -1（errno） | 0            // 删除文件
int   rename(const char *old_name, const char *new_name)  ⇒ -1（errno） | 0            // 更名一个文件 
       
FILE *tmpfile(void)                                       ⇒ NULL（errno） | FILE *     // 以二进制更新模式（wb+）创建临时文件，被创建的临时文件会在流关闭的时候或者程序终止的时候自动删除
char *tmpnam(char *str)                                   ⇒ NULL（errno） | 字符串地址  // 生成一个有效的临时文件名
```