# [函数](http://nim-lang.org/docs/manual.html#procedures)

在大多数编程语言中，称为方法或者函数，在 Nim 语言中，叫做过程。函数声明由一个标识符、0 或多个参数、一个返回值类型和一个块代码组成。声明的参数列表使用逗号（`,`）或者分号（`;`）间隔：

```nim
# 只使用逗号
proc foo(a, b: int, c, d: bool): int

# 使用分号
proc foo(a, b: int; c, d: bool): int

# 失败：a 没有定义类型
proc foo(a; b: int; c, d: bool): int
```



声明函数时，可以使用默认值，当调用者没有提供实参时，使用该默认值：

```nim
proc foo(a: int, b: int = 47): int
```



通过类型修饰符 `var`，参数可以是可变的、并且函数可以修改该参数值：

```nim
proc foo(inp: int, outp: var int) =
    outp = inp + 47
```



如果函数没有主体，它就是个前置声明。如果函数返回值，函数主体会隐式地声明一个名为 `result` 的变量，用于表示返回值。函数可以被重载。重载解析算法决定了如何挑选最匹配的函数。例子：

```nim
proc toLower(c : char) : char =      # toLower for characters
    if c in {'A'..'Z'}:
        result = chr(ord(c) + (ord('a') - ord('A')))
    else:
        result = c

proc toLower(s : string) : string =  # toLower for strings
    result = newString(len(s))
    for i in 0..len(s) - 1:
        result[i] = toLower(s[i])    # calls toLower for characters; 不会递归！ 
```



调用函数有很多方式:

```nim
proc callme(x, y : int, s : string = "", c : char, b : bool = false) = ...

# call with positional arguments # parameter bindings:
callme(0, 1, "abc", '\t', true)  # (x=0, y=1, s="abc", c='\t', b=true)

# call with named and positional arguments:
callme(y=1, x=0, "abd", '\t')    # (x=0, y=1, s="abd", c='\t', b=false)

# call with named arguments (order is not relevant):
callme(c='\t', y=1, x=0)         # (x=0, y=1, s="", c='\t', b=false)

# call as a command statement: no () needed:
callme 0, 1, "abc", '\t'
```

递归调用函数是允许的。



作为标识符的特殊操作符是一个函数：

```nim
proc `$` (x : int): string =
    # 把整数转换为字符串，这是一个前缀操作符
    result = intToStr(x)
```

有一个参数的操作符是前缀操作符，有两个参数的操作符是中缀操作符（不管怎么样，解析器其实是通过表达式中操作符的位置来区分的）。不能声明后缀操作符：所有的后缀操作符都是内置的并且用来作为语法标记。

任何操作符都可以像普通函数一样被调用(因此，操作符可以有多个参数)：

```nim
proc `*+` (a, b, c : int): int =
    result = a * b + c

assert `*+`(3, 4, 6) == `*`(a, `+`(b, c))
```

## 导出标记

如果声明符号时用 `*` 标记，那么该符号从当前模块导出---其他模块可以调用：

```nim
proc exportedEcho*(s: string) = echo s
proc `*`*(a: string; b: int): string =
    result = newStringOfCap(a.len * b)
    for i in 1..b: result.add a

var exportedVar*: int
const exportedConst* = 78
type
    ExportedType* = object
        exportedField*: int
```

## 方法调用语法

当使用面向对象编程风格时，可以用语法 `obj.method(args)` 替代 `method(obj, args)`。如果没有额外的参数，可以省略括号： `obj.len` 等价于 `len(obj)`。

这种方法调用语法并不局限于对象，可以用于任意函数的第一个参数：

```nim
echo("abc".len)
echo("abc".toUpper())
echo({'a', 'b', 'c'}.card)
stdout.writeln("Hallo")
```

这种方法调用语法在显式地泛型实例化时会发生冲突：`p[T](x)` 不能写作 `x.p[T]`，因为 `x.p[T]` 总是被解析为 `(x.p)[T]`。

未来方向：`p[.T.]` 可能会被引入，作为另一种语法以使得 `x.p[.T.]` 可以被解析为 `x.(p[.T.])`。

## 属性器

Nim 语言不需要 getter：普通的 getter 属性器。不过设置值是不同的，一个特殊的 setter 是必要的：

```nim
type
    Socket* = ref object of RootObj
    FHost : int      # 不能通过外部模块访问

proc `host=`*(s : var Socket, value : int) {.inline.} =
    s.FHost = value  # setter

proc host*(s : Socket): int {.inline.} =
  s.FHost            # getter

var s: Socket
new s
s.host = 34          # same as `host=`(s, 34)
```

## 命令调用语法

