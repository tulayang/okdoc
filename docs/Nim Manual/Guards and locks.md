# [警卫和锁](http://nim-lang.org/docs/manual.html#guards-and-locks)

除了 `spawn` 和 `parallel`，Nim 也提供了通用的低阶并行机制，像锁、原子、条件变量、等等。

Nim 通过附加注释，来改善这些特性的线程安全:

1. `{.guard.}` 语法标记，用来防止数据竞争 **`译注：编译器在内部增加一个互斥量`**
2. 每一个对 `{.guard.}` 内存地址的访问，都应该位于一个规定的锁语句内 **`译注：看例子`**
3. 锁和例程,可以标记锁级别，防止在编译期死锁 **`译注：编译器在内部增加嵌套的互斥量`**

## 警卫和锁块

### 保护全局变量

对象字段和全局变量，可以使用 `{.guard.}` 语法标记：

```nim
var glock: TLock
var gdata {.guard : glock.}: int
```

编译器确保对 `gdata` 的访问在一个 `locks` 块内:

```nim
proc invalid =
    # 无效：
    echo gdata

proc valid =
    # 有效：
    {.locks : [glock].}:
        echo gdata
```

对 `gdata` 的顶级访问总是被允许的，这样可以方便初始化。一般假定（不是强制的）每个顶级语句是在任何并发语句前运行。

`{.locks.}` 故意制作的看起来很难用，由于他没有运行时语法，不应该直接使用。需要实现运行时锁时，请在模板中使用:

```nim
template lock(a : TLock; body : stmt) =
    pthread_mutex_lock(a)
    {.locks: [a].}:
        try:
            body
        finally:
            pthread_mutex_unlock(a)
```

The guard does not need to be of any particular type. It is flexible enough to model low level lockfree mechanisms:

```nim
var dummyLock {.compileTime.} : int
var atomicCounter {.guard : dummyLock.} : int

template atomicRead(x) : expr =
    {.locks : [dummyLock].}:
        memoryReadBarrier()
        x

echo atomicRead(atomicCounter) 
```

为了支持多个锁语句，`{.locks.}` 可以采用锁表达式列表： `locks: [a, b, ...]` [lock levels](http://nim-lang.org/docs/manual.html#lock-levels) 描述了为什么这很重要.

### 保护通用地址

`{.guard.}` 也能用来保护一个对象的字段。`{.guard.}` 必须是同一个对象的另一个字段、或者一个全局变量。

```nim
type
    ProtectedCounter = object
        v {.guard: L.}: int
        L: TLock

proc incCounters(counters: var openArray[ProtectedCounter]) =
    for i in 0..counters.high:
        lock counters[i].L:
            inc counters[i].v
```
  
由于 `x.L` 的警卫是激活的，访问 `x.v` 是允许的。模板替换后，相当于:

```nim
proc incCounters(counters: var openArray[ProtectedCounter]) =
    for i in 0..counters.high:
        pthread_mutex_lock(counters[i].L)
        {.locks: [counters[i].L].}:
            try:
                inc counters[i].v
            finally:
                pthread_mutex_unlock(counters[i].L)    
```

There is an analysis that checks that counters[i].L is the lock that corresponds to the protected location counters[i].v. This analysis is called path analysis because it deals with paths to locations like obj.field[i].fieldB[j].

The path analysis is currently unsound, but that doesn't make it useless. Two paths are considered equivalent if they are syntactically the same.

This means the following compiles (for now) even though it really should not:   

```nim
{.locks: [a[i].L].}:
    inc i
    access a[i].v
```

###

## 锁级别

锁级别，用来强制指定全局锁的顺序，以防止编译期死锁。锁级别是 0..1_000 的整数常量。0 级意味着不捕获锁。

如果一段代码持有 M 级锁，则它能获得任何 N < M 级别的锁。不能获得另一个 M 级别的锁。相同级别的锁只能在一个单独的 `{.locks.}` 块同一时间获得:

```nim
var a, b: TLock[2]
var x: TLock[1]
# 无效的锁顺序： TLock[1] 不能在 TLock[2] 前捕获：
{.locks: [x].}:
    {.locks: [a].}:
        ...
# 有效的锁顺序： TLock[2] 在 TLock[1] 前捕获：
{.locks: [a].}:
    {.locks: [x].}:
        ...

# 无效的锁顺序： TLock[2] 在 TLock[2] 前捕获：
{.locks: [a].}:
    {.locks: [b].}:
        ...

# 有效的锁顺序, 在同一时间同一级别的锁捕获：
{.locks: [a, b].}:
    ...
```

这是一个在 Nim 中实现的典型的多锁语句。注意，要求运行期检查，以确定同一锁级别两个锁 a 和 b 一个全局顺序： 

```nim
template multilock(a, b: ptr TLock; body: stmt) =
    if cast[ByteAddress](a) < cast[ByteAddress](b):
        pthread_mutex_lock(a)
        pthread_mutex_lock(b)
    else:
        pthread_mutex_lock(b)
        pthread_mutex_lock(a)
    {.locks: [a, b].}:
        try:
            body
        finally:
            pthread_mutex_unlock(a)
            pthread_mutex_unlock(b)
```

整段例程也可以使用 `{.locks.}` 标记，以使用锁级别。这对于函数能够在 `{.locks.}` 中调用是必要的:

```nim
proc p() {.locks: 3.} = discard

var a: TLock[4]
{.locks: [a].}:
    # p's locklevel (3) is strictly less than a's (4) so the call is allowed:
    p()
```

通常，`{.locks.}` 是一个推导效应，并且存在一个子类型关系: `proc () {.locks: N.}` 是 `proc () {.locks: M.}` 的子类型，其中 M <= N。