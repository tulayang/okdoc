# [泛型](http://nim-lang.org/docs/manual.html#generics)

泛型，在 Nim 语言中，是用类型参数参数化函数、迭代器或类型。根据上下文环境，使用 `[ ]` 引入类型参数或者实例化一个泛型的函数、迭代器或者类型。 

下面的例子，演示了如何建模一个泛型的二进制树:

```nim
type
    BinaryTreeObj[T] = object    # 一个使用泛型参数 ``T`` 的泛型类型
        le, ri: BinaryTree[T]      # 左子树和右子树; 可能是 nil
        data: T                    # 用于存储数据
    BinaryTree[T] = ref BinaryTreeObj[T]     # 短写形式更方便呀

proc newNode[T](data: T): BinaryTree[T] =  # 树节点构造器
    new(result)
    result.data = data

proc add[T](root: var BinaryTree[T], n: BinaryTree[T]) =
    if root == nil:
        root = n
    else:
        var it = root
        while it != nil:
            var c = cmp(it.data, n.data) # 比较 data 项; uses
                                         # the generic ``cmp`` proc that works for
                                         # any type that has a ``==`` and ``<``
                                         # operator
        if c < 0:
            if it.le == nil:
                it.le = n
                return
            it = it.le
        else:
            if it.ri == nil:
                it.ri = n
                return
            it = it.ri

iterator inorder[T](root: BinaryTree[T]): T =
    # 递归遍历一个二进制树
    # 注意：递归迭代器现在没有实现，在编译器里实际上不能工作！
    if root.le != nil: yield inorder(root.le)
    yield root.data
    if root.ri != nil: yield inorder(root.ri)

var
    root: BinaryTree[string]  # 使用字符串类型实例化一个 BinaryTree
add(root, newNode("hallo")) # 调用泛型函数 ``newNode()`` 和
add(root, newNode("world")) # ``add()``
for str in inorder(root):
  writeLine(stdout, str)
```

## is 操作符

`is` 操作符在编译期检查类型是否等价。这在泛型编码中非常有用。

```nim
type
    Table[Key, Value] = object
        keys: seq[Key]
        values: seq[Value]
        when not (Key is string):  # 为了优化，字符串值设定为 nil
            deletedKeys: seq[bool]
```

## type 操作符

`type` 操作符（在许多其他语言称为 `typeof`）获取一个表达式的（结果值）类型：

```nim
var x = 0
var y: type(x)  # y 是 int 类型
```

如果 `type` 被用来确定一个函数、迭代器、类型转换器的类型（比如 `c(X)`，`X` 表示参数列表），如果 `c` 是一个迭代器，会被优先解释：

```nim
import strutils

# strutils 模块同时包含 ``split`` 函数和迭代器 ，因为迭代器有更高的优先级，
# 所以 `y` 的类型是 ``string``：
var y: type("a b c".split)
```

## 类类型

一个类类型,是一个特殊的伪类型，可以在重载或者 `is` 操作符中匹配类型。Nim 语言支持下面的内置类类型：

类类型     | 匹配
-|-
`object`       |   any object type
`tuple`        |   any tuple type
`enum`         |   any enumeration
`proc`         |   any proc type
`ref`          |   any ref type
`ptr`          |   any ptr type
`var`          |   any var type
`distinct`     |   any distinct type
`array`        |   any array type
`set`          |   any set type
`seq`          |   any seq type
`auto`         |   any type

此外，每个泛型类型会自动创建一个同名的类类型，该类类型会匹配这个泛型类型的任何实例。

可以使用标准的布尔操作符组合类类型，用来生成复合的类类型：

```nim
# 创建一个类类型，它可以匹配元组和对象类型
type RecordType = tuple or object

proc printFields(rec: RecordType) =
    for key, value in fieldPairs(rec):
        echo key, " = ", value
```

利用这种机制的函数，可以认为是隐式泛型。They will be instantiated once for each unique combination of param types used within the program.

对于泛型的类型参数，Nim 语言也允许把类类型和常规类型指定为类型约束：

```nim
proc onlyIntOrString[T: int|string](x, y: T) = discard

onlyIntOrString(450, 616)  # 有效
onlyIntOrString(5.0, 0.0)  # 类型匹配
onlyIntOrString("xy", 50)  # 无效，'T' 同一时间匹配到 string 和 int
```

默认情况下，对每一个命名的类类型的重载解析，会绑定到一个适合的类型。例子:

```nim
proc `==`*(x, y: tuple): bool =
    ## 要求 `x` and `y` 同时是元组类型
    result = true
    for a, b in fields(x, y):
        if a != b: result = false
```

此外, the `distinct` type modifier can be applied to the type class to allow each param matching the type class to bind to a different type.

Procs written with the 隐式 generic style will often need to 涉及 to the type parameters of the matched generic type. They can be easily 访问 using the dot syntax:

```nim
type Matrix[T, Rows, Columns] = object
  ...

proc `[]`(m: Matrix, row, col: int): Matrix.T =
    m.data[col * high(Matrix.Columns) + row]
```

此外, the type operator can be used over the proc params for similar effect when anonymous or distinct type classes are used.

实例化一个泛型类型时，如果使用类类型替代一个具体类型，那么结果是产生另一个类类型：

```nim
seq[ref object]   # 可存储任意对象引用的序列

type T1 = auto
proc foo(s: seq[T1], e: T1)
    # seq[T1] is the same as just `seq`, but T1 will be allowed to bind
    # to a single type, while the signature is being matched

Matrix[Ordinal] # Any Matrix instantiation using integer values
```

如同上例所示, in such instantiations, it's not 必需的 to supply all type parameters of the generic type, because any missing ones will be 推导 to have the equivalent of the any type class and 因此 they will match anything without discrimination.

## concepts

注意: concepts 仍在开发中。

## 泛型符号的查找

泛型符号的绑定规则稍微有些微妙：存在 "open" 和 "closed" 两种符号。一个 "closed" 符号不能在实例化语境中被重新绑定，一个 "open" 符号则可以。每一个默认的重载符号是 "open" ，而其他的符号则是 "closed"。

可以在两种不同的语境中查找 "open" 符号：定义时的语境和实例化时的语境：

```nim
type
    Index = distinct int

proc `==` (a, b: Index): bool {.borrow.}

var a = (0, 0.Index)
var b = (0, 0.Index)

echo a == b  # works!
```

在这个例子中，元组的泛型操作符 `==` 使用了元组成员的 `==` 操作符。然而，`Index` 类型的 `==` 操作符是在元组的 `==` 操作符之后定义的！这个例子却能通过编译，是因为实例化操作时也会把当前定义的符号加入符号表记录。

符号可以通过 `mixin` 声明强制成为 "open"：

```nim
proc create*[T](): ref T =
    # 这里没有重载 init，所以需要将其显式地设为 "open" 符号：
    mixin init
    new result
    init result  # 译注：如果在定义 create 时没有找到 init 符号，可以把查找推迟到
                 # 实例化时（再次查看当时的符号表记录）。
                 # 只有 "open" 符号享有这个“特权”！
```

## bind 语句

`bind` 语句和 `mixin` 语句是对应的。它可以被用来显式地声明标识符应该在早期绑定。下面这个例子演示了使标识符在模板的作用域内进行符号查找：

```nim
# Module A
var
  lastId = 0

template genId*: expr =
    bind lastId
    inc(lastId)
    lastId
```

<span>

```nim
# Module B
import A

echo genId()
```

但是 `bind` 很少用，因为符号绑定到定义时的作用域是默认的。

