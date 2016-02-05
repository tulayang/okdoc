# [数据类型](http://nim-lang.org/docs/manual.html#types)

## 整数

### int

通用的有符号整数类型。它的尺寸大小有平台依赖性，不同平台可能大小不同，和指针的大小相同。这个类型，推荐广泛使用。表示整数时，不需要类型后缀，比如 `1`。

### int8 int16 int32 int64

附加的有符号整数类型。用于更精细的内存分配。表示整数时，需要类型后缀，比如 `1'i8` `1'i16` `1'i32` `1'i64`。

### uint

通用的无符号整数类型。它的尺寸大小有平台依赖性，不同平台可能大小不同，和指针的大小相同。这个类型，推荐广泛使用。表示整数时，需要类型后缀，比如 `1'u`。

### uint8 uint16 uint32 uint64

附加的无符号整数类型。用于更精细的内存分配。表示整数时，需要类型后缀，比如 `1'u8` `1'u16` `1'u32` `1'u64`。

### 特殊操作符

对于有符号整数和无符号整数，除了通用算术操作符（`+` `-` `*` 等等）之外，还有一些特殊的操作符：它们把有符号整数当做无符号整数对待，这么做是为了向后兼容一些没有无符号整数的旧式编程语言。这种特殊的操作符，使用 `%` 作为后缀：

操作符|描述
-|-
`a +% b`    |无符号整数加法
`a -% b`    |无符号整数减法
`a *% b`    |无符号整数乘法
`a /% b`    |无符号整数除法
`a %% b`    |无符号整数取模
`a <% b`    |作为无符号整数比较
`a <=% b`   |作为无符号整数比较
`ze(a)` |使用 0 扩充 a 的位直到达到 int 类型的宽度
`toU8(a)`   |把 a 作为无符号整数对待并且转换为 8 位无符号整数的宽度（但是仍然是 int8 类型）
`toU16(a)`|把 a 作为无符号整数对待并且转换为 16 位无符号整数的宽度（但是仍然是 int16 类型）
`toU32(a)`  |把 a 作为无符号整数对待并且转换为 32 位无符号整数的宽度（但是仍然是 int32 类型）



### 自动类型转换

当表达式包含不同的整数类型时，会自动启用类型转换：较小的类型转换为较大的类型。

“缩小的类型转换”，是把较大的类型转换为较小的类型，比如 `int32` 转换为 `int16`。“扩大的类型转换”，是把较小的类型转换为较大的类型，比如 `int16` 转换为 `int32`。在 Nim 语言中，只有“扩大的类型转换”是隐式工作的：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
var myInt16 = 5i16
var myInt: int
myInt16 + 34     #  int16 类型
myInt16 + myInt  #  int   类型
myInt16 + 2i32   #  int32 类型
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

然而，如果数值适合较小的类型，并且转换并不比其他隐式转换昂贵，`int` 值就会隐式地转换为较小的类型。因此 `myInt16 + 34` 返回的是 `int16` 类型。  

### 

## 子域类型

### range

子域类型，属于有序类型的范围值。要定义一个子域类型，必须指定它的范围：最小值和最大值：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
type
    Subrange = range[0..5]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

`Subrange` 是一个整数的子域，只能操作数值 `0` 到 `5`。为 `Subrange` 类型的变量分配任何其它的值，都会引发运行期错误（如果可以静态取值，则会引发编译期错误）。

子域类型和它的基类型，拥有相同的内存大小。



### interval arithmetic

Nim requires interval arithmetic for subrange types over a set of built-in operators that involve constants: x %% 3 is of type range[0..2]. The following built-in operators for integers are affected by this rule: -, +, *, min, max, succ, pred, mod, div, %%, and (bitwise and).

Bitwise and only produces a range if one of its operands is a constant x so that (x+1) is a number of two. (Bitwise and is then a %% operation.)

This means that the following code is accepted:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
case (x and 3) + 7
of 7: echo "A"
of 8: echo "B"
of 9: echo "C"
of 10: echo "D"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   

###

## 浮点数类型

### float

通用的浮点数类型。它的尺寸大小有平台依赖性，不同平台可能大小不同，和指针的大小相同。这个类型，推荐广泛使用。表示浮点数时，不需要类型后缀，比如 `1.0`。



### float32 float64

附加的浮点数类型。用于更精细的内存分配。表示浮点数时，需要类型后缀，比如 `1.0'f32` `1.0'f64` `1.0'd` `1.0'D`。



### 自动类型转换

当表达式包含不同的浮点数类型时，会自动启用类型转换：较小的类型转换为较大的类型。浮点数类型的算术运算，遵循 IEEE 标准。整数类型不能自动转换为浮点数类型，反之亦然。



