# 语句／表达式范式

Nim 语言采用通用语句／表达式范式：语句不产生值，表达式产生值。不过，有些表达式是语句形式。

语句分为简单语句和复合语句。简单语句不能内嵌其他的语句，比如赋值语句、调用语句或者返回值语句。复合语句可以内嵌其他的语句，并且总是采用缩进。

## 语句列表表达式

语句可以出现在表达式环境中，看起来像是 `(stmt1; stmt2; ...; ex)`，称为语句列表表达式。`(stmt1; stmt2; ...; ex)`　的结果值类型是　`ex` 的类型，其他的语句项必须是　`void` 类型（可以调用 `discard` 产生 `void` 类型）。`(;)` 不会引入新的作用域。

例子：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
const x = (var y = 1; for i in 1..6: y *= i; y)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## discard 语句

例子：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc p(x, y: int): int =
    result = x + y
discard p(3, 4) # discard the return value of `p`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

`discard` 语句会评估它的表达式的副作用并且可以引发异常。

不使用 `discard`，并忽略一个函数的返回值，会导致静态错误。

如果被调用的函数、迭代器有语法标记 `{.discardable.}`，那么也可以忽略返回值。

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc p(x, y: int): int {.discardable.} =
    result = x + y
p(3, 4)  # now valid
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

一个空的 `discard` 语句通常用于表示空语句：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc classify(s: string) =
    case s[0]
    of SymChars, '_' : echo "an identifier"
    of '0'..'9'      : echo "a number"
    else             : discard
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## void 语境

在一个语句列表中，除了最后一个表达式，其他都必须是 `void` 类型。除此规则外，赋值给内置的 `result`　符号也会触发 `void` 语境：    

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc invalid*(): string =
    result = "foo"
    "invalid"  # Error: value of type 'string' has to be discarded

proc valid*(): string =
    let x = 317
    "valid"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## var 语句

var 语句声明一个新的局部变量、全局变量，并初始化他们。逗号 `,` 可以分隔相同类型：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
var
    a: int = 0
    x, y, z: int
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

如果采用初始化，那么可以省略类型: 之后变量会使用和初始化表达式相同的类型。如果没有初始化表达式，那么变量总会被初始化为一个默认值。这个默认值对不同的类型是不一样的，并且总是一个二进制 0：

类型|                            默认值
-|-
any integer type                |0
any float                       |0.0
char                            |'\0'
bool                            |false
ref or pointer                  |type nil
procedural                      |type nil
sequence                        |nil (not @[])
string                          |nil (not "")
tuple(元组)[x: A, y: B, ...]     |(default(A), default(B), ...) (analogous for objects)
array[0..., T]                  |[default(T), ...]
range[T]                        |default(T); this may be out of the valid range
T = enum                        |cast[T](0); this may be an invalid value

当考虑最大优化时，可以通过语法标记 `{.noInit.}` 取消隐式的初始化：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
var a {.noInit.}: array [0..100, char]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

如果一个函数标记 `{.noInit.}`，那么隐含的返回值变量 `result` 不会被初始化：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc p: int {.noInit.} = discard
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

也可以通过语法标记 `{.requiresInit.}` 阻止隐式地初始化。之后编译器会要求显式地初始化。然而，这样做可以控制何时对变量初始化，而不是依靠语法特性。

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
type
    MyObject = object {.requiresInit.}
proc p() =
    # 以下是有效的：
    var x: MyObject
    if someCondition():
        x = a()
    else:
        x = b()
    use x
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## let 语句

`let` 语句声明新的局部变量、全局变量，并为他们绑定一个值。语法和 `var` 语句是相同的。`let` 变量一定不是 l-value，并且不能作为实参传递给 `var` 形参。它们不能赋予新的值。

## 元组拆箱

在一个 `var` `let` 语句中可以执行元组拆箱。特殊标识符 `_` 用于忽略元组的成员：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc returnsTuple(): (int, int, int) = (4, 2, 3)
let (x, _, z) = returnsTuple()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## 关于常量

常量是绑定了值的符号。常量的值不能改变。编译器一定可以在编译期求得常量的值。

Nim 语言包含了一个复杂的编译期求值器，没有副作用的函数也可以用于常量表达式：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
import strutils
const
    constEval = contains("abc", 'b') 　# 在编译器计算！
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

编译期的可以计算的规则是：

