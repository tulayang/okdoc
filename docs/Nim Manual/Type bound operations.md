# [类型绑定是如何操作的](http://nim-lang.org/docs/manual.html#type-bound-operations)

绑定类型，有三种方式:

1. 赋值
2. 析构
3. 线程通信的深拷贝

These operations can be overriden instead of overloaded.This means the implementation is automatically lifted to structured types. For instance if type T has an overriden assignment operator = this operator is also used for assignments of the type seq[T].Since these operations are bound to a type they have to be bound to a nominal type for reasons of simplicity of implementation:This means an overriden deepCopy for ref T is really bound to T and not to ref T.This also means that one cannot override deepCopy for both ptr T and ref T at the same time; instead a helper distinct or object type has to be used for one pointer type.

## = 操作符

`=` 是个赋值操作符。注意：`result = expr`，`parameter = defaultValue` 或者 `for` 的参数传递，不是赋值。`var v = T()` 会被重写为 `var v: T; v = T();` 。`var` 和 `let` 作为赋值语句。

The assignment operator needs to be attached to an object or distinct type `T`. Its signature has to be `(var T, T)`. Example: 

```nim
type
    Concrete = object
        a, b: string

proc `=`(d: var Concrete; src: Concrete) =
    shallowCopy(d.a, src.a)
    shallowCopy(d.b, src.b)
    echo "Concrete '=' called"

var x, y: array[0..2, Concrete]
var cA, cB: Concrete

var cATup, cBTup: tuple[x: int, ha: Concrete]

x = y
cA = cB
cATup = cBTup
```

## 析构

析构必须有一个单一参数，这个参数要有一个具体的类型（泛型类型也是允许的）。析构的名字必须是 `=destroy` 。

对于每一个局部栈变量 `v`，当离开其作用域范围时 `=destroy(v)` 就会被自动调用。

如果一个结构化类型有一个析构类型的字段，并且用户没有提供一个显式的实现，会自动生成一个该结构化类型的析构。调用任何类类型，用户定义的析构和生成的析构都会被插入。

一个附加到类型上的析构自动销毁。这种类型的表达式只能用在可析构的环境和作为参数：

```nim
type
    MyObj = object
        x, y : int
        p    : pointer

proc `=destroy`(o : var MyObj) =
    if o.p != nil : dealloc o.p

proc open: MyObj =
    result = MyObj(x : 1, y : 2, p : alloc(3))

proc work(o : MyObj) =
    echo o.x
    # No destructor invoked here for 'o' as 'o' is a parameter.

proc main() =
      # destructor automatically invoked at the end of the scope:
      var x = open()
      # valid: pass 'x' to some other proc:
      work(x)
     
      # Error: usage of a type with a destructor in a non destructible context
      echo open()
```

一个可析构的环境是以下:

1. `var x = expr` 中的 `expr`
2. `let x = expr` 中的 `expr`
3. `return expr` 中的 `expr`
4. `result = expr` 中的 `expr`

这些规则保证构造器绑定到一个变量，并且在退出其作用域时容易自动销毁。以后版本会改进析构的支持度。

要意识到对象使用 `new()` 分配内存时，并不会调用析构。这在未来版本可能会改变，但是现在 `new()` 必须使用 `finalizer` 参数。

注意: 析构仍然是实验性质的，并且规则也有可能会改变。

## deepCopy

`=deepCopy` 是内置的，每当数据传递给一个 spawn'ed 函数时（确保内存安全），都会调用它。程序员可以为一个特定的 `ref T`　或者 `ptr T` 重写这个行为。

```nim
 proc `=deepCopy`(x: T) : T
```

这个机制会被许多支持共享内存的数据结构使用，比如实现了线程安全能自动管理内存的 `channel`。

内置的 `=deepCopy` 甚至可以拷贝闭包和它们的环境变量。查看 `spawn` 的文档了解更多细节。