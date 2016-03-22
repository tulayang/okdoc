# [Nim 语言为你准备的高阶并行语法](http://nim-lang.org/docs/manual.html#parallel-spawn)

Nim 有两种风格的并行（**`译注：其实这是高阶接口，也可以直接编写、调用 C 语言的低阶接口`**）:

1. 通过 `parallel` 语句的结构化并行
2. 通过 `spawn` 语句的非结构化并行

Nim 有一个内置的线程池，用来执行 CPU 密集任务。对于 IO 密集任务，应该使用 `async` 和 `await`。`parallel` 语句和 `spawn` 语句都需要导入 [threadpool module](http://nim-lang.org/docs/threadpool.html) 来工作。    

`spawn` 总是以表达式 `f(a, ...)` 的形式调用。假设 `T` 是 `f` 的返回类型，如果 `T` 是 `void`，那么 `spawn` 的返回类型也是 `void`，否则是 `FlowVar[T]`。

在一个 `parallel` 块中，`FlowVar[T]` 退化为 `T`。这在 `T` 没有含有任何 GC 内存时发生。编译器可以确保 `location = spawn f(...)` 不会过早的读，并且通过 `FlowVar[T]` 确保正确性不需要额外的开销。

注意: 当前，异常不会在 spawn'ed 任务之间传播。

## spawn 语句

`spawn` 用来给一个线程池派送任务:

```nim
import threadpool

proc processLine(line : string) =
    discard "do some heavy lifting here"

for x in lines("myinput.txt"):
    spawn processLine(x)
sync()
```

出于类型安全和实现方便的原因，spawn 表达式有一些限制:

* 必须是一个调用表达式 `f(a, ...)`
* `f` 必须是 GC 安全的
* `f` 必须没有闭包调用约定
* `f` 的形参不能是 `var` 类型。这也表示可以使用 `ptr` 来传送数据。在此提醒程序员们要小心
* `ref` 参数有些微妙的语法变法：在这里会执行深拷贝，当然这会引起性能问题，但是能够确保内存安全。深拷贝是通过 `system.deepCopy()` 来工作的，它可被重写
* 为了安全的数据交换，需要在 `f` 和调用者之间使用一个全局的 `TChannel`。然而，因为 `spawn` 可以返回值，通常更深层的通信是不需要的。

`spawn` 在线程池中执行派送的表达式，并且返回一个数据流变量 `FlowVar[T]` ，这个变量是可读的。使用 `^` 操作符读是阻塞模式。然而，可以使用 `awaitAny` 在同一时间等待多个流变量：

```nim
import threadpool, ...

# 等待，直到 3 个服务中的 2 个收到更新：
proc main =
    var responses = newSeq[RawFlowVar](3)
    for i in 0..2:
        responses[i] = spawn tellServer(Update, "key", "value")
    var index = awaitAny(responses)
    assert(index = 0)
    del(responses, index)
    discard awaitAny(responses)
```

数据流变量确保没有数据竞争。由于技术上的限制，不是每个类型 `T` 都可以用在数据流变量：T has to be of the type ref, string, seq or of a type that doesn't contain a type that is garbage collected. This restriction is not hard to work-around in practice.

## parallel 语句

例子：

```nim
# Compute PI in an inefficient way
import strutils, math, threadpool

proc term(k : float) : float = 
    4 * math.pow(-1, k) / (2*k + 1)

proc pi(n : int) : float =
    var ch = newSeq[float](n+1)
    parallel:
        for k in 0..ch.high:
            ch[k] = spawn term(float(k))
    for k in 0..ch.high:
        result += ch[k]

echo formatFloat(pi(5000))
```

在一个 Nim 程序中，`parallel` 语句是引入并行的首选机制。`parallel` 块会在编译期检查数据竞争的自由。一个复杂的检查程序，确保在广泛支持共享堆内存的同时没有数据竞争。

`parallel` 块有以些限制：

* spawn within a parallel section has special semantics.
* Every location of the form a[i] and a[i..j] and dest where dest is part of the pattern dest = spawn f(...) has to be provably disjoint. This is called the disjoint check.
* Every other complex location loc that is used in a spawned proc (spawn f(loc)) has to be immutable for the duration of the parallel section. This is called the immutability check. Currently it is not specified what exactly "complex location" means. We need to make this an optimization!
* Every array access has to be provably within bounds. This is called the bounds check.
* Slices are optimized so that no copy is performed. This optimization is not yet performed for ordinary slices outside of a parallel section.

