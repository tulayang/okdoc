# [模板](http://nim-lang.org/docs/manual.html#templates)

模板是宏的简单形式：它是操作 Nim 语言抽象语法树的一个简单的替代机制。由编译器完成语义分析。

调用模板和调用函数一样简单：

```nim
template `!=` (a, b: expr): expr = 
    # system 模块实现了这个这个定义
    not (a == b)

assert(5 != 6)  # 编译器将其重写为：assert(not (5 == 6))
```

事实上 `!=` `>` `>=` `in` `notin` `isnot` 这些操作符都是由模板实现的：

* `a b` 会被重写为 `b < a`
* `a in b` 会被重写为 `contains(b, a)`
* `notin` 和 `isnot` 的名字就说明了一切

模板中的类型参数，可以是符号 `expr` （表示表达式），`stmt` （表示语句），`typedesc` （表示类型描述）。这些都是元类型。它们只能用在特定的场景中。当然，也可以使用实际类型，这暗示表达式是可预期的。

## 普通模板 vs 直接模板

有两种不同的模板：“普通的”和“直接的”。普通模板参与重载解析。在模板执行前，需要对它们的实参执行类型检查。因此，普通模板不能接受未声明的标识符：

```nim
template declareInt(x: expr) =
    var x: int

declareInt(x)  # Error: unknown identifier: 'x'
```

直接模板不参与重载解析。在模板执行前，不需要对它们的实参执行语义上的检查。因此，直接模板可以接受未声明的标识符：

```nim
template declareInt(x: expr) {.immediate.} =
    var x: int

declareInt(x) # 有效
```

**`更新：---------`**

在 0.13 后，`{.immediate.}` 被弃用，使用新的语法来区分上面的模板：`typed` 和 `untyped`。上面的两个例子，用新的语法，写作：

```nim
template declareInt(x: typed) =
    var x: int # 无效，x 没有声明，也没有类型

declareInt(x)
```

<span>


```nim
template declareInt(x: untyped) =
    var x: int

declareInt(x) # 有效
x = 3
```

所有参数都是 `untyped` 的模板，是直接模板；否则，是普通模板。在过去，我们使用 `expr`、`stmt` 来表示模板的表达式参数、语句参数，从新版本开始，请使用 `typed` （`expr`）、`untyped` （`stmt`）。

> 译注：本章后面的例子，`expr` 都应该用 `typed` 替换，`stmt` 用 `untyped` 替换； 标记为 `{.immediate.}` 的直接模板，不管其过去参数是 `expr` 还是 `stmt`，一律替换为 `untyped`。

**`--------------`**

## 给模板传递代码块

如果有一个 `stmt` 参数，那么它应该是模板声明的最后一个参数。因为语句被传递给模板时是通过特殊的冒号语法：

```nim
# 过去版本是这样定义的：
# template withFile(f, fn, mode: expr, actions: stmt): stmt {.immediate.} =
#
# 新版本请这样定义：
template withFile(f, fn, mode: untyped, actions: untyped): untyped =
    var f: File
    if open(f, fn, mode):
        try:
            actions
        finally:
            close(f)
    else:
        quit("cannot open: " & fn)

withFile(txt, "ttempl3.txt", fmWrite):
    txt.writeLine("line 1")
    txt.writeLine("line 2")
```

在这个例子中，两个 `writeLine()` 被绑定到 `actions` 参数。

## varargs 和 untyped

`untyped` 元类型，可以阻止类型检查---我们上面已经说过了；`varargs[untyped]` 则能让你有可变的参数列表。例子：

```nim
template hideIdentifiers(x: varargs[untyped]) = discard

hideIdentifiers(undeclared1, undeclared2)
```

然而，模板不能迭代其 `varargs` 参数列表，用宏来完成这个功能更好用些。注意：过去版本的 `varagrs[expr]` 和现在的 `varargs[typed]` 是不同的。

## 模板的符号绑定