1. 字面值是编译期可以计算的
2. 类型转换是编译期可以计算的
3. 对于函数调用 `p(X)`，如果 `p` 是一个没有副作用的函数，并且 `X` 是一个（可能是空的）编译期可以计算的参数列表，那么此调用是编译期可以计算的

常量不能是 `ptr` `ref` `var` `object` 类型，也不能包含这些类型。

## static 语句、表达式

static 语句、表达式可以用来强制在编译期执行显式求值。强制编译期求值，甚至可以作用于有副作用的代码:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
static:
    echo "echo at compile time"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    

如果编译器不能执行编译期求值，会引发一个静态错误。

当前版本对编译期求值有一些限制: 含有 `cast` 或者使用了外部函数接口（FFI）的代码，不能在编译期求值。后续版本会支持 FFI 在编译期求值。

## if 语句

例子：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
var name = readLine(stdin)
if name == "Andreas":
    echo("What a nice name!")
elif name == "":
    echo("Don't you have a name?")
else:
    echo("Boring name...")
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

`if` 语句是创建分支控制流的简单方式。`if` 关键字后面的表达式会被求值，如果是 `true` 则 `:` 后面对应的语句就会执行。否则，下面的 elif 表达式会被求值，... 直到 else 。

基于可读的目的，`if` 语句的作用域可以使用 ` {| |}` 包裹：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
if {| (let m = input =~ re"(\w+)=\w+"; m.isMatch):
    echo "key ", m[0], " value ", m[1]  |}
elif {| (let m = input =~ re""; m.isMatch):
    echo "new m in this scope"  |}
else: {|
    echo "m not declared here"  |}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## case 语句

例子：

```nim
case readline(stdin)
of "delete-everything", "restart-computer":
    echo("permission denied")
of "go-for-a-walk":     
    echo("please yourself")
else:                   
    echo("unknown command")

# indentation of the branches is also allowed; and so is an optional colon
# after the selecting expression:
case readline(stdin):
    of "delete-everything", "restart-computer":
        echo("permission denied")
    of "go-for-a-walk":     
        echo("please yourself")
    else:                   
        echo("unknown command")
```

`case` 语句和 `if` 语句很相似，但是它描述了一个多分支选择项。`case` 关键字后面的表达式会被评估，当其结果值符合 `of` 关键字后面的值时执行对应的语句。如果没有匹配任何给出的 `of` 参考值，则会运行 `else` 对应的语句。应该总是为 `case` 语句提供所有可能的参考值，或者使用 `else` 来表示其他任何可能的情况。如果有潜在的参考值被遗漏，将会引发静态错误。

对于非有序的类型来讲，列举出每一个可能的参考值是不可能的，因此它们总是需要配有 `else`。

作为一个特殊的语法扩展，`case` 语句的 `of` 分支可以对一个集合或者数组的构造器求值：

```nim
const
    SymChars: set[char] = {'a'..'z', 'A'..'Z', '\x80'..'\xFF'}

proc classify(s: string) =
    case s[0]
    of SymChars, '_' : echo "an identifier"
    of '0'..'9'      : echo "a number"
    else             : echo "other"

# 上面的代码等价于
proc classify(s: string) =
    case s[0]
    of 'a'..'z', 'A'..'Z', '\x80'..'\xFF', '_' : echo "an identifier"
    of '0'..'9'                                : echo "a number"
    else                                       : echo "other" 
```

## when 语句

例子：

```nim
when sizeof(int) == 2:
    echo("running on a 16 bit system!")
elif sizeof(int) == 4:
    echo("running on a 32 bit system!")
elif sizeof(int) == 8:
    echo("running on a 64 bit system!")
else:
    echo("cannot happen!")
```
        
`when` 语句和 `if` 语句几乎是一模一样的，但是有其独有的特征：

* 每一个条件必须是一个常量表达式(结果值是布尔类型)
* 语句不会制造新的作用域
* The statements that belong to the expression that evaluated to true are translated by the compiler, the other statements are not checked for semantics!然而，每个条件都会执行语法检查

`when` 语句采用条件编译技术（同 C 语言的 #if #ifdef）。作为一个特殊的语法扩展，`when` 结构也能用在 `object` 定义时进行一些条件筛选。

译注： when 语句是编译期的条件语法，if 语句是运行期的条件语法，这是他们最大的不同。因此，从某些层面来说，当条件可以在编译期确定的时候，when 语句可以带来更优的性能。

## when nimvm 语句

`nimvm` 是一个特殊的符号，用来在 `when nimvm` 语句中区分运行期和编译期的执行路径。

例子：