### 浮点数异常

IEEE 标准定义了 5 种浮点数类型异常：

*  Invalid - 计算无效的操作数，比如 `0.0/0.0`，`sqrt(-1.0)`，`log(-37.8)`
*  Division by zero - 除数是 0 并且被除数是非 0 数字，比如 `1.0/0.0`
*  Overflow - 结果值过大，超出范围，比如 `MAXDOUBLE+0.0000000000001e308`
*  Underflow - 结果值过小，超出范围，比如 `MINDOUBLE * MINDOUBLE`
*  Inexact - 结果值无限精度，不能被有效表示，比如 `2.0/3.0`, `log(1.1)`

IEEE 标准异常，在运行期要么被忽略、要么映射到 Nim 语言的内置异常：`FloatInvalidOpError` `FloatDivByZeroError` `FloatOverflowError` `FloatUnderflowError` `FloatInexactError`。这些异常继承自 `FloatingPointError`。

语法标记 `{.NaNChecks.}` 和 `{.InfChecks.}` 可以控制忽略、或者追踪 IEEE 标准异常：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
{.NanChecks: on, InfChecks: on.}
var a = 1.0
var b = 0.0
echo b / b  #  引发 FloatInvalidOpError
echo a / b  #  引发 FloatOverflowError
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

在当前版本，`FloatDivByZeroError` 和 `FloatInexactError` 永远不会引发异常。`FloatOverflowError` 代替 `FloatDivByZeroError` 用来引发异常。 `{.NaNChecks.}` 和 `{.InfChecks.}` 组合的简写是 `{.floatChecks.}`，`{.floatChecks.}` 默认是关闭的。

`{.floatChecks.}` 只对 `+` `-` `*` `/` 计算浮点数类型时生效。



在编译期，对浮点数类型求值总是使用最大有效精度，比如 `0.09'f32 + 0.01'f32 == 0.09'f64 + 0.01'f64` 返回 `true`。

###

## 布尔类型

### bool

布尔类型命名为 `bool`，并且只能是 `true` 或者 `false`。`while`、`if`、`elif`、`when` 语句条件都需要布尔类型。

条件：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ebnf
ord(false) == 0 and ord(true) == 1
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



### 内存大小

布尔类型占用 1 个字节内存。



### 操作符

操作符 `not` `and` `or` `xor` `<` `<=` `>` `>=` `!=` `==` 可用于布尔类型。`and` 和 `or` 执行短连接评估:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
while p != nil and p.name != "xyz":
    # p.name 不会被检查，因为 p == nil
    p = p.next
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

###

## 字符类型

### char 

字符类型命名为 `char`。



### 内存大小

字符类型占用 1 个字节内存。

###

## 枚举类型

### enum

枚举类型定义一个新类型，它由指定的值组成，这些值是有序的。例子：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
type
    Direction = enum
        north, east, south, west
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

然后可以：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
ord(north) == 0
ord(east) == 1
ord(south) == 2
ord(west) == 3
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

显然 `north` < `east` < `south` < `west` 。比较操作符可用于枚举类型。



### 字段赋值

为了与其他编程语言更好的接口交互，可对枚举类型的字段显式赋值。字段值必须是有序的、并且是升序的。当字段没有被显式赋值时，默认采用 +1 赋值的方式。

一个显式赋值的枚举可以有空洞：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
type
    TokenType = enum
        a = 2, b = 4, c = 89
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

编译器支持将内置的字符化操作符 `$` 用在枚举类型：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
type
    MyEnum = enum
        valueA = (0, "my value A"),
        valueB = "value B",
        valueC = 2,
        valueD = (3, "abc")
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

从这个例子可以看出，通过元组同时为字段指定一个有序值和字符串值是可行的。只指定其中一个也可以。



### 限定命名空间

可以使用 `{.pure.}` 标记枚举类型，使其字段不能加入当前作用域，必须通过类型名访问：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
type
    MyEnum {.pure.} = enum
        valueA, valueB, valueC, valueD

    YrEnum {.pure.} = enum
        valueX, valueY, valueZ, valueM

    echo valueA         #  Error: Unknown identifier
    echo MyEnum.valueA  #  Ok

    echo valueX         #  Ok
    echo YrEnum.valueX  #  Ok
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### 

## 字符串类型

### string

所有的字符串字面值，是字符串类型。字符串非常类似字符序列。然而，Nim 语言中的字符串是以 '\0' 作为终止符。使用内置函数 `len()` 返回长度，长度不包括终止符。对字符串使用赋值操作符时，总是执行复制。`&` 操作符拼接字符串。 

