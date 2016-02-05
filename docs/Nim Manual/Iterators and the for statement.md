# [迭代器和 for 语句](http://nim-lang.org/docs/manual.html#statements-and-expressions)

`for` 语句是一种抽象，用来迭代一个容器的内部成员。它依赖迭代器的流程。跟 `while` 语句一样，`for` 语句开启一个隐式的块语句，所以可使用 `break` 语句跳出。

`for` 循环声明迭代变量---这些变量的作用域仅在 `for` 循环体内。迭代变量的类型，根据迭代器的返回值类型推导出来。

除了在 `for` 循环中调用外，迭代器跟函数很相似。迭代器提供了一种方法，以迭代一个抽象类型。`for` 循环调用迭代器时，`yield` 语句负责实际的执行工作。当迭代进行到一个 `yield` 语句时，其数据被绑定到 `for` 循环的迭代变量，并且控制 `for` 循环体的前进。调用期间，迭代器的局部变量和执行状态被自动保存。例子：

```nim
# 这个迭代器已经在 system 模块中定义
iterator items*(a: string): char {.inline.} =
    var i = 0
    while i < len(a):
        yield a[i]
        inc(i)

for ch in items("hello world"):  # ch 是一个迭代变量
    echo(ch)
```

编译器会为此生成代码，就好象程序员自己写出来的一样：

```nim
var i = 0
while i < len(a):
    var ch = a[i]
    echo(ch)
    inc(i)
```

如果迭代器 `yield` 一个元组，那么可以生成许多迭代变量，它们是元组的成员。`for` 循环会隐式地对元组拆箱。

### 隐式的项、对调用

如果 `for` 循环的表达式 `e` 不是一个迭代器，并且 `for` 循环恰好只有一个迭代变量，那么 `for` 循环的表达式（在内部）被改写成 `items(e)`，换句话说，会采用一个隐式的 `items` 迭代器：

```nim
for x in [1,2,3]: 
    echo x

# 会被编译器改写为
for x in items([1,2,3]): 
    echo x
```

如果 `for` 循环的表达式刚好有两个迭代变量，那么隐式调用一个 `pairs` 迭代器。

改写为 `items`、`pairs` 之后，会对其进行符号查找。因此，所有对 `items`、`pairs` 的重载项，都会被考虑。 

### 一等迭代器

Nim 语言有两种迭代器：内联和闭包。内联迭代器总是由编译器生成嵌入代码，这使得该迭代器抽象在实际运行时是零开销，具有很高的运行速度，但同时增大生成代码的体积。内联迭代器是二等公民：它们作为参数使用时，只能传递给其它可以嵌入内联代码的工具，比如模板、宏和其他的内联迭代器。

相比之下，闭包迭代器能够更自由的传递：

```nim
iterator count0(): int {.closure.} =
    yield 0

iterator count2(): int {.closure.} =
    var x = 1
    yield x
    inc x
    yield x

proc invoke(iter: iterator(): int {.closure.}) =
    for x in iter(): 
        echo x

invoke(count0)
invoke(count2)
```

闭包迭代器相比内敛迭代器有一些限制：

1. `yield` 不能出现在 `try` 语句中 
2. 目前，不能够在编译期进行评估
3. `return` 是允许的（但很少用），使用 `return` 会立刻结束迭代
4. 两个都不能够递归

如果一个迭代器既没有语法标记 `{.closure.}` 也没有语法标记 `{.inline.}`，那么默认是内联迭代器（`{.inline.}`），不过在未来版本中也许会改变！

下面这个例子，演示了如何使用迭代器实现一个协同任务系统：

```nim
# simple tasking:
type
    Task = iterator (ticker: int)

iterator a1(ticker: int) {.closure.} =
      echo "a1: A"
      yield
      echo "a1: B"
      yield
      echo "a1: C"
      yield
      echo "a1: D"

iterator a2(ticker: int) {.closure.} =
      echo "a2: A"
      yield
      echo "a2: B"
      yield
      echo "a2: C"

proc runTasks(t: varargs[Task]) =
    var ticker = 0
    while true:
        let x = t[ticker mod t.len]
        if finished(x): break
        x(ticker)
        inc ticker

runTasks(a1, a2)
```

内置例程 `system.finished()` 可以确定迭代器是否已经完成工作。试图调用已经完成工作的迭代器，并不会引发异常。

注意 `system.finished()` 的使用，如果迭代器已经完成工作，它只返回 `true`（否则是 `false`）：

```nim
iterator mycount(a, b: int): int {.closure.} =
    var x = a
    while x <= b:
        yield x
        inc x

var c = mycount  # 实例化迭代器
while not finished(c):
    echo c(1, 3)

# 执行过程
1
2
3
0
```

相反，这段代码中已经被使用：

```nim
    var c = mycount  # 实例化迭代器
    while true:
        let value = c(1, 3)
        if finished(c): break  # 丢弃 'value'!
        echo value
```

也许，这样思考会对你有帮助：迭代器实际上返回一个 `(value, done)`，`finished` 则是访问隐含的字段 `done`。

因为闭包迭代器是“可恢复的函数”（闭包会保存内部环境），所以，每次调用时都必须提供参数。为了解决这个限制，可以使用一个外部的工厂函数来捕获参数：

```nim
proc mycount(a, b: int): iterator (): int =
    result = iterator (): int =
        var x = a
        while x <= b:
            yield x
            inc x

let foo = mycount(1, 4)  # 工厂函数

for f in foo():           
    echo f
```
