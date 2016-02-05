Module system （p & t for common）
=========================================

```
proc isNil   (x: string) : bool {.noSideEffect, magic: "IsNil".}
proc isNil   (x: cstring): bool {.noSideEffect, magic: "IsNil".}
proc isNil[T](x: seq[T]) : bool {.noSideEffect, magic: "IsNil".}
proc isNil[T](x: ref T)  : bool {.noSideEffect, magic: "IsNil".}
proc isNil[T](x: ptr T)  : bool {.noSideEffect, magic: "IsNil".}
proc isNil   (x: pointer): bool {.noSideEffect, magic: "IsNil".}
proc isNil[T](x: T)      : bool {.noSideEffect, magic: "IsNil".}
     ## 快速检测 x 是否 nil； 有时比 x == nil 高效
```

<span>

```
proc `==`[TEnum](x, y: TEnum)  : bool {.magic: "EqEnum",    noSideEffect.}
proc `==`       (x, y: bool)   : bool {.magic: "EqB",       noSideEffect.}
proc `==`       (x, y: char)   : bool {.magic: "EqCh",      noSideEffect.}
proc `==`       (x, y: string) : bool {.magic: "EqStr",     noSideEffect.}
proc `==`       (x, y: cstring): bool {.magic: "EqCString", noSideEffect.}
proc `==`       (x, y: pointer): bool {.magic: "EqRef",     noSideEffect.}
proc `==`[T]    (x, y: set[T]) : bool {.magic: "EqSet",     noSideEffect.}
proc `==`[T]    (x, y: ref T)  : bool {.magic: "EqRef",     noSideEffect.}
proc `==`[T]    (x, y: ptr T)  : bool {.magic: "EqRef",     noSideEffect.}
proc `==`[T]    (x, y: T)      : bool {.magic: "EqProc",    noSideEffect.}

proc `<=`[TEnum](x, y: TEnum)  : bool {.magic: "LeEnum",    noSideEffect.}
proc `<=`       (x, y: bool)   : bool {.magic: "LeB",       noSideEffect.}
proc `<=`       (x, y: char)   : bool {.magic: "LeCh",      noSideEffect.}
proc `<=`       (x, y: string) : bool {.magic: "LeStr",     noSideEffect.}
proc `<=`       (x, y: pointer): bool {.magic: "LePtr",     noSideEffect.}
proc `<=`[T]    (x, y: set[T]) : bool {.magic: "LeSet",     noSideEffect.}
proc `<=`[T]    (x, y: ref T)  : bool {.magic: "LePtr",     noSideEffect.}

proc `<`[TEnum] (x, y: TEnum)  : bool {.magic: "LtEnum",    noSideEffect.}
proc `<`        (x, y: bool)   : bool {.magic: "LtB",       noSideEffect.}
proc `<`        (x, y: char)   : bool {.magic: "LtCh",      noSideEffect.}
proc `<`        (x, y: string) : bool {.magic: "LtStr",     noSideEffect.}
proc `<`        (x, y: pointer): bool {.magic: "LtPtr",     noSideEffect.}
proc `<`[T]     (x, y: set[T]) : bool {.magic: "LtSet",     noSideEffect.}
proc `<`[T]     (x, y: ref T)  : bool {.magic: "LtPtr",     noSideEffect.}
proc `<`[T]     (x, y: ptr T)  : bool {.magic: "LtPtr",     noSideEffect.}
proc `<`[T]     (x: Ordinal[T]): T    {.magic: "UnaryLt",   noSideEffect.}
     ## 用于排除范围时，增加可读性。语法上同 pred(10)。
     for i in 0 .. <10: echo i

proc `==`[T]    (x, y: T): bool       
proc `<=`[T]    (x, y: T): bool      
proc `<`[T]     (x, y: T): bool      
     ## 用于 tuples 元素表示
     assert (23, 45) == (23, 45)

template `!=`(x, y: expr): expr {.immediate.}
template `>=`(x, y: expr): expr {.immediate.}
template `>` (x, y: expr): expr {.immediate.}
template `-|`(b, s: expr): expr
```

<span>

```
proc `+=`[T](x: var T; y: T) {.magic: "Inc", noSideEffect.}
proc `-=`[T](x: var T; y: T) {.magic: "Dec", noSideEffect.}
proc `*=`[T](x: var T; y: T) {.inline, noSideEffect.}
     ## ordinal 类型算术 

proc `+=`[T](x: var T; y: T) {.inline, noSideEffect.}
proc `-=`[T](x: var T; y: T) {.inline, noSideEffect.}
proc `*=`[T](x: var T; y: T) {.inline, noSideEffect.}
proc `/=`[T](x: var T; y: T) {.inline, noSideEffect.}
proc `/=`(x: var float64; y: float64) {.inline, noSideEffect, raises: [], tags: [].}
     ## placee a floating point number 类型算术

proc `&=`(x: var string; y: string) {.magic: "AppendStrStr", noSideEffect.}
```

<span>

```
proc ord[T](x: T): int {.magic: "Ord", noSideEffect.}
     ## 获取一个 ordinal 的整数值表示。

proc chr(u: range[0 .. 255]): char {.magic: "Chr", noSideEffect.}
     ## 转换一个 0..255 的 integer 为 character。
```

<span>