字符串的比较，按照单词表中的顺序。所有的比较操作符都有效。可以像数组一样索引字符串（最低位是 0）。和数组不同的是，字符串可以使用 `case` 语句：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
case paramStr(i)
of "-v": incl(options, optVerbose)
of "-h", "-?": incl(options, optHelp)
else: write(stdout, "invalid command line option!\n")
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



### 字符串化

大多数数据类型，支持使用 `$` 操作符转换为字符串。当调用 `echo()` 时，会在内部调用 `$`：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
echo 3  #  为 int 调用 $()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

当用户创建对象时，可以实现这些函数：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
type
    Person = object
        name: string
        age: int

proc `$`(p: Person): string =  # `$` 总是返回一个字符串
    result = p.name & " is " &
            $p.age &  # we *need* the `$` in front of p.age, which
                      # is natively an integer, to convert it to
                      # a string
            " years old."
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

当对字符串使用 `$` 时，`$` 什么也不做。注意：和 `echo()` 不同，从`int` 类型到 `string` 类型时，不会自动转换---你必须显式地转换。



### 字符串和 Unicode

按照惯例，所有字符串都可以是 UFT-8 字符串，但这不是强制的。例如，从二进制文件读取字符串时，它们仅仅是一个字节序列。索引操作符 `s[i]` 表示 `s` 第 i 个 `char`，而不是第 i 个 `unichar`。[unicode module](http://nim-lang.org/docs/unicode.html) 中的迭代器 `runes` 可以用来迭代所有的 Unicode 字符。

###

## 字符串指针

### cstring

`cstring` 类型表示一个指针，指向一个以 `'\0'` 作为终止符的字符数组，以兼容 C 语言的 `char *` 类型。它的主要目的是：方便和 C 语言接口交互。索引操作符 `s[i]` 表示 `s` 第 i 个 `char`。

>`ctring` 类型不执行边界检查，因此对其执行索引操作是“不安全的”！！！



### string 转换到 ctring

一个 `string` 可以隐式地转换到 `cstring`。当把一个 `string` 传递到 C 语言风格的可变函数时，就会隐式转换到 `cstring`：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc printf(formatstr: cstring) {.importc: "printf", varargs, header: "<stdio.h>".}

printf("This works %s", "as expected")
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
尽管转换是隐式执行，但它是“不安全的”：垃圾收集器不会把 `cstring` 纳入根管理以收集底层内存！！！然而许多实践表明，GC 把栈内存纳入根管理这种情况很少出现。在极少出现的情况下，用户可以调用 `GC_ref()` 和 `GC_unref()` 内置函数，来强制 `string` 数据（本该被内存回收）继续存在。



### ctring 转换到 string

`$()` 函数使 `cstring` 转换为 `string`。从一个 `cstring` 得到一个 `string`：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
var str: string = "Hello!"
var cstr: cstring = str
var newstr: string = $cstr
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

###

## 结构化类型

结构化类型的变量，可在同一时间持有多个值。结构化类型可以无限制地嵌套。数组、序列、元组、对象和集合，属于结构化类型。



### array

数组类型，每个成员都是相同的类型。长度是固定的，并且在编译期确定（除了　`open array`）。形参 `A` 可以是 `open array`，此时从 `0` 到 `len(A)-1` 整数索引。可在表达式中使用数组构造器 `[　]` 构造数组。

数组总是执行边界检查（在编译期或运行期）。这些检查可以通过语法标记、或编译器命令项 `--boundChecks:off` 关闭。



### seq

序列类型，类似数组类型，但长度在运行期是动态可变的（类似字符串类型）。序列，是作为一个可变长度数组实现的，新的项被添加时，同时分配新的内存。序列 `S` 可整数索引，从 `0` 到 `len(S)-1`，并且执行边界检查。和数组类型类似，可在表达式中通过序列构造器 `@[]` 构造序列。另一种构造序列的方式，是调用内置函数 `newSeq()` 分配内存空间。

序列可以作为参数传递给 `open array` 类型。

例子：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
type
    IntArray = array[0..5, int]
    IntSeq = seq[int]
var
    x: IntArray
    y: IntSeq
x = [1, 2, 3, 4, 5, 6]   # []  是数组构造器
y = @[1, 2, 3, 4, 5, 6]  # @[] 是序列构造器
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

调用内置函数 `low()` 可获取数组和序列的最低索引，调用 `high()` 可获取最高索引，调用 `len()` 可获取长度。对一个序列或者 `open array` 调用 `low()` 时总是返回 `0`，因为它们的第一个有效索引必须是 0。调用 `add()` 或者 `&` 可向序列中增加元素。调用 `pop()` 可移除序列最后一个元素。



### open array

`open array` 只能够用作形参，并且总是以 0 开始索引。`len()` `low()` `high()` 对 `open array` 都可用。一个拥有兼容基本类型的数组，可作为实参传递给 `open array` 形参，其索引类型并不重要。除了数组，序列也可作为实参传递给 `open array` 形参。

`open array` 类型不能嵌套：多维 `open array` 不受支持，因为这种情况很少并且效率很差。


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc testOpenArray(x: openArray[int]) = echo repr(x)

testOpenArray([1,2,3])   # array[]
testOpenArray(@[1,2,3])  # seq[]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### varargs

`varargs` 形参表示 `open array` 形参。此外，还允许传递的实参数目可变。编译器会隐式地把实参列表转换为数组：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc myWriteln(f: File, a: varargs[string]) =
    for s in items(a):
        write(f, s)
    write(f, "\n")

myWriteln(stdout, "abc", "def", "xyz")
# 转换为：
myWriteln(stdout, ["abc", "def", "xyz"])
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

函数最后一个参数是 `varargs` 形参时，才会执行转换。下面这种场景下，也可提供类型转换：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc myWriteln(f: File, a: varargs[string, `$`]) =
    for s in items(a):
        write(f, s)
    write(f, "\n")

myWriteln(stdout, 123, "abc", 4.0)
# 转换为：
myWriteln(stdout, [$123, $"def", $4.0])
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

在这个例子，`$` 用在参数 `a` 的参数列表中的每一项。

注意：把数组构造器作为实参传递给 `varargs` 形参时，并不会隐式地用数组包裹：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc takeV[T](a: varargs[T]) = discard

takeV([123, 2, 1])  # takeV's T is "int", not "array of int"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

`varargs[expr]` 是个例外：它匹配任意类型的变量实参列表，同时，隐式地对其用数组包裹。这很有用，内置函数 `echo()` 可以实现期望的结果：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc echo*(x: varargs[expr, `$`]) {...}

echo(@[1, 2, 3])
# 打印 "@[1, 2, 3]" 而不是 "123"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



### tuple 和　object

元组和对象属于容器类型，用来存储多个类型的值。它们定义各种各样类型的字段。元组同时定义字段的顺序。

元组存储多个类型时，没有额外开销。元祖不是用来抽象的，那是对象的任务。构造器 `( )` 可以用于构造元组。构造器的字段顺序，必须匹配元组定义的顺序。对于不同的元组类型，如果它们的字段名字、字段类型和字段顺序都相同，那么这些元组是等价的。

对元组使用赋值操作符，会复制每个元素。对对象使用默认的赋值操作符，也会复制每个元素。当前，重写对象的赋值操作符是不允许的，不过在未来编译器版本中会改变这种情况。


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
type
    Person = tuple[name: string, age: int]  # 一个 Person 类型:
                                            # 包含一个 name 和 一个 age
var
    person: Person
person = (name: "Peter", age: 30)
# 同样的实现，但是更可读：
person = ("Peter", 30)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

在实现中对齐字段可以获得最好的性能。对齐规则采用兼容 C 语言编译器的方式。

为了和对象声明一致，也可以在 `type` 块通过缩进（代替 `tuple[] `）定义元组：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
type
    Person = tuple      
        name: string    
        age: natural    
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

对象提供元组没有的许多功能。对象可以继承和信息隐藏。可以在运行期访问对象的类型：`of` 操作符可以确定该对象的类型。`of` 操作符类似 Java 中的 `instanceof` 操作符：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
type
    Person = object of RootObj
        name*: string   # * 表示该字段可以被其他模块访问
        age: int        # 没有 * 表示该字段对其他模块隐藏
    Student = ref object of Person  
        id: int                       
var
    student: Student
    person: Person
assert(student of Student)  # is true
assert(student of Person)   # also true
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

如果你想让对象的字段可以在模块外访问，那么必须使用 `*` 标记它。和元组不同：不同的对象类型一定不等价。没有始祖的对象隐含 `{.final.}`。使用 `{.inheritable.}` 语法标记，可以使对象继承根对象 `system.RootObj`。



### 对象的构造

也可以使用对象构造器来构造对象，语法是这样的：`T(fieldA: valueA, fieldB: valueB, ...)`，其中 `T` 是一个 `object` 类型或者 `ref object` 类型：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
var student = Student(name: "Anton", age: 5, id: 3)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

注意，和元组不同：对象构造器必须填入字段名及其字段值；对于 `ref object`，对象构造器会隐式地调用 `system.new()`。



### 对象的变体

在某些情况，一个对象的层次结构会变得很复杂，这时候需要简单可用的变体。一个例子：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
# This is an example how an abstract syntax tree could be modelled in Nim
type
    NodeKind = enum  # the different node types
        nkInt,          # a leaf with an integer value
        nkFloat,        # a leaf with a float value
        nkString,       # a leaf with a string value
        nkAdd,          # an addition
        nkSub,          # a subtraction
        nkIf            # an if statement
    Node = ref NodeObj
    NodeObj = object
        case kind: NodeKind  # the ``kind`` field is the discriminator
        of nkInt: intVal: int
        of nkFloat: floatVal: float
        of nkString: strVal: string
        of nkAdd, nkSub:
            leftOp, rightOp: Node
        of nkIf:
            condition, thenPart, elsePart: Node
# create a new case object:
var n = Node(kind: nkIf, condition: nil)
# accessing n.thenPart is valid because the ``nkIf`` branch is active:
n.thenPart = Node(kind: nkFloat, floatVal: 2.0)
# the following statement raises an `FieldError` exception, because
# n.kind's value does not fit and the ``nkString`` branch is not active:
n.strVal = ""
# invalid: would change the active object branch:
n.kind = nkInt
var x = Node(kind: nkAdd, leftOp: Node(kind: nkInt, intVal: 4),
                          rightOp: Node(kind: nkInt, intVal: 2))
# valid: does not change the active object branch:
x.kind = nkSub
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

如同例子所示，该对象的层次结构有这样的优势：对不同的对象类型不需要构造多次。不过，访问无效的对象字段会引发异常。

对象声明中的 `case` 语法非常类似 `case` 语句的语法：其中的分支必须使用缩进。

在这个例子中，`kind` 字段被称为鉴别器。为了安全起见，它的地址不能被获取，并且对它的赋值是受限的：赋给它的新值，不能导致对象活动分支出现变动。可以调用 `system.reset()` 来激活/关闭一个对象的分支。



### set

集合类型，体现了数学中的集合概念。集合的基类型，必须是特定尺寸的有序类型，即：

* `int8`-`int16`
* `uint8`/`byte`-`uint16`
* `char`
* `enum`

或者是与此等价的类型。这样设定，是为了把集合实现为高效的位矢量。试图用大尺寸的类型声明一个集合，会引发错误：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
var s: set[int64] # Error: set is too large
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

可以使用集合构造器 `{ }` 构造集合：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
type
    CharSet = set[char]
var x: CharSet
x = {'a'..'z', '0'..'9'} # 这个集合构造器包含了 'a' to 'z' 的字母和 '0' to '9' 的十进制字符
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

集合支持下列操作：

操作  | 描述
-|-
A + B   |连接
A * B   |交集
A - B   |差集
A == B  |相等？
A <= B  |A是B的子集？
A < B   |A是B的子集？
e in A  |A 包含元素 e？ 
e notin A   |A 不包含元素e
contains(A, e)  |A 包含元素e？
card(A) |A 元素个数
incl(A, elem)   |A 添加一个元素
excl(A, elem)   |A 删除一个元素

集合通常用来定义一个函数的标志位。比起单纯的定义整数常量、然后执行二进制或计算，使用集合更清晰，并能保证类型安全。

### 

## 指针类型和引用

### 追踪引用和非追踪引用

引用，表示多对一的关系。不同的引用，可以指向和修改同一个内存地址。

在 Nim 语言中，分为追踪引用和非追踪引用。非追踪引用也称为指针。追踪引用所指向的内存，是由 GC 在堆上分配的（受到 GC 的影响）。非追踪引用所指向的内存，是手动分配的（堆内存），或者是在内存其他位置（栈内存）。因此，非追踪引用是“不安全的”。然而，对于底层运算（比如访问硬件），使用非追踪引用是非常必要的。

追踪引用使用 `ref` 关键字声明，非追踪引用使用 `ptr` 关键字声明。

`[ ]` 可以用来解引用。`addr()` 返回一个目标的内存地址，这个内存地址总是非追踪引用，因此 `addr()` 是一个“不安全的”操作。

`.` 操作符用在引用类型时，提供隐式的解引用操作：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
type
    Node = ref NodeObj
    NodeObj = object
        le, ri: Node
        data: int
var
    n: Node
new(n)
n.data = 9  # 不需要写作 n[].data
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

函数调用的第一个参数，也可以自动解引用。但是，当前版本必须在前面添加语法标记 `{.experimental.}`： 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
{.experimental.}

proc depth(x: NodeObj): int = ...
var
    n: Node
new(n)
echo n.depth  # 不需要写作 n[].depth
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

为了简化结构类型检查，元组递归是无效的：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
# 无效递归
type MyTuple = tuple[a: ref MyTuple]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

同样的 `T = ref T` 也是无效的。



### 匿名对象

在 `type` 定义块中，通过 `ref object` 或者 `ptr object` 声明类型时，对象类型可以匿名。如果只想使用引用类型，这个特性会很有用：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
type
    Node = ref object
        le, ri: Node
        data: int
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 



### 分配和释放内存

为一个新的追踪引用分配内存，需要调用内置函数 `new()`。对于非追踪的内存，调用内置函数 `alloc()` `dealloc()` `realloc()` 等等。[system module](nim-lang.org/docs/system.html) 的文档描述了具体的细节。

如果一个引用不指向任何内容，那么它的值是 `nil`。

必须特别注意：如果一个非追踪对象包含了追踪对象（比如追踪引用、字符串或者序列），为了正确释放每一块内存，手动释放非追踪内存前必须调用 `GC_unref()`：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
type
    Data = tuple[x, y: int, s: string]
# 为 Data 在堆上分配内存：
var d = cast[ptr Data](alloc0(sizeof(Data)))
# 通过 GC 在堆上创建一个新的字符串：
d.s = "abc"
# 告诉 GC 该字符串不再需要：
GC_unref(d.s)
# 释放内存：
dealloc(d)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

如果在 `dealloc(d)` 之前没有调用 `GC_unref(d.s)`，那么这个字符串内存永远不会释放。上面的例子也给出了底层编程的两个重要特点：`sizeof()` 函数返回一个类型的字节大小，`cast()` 使编译器强制把内存用某个特定类型表示。只在非常必要的情况下使用 `cast()`，它破坏“类型安全”并且容易滋生 bug。 

注意：上面的例子可以工作是因为其内存已经通过 `alloc0()` 初始化为 0，也因此 `d.s` 被初始化为 `nil` 并可对其赋值。

###

## not nil

所有值可以是 `nil` 的类型，可以通过 `not nil` 声明，禁止使用 `nil` 值：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
type
    PObject = ref TObj not nil
    TProc = (proc (x, y: int)) not nil
proc p(x: PObject) =
    echo "not nil"
# 编译器捕获到这个问题：
p(nil)
# 这里也是同样的： !!! 译注：nim v0.12 发现此处是个 bug
var x: PObject
p(x)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## 内存区域

`ref` 类型和 `ptr` 类型，可以获得一个可选的区域标注。只有对象类型能使用区域标注。

在开发操作系统内核时，划分用户空间和内核空间是非常有用的：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
type
    Kernel = object
    Userspace = object
var a: Kernel ptr Stat
var b: Userspace ptr Stat
# 下面的内容不能编译，因为指针类型不兼容：
a = b
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

如例子所示，`ptr` 也能用做二元操作符，`region ptr T` 是 `ptr[region, T]` 的简写。

为了简化泛型编码，`ptr T` 表示 `ptr[R, T]` （任意 R） 的派生子类。

作为特殊的类型规则，`ptr[R, T]` 不兼容 `pointer`： 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
# from system
proc dealloc(p: pointer)
# wrap some scripting language
type
    PythonsHeap = object
    PyObjectHeader = object
        rc: int
        typ: pointer
    PyObject = ptr[PythonsHeap, PyObjectHeader]
proc createPyObject(): PyObject {.importc: "...".}
proc destroyPyObject(x: PyObject) {.importc: "...".}
var foo = createPyObject()
# type error here, how convenient:
dealloc(foo)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



未来方向：

* 内存区域也可以对 `string` 和 `seq` 有效
* 内置区域比如 `private` `global` `local` 在即将到来的 OpenCL 会更有用
* 内置区域可以构造 `lent` 和 `unique` 指针
* 赋值操作符可以附加到区域，以生成合适的写屏障。这意味着 GC 可以彻底在用户空间实现。

## 函数类型

### 何谓函数类型？

函数类型，是一个指向函数地址的指针。允许把 `nil` 作为函数的值。Nim 语言使用函数类型来达成函数式编程语言的技巧。

例子：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc printItem(x: int) = ...
proc forEach(c: proc (x: int) {.cdecl.}) =...
forEach(printItem)  # 不能编译，因为调用约定不同
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
type
    OnMouseMove = proc (x, y: int) {.closure.}
proc onMouseMove(mouseX, mouseY: int) =
    # 使用默认的调用约定
    echo "x: ", mouseX, " y: ", mouseY
proc setOnMouseMove(mouseMoveEvent: OnMouseMove) = discard
# ok，onMouseMove 使用默认的调用约定，该约定兼容  {.closure.}
setOnMouseMove(onMouseMove)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



### 调用约定

有个极其微妙的细节，函数的调用约定会影响类型的兼容：拥有相同调用约定的函数类型，才能够彼此兼容。有一个例外扩展：使用 `{.nimcall.}` 调用约定的函数，可以作为参数，传递给期望调用约定是 `{.closure.}` 的函数参数。

Nim 语言支持如下调用约定：

* `{.nimcall.}` - 函数的默认调用约定。它和 `{.fastcall.}` 是相同的，但是只有 C 语言编译器支持 fastcall 。

* `{.closure.}` - 当一个函数参数类型缺乏该语法标记时，作为其默认的调用约定。它表示函数有一个隐式的参数（一个环境变量）。拥有该调用约定的函数变量有两个机器字：一个用于函数指针，另一个指向隐式的环境变量。

* `{.stdcall.}` - 由微软指定的调用约定。生成的 C 语言函数声明为 `__stdcall`。

* `{.cdecl.}` - 表示该函数将会使用和 C 语言编译器相同的调用约定。在 Windows 下生成的 C 语言函数声明为 `__cdecl`。

* `{.safecall.}` - 由微软指定的调用约定。生成的 C 语言函数声明为 `__safecall`。

* `{.inline.}` - 表示该函数不应该被调用而是嵌入到代码段中。注意 Nim 不会进行嵌入，而是交由 C 语言编译器执行。生成的 C 语言函数声明为 `__inline`。

* `{.fastcall.}` - 对于不同的 C 语言编译器有不同的行为。其同 C 语言的 `__fastcall` 是相同的功能。

* `{.syscall.}` - 同 C 语言的 `__syscall` 是相同的意思。

* `{.noconv.}` - 生成的 C 语言代码不会包含任何显式的调用约定，因此会使用 C 语言的默认调用约定。这是必要的，因为 Nim 语言为了提高性能，默认采用 fastcall 。



把一个函数赋值／传递给一个函数变量时，需要满足下面规则之一：

* 这个函数在当前模块内
* 这个函数使用 `{.procvar.}` 语法标记
* 这个函数有一个和 `{.nimcall.}` 不同的调用约定
* 这个函数是匿名的

这个规则的目的，是为了阻止使用默认参数、但是没有使用 `{.procvar.}` 标记的函数破坏客户代码。



### 默认调用约定

默认调用约定是 `{.nimcall.}`，除非是一个内嵌函数（一个函数嵌套在另一个函数内部）。对于内嵌函数，会执行语法分析，判断其是否访问环境。如果它确实访问环境，默认调用约定就是 `{.closure.}`，否则是 `{.nimcall.}`。

###

## 独特类型

### distinct

distinct 类型，是由一个基类型推导出来的新类型，它和它的基类型不兼容。重要的是，distinct 类型和它的基类型之间，不存在隐式的子类关系。distinct 类型和它的基类型，可以执行显式的类型转换。



### 模拟货币

distinct 类型，可以用数字类型作为基类型，来模拟不同的物理单位。比如下面的例子模拟货币。

不同的货币，不应该混用货币计算规则。distinct 类型是模拟货币的完美工具：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
type
    Dollar = distinct int
    Euro = distinct int
var
    d: Dollar
    e: Euro
echo d + 12
# Error: 不能对一个 ``Dollar`` 加一个没有单位的数字
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

`d + 12.Dollar` 也是不允许的，因为 `+` 操作符对 `int` 是有定义的，但是对 `Dollar` 则没有。因此需要实现 `Dollar` 的 `+` 定义：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc `+` (x, y: Dollar): Dollar =
    result = Dollar(int(x) + int(y))
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc `*` (x: Dollar, y: int): Dollar =
    result = Dollar(int(x) * y)

proc `*` (x: int, y: Dollar): Dollar =
    result = Dollar(x * int(y))

proc `div` ...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
这样会让你写的很烦。使用 `{.borrow.}` 语法标记，可以帮你节省时间，编译器为你自动实现上面代码的功能：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc `*` (x: Dollar, y: int): Dollar {.borrow.}
proc `*` (x: int, y: Dollar): Dollar {.borrow.}
proc `div` (x: Dollar, y: int): Dollar {.borrow.}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
`{.borrow.}` 语法标记，使编译器对函数采用 distinct 类型的基类型相同的实现方式，所以，并不会生成代码。

对于欧洲货币，示例代码似乎存在很多重复。可以使用 `template` 解决这个问题：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
template additive(typ: typedesc): stmt =
    proc `+` *(x, y: typ): typ {.borrow.}
    proc `-` *(x, y: typ): typ {.borrow.}
    # unary operators:
    proc `+` *(x: typ): typ {.borrow.}
    proc `-` *(x: typ): typ {.borrow.}

template multiplicative(typ, base: typedesc): stmt =
    proc `*` *(x: typ, y: base): typ {.borrow.}
    proc `*` *(x: base, y: typ): typ {.borrow.}
    proc `div` *(x: typ, y: base): typ {.borrow.}
    proc `mod` *(x: typ, y: base): typ {.borrow.}

template comparable(typ: typedesc): stmt =
    proc `<` * (x, y: typ): bool {.borrow.}
    proc `<=` * (x, y: typ): bool {.borrow.}
    proc `==` * (x, y: typ): bool {.borrow.}

template defineCurrency(typ, base: expr): stmt =
    type
        typ* = distinct base
    additive(typ)
    multiplicative(typ, base)
    comparable(typ)

defineCurrency(Dollar, int)
defineCurrency(Euro, int)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
`{.borrow.}` 语法标记也能用于标记 distinct 类型解除特定的内置操作符：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
type
    Foo = object
        a, b: int
        s: string
    Bar {.borrow: `.`.} = distinct Foo
var bb: ref Bar
new bb
# 现在字段访问是无效的
bb.a = 90
bb.s = "abc"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

当前，这种功能只支持 `.` 操作符。



### 避免 SQL 注入攻击

从 Nim 向一个 SQL 数据库传送 SQL 语句，可以用字符串来完成。然而，使用字符串模板、并且填充其中的占位符，容易导致潜在的 SQL 注入攻击：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
import strutils
proc query(db: DbHandle, statement: string) = ...
var
    username: string
db.query("SELECT FROM users WHERE name = '$1'" % username)
# 可怕的安全漏洞，但是编译器可不管！
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

distinct 类型提供了一种方法避免这种漏洞，引入一个与字符串类型不兼容的新类型：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
type
    SQL = distinct string
proc query(db: DbHandle, statement: SQL) = ...
var
    username: string
db.query("SELECT FROM users WHERE name = '$1'" % username)
# 编译器错误： `query` 期望一个 SQL string！
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

在 string 和 SQL 之间显式的类型转换是允许的：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
import strutils, sequtils
proc properQuote(s: string): SQL =
    # quotes a string properly for an SQL statement
    return SQL(s)
proc `%` (frmt: SQL, values: openarray[string]): SQL =
    # quote each argument:
    let v = values.mapIt(SQL, properQuote(it))
    # we need a temporary type for the type conversion :-(
    type StrSeq = seq[string]
    # call strutils.`%`:
    result = SQL(string(frmt) % StrSeq(v))
db.query("SELECT FROM users WHERE name = '$1'".SQL % [username])
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

现在我们有了避免 SQL 注入攻击的编译期检查。因为 `"".SQL` 转换到 `SQL("")`，可以获得更可读的 SQL 字符串值，却不需要增加新的语法。事实上，上面的 `SQL` 类型就在我们的标准库，查看 db_sqlite 模块可以获得更多细节。       

###

## void 类型

void 类型，表示没有任何类型。参数中的 void 类型，作为不存在来处理，返回值是 void 类型，表示不返回任何值：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc nothing(x, y: void): void =
    echo "ha"
nothing()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



void 类型对于泛型编程特别有用：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc callProc[T](p: proc (x: T), x: T) =
    when T is void:
        p()
    else:
        p(x)
proc intProc(x: int) = discard
proc emptyProc() = discard
callProc[int](intProc, 12)
callProc[void](emptyProc)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



然而，不能在泛型代码中推导 void 类型：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
callProc(emptyProc)
# Error: type mismatch: got (proc ()) but expected one of: callProc(p: proc (T), x: T)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## auto 类型

auto 类型只能用于返回值和参数。作为返回值类型时，编译器会通过程序主体推导其类型：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc returnsInt(): auto = 1984
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

作为参数时，一般会隐式地执行泛型：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc foo(a, b: auto) = discard
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

类似：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc foo[T1, T2](a: T1, b: T2) = discard
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

不管怎么样，Nim 语言的后续版本可能会将其改变为“通过主体推导参数类型”。到时，上面的 `foo` 会因为一个空 `discard` 语句导致参数类型无法被推导，而被编译器拒绝。