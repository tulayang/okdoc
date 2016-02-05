
# [重载解析](http://nim-lang.org/docs/manual.html#overloading-resolution)

当调用 `p(args)` 时，编译器会选择最匹配 `p` 的例程。如果有多个例程同等地匹配，会在编译期报告：存在匹配歧义。

`args` 中的每一个参数都需要匹配。匹配参数的算法是多样的。假设 `f` 是定义的形参类型，`a` 是实际传递的实参类型：

1. 精确匹配 - `a` 和 `f` 是相同的类型。
2. 字面值匹配 - `a` 是一个整数字面值 `v` 的类型，`f` 是一个有符号或者无符号整数类型，并且 `v` 在 `f` 定义的范围内。或者，`a` 是一个浮点数字面值 `v` 的类型，`f` 是一个浮点数类型，并且 `v` 在 `f` 定义的范围内。
3. 泛型匹配 - `f` 是一个泛型类型并且和 `a` 匹配，比如 `a` 是 `int` 并且 `f` 是一个泛型参数类型（类似 [T] 或者 [T: int|char]）。
4. 子域或者子类匹配 - `a` 是一个  `range[T]` 并且 `T` 和 `f` 恰好匹配。或者，`a` 是 `f` 的子类。
5. 整体转换匹配 - `a` 可以转换为 `f` 并且 `f` 和 `a` 是整数或者浮点数类型。
6. 转换匹配 - `a`    可以转为 `f`，包括通过用户定义的转换器。

这些匹配规则有不同的优先级：精确匹配 字面值匹配 泛型匹配 子域或者子类匹配 整体转换匹配 转换匹配。在下面的例子中，`count(m, p)` 计算匹配到的例程 `p` 个数。

如果例程 `p` 比例程 `q` 更匹配返回 `true`：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~md
for each matching category m in ["exact match", "literal match",
                                "generic match", "subtype match",
                                "integral match", "conversion match"]:
    if count(p, m) count(q, m): return true
    elif count(p, m) == count(q, m):
        discard "continue with next category m"
    else:
        return false
return "ambiguous"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



一些例子：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc takesInt(x: int) = echo "int"
proc takesInt[T](x: T) = echo "T"
proc takesInt(x: int16) = echo "int16"
takesInt(4)  # "int"
var x: int32
takesInt(x)  # "T"
var y: int16
takesInt(y)  # "int16"
var z: range[0..4] = 0
takesInt(z)  # "T"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



如果算法返回“ambiguous”，表示需要进一步消除歧义：如果传递的实参 `a` 同时匹配 `p` 的形参类型和 `q` 的形参类型（存在子类关系），继承深度会被考虑：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
type
    A = object of RootObj
    B = object of A
    C = object of B
proc p(obj: A) =
    echo "A"
proc p(obj: B) =
    echo "B"
var c = C()
# 没有歧义,，calls 'B', not 'A' 因为 B 是 A 的子类型
# 但是反过来不行:
p(c)
proc pp(obj: A, obj2: B) = echo "A B"
proc pp(obj: B, obj2: A) = echo "B A"
# 这样是有歧义的：
pp(c, c)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 



同样地泛型匹配最精确的类型：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc gen[T](x: ref ref T) = echo "ref ref T"
proc gen[T](x: ref T) = echo "ref T"
proc gen[T](x: T) = echo "T"
var ri: ref int
gen(ri)  # "ref T"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### 基于 var T 的重载规则

如果定义的形参 `f` 是一个 `var T` 类型，除了普通检查外，还会检查传递的实参是否是一个 l-value。`var T` 要比单纯的 `T` 匹配更好。

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc sayHi(x: int): string =
    # 匹配一个 non-var int
    result = $x
proc sayHi(x: var int): string =
    # 匹配一个 var int
    result = $(x + 10)
proc sayHello(x: int) =
    var m = x      # 一个  x 的可变版本
    echo sayHi(x)  # 匹配 non-var 版本
    echo sayHi(m)  # 匹配 var   版本
sayHello(3)  # 3
             # 13
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

### 自动解引用

如果 `{.experimental.}` 激活并且没有匹配被找到，当第一个实参 `a` 是一个指针时会被自动解引用，并且重载解析会使用 `a[]` 代替来尝试匹配。

### expr 的惰性类型解析

注意：一个未确定的表达式，是指一个不执行符号查找、并且也不执行类型检查的表达式。

因为模板和宏声明时不能立刻参与重载解析，提供一种方式来传递未确定的表达式给模板或者宏，是非常必要的。这就是元类型 `expr` 完成的内容：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
template rem(x: expr) = discard
rem unresolvedExpression(undeclaredIdentifier)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

一个 `expr` 类型参数总是匹配任意参数（只要有任意参数传递给它）。

但是你必须小心，因为其他的重载可能会触发参数解析：  

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
template rem(x: expr) = discard
proc rem[T](x: T) = discard
# undeclared identifier: 'unresolvedExpression'
rem unresolvedExpression(undeclaredIdentifier)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

元类型中，`expr` 是唯一一个在这种场景中呈现惰性的，其他元类型 `stmt` `typedesc` 不是惰性的。

### varargs 匹配

参看 varargs