```
proc succ[T](x: Ordinal[T]; y = 1): T {.magic: "Succ", noSideEffect.}
     ## 获取 x 第 y 个后任者。如果不存在，编译期抛出 EOutOfRange 。T 是 ordinal 类型。

proc pred[T](x: Ordinal[T]; y = 1): T {.magic: "Pred", noSideEffect.}
     ## 获取 x 第 y 个前任者。如果不存在，编译期抛出 EOutOfRange 。T 是 ordinal 类型。

proc inc[T](x: var T; y = 1) {.magic: "Inc", noSideEffect.}
     ## 增加一个 ordinal 的值。如果不存在，编译期抛出 EOutOfRange。等同于 x = succ(x, y)

proc dec[T](x: var T; y = 1) {.magic: "Dec", noSideEffect.}
     ## 减小一个 ordinal 的值。如果不存在，编译期抛出 EOutOfRange。等同于 x = pred(x, y)
```

<span>

```
proc `is`[T, S](x: T; y: S): bool {.magic: "Is", noSideEffect.}
     ## 检查 x 和 y 是相同类型
     proc test[T](a: T): int =
         when (T is int): return a
         else           : return 0
     assert(test[int](3) == 3)
     assert(test[string]("xyz") == 0)

template `isnot`(x, y: expr): expr {.immediate.}
         ## not(x is y)

proc `of`[T, S](x: T; y: S): bool {.magic: "Of", noSideEffect.}
　　　## 检查 x 有一个类型 y
     assert FloatingPointError of Exception
     assert DivByZeroError     of Exception

proc cmp[T](x, y: T)     : int {.procvar.}
     ## # 通用比较 proc； x < y => <0 ； x > y => >0 ； x == y => 0。 
proc cmp   (x, y: string): int {.noSideEffect, procvar, raises: [], tags: [].} 
     ## 比泛型版本效率高。

proc swap[T](a, b: var T) {.magic: "Swap", noSideEffect.}
     ## 交换 a b 的值，比起 tmp = a; a = b; b = tmp 通常效率更高。对排序算法特别有用。

proc finished[T](x: T): bool {.noSideEffect, inline.}
     ## 用于确定一个 iterator 已经完成 

template accumulateResult(iter: expr)
         ## iterator => proc

proc procCall[expr](x: expr) {.magic: "ProcCall".}
     ## 特殊的 magic，阻止 method 调用的动态绑定； 使 OO 编程变的简单。
     procCall someMethod(a, b)
```

<span>

```
proc atomicInc(memLoc: var int; x: int = 1): int 
              {.inline, discardable, gcsafe, locks: 0, raises: [], tags: [].}
     ## 原子操作，用于增加 memLoc 。

proc atomicDec(memLoc: var int; x: int = 1): int 
              {.inline, discardable, gcsafe, locks: 0, raises: [], tags: [].}
     ## 原子操作，用于减小 memLoc 。

proc nimDestroyRange[T](r: T)
```

<span>

```
proc deepCopy[T](x: var T; y: T) {.noSideEffect, magic: "DeepCopy".}
     ## 运行一次对 x 的深拷贝。也被代码生成器用于 spawn 的实现。

proc shallowCopy[T](x: var T; y: T) {.noSideEffect, magic: "ShallowCopy".}
     ## 使用其代替 = 进行浅拷贝； 浅拷贝只改变 sequences 和 strings 的语法，需要小心。这也是为什么默认的 
     ## = 是深拷贝。

proc shallow[T](s: var seq[T]) {.noSideEffect, inline.}
proc shallow   (s: var string) {.noSideEffect, inline, raises: [], tags: [].}
　　  ## 标记为 shallow，后续的赋值不使用深拷贝。仅用于优化目的。　
```

<span>

```
proc zeroMem(p: pointer; size: Natural) {.importc, noDecl, gcsafe, locks: 0.}
     ## 重写 p 的内存内容为 0，恰好 size 字节。像任何处理原始内存的 procedure，这是 unsafe。

proc copyMem(dest, source: pointer; size: Natural) 
            {.importc: "memcpy", header: "<string.h>", gcsafe, locks: 0.}
　　  ## 拷贝 source 的内存内容到 dest 内存中，恰好 size 字节。内存区域不能重叠。像任何处理原始内存的 
    ## procedure，这是 unsafe。

proc moveMem(dest, source: pointer; size: Natural) 
            {.importc: "memmove", header: "<string.h>", gcsafe, locks: 0.}
     ## 拷贝 source 的内存内容到 dest 内存中，恰好 size 字节。内存区域不能重叠。比 copyMem 稍微 safe， 
     ## 但是像任何处理原始内存的 procedure，这是 unsafe。 

proc equalMem(a, b: pointer; size: Natural): bool {.importc: "equalMem", noDecl, noSideEffect.}
     ## 比较 a b 两块内存，恰好 size 字节。如果内存是相等的，返回 true。像任何处理原始内存的 procedure，
     ## 这是 unsafe。
```

<span>

```
proc rawProc[T](x: T): pointer {.noSideEffect, inline.}
     ## 获取闭包 x 的 raw proc pointer。用于 C 接口编程时的闭包调用。

proc rawEnv[T](x: T): pointer {.noSideEffect, inline.}
     ## 获取闭包 x 的 raw environment pointer。用于 C 接口编程时的闭包调用。
```

<span>

```
proc addAndFetch(p: ptr int; val: int): int {.inline, raises: [], tags: [].}
proc cas[T](p: ptr T; oldValue, newValue: T): bool 
           {.importc: "__sync_bool_compare_and_swap", nodecl.}
proc cpuRelax() {.inline, raises: [], tags: [].}
```

