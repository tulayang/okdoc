```
#include <stddef.h>
```

数据类型 (typedef)
------------------

```
• size_t                                 // usinged int，表示 sizeof 的值
• ptrdiff_t                              // singed int，表示两个指针相减的值
• wchar_t                                // int，宽字符常量大小的整数类型
```

宏常量 (#define)
----------------

```
• NULL                                   // 空指针常量
• offsetof(type, member-designator)      // 生成一个类型为 size_t 的整型常量，
                                         // 是一个结构成员相对于结构开头的字节偏移量
```

stddef.h
----------

```
#ifndef _LINUX_STDDEF_H
#define _LINUX_STDDEF_H

#include <uapi/linux/stddef.h>

#undef  NULL
#define NULL ((void *)0)

enum {
   false = 0,
   true  = 1
};

#undef  offsetof
#ifdef  __compiler_offsetof
#define offsetof(TYPE,MEMBER)  __compiler_offsetof(TYPE,MEMBER)
#else
#define offsetof(TYPE, MEMBER) ((size_t) &((TYPE *)0)->MEMBER)
#endif
#endif
 
/**
* offsetofend(TYPE, MEMBER)
*
* @TYPE: The type of the structure
* @MEMBER: The member within the structure to get the end offset of
*/
#define offsetofend(TYPE, MEMBER) \
    (offsetof(TYPE, MEMBER) + sizeof(((TYPE *)0)->MEMBER))
```