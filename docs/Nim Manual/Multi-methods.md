
# [多态方法](http://nim-lang.org/docs/manual.html#multi-methods)

函数的调度总是静态的。“多态方法”的调度是动态的。

```nim
type
    Expression = ref object of RootObj  ## 一个表达式的抽象基类
    Literal = ref object of Expression
        x: int
    PlusExpr = ref object of Expression
        a, b: Expression

method eval(e: Expression): int {.base.} =
    # 重写基类
    quit "to override!"

method eval(e: Literal): int = return e.x

method eval(e: PlusExpr): int =
    # 当心：依赖动态绑定
    result = eval(e.a) + eval(e.b)

proc newLit(x: int): Literal =
    new(result)
    result.x = x

proc newPlus(a, b: Expression): PlusExpr =
    new(result)
    result.a = a
    result.b = b

echo eval(newPlus(newPlus(newLit(1), newLit(2)), newLit(4)))
```

在这个例子中，构造器 `newLit()` 和 `newPlus()` 都是函数，它们使用静态绑定。但是 `eval()` 是“多态方法”，它要求动态绑定。

如同例子看到的，“基础方法”必须使用语法标记 `{.base.}`。The base pragma also acts as a reminder for the programmer that a base method m is used as the foundation to determine all the effects that a call to m might cause。

在“多态方法”的所有的参数中，有一个对象类型用来调度：

```nim
type
    Thing = ref object of RootObj
    Unit = ref object of Thing
        x: int

method collide(a, b: Thing) {.base, inline.} =
    quit "to override!"

method collide(a: Thing, b: Unit) {.inline.} =
    echo "1"

method collide(a: Unit, b: Thing) {.inline.} =
    echo "2"

var a, b: Unit
new a
new b
collide(a, b) # output: 2
```

调用“多态方法”不会引起歧义: `collide 2` 比 `collide 1` 有更高的优先级，因为分析算法是从左到右。在这个例子中，`Unit Thing` 比 `Thing, Unit` 优先级更高。 

性能提示: Nim 语言不需要产生虚拟方法表，而是生成调度树。这使“多态方法”的调用避免了昂贵的间接分支，并且可以使代码内联。不过，一些其他优化机制，比如编译期求值或者坏代码消除，“多态方法”则无法使用。

