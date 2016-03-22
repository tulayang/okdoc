Module system （types）
=======================

The compiler depends on the System module to work properly(正确地工作) and the System module depends on the compiler. Most of the routines listed here use special compiler magic. Each module implicitly(隐式地) imports the System module; it must not be listed explicitly(明确地). Because of this there cannot be a user-defined module named **system**.

Types build-in
----------------

```
int                         ## signed integer   类型； 默认的； 尺寸依赖平台；总是与指针相同大小 
int8                        ##                         8 位
int16                       ##                        16 位
int32                       ##                        32 位
int64                       ##                        64 位

uint                        ## unsigned integer 类型； 默认的； 尺寸依赖平台
uint8                       ##                         8 位 
uint16                      ##                        16 位 
uint32                      ##                        32 位 
uint64                      ##                        64 位

float                       ## floating point   类型； 默认的
float32                     ##                        32 位
float64                     ##                        64 位
```

<span>

```
bool = enum                 // boolean         类型； 
    false = 0, true = 1
```

<span>

```
char                        ## character        类型；  8 位     
string                      ## string           类型；
cstring                     ## cstring          类型； 兼容 string 类型
```

<span>

```
pointer                     ## pointer          类型； 使用 addr() 获取
ptr[T]                      ##                        泛型非追踪
ref[T]                      ##                        泛型追踪      
Ordinal[T] 
```

<span>

```
expr                        ## meta             类型； 表示表达式； 用于 templates
stmt                        ##                        表示语句；   用于 templates

typedesc                    ##                        表示类型描述
void                        ##                        表示没有类型

untyped                     ##                        表示表达式； 用于 templates；not resolved
typed                       ##                        表示表达式； 用于 templates；resolved
```

<span>

```
range[T]                    ## 泛型 range      类型； 构造 range 类型
array[I, T]                 ## 泛型 array      类型； 构造固定长度的 array
openArray[T]                ## 泛型 open array 类型； 构造 open array
varargs[T]                  ## 泛型 varargs    类型； 构造 varargs
seq[T]                      ## 泛型 sequence   类型； 构造 sequence
set[T]                      ## 泛型 set        类型； 构造 bit set

Slice[T] = object           ## 泛型 slice      类型；
  a*, b*: T 

RootObj  = object           ## the root of Nim's object hierarchy
RootRef  = ref RootObj      ## reference to RootObj
```

Types alias
------------

```
auto = expr                 
any  = distinct auto
```

<span>

```
SomeSignedInt   = int | int8 | int16 | int32 | int64 ## type class； 匹配所有 signed integer 类型
SomeUnsignedInt = uint   | uint8  | uint16 | 
                  uint32 | uint64                    ## type class； 匹配所有 unsigned integer 类型
SomeInteger     = SomeSignedInt | SomeUnsignedInt    ## type class； 匹配所有 integer 类型  
SomeOrdinal     =   int  | int8   | int16 | int32 | 
                  int64  | bool   | enum  | uint8 | 
                  uint16 | uint32                    ## type class； 匹配所有有序类型
SomeReal        = float | float32 | float64          ## type class； 匹配所有 floating point 类型
SomeNumber      = SomeInteger | SomeReal             ## type class； 匹配所有 number 类型
```

<span>

```
shared
guarded

byte     = uint8                                     ## uint8 别名
Natural  = range[0 .. high(int)]                     ## 0 到 int 最大值的 integer 类型
Positive = range[1 .. high(int)]                     ## 1 到 int 最大值的 integer 类型
```

<span>

```
PFloat32      = ptr float32                          ## ptr float32 的别名
PFloat64      = ptr float64                          ## ptr float64 的别名
PInt64        = ptr int64                            ## ptr int64   的别名
PInt32        = ptr int32                            ## ptr int32   的别名
```

<span>

```
TResult       = enum 
                Failure, Success
Endianness    = enum                    ## 一个类型，描述处理器的字节序
                littleEndian, bigEndian
TaintedString = string                  ## distinct string 类型；使用 -d:taintMode 命令行选项，
                                        ## 开启关闭这个类型
TLibHandle    = pointer
TProcAddr     = pointer

ByteAddress   = int                     ## 用于把 pointers 转换到 integer 地址，以增加可读性
BiggestInt    = int64                   ## 最大有符号 integer 类型；   当前是 int64；   通常有平台依赖
BiggestFloat  = float64                 ## 最大 floating point 类型； 当前是 float64； 通常有平台依赖
```

Types for C
-----------------