调用例程时可以没有括号，看起来像语句一样。命令调用语法也适用表达式，但是表达式只能跟随一个参数。这个限制意味着 `echo f 1, f 2` 会被解析为 `echo(f(1), f(2))` 而不是 echo(f(1, f(2)))。方法调用语法，可以用来在此场景提供一个或者多个参数:

```nim
proc optarg(x : int, y : int = 0): int = x + y
proc singlearg(x : int) : int = 20*x

echo optarg 1, " ", singlearg 2 # 打印 "1 40"

let fail = optarg 1, optarg 8   # 错误，命令调用过多参数
let x = optarg(1, optarg 8)     # 
let y = 1.optarg optarg 8       #
assert x == y
```

## 闭包

函数可以出现在模块顶层，也能出现在其他作用域内（这被称为嵌套函数）。嵌套函数可以在其所处的作用域中访问局部变量，当它这么做时它会成为一个闭包。任何捕获的变量，被存储在这个闭包的一个隐含的附加参数中（环境变量），该闭包和它所处的作用域，通过引用来进行访问该环境变量（任何的修改都是双方可见的）。闭包的环境变量，可以在堆上分配内存，也可以在栈上（编译器根据当时的安全考虑来选择）。

## 匿名函数

函数也能用作表达式，这时候可以省略函数名字：

```nim
    var cities = @["Frankfurt", "Tokyo", "New York"]

    cities.sort(proc (x : string, y : string) : int = cmp(x.len, y.len))
```

函数作为表达式时，可以出现在嵌套函数中，并且也能出现在顶层执行代码内。

## do 

注意: do notation 是不稳定的。

......

## 内置中那些禁止重载的

因为一些实现的内部原因，下面的内置函数不能被重载（它们要求专项的语法检查）：

```?
declared, defined, definedInScope, compiles, low, high, sizeOf,
is, of, shallowCopy, getAst, astToStr, spawn, procCall 
```

下面列举的不能写作语法 `x.f`，因为 `x` 在传递给 `f` 前，不能通过类型检查：

```nim
declared, defined, definedInScope, compiles, getAst, astToStr
```

## var 参数

参数的类型可以使用 `var` 关键字作为前缀:

```nim
proc divmod(a, b: int; res, remainder: var int) =
    res = a div b
    remainder = a mod b

var
    x, y: int

divmod(8, 5, x, y)  # 修改 x 和 y
assert x == 1
assert y == 3
```

在这个例子中，`res` 和 `remainder` 是 `var` 参数。`var` 参数可以被函数修改，并且该修改对调用者是可见的。传递给 `var` 参数的实参必须是一个 l-value。`var` 参数被实现为隐含的指针。上面的例子等价于:

```nim
proc divmod(a, b: int; res, remainder: ptr int) =
    res[] = a div b
    remainder[] = a mod b

var
    x, y: int
divmod(8, 5, addr(x), addr(y))
assert x == 1
assert y == 3
```

在这两个例子中，`var` 参数或者指针用来提供两个返回值。可以通过返回一个元组使之更简洁：

```nim
proc divmod(a, b: int): tuple[res, remainder: int] =
  (a div b, a mod b)

var t = divmod(8, 5)

assert t.res == 1
assert t.remainder == 3
```

可以利用元组拆箱访问元组字段：

```nim
var (x, y) = divmod(8, 5)  # 元组拆箱
assert x == 1
assert y == 3
```

注意：永远不要把 `var` 参数作为高效传递参数的手段。因为，对于 `non-var` 参数、并且该参数不能被修改时，编译器总是为其考虑周到：当编译器认为传递实参的引用可以提高执行效率时，就会直接传递该实参的引用（而不是整个实参值）。

> 译注：Nim 语言的函数传递，不是简单的复制传递或引用传递，而是综合这两个：当复制参数更效率时，复制传递；当传递引用更高效时，传递实参的引用。因此，你不需要像 C 语言那样，为了效率，故意把参数做成 var 参数---编译器内部会自动识别哪个更效率。

## var 返回值

函数、类型转换器和迭代器都可以返回 `var` 类型，这样的返回值是一个 l-value，可以被调用者修改：

```nim
var g = 0

proc WriteAccessToG(): var int =
    result = g

WriteAccessToG() = 6
assert g == 6
```

下面这样访问该返回值的 location 会引发编译期错误：

```nim
proc WriteAccessToG(): var int =
    var g = 0
    result = g # Error!
```

迭代器也可以返回一个字段是 `var` 类型的元组：

```nim
iterator mpairs(a: var seq[string]): tuple[key: int, val: var string] =
    for i in 0..a.high:
        yield (i, a[i])
```

在标准库中，每个返回 `var` 类型的例程，（按照约定）其名字都使用 `m` 作为前缀。

## [ ] 操作符和重载

用于数组、open array、序列的 `[ ]` 操作符，可以被重载。
