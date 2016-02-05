
###: offsetOf() 

```c
size_t offsetOf(type, member);
```

* Macro

获取成员 `member` 的偏移地址 - 字节表示。

```c
#define offsetOf(type, member)     \
    ((size_t)&((type *)0)->member)
```

<span>

```nim
template offsetOf(typ: typedesc, member: expr): ByteAddress =
    let zero = cast[typ](ByteAddress(0))
    cast[ByteAddress](addr(zero.member))
```

###: containerOf()

```c
type *containerOf(ptr, type, member);
```

* Macro 

获取成员 `ptr` 的父对象地址 - 指针表示。

```c
#define containerOf(ptr, type, member) ({                 \
    const typeof(((type *)0)->member) *__mptr = (ptr);    \
    (type *)((char *)__mptr - offsetOf(type, member));    \
})
```

<span>

```nim
template containerOf(x: pointer, typ: typedesc, member: expr): ptr expr =
    let it = x
    let containerAddr = cast[ByteAddress](it) - offsetOf(typ, member)
    cast[typ](containerAddr)
```

### 例子：指针的表示

```c
#include <stdio.h>

struct Obj {
    int a;
    char b;
};

int main() {
    struct Obj o = {.a=1, .b='b'};
    
    int *a = &(o.a);                  /* 字段 a 的地址 - 使用指针表示 */
    size_t address = (size_t)&(o.a);  /* 字段 a 的地址 - 使用字节表示 */

    printf("%p\n", a);                /* 0x7ffc4b3aaea0  */
    printf("%ld\n", address);         /* 140721570623136 */
    
    /* 0x7ffc4b3aaea8 */
    printf("%p\n", (int *)&(o.a) + (size_t)2);  
    /* 0x7ffc4b3aaea8 */
    printf("%p\n", (int *)((size_t)(int *)&(o.a) + (size_t)2 * sizeof(int)));  

    /* 0x7ffc4b3aaea2 */
    printf("%p\n", (char *)&(o.a) + 2);
    /* 0x7ffc4b3aaea2 */
    printf("%p\n", (char *)((size_t)(char *)&(o.a) + (size_t)2 * sizeof(char)));  

    struct Obj *zero = (struct Obj *)0;
    printf("%p\n",  zero);              /* (nil) */
    printf("%p\n",  &zero->a);          /* (nil) */
    printf("%p\n",  &zero->b);          /* 0x4   */
    printf("%ld\n", (size_t)&zero->a);  /* 0     */
    printf("%ld\n", (size_t)&zero->b);  /* 4     */
}
```