```
clong        = int32                                    ## 等同于 C 语言的 long 类型
culong       = uint32                                   ## 等同于 C 语言的 unsigned long 类型
cchar        = char                                     ## 等同于 C 语言的 char 类型
cschar       = int8                                     ## 等同于 C 语言的 signed char 类型
cshort       = int16                                    ## 等同于 C 语言的 short 类型
cint         = int32                                    ## 等同于 C 语言的 int 类型
csize        = int                                      ## 等同于 C 语言的 size_t 类型
clonglong    = int64                                    ## 等同于 C 语言的 long long 类型
cfloat       = float32                                  ## 等同于 C 语言的 float 类型
cdouble      = float64                                  ## 等同于 C 语言的 double 类型
clongdouble  = BiggestFloat                             ## 等同于 C 语言的 long double 类型
cuchar       = char                                     ## 等同于 C 语言的 unsigned char 类型
cushort      = uint16                                   ## 等同于 C 语言的 unsigned short 类型
cuint        = uint32                                   ## 等同于 C 语言的 unsigned int 类型
culonglong   = uint64                                   ## 等同于 C 语言的 unsigned long long 类型
cstringArray = ptr array[0 .. ArrayDummySize, cstring]  ## 等同于 C 语言的 char**；
                            ## The array's high value is large enough to disable bounds checking
                            ## in practice.Use cstringArrayToSeq to convert it into a seq[string]

File         = ptr CFile                                ## 表示文件句柄
FileMode     = enum                                     ## 打开文件的模式
    fmRead,                 ## Open the file for read access only.
    fmWrite,                ## Open the file for write access only.
    fmReadWrite,            ## Open the file for read and write access.
                            ## If the file does not exist, it will be
                            ## created.
    fmReadWriteExisting,    ## Open the file for read and write access.
                            ## If the file does not exist, it will not be
                            ## created.
    fmAppend                ## Open the file for writing only; append data
                            ## at the end.
FileHandle   = cint                                     ## 表示一个 OS 文件句柄；在低阶文件访问时有用

THINSTANCE   = pointer
TAlignType   = BiggestFloat
TRefCount    = int
TUtf16Char   = distinct int16
WideCString  = ref array[0 .. 1000000, TUtf16Char]

```

Types effect and exception
--------------------------

```
RootEffect             = object of RootObj             // 基础 effect 类
TimeEffect             = object of RootEffect          // Time effect
IOEffect               = object of RootEffect          // IO effect
ReadIOEffect           = object of IOEffect            // IO effect，描述读操作
WriteIOEffect          = object of IOEffect            // IO effect，描述写操作
ExecIOEffect           = object of IOEffect            // IO effect，描述运行操作
```

<span>

```
Exception              = object of RootObj              ## 基础 exception 类
    parent*: ref Exception      ## parent exception (can be used as a stack)
    name: cstring               ## The exception's name is its Nim identifier.
                                ## This field is filled automatically in the ``raise`` statement.
    msg* {.exportc: "message".}: string  ## the exception's message. Not
                                         ## providing an exception message is bad style.
    trace: string
SystemError            = object of Exception            ## 异常抽象类，用于运行时抛出系统错误
IOError                = object of SystemError          ## IO 错误
OSError                = object of SystemError          ## 系统服务失败
    errorCode*: int32
LibraryError           = object of OSError              ## 动态库不能加载
ResourceExhaustedError = object of SystemError          ## 资源请求不能满足
ArithmeticError        = object of Exception            ## 算法错误
DivByZeroError         = object of ArithmeticError      ## integer divide-by-zero 错误
OverflowError          = object of ArithmeticError      ## 运行时 integer 溢出
AccessViolationError   = object of Exception            ## 无效的内存访问错误
AssertionError         = object of Exception            ## 断言错误；通常用于 assert()
ValueError             = object of Exception            ## string 和 object 转换错误
KeyError               = object of ValueError           ## key 不能在 table 中找到；大部分用于 tables module
OutOfMemError          = object of SystemError          ## 分配内存不成功
IndexError             = object of Exception            ## array 索引超出边界
FieldError             = object of Exception            ## 无法访问一个字段
RangeError             = object of Exception            ## range 检测错误
StackOverflowError     = object of SystemError          ## 硬件栈调用溢出
ReraiseError           = object of Exception            ## 没有异常可以 reraise
ObjectAssignmentError  = object of Exception            ## object 被分配给其父 object
ObjectConversionError  = object of Exception            ## object 转换到一个不相容的 object 类型
FloatingPointError     = object of Exception            ## 基础类，用于floating point 异常
FloatInvalidOpError    = object of FloatingPointError   ## 不符合 IEEE 的无效操作；比如 0.0/0.0
FloatDivByZeroError    = object of FloatingPointError   ## 非 0 被 0 除
FloatOverflowError     = object of FloatingPointError   ## 最大值溢出
FloatUnderflowError    = object of FloatingPointError   ## 最小值溢出
FloatInexactError      = object of FloatingPointError   ## 不精确的结果；操作产生的结果，不能用无穷精确表示，例如 2.0 / 3.0, log(1.1)
DeadThreadError        = object of Exception            ## 给一个 dead thread 发送消息
```

Types gc，debugger，nimnode
-----------------------------

```
GC_Strategy = enum            ## GC 策略
    gcThroughput,             ## optimize for throughput （吞吐）
    gcResponsiveness,         ## optimize for responsiveness (default) （响应）
    gcOptimizeTime,           ## optimize for speed （速度）
    gcOptimizeSpace           ## optimize for memory footprint （内存占用）

PFrame = ptr TFrame           ## 表示运行时调用栈； part of the debugger API
TFrame = object               ## the frame itself
  prev*: PFrame               ## previous frame; used for chaining the call stack
  procname*: cstring          ## name of the proc that is currently executing
  line*: int                  ## line number of the proc that is currently executing
  filename*: cstring          ## filename of the proc that is currently executing
  len*: int16                 ## length of the inspectable slots
  calldepth*: int16           ## used for max call depth checking

NimNode = ref NimNodeObj      ## 表示一个 Nim AST Node； 用于 macro 操作
```