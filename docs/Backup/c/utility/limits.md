```
#include <limits.h>
```
limits.h 头文件决定了各种变量类型的各种属性，定义在该头文件中的宏限制了各种变量类型（比如 char、int 和 long）的值，这些限制指定了变量不能存储任何超出这些限制的值，例如一个无符号可以存储的最大值是 255。

```
#define CHAR_BIT    8           // 定义一个字节的比特数 
#define SCHAR_MIN  -128         // 定义一个有符号字符的最小值 
#define SCHAR_MAX   127         // 定义一个有符号字符的最大值 
#define UCHAR_MAX   255         // 定义一个无符号字符的最大值 
#define CHAR_MIN    0           // 定义类型 char 的最小值
#define CHAR_MAX    127         // 定义类型 char 的最大值
#define MB_LEN_MAX  1           // 定义多字节字符中的最大字节数 
#define SHRT_MIN   -32768       // 定义一个短整型的最小值 
#define SHRT_MAX   +32767       // 定义一个短整型的最大值 
#define USHRT_MAX   65535       // 定义一个无符号短整型的最大值 
#define INT_MIN    -32768       // 定义一个整型的最小值 
#define INT_MAX    +32767       // 定义一个整型的最大值 
#define UINT_MAX    65535       // 定义一个无符号整型的最大值 
#define LONG_MIN   -2147483648  // 定义一个长整型的最小值 
#define LONG_MAX   +2147483647  // 定义一个长整型的最大值 
#define ULONG_MAX  4294967295   // 定义一个无符号长整型的最大值
```