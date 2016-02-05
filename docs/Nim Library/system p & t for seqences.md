Module system （p & t for seqences）
===========================================

```
proc len[T]   (x: seq[T]): int {.magic: "LengthSeq", noSideEffect.}
     ## 获取长度。约等于 high(T) - low(T) + 1 。

proc xlen[T]  (x: seq[T]): int {.magic: "XLenSeq", noSideEffect.}
     ## 获取长度，并且不检测 nil。一种用于 nil 问题的优化。

proc setLen[T](s: var seq[T]; newlen: Natural) {.magic: "SetLengthSeq", noSideEffect.}
     ## 设置新的长度，如果长度溢出则缩短。s 不能是 nil！

proc add[T]   (x: var seq[T]; y: T) {.magic: "AppendSeqElem", noSideEffect.}
proc add[T]   (x: var seq[T]; y: openArray[T]) {.noSideEffect.}
     ## 添加数据项 y 。新的泛型容器，也应该调用他们的 adding proc 保持一致。

proc insert[T](x: var seq[T]; item: T; i = 0.Natural) {.noSideEffect.}
     ## 添加 item

proc del[T]   (x: var seq[T]; i: Natural) {.noSideEffect.}  
     ## 删除 i 项，同时设为 x[high(x)]。O(1) 复杂度。

proc delete[T](x: var seq[T]; i: Natural) {.noSideEffect.}  
     ## 删除 i 项，移动 x[i+1..]。O(n) 复杂度。

proc pop[T]   (s: var seq[T]): T {.inline, noSideEffect.}
     ## 删除最后一项

proc safeAdd[T](x: var seq[T]; y: T) {.noSideEffect.}
```

<span>

```
proc `&`[T](x, y: seq[T])   : seq[T] {.noSideEffect.}     
     ## 拼接两个 sequences。需要拷贝 sequences！
     assert @[1, 2, 3, 4] & @[5, 6] == @[1, 2, 3, 4, 5, 6]

proc `&`[T](x: seq[T]; y: T): seq[T] {.noSideEffect.}
     ## 拼接一个 sequence 和 y 。需要拷贝 sequence！
     assert @[1, 2, 3] & 4 == @[1, 2, 3, 4]

proc `&`[T](x: T; y: seq[T]): seq[T] {.noSideEffect.}
     ## 拼接一个 x 和 sequence。需要拷贝 sequence！
     assert 1 & @[2, 3, 4] == @[1, 2, 3, 4]

proc `[]`[T](s: seq[T]; x: Slice[int]): seq[T]
     ## sequences 切片操作符

proc `[]=`[T](s: var seq[T]; x: Slice[int]; b: openArray[T])
     ## sequences 切片赋值操作符

proc `@`[IDX, T](a: array[IDX, T]): seq[T] {.magic: "ArrToSeq", nosideeffect.}
     ## 转换一个 array 为 sequence 

proc `@`[T](a: openArray[T]): seq[T]
     ## 转换一个 open array 为 sequence。并不比把 array => sequence 有效率，总是拷贝每一个值。
```

<span>

```
proc `==`[T](x, y: seq[T]): bool {.noSideEffect.}     
     ## sequences 的泛型相等操作符。需要扫描 sequences！

proc isNil[T](x: seq[T]): bool {.noSideEffect, magic: "IsNil".}
	 ## 快速检测 x 是否 nil。有时比 x == nil 高效
```

<span>

```
proc newSeq[T](len = 0.Natural): seq[T]
proc newSeq[T](s: var seq[T]; len: Natural) {.magic: "NewSeq", noSideEffect.}
     ## 创建 seq[T] 类型的一个实例，内存大小为 len。等同于 s = @[]; setlen(s, len) 但是不需要
     ## 再分配，效率更高。使用 zeroed entries 填充，当包含 strings 时，他们的值是 nil； 创建之
     ## 后，应该使用赋值代替 add()。
     var inputStrings : seq[string]
     newSeq(inputStrings, 3)
     inputStrings[0] = "The fourth"
     inputStrings[1] = "assignment"
     inputStrings[2] = "would crash"
     #inputStrings[3] = "out of bounds"
```