模板是一个卫生宏，因此，可以开启一个新的作用域。大多数符号会被绑定到模板定义的作用域：

```nim
# Module A
var
    lastId = 0

template genId*: expr =
    inc(lastId)
    lastId


```nim
# Module B
import A
echo genId()  # Works as 'lastId' has been bound in 'genId's defining scope
```

这跟泛型符号绑定会被 `mixin` 和 `bind` 语句影响是一个道理。

## 构建标识符

在模板中，标识符可以像下面这样构建：

```nim
template typedef(name: expr, typ: typedesc) {.immediate.} =
    type
        `T name`* {.inject.} = typ
        `P name`* {.inject.} = ref `T name`

typedef(myint, int)
var x: PmyInt
```

在这个例子中，`name` 被实例化为 `myint`，所以 `T name` 变成了 `Tmyint`。

## 模板参数的符号查找规则

模板的参数可以被用作字段名字和全局符号（可被同样实参名映射）：

A parameter p in a template is even substituted in the expression x.p. Thus template arguments can be used as field names and a global symbol can be shadowed by the same argument name even when fully qualified:

```nim
# module 'm'

type
    Lev = enum
        levA, levB

var abclev = levB

template tstLev(abclev: Lev) =
    echo abclev, " ", m.abclev

tstLev(levA)
# produces: 'levA levA'
```

不过，可以通过 `bind` 语句正确地捕获全局符号：

```nim
# module 'm'

type
    Lev = enum
        levA, levB

var abclev = levB

template tstLev(abclev: Lev) =
    bind m.abclev
    echo abclev, " ", m.abclev

tstLev(levA)
# produces: 'levA levB'
```

## 模板的卫生

每一个模板默认都是卫生宏：模板声明的局部标识符，不能被实例化环境访问:

```nim
template newException*(exceptn: typedesc, message: string): expr =
    var
        e: ref exceptn  # e is implicitly gensym'ed here
    new(e)
    e.msg = message
    e

# so this works:
let e = "message"
raise newException(EIO, e)   
```

在一个模板内声明的符号是否暴露给实例化作用域，是由语法标记 `{.inject.}` 和 `{.gensym.}` 控制的：gensym'ed 符号不暴露，而 inject'ed 暴露.

默认情况下，`type` `var` `let` `const` 得到的符号实体是 gensym'ed，`proc` `iterator` `converter` `template` `macro` 得到的符号实体是 inject'ed 。然而，如果符号实体的名字是用作模板的参数传递，那么它是一个 inject'ed 符号:  

```nim
template withFile(f, fn, mode: expr, actions: stmt) : stmt {.immediate.} =
    block:
        var f: File  # 因为 'f' 是模板参数，所以它是 injected （隐式地）！  
        ...

withFile(txt, "ttempl3.txt", fmWrite):
    txt.writeln("line 1")
    txt.writeln("line 2")
```

语法标记 `{.inject.}` 和 `{.gensym.}` 是二等编译指示，它们在模板定义外没有意义，并且不能被提取出来:

```nim
{.pragma myInject: inject.}

template t() =
    var x {.myInject.}: int  # does NOT work
```

要去掉模板的卫生功能，可以使用语法标记 `{.dirty.}`。`{.inject.}` 和 `{.gensym.}` 在 `{.dirty.}` 标记的模板中不起作用。

## 方法调用语法的限制

表达式 `x.f` 中的 `x` 需要语义检查（意味着符号查找和类型检查），才能确定是否可以改写为 `f(x)`。因此在模板和宏中 `.` 操作符的使用有一些限制： 

```nim
template declareVar(name: expr): stmt =
    const name {.inject.} = 45

# 不能编译：
unknownIdentifier.declareVar
```
另一个通用的例子如下：

```nim
from sequtils import toSeq

iterator something: string =
    yield "Hello"
    yield "World"

var info = toSeq(something())
```

The problem here is that the compiler already decided that `something()` as an iterator is not callable in this context before toSeq gets its chance to convert it into a sequence.