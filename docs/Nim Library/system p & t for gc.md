Module system （p & t for gc）
===========================================

```
proc GC_enableMarkAndSweep()  {.gcsafe, gcsafe, locks: 0, raises : [], tag s: [].}  
proc GC_disableMarkAndSweep() {.gcsafe, gcsafe, locks: 0, raises : [], tags : [].} 
     ## Nim's Garbage Collector 基于引用计数进行循环检测，并使用收集器标记和循环清扫完成工作。如果应用程序
     ## 不创建周期收集，那么标记和清扫可能需要很长时间，并且是不需要的。因此，可以激活 | 关闭标记和清扫。

proc GC_enable () {.gcsafe, inline, gcsafe, locks: 0, raises: [], tags: [].}
proc GC_disable() {.gcsafe, inline, gcsafe, locks: 0, raises: [], tags: [].}
     ## 激活 | 关闭 GC 。如果调用 n 次 GC_disable，应该调用 n 次 GC_enable 恢复 GC 。大部分场景应该
     ## 使用 GC_disableMarkAndSweep 只关闭标记和清扫。
```

<span>

```
proc GC_addCycleRoot[T](p: ref T) {.inline.}
	 ## 添加 p 到周期收集器的候选集 root 中。使用场景: 使用 {.acyclic.} 优化，需要手动管理内存时（暂时
	 ## 不对 p 使用周期收集）。

proc GC_fullCollect() {.gcsafe, gcsafe, locks : 0, raises : [Exception], tags : [RootEffect].}
     ## 强制进行一次垃圾收集，普通代码不需要调用（一般也不应该调用）。

```

<span>

```
proc GC_ref     (x: string) {.magic: "GCref", gcsafe, locks: 0.}
proc GC_ref[T]  (x: seq[T]) {.magic: "GCref", gcsafe, locks: 0.}
proc GC_ref[T]  (x: ref T)  {.magic: "GCref", gcsafe, locks: 0.}
proc GC_unref   (x: string) {.magic: "GCunref", gcsafe, locks: 0.}
proc GC_unref[T](x: seq[T]) {.magic: "GCunref", gcsafe, locks: 0.} 
proc GC_unref[T](x: ref T)  {.magic: "GCunref", gcsafe, locks: 0.}
     ## 标记 x 引用，除非使用 GC_unref，否则不会释放。调用 n 次 GC_ref，相应调用 n 次 GC_unref 才能
     ## 取消标记。
```

<span>

```
proc getRefcount   (x: string): int {.importc: "getRefcount", noSideEffect.}
proc getRefcount[T](x: seq[T]): int {.importc: "getRefcount", noSideEffect.}
proc getRefcount[T](x: ref T) : int {.importc: "getRefcount", noSideEffect.} 
     ## 获取 x (一个基于堆分配的对象) 被引用的次数。

proc GC_getStatistics(): string {.gcsafe, gcsafe, locks: 0, raises: [], tags: [].}
     ## 获取 GC 活动信息的字符串，对于调整可能是有用的。

proc setupForeignThreadGc() {.raises: [Exception], tags: [RootEffect].}
	 ## 这个过程会被调用，当: 在一个你无法控制的线程，注册一个回调函数时。这是一个廉价的线程局部 guard。
	 ## GC 只会对每个线程初始化一次。调用通常不会制造麻烦。

proc gcInvariant() {.raises: [], tags: [].}
```