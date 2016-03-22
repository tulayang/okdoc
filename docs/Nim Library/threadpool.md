[Module threadpool](http://nim-lang.org/docs/threadpool.html)                                                 
=====================

这个模块定义了高阶的线程分发。当导入这个模块时，会启动一个包含 256 （默认）个线程的线程池。这个模块抽象了三个模型，表述线程分发的结果状态：`foreign`、`FlowVarBase`、`FlowVar[T]`。包含了分发过程：`spawn`，同步线程流的过程和语句：`sync`、`parallel`，配置线程池容量的过程：`setMinPoolSize`、`setMaxPoolSize`，等待线程的过程：`await`、`awaitAndThen`、`awaitAny`、`^`，自动调用／分发的过程和模板：`preferSpawn`、`spawnX`。

```
import cpuinfo, cpuload, locks 
```

Types
---------

```
foreign     = object                 ## 一个域，表示来自外部线程堆的指针
                                     ## a region that indicates the pointer comes from
                                     ## a foreign thread heap

FlowVarBase = ref FlowVarBaseObj     ## 一个无类型，用于FlowVar[T]
                                     ## untyped base class for 'FlowVar[T]' 

FlowVar[T]  = ref FlowVarObj[T]      ## 一个数据流变量
                                     ## a data flow variable
``` 

Consts
------------

```
MaxThreadPoolSize = 256              ## 线程池的最大数量。256 应该适应大多数情况。 
                                     ## maximal size of the thread pool. 256 threads should be 
                                     ## good enough for anybody ;-) 
```

Procs
-------------

```
proc await(fv: FlowVarBase) {.raises: [], tags: [].}
     ## 等待，直到 flowVar 可用。通常不需要显示调用。
     ## waits until the value for the flowVar arrives. Usually it is not necessary to call 
     ## this explicitly. 

proc awaitAndThen[T](fv: FlowVar[T]; action: proc (x: T) {.closure.})
     ## 阻塞，直到 flowVar 可用，并且将其值传递给 action 。注意: 根据 Nim 参数传递的语法，T 不需要拷贝，
     ## 所以 awaitAndThen 有时比 ^ 更有效率。
     ## blocks until the fv is available and then passes its value to action. Note that due to 
     ## Nim's parameter passing semantics this means that T doesn't need to be copied and so 
     ## awaitAndThen can sometimes be more efficient than ^.

proc `^`[T](fv: FlowVar[ref T]): foreign ptr T
proc `^`[T](fv: FlowVar[T])    : T
     ## 阻塞，直到 fv 可用，返回该值。
     ## blocks until the value is available and then returns this value.

proc awaitAny(flowVars: openArray[FlowVarBase]): int {.raises: [], tags: [].}
     ## 等待给出的 flowVars 中的任一个。返回索引号和可用值。同一时间，一个 flowVar 只支持一次 awaitAny 
     ## 调用。这意味着如果你 await([a, b]) 并且 await([b, c])，第二次调用只会等待 c 。如果没有 flowVar 
     ## 能够等待，返回 -1。注意: 这种情况下结果是不确定的，所以应该避免。
     ## awaits any of the given flowVars. Returns the index of one flowVar for which a value 
     ## arrived. A flowVar only supports one call to 'awaitAny' at the same time. That means 
     ## if you await([a,b]) and await([b,c]) the second call will only await 'c'. If there is 
     ## no flowVar left to be able to wait on, -1 is returned. Note: This results in 
     ## non-deterministic behaviour and so should be avoided. 

proc setMinPoolSize(size: range[1 .. MaxThreadPoolSize]) {.raises: [], tags: [].}
     ## 设置线程池的最小数量。默认值是 4。

proc setMaxPoolSize(size: range[1 .. MaxThreadPoolSize]) {.raises: [], tags: [].}
     ## 设置线程池的最大数量。默认值是 MaxThreadPoolSize。

proc preferSpawn(): bool {.raises: [], tags: [].}
     ## 用来快速确定，优先使用一个 spawn 还是直接调用。如果返回 true，一个 spawn 可能更优势。一般不需要
     ## 直接调用这个 proc，使用 spawnX 代替。

proc spawn[expr](call: expr): expr {.magic: "Spawn".}
     ## always spawns a new task, so that the 'call' is never executed on the calling thread. 
     ## 'call' has to be proc call 'p(...)' where 'p' is gcsafe and has a return type that 
     ## is either 'void' or compatible with FlowVar[T].

proc parallel(body: stmt) {.magic: "Parallel".}
     ## a parallel section can be used to execute a block in parallel. body has to be in a 
     ## DSL that is a particular subset of the language. Please refer to the manual for further
     ## information. 

proc sync() {.raises: [], tags: [].}
     ## a simple barrier to wait for all spawn'ed tasks. If you need more elaborate waiting, 
     ## you have to use an explicit barrier.
```

Templates

```
template spawnX(call: expr): expr
```