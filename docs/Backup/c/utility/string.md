```
#include <string.h>
```

Typedef
-----------

```
• size_t           // 无符号整数类型，sizeof 关键字的结果
```

Define
---------

```
• NULL             // 空指针常量
```

函数
----

1. 比较

       int memcmp (const void *str1, const void *str2, size_t n) ⇒ <0，>0，=0    // 比较字符串前 n 个字节
       int strcmp (const char *str1, const char *str2)           ⇒ <0，>0，=0    // 比较　str1 str2
       int strncmp(const char *str1, const char *str2, size_t n) ⇒ <0，>0，=0    // 比较　str1 str2，最多前 n 个字节
       int strcoll(const char *str1, const char *str2)           ⇒ <0，>0，=0    // 比较　str1 str2，结果取决于 LC_COLLATE 的位置设置
 
2. 查找

       void   *memchr (const void *str,  int c, size_t n)        ⇒ NULL | 地址   // 检索字符串前 ｎ 个第一个字符 c　的地址
       char   *strchr (const char *str,  int c)                  ⇒ NULL | 地址   // 检索 str 第一次出现字符 c（一个无符号字符）的位置
       char   *strrchr(const char *str,  int c)　　　　　　　　　   ⇒ NULL | 地址   // 检索 str 最后一次出现字符 c（一个无符号字符）的位置
       char   *strpbrk(const char *str1, const char *str2)       ⇒ NULL | 地址   // 检索 str1 中第一个匹配 str2 中字符，不包含空结束字符
       char   *strstr (const char *str1, const char *str2)       ⇒ NULL | 地址   // 检索 str1 中第一次出现 str2 的位置，不包含空结束字符
       size_t  strcspn(const char *str1, const char *str2)       ⇒ 字符数        // 检索 str1 开头连续有几个字符都不含 str2 中的字符
       size_t  strspn (const char *str1, const char *str2)       ⇒ 字符下标      // 检索 str1 中第一个不在 str2 中出现的字符下标
       
3.　复制

       void *memset (void *str1, int c, size_t n)                ⇒ str1　地址 　 // 把 c 复制到 str1 第　n 个字符
       void *memcpy (void *str1, const void *str2, size_t n)     ⇒ str1 地址　　 // 从　str1　复制 n 个到　str2
       char *strncpy(char *str1, const char *str2, size_t n)     ⇒ str1 地址　　 // 从　str2　复制到 str1，最多　n 个字符
       char *strcpy (char *str1, const char *str2)               ⇒ str1 地址　　 // 把 str2 复制到 str1
       char *strcat (char *str1, const char *str2)               ⇒ str1 地址    // 把 str2 追加到 str1 结尾
       char *strncat(char *str1, const char *str2, size_t n)     ⇒ str1 地址    // 把 str2 追加到 str1 结尾，最多　n 个字符

4. 长度

       size_t strlen(const char *str)                            ⇒ 长度　       // 计算 str 的长度，不包括空结束字符

5. 提取错误

       char *strerror(int errnum)                                ⇒ 错误消息　    // 从内部数组中搜索错误号 errnum，通常是errno，并返回一个指向错误消息字符串的地址

6. 拼接

       char   *strtok(char *str, const char *delim)              ⇒ NULL | 地址  // 拆分 str，delim 为分隔符
       size_t  strxfrm(char *str1, const char *str2, size_t n)   ⇒ 转换长度      // 根据程序当前的区域选项中的 LC_COLLATE 来转换 str2 的前 n 个字符，并把它们放置在 str1 中