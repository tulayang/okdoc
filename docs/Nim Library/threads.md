[Module threads](http://nim-lang.org/docs/threads.html)                                                
==================

Thread support for Nim. Note: This is part of the system module. Do not import it directly. 
To activate thread support you need to compile with the --threads:on command line switch.

Nim's memory model for threads is quite different from other common programming languages (C, 
Pascal): Each thread has its own (garbage collected) heap and sharing of memory is restricted
（受限制的）. This helps to prevent race conditions （条件竞争） and improves efficiency （提高效率）. 
See [the manual for details of this memory model](http://nim-lang.org/docs/manual.html#threads).

这个模块定义了低阶的线程模型，对应 POSIX 多线程的 `pthread_t`。属于 system module，不需要显式的导入。抽象了两个类型，用来表述线程和线程ID：`TThread`、`TThreadId`。包含了创建和控制线程流的过程 `createThread` 、`joinThread` 、` joinThreads`，以及检测线程状态的过程 `running`、`threadId`、`myThreadId`  。

Example:

```
import locks

var
    thr: array[0..4, TThread[tuple[a, b: int]]]
    L: TLock

proc threadFunc(interval: tuple[a, b: int]) {.thread.} =
    for i in interval.a..interval.b:
        acquire(L) # lock stdout
        echo i
        release(L)

initLock(L)

for i in 0..high(thr):
      createThread(thr[i], threadFunc, (i * 10, i * 10 + 5))
joinThreads(thr)
```


Types
-------

```
TThread* {.pure, final.}[TArg] = object of TGcThread  
    when TArg is void: 
        dataFn: proc () {.nimcall, gcsafe.}
    else: 
        dataFn: proc (m: TArg) {.nimcall, gcsafe.}
        data: TArg
    ## Nim thread. A thread is a heavy object (~14K) that must not be part of a message! Use a 
    ## TThreadId for that.

TThreadId*[TArg] = ptr TThread[TArg]
    ## the current implementation uses a pointer as a thread ID.
```

Procs
---------

```
proc running[TArg](t: TThread[TArg]): bool {.inline.}
     ## 如果 t 运行，返回 true

proc joinThread[TArg](t: TThread[TArg]) {.inline.}
     ## 等待线程 t 结束

proc joinThreads[TArg](t: varargs[TThread[TArg]])
     ## 等待 t 中的每一个线程结束

proc createThread*[TArg](t: var TThread[TArg]; tp: proc (arg: TArg) {.thread.}; param: TArg)
     ## 创建一个新的线程，并且启动。tp 作为进入点，param 传递给 tp 作为参数。对于 TArg，如果不想传入任何
     ## 参数，可以是 void。

proc threadId[TArg](t: var TThread[TArg]): TThreadId[TArg] {.inline.}
     ## 返回 t 的线程ID。

proc myThreadId*[TArg](): TThreadId[TArg]
     ## 返回线程 proc 所在的线程ID。这是 unsafe，因为不会检测 TArg 类型的一致。
```

