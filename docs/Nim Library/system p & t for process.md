Module system （p & t for process）
===========================================

```
proc `addr`[T](x: var T): ptr T {.magic: "Addr", noSideEffect.}
     ## 内置操作符，用于获取一块内存的地址。不能 overloaded 。

proc `type`[expr, ](x: expr): typedesc {.magic: "TypeOf", noSideEffect.}
     ## 内置操作符，访问一个表达式的类型。不能 overloaded 。

proc sizeof[T](x: T): int {.magic: "SizeOf", noSideEffect.}
     ## 返回 x 的字节大小。常用于低阶编程，大部分时候使用 new 足够了。x 也可以是一个标识符: sizeof(int)。 
```

<span>

```
proc getTotalMem(): int {.gcsafe, raises: [], tags: [].}
	 ## 获取进程拥有的内存字节数

proc getOccupiedMem(): int {.gcsafe, raises: [], tags: [].}
     ## 获取进程拥有的内存字节数，包含使用的数据

proc getFreeMem(): int {.gcsafe, raises: [], tags: [].}
     ## 获取进程拥有的内存字节数，不包含使用的数据
```

<span>

```
proc reset[T](obj: var T) {.magic: "Reset", noSideEffect.}
     ## 重置对象的初始化值（二进制 0）。This needs to be called before any possible object branch 
     ## transition 。
```

<span>

```
proc quit(errorcode: int = QuitSuccess) 
         {.magic: "Exit", importc: "exit", header: "<stdlib.h>", noReturn.}
     ## 立刻结束程序，返回一个退出代码。不调用垃圾收集器释放内存，除非 quit 进程调用 GC_fullCollect 。注意: 
     ## 这是运行时调用，不会触发编译期 effect 。如果你想阻止编译器加入一个 macro，使用 error 或 {.fatal.}。
proc quit(errormsg: string; errorcode = QuitFailure) {.noReturn, raises: [], tags: [].}
	 ## echo(errormsg); quit(errorcode) 的简写

proc addQuitProc(QuitProc: proc () {.noconv.}) {.importc: "atexit", header: "<stdlib.h>".}
     ## 注册退出 procedure，最多注册 30 个。当程序退出前，这些 procedures 会采用后进先出的顺序被运行。如果 
     ## QuitProc 不能注册抛出 EOutOfIndex 。
```

