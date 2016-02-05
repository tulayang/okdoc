Structure (数据结构)
-----------------

1. Number (数字)
   
   * shor int        16
   * int             16 | 32，编译器有关
   * long int        32 | 64，编译器有关
   * long long       64
   * float           32
   * double          64
   * unsigned type   >= 0
   
   有符号 signed，无符号 unsigned。

       unsigned int a = 100;

2. Char (字符)
   
       char a = 'a';  // 8位
   
3. Array (固定数组)

       int  array[]     = {1, 2, 3};
       int  array[3]    = {1, 2, 3};
       char labels[][4] = {"abc", "acd"};
       char *labels[4]  = {"abc", "acd"};
       
       sizeof(array);

   array[{key, value}]

   * 初始化:  array[0, ...]  
   * 存储: key -> (f key) -> num % length -> index -> array[index]  
   * 提取: key -> (g key) -> index                 -> array[index] -> array[index].value

4. Struct （结构）

       struct test {
           int   id; 
           char *label;
           typedef struct {
               char name[10];
           } data;
       };

5. Enum （枚举）

       enum test {
           a, 
           b
       };

       enum test {
           a = 'a', 
           b = 'b'
       };
       
6. Pointer (地址)

       int *x;                       // 声明指针
       int y = 1;                    // 分配1个整数的内存空间
       x = &y;                       // 复制内存地址     
       
      <span>
       
       int   a = 1;
       int  *b;
       int **c;

       b = &a;
       c = &b;

       printf("%d\n", *(*c));        // 1
       
       c[int **] -> b[int *] -> a[int 1]
      
      <span>
      
       #define offsetof(TYPE, MEMBER) ((size_t)&((TYPE *)0)->MEMBER)  // TYPE结构中MEMBER的地址偏移量 
	   #define container_of(ptr, type, member) ({                      \
               const typeof( ((type *)0)->member ) *__mptr = (ptr);    \
               (type *)( (char *)__mptr - offsetof(type, member) );    \
           })
      
       struct T {
           int    a;
           double b;
           chr    c;
       };
       
       void main () {
           struct T t = {1, 1.1, 'c'};
           
           size_t b = (size_t)&((struct T *)0)->b;   // 偏移地址8 
           size_t c = (size_t)&((struct T *)0)->c;   // 偏移地址16
       }
       
       typedef struct T {
           int    a;
           double b;
           char   c;
       } T;

       typedef struct M {
           int  d;
           T   *t;
           char e;
       } M;

       void main() {
           T t = {1, 1.1, 'c'};
           M m = {1, &t, 'e'};

           size_t address_m = (size_t)&m.t - (size_t)&((M *)0)->t;

           (size_t)&m == address_m;   // true

           M * mm = (M *)address_m;

           printf("%c\n", mm->e);     // 'e'
       }
      
7. Function (函数)

       // 返回类型 函数名(参数类型 参数名, 返回类型 (函数指针)(参数类型, 参数类型, ...), ...)

       int sort(int *array, int len, int (*cmp)(int, int)) {...}
       int cmp (int curr,   int item) { return curr > item; }
       int array[] = {1, 2, 3}

       sort(array,     sizeof(array) / sizeof(array[0]), &cmp)
       sort(&array[0], sizeof(array) / sizeof(array[0]), &cmp)

Typedef (类型定义)
---------------

```
typedef struct point Point;
struct point {
    void  *data;
    Point *next;
};

typedef int      int32;
typedef longlong int64;
```

Typeof (动态类型定义)
------------------
       
```
int a = 1;
typeof(a)  b = 2;
typeof(&a) c = &b;
```

Macro (宏)
---------

1. 字符替换

       #define MAX       100;
       #define a(x * x)  x * x; 
       
       #define foreach(list, curr) \
           for (curr = list.head; curr != NULL; curr = curr.next) 

2. 条件
   
       #if defined(MAX)
       #define MIN 100
       #include <malloc.h>
       #elif defined(MMM)
       #define MIN 10
       #else 
       #error "Newer version of code required"
       #endif
       
       #ifndef _CODE_NODE_H
       #define _CODE_NODE_H
       #endif
       
3. sizeof
    
       sizeof(char)
       
       
Special Syntaxes (特殊语法)
--------------------------

```
int a = ({
	int b = 1;
	1;
});
printf("%d\n", a);                // 1
```

<span>

