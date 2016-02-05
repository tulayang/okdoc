Module system （p & t for containers）
===========================================


```
proc min[T](x: varargs[T]): T  # T 需要有一个 < 操作符 
proc max[T](x: varargs[T]): T  # T 需要有一个 < 操作符 

proc clamp[T](x, a, b: T): T
     ## 限制 x 必须位于 [a, b] 范围内。
     assert (1.4).clamp(0.0, 1.0) == 1.0
     assert (0.5).clamp(0.0, 1.0) == 0.5

proc find[T, S](a: T; item: S): int {.inline.}              
     ## 获取 item 在容器 a 中的索引，没有为 -1 。

proc contains[T](a: openArray[T]; item: T): bool {.inline.} 
     ## 等同于 find(a, item) >= 0

template `in` (x, y: expr): expr {.immediate, dirty.}
         assert 1 in (1..3) == true
         assert 5 in (1..3) == false
         ## contains 的语法糖

template `notin`(x, y: expr): expr {.immediate, dirty.}
         assert 1 notin (1..3) == false
         assert 5 notin (1..3) == true
         ## not containing 的语法糖

proc map[T, S](data: openArray[T]; op: proc (x: T): S {.closure.}): seq[S]
     let
         a = @[1, 2, 3, 4]
         b = map(a, proc(x: int): string = $x)
     assert b == @["1", "2", "3", "4"]

proc map[T](data: var openArray[T]; op: proc (x: var T) {.closure.})
     var a = @["1", "2", "3", "4"]
     echo repr(a)  # --> ["1", "2", "3", "4"]
     map(a, proc(x: var string) = x &= "42")
     echo repr(a)  # --> ["142", "242", "342", "442"]
```

<span>

```
proc len[TOpenArray](x: TOpenArray) : int {.magic: "LengthOpenArray", noSideEffect.}
proc len[I, T]      (x: array[I, T]): int {.magic: "LengthArray",     noSideEffect.}

proc high[T](x: T): T {.magic: "High", noSideEffect.}
     ## 获取一个 array，sequence，string 的最高可能索引，或者一个 ordinal 的最高可能值。另外，x 也可以是
     ## 一个标识符: high(int)。

proc low[T] (x: T): T {.magic: "Low", noSideEffect.}
     ## 获取一个 array，sequence，string 的最小可能索引，或者一个 ordinal 的最小可能值。另外，x 也可以是
     ## 一个标识符: low(int)。
```

<span>

```
proc `^`(x: int): int {.noSideEffect, magic: "Roof", raises: [], tags: [].}
     ## 用于 array 访问； a[^x] 会被重写为 a[a.len - x]

proc `==`[I, T](x, y: array[I, T]): bool

proc `[]`[Idx, T](a: array[Idx, T]; x: Slice[int]): seq[T]
proc `[]`[Idx, T](a: array[Idx, T]; x: Slice[Idx]): seq[T]
     ## arrays 切片操作符

proc `[]=`[Idx, T](a: var array[Idx, T]; x: Slice[int]; b: openArray[T])
proc `[]=`[Idx, T](a: var array[Idx, T]; x: Slice[Idx]; b: openArray[T]) 
     ## arrays 切片赋值操作符

proc `..`[T](a, b: T): Slice[T] {.noSideEffect, inline, magic: "DotDot".}
     ## 切片操作符，构造一个范围值 [a, b] 。也可以用作 set 构造器和 ordinal 的 case 语句。

proc `..`[T](b   : T): Slice[T] {.noSideEffect, inline, magic: "DotDot".}
     ## 切片操作符，构造一个范围值 [default(T), b] 。

template `..^`(a, b: expr): expr
template `..<`(a, b: expr): expr
```