```nim
proc someProcThatMayRunInCompileTime(): bool =
    when nimvm:
        # 这段代码在编译期运行
        result = true
    else:
        # 这段代码在运行期运行
        result = false
const ctValue = someProcThatMayRunInCompileTime()
let rtValue = someProcThatMayRunInCompileTime()
assert(ctValue == true)
assert(rtValue == false)
```

`when nimvm` 语句必须满足下列要求：

* 条件表达式应该总是 `when nimvm`，任何复合的表达式都是不允许的
* 一定不能包含 `elif` 分支
* 一定包含 `else` 分支
* `when nimvm` 分支内的代码一定不能影响代码语义。比如不能定义用于后续代码使用的符号。

## return 语句

例子：

```nim
return 40 + 2
```

`return` 语句结束当前函数的执行并返回值。它只允许出现在函数中。如果返回值是一个 `expr`，这是一种语法糖：

```nim
result = expr
return result
```
没有表达式的 `return` 语句是 `return result` 的简写（函数有返回值类型）。`result` 变量总是作为函数的返回值。它是由编译器自动声明的。像所有的变量一样，`result` 被初始化为 (二进制的)0：

```nim
    proc f(): int =
        # 隐式返回 0
```

## yield 语句

例子：

```nim
yield (1, 2, 3)
```

`yield` 语句只能用于迭代器中，以取代 `return` 语句。它只在迭代器中有效。在 `for` 循环中调用迭代器时返回其执行的结果。`yield` 不会结束迭代过程，如果下一个迭代项开始就把执行结果传递给迭代器。

## block 语句

例子：

```nim
var found = false
block myblock:
    for i in 0..3:
        for j in 0..3:
            if a[j][i] == 7:
                found = true
                break myblock  # 跳出块语句，哪怕是在两层循环里边
echo(found)
```

`block` 语句表示组合多个语句变成一个（可命名的）块语句。在块语句中，允许使用 `break` 语句立刻跳出块语句。`break` 语句后面可以跟随要跳出的指定块的名字。

## break 语句

例子：

```nim
break
```

`break` 语句用来立刻离开一个块语句，后面可以跟随要跳出的指定块的名字。

## while 语句

例子：

```nim
echo("Please tell me your password: \n")
var pw = readLine(stdin)
while pw != "12345":
    echo("Wrong password! Next try: \n")
    pw = readLine(stdin)
```

`while` 语句一直执行直到跟随的条件表达式的结果值是 `false`。无限循环并不是个错误。`while` 语句开启一个隐式的块语句，所以也可以使用 `break` 语句离开。

## continue 语句

`continue` 语句使循环结构立刻进入下一次迭代。它只允许在循环中使用。`continue` 语句是一个嵌套的块语句语法糖：

```nim
while expr1:
    stmt1
    continue
    stmt2
```
等价于：

```nim
while expr1:
    block myBlockName:
        stmt1
        break myBlockName
        stmt2　
```

## asm 语句

Nim 语言支持在代码中通过“不安全的” `asm` 语句直接嵌入汇编代码。汇编代码中的标志符和 Nim 语言的标识符发生冲突时，应当使用一个特殊的字符包裹：

```nim
{.push stackTrace:off.}
proc addInt(a, b: int): int =
    # a in eax, and b in edx
    asm """
            mov eax, `a`
            add eax, `b`
            jno theEnd
            call `raiseOverflow`
        theEnd:
    """
{.pop.}
```

如果使用 GNU 汇编，包裹符和新行符会自动插入：

```nim
proc addInt(a, b: int): int =
    asm """
        addl %%ecx, %%eax
        jno 1
        call `raiseOverflow`
        1:
        :"=a"(`result`)
        :"a"(`a`), "c"(`b`)
    """
```

会被替换为：

```nim
proc addInt(a, b: int): int =
    asm """
        "addl %%ecx, %%eax\n"
        "jno 1\n"
        "call `raiseOverflow`\n"
        "1: \n"
        :"=a"(`result`)
        :"a"(`a`), "c"(`b`)
    """
```

## using 语句

警告：using 语句是实验性质的，并且需要显式启用其语法标记或者指定命令行选项。

......

## if 表达式 

`if` 表达式很像 `if` 语句，但是它是一个表达式。例子：

```nim
    var y = if x 8 : 9 else : 10   
```

`if` 表达式总是返回值，因此 `else` 是必需的。也允许使用 `elif` 。

## when 表达式

和 `if` 表达式类似，但是在编译期求值。

## case 表达式

`case` 表达式也跟 `case` 语句非常相似：

```nim
var favoriteFood = case animal
    of "dog": "bones"
    of "cat": "mice"
    elif animal.endsWith"whale": "plankton"
    else:
    echo "I'm not sure what to serve, but everybody loves ice cream"
    "ice cream"
```

如同例子所示，`case` 表达式也会带来副作用。当一个分支存在多个语句时，使用最后一个表达式作为返回值。

## 表构造器

表构造器是数组构造器的语法糖：

```nim
    {"key1": "value1", "key2": "value2", "key3": "value3"}

    # 等同于：
    [("key1", "value1"), ("key2", "value2"), ("key3", "value3")]  　
```

空表可以写作 `{:}`，还有另外一种方式是写作空的数组构造器 `[]`。使用表构造器有许多优势:

* 键值对序会被保留，因此容易支持有序的词典，比如 `{key : val}.newOrderedTable`。
* 表的字面值可以放到一个常量段，而且编译器可以像对待数组一样轻易的将其放入可执行数据段，所生成的数据段只需要很小的内存。
* 每一个表实现都在语义上相同。
* 表作为语言核心的语法糖，我们不需要了解更多的细节。

## 类型转换

从语法上一个类型转换很像函数调用，只是用类型名替换函数名而已。类型替换总是安全的，因为从一个类型转换到另一个类型失败时总会引发一个异常（如果在编译期不能确定的话）。

在 Nim 语言中，比起使用类型转换，普通函数通常更优先考虑：比如，`$` 是 `toString()` 类型转换的操作符，`toFloat()` `toInt()` 能够用来在浮点数和整数之间转换。 
 
## 类型映射

例子：

```nim
    cast[int](x)
```

类型映射是一种原生机制，它把一个表达式的结果值翻译成另一个类型的位形态。类型映射只需要在底层编程使用，因为它虽然很高效，但是同时是“不安全的”。 

```nim
var a = ['a', 'b', 'c']

echo repr a                                         ## ['a', 'b', 'c']
echo repr a.addr()                                  ## ref 0x623f24 --['a', 'b', 'c']
echo repr a[0].addr()                               ## ref 0x623f24 --'a'
echo repr cast[ptr int8](a[0].addr())               ## ref 0x623f24 --97
echo repr cast[ptr char](a[0].addr())               // ref 0x623f24 --'a'
echo repr cast[int](a[0].addr())                    ## 6438692
echo repr sizeof(a.addr()[])                        ## 3
echo repr sizeof(a[0].addr())                       ## 8
echo repr sizeof(a[0].addr()[])                     ## 1          
echo repr cast[int](a[0].addr()) + 
          1 * sizeof(a[0].addr()[])                 ## 6438693
echo repr cast[ptr char](cast[int](a[0].addr()) + 
            1 * sizeof(a[0].addr()[]))[]            ## 'b'

template `+`*[T](p: ptr T, offset: int): ptr T =
    cast[ptr type(p[])](cast[ByteAddress](p) +% 
                        offset * sizeof(p[]))

echo repr a[0].addr() + 1                           ## ref 0x623f25 --'b'
echo repr a[0].addr() + 2                           ## ref 0x623f26 --'c'          
```

## 内存地址操作符

`addr()` 操作符返回一个 l-value 的内存地址。如果该地址的类型是 `T`，`addr()` 操作符的结果值就是 `ptr T` 类型。一个地址总是一个非追踪引用。提取驻留在栈上的内存地址是“不安全的”，因为这种指针在退出当前栈时就被销毁了，当需要比在栈上存留更长久的指针引用时，会导致引用错误的地址。比如 C 语言：

```c
void f(struct person *y) {
    int x = 1;
    y-p = &x;
    // 退出栈，x销毁
    // y 上的 p 就会成为一个悬垂指针，引用了一个不存在的对象
}

void f(struct person *y) {
    int *x = malloc(sizeof(int));
    y-p = x;
    // 退出栈，x不会销毁，因为是在堆上分配的内存
    // 但同时要保持堆上内存回收
}
```

用户可以获取变量的地址，但是不能用于 `let` 语句声明的变量：

```nim
let t1 = "Hello"
var
    t2 = t1
    t3 : pointer = addr(t2)
echo repr(addr(t2))
# --ref 0x7fff6b71b670 --0x10bb81050"Hello"
echo cast[ptr string](t3)[]
# --Hello
# The following line doesn't compile:
echo repr(addr(t1))
# Error: expression has no address
```

