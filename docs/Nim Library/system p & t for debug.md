Module system （p & t for debug）
===========================================

```
proc echo(x: varargs[expr, `$`]) 
         {.magic: "Echo", tags: [WriteIOEffect], gcsafe, locks: 0, sideEffect.}
     ## 等同于 writeln(stdout, x); flushFile(stdout) 。

proc debugEcho(x: varargs[expr, `$`]) 
     {.magic: "Echo", noSideEffect, tags: [], raises: [].}
     ## 忽略副作用的 echo 。 

proc getTypeInfo[T](x: T): pointer {.magic: "GetTypeInfo", gcsafe, locks: 0.}
```

<span>

```
proc writeStackTrace() {.tags: [WriteIOEffect], raises: [Exception].}
　   ## 把当前的栈追踪写入 stderr ，只用于调试。

proc getStackTrace(): string {.raises: [], tags: [].}
proc getStackTrace(e: ref Exception): string {.raises: [], tags: [].}
     ## 获取栈追踪，只用于调试。

proc stackTraceAvailable(): bool {.raises: [], tags: [].}

proc isOnStack(p: pointer): bool {.noinline, gcsafe, locks: 0, raises: [], tags: [].}

proc astToStr[T](x: T): string {.magic: "AstToStr", noSideEffect.}
     ## AST => string，debugging。
```

<span>

```
proc locals(): RootObj {.magic: "Plugin", noSideEffect, raises: [], tags: [].}
	 ## 生成一个 tuple，列出当前作用域内所有的局部变量。不需要任何运行期 debug，非常快。
	 ## 注意: 返回值并非 RootObj 而是一个依赖当前作用域的 tuple 结构体。
     proc testLocals() =
         var
             a = "something"
             b = 4
             c = locals()
             d = "super!"
       
         b = 1
         for name, value in fieldPairs(c):
             echo "name ", name, " with value ", value
         echo "B is ", b
     # -> name a with value something
     # -> name b with value 4
     # -> B is 1
```

<span>

```
template assert(cond: bool; msg = "")
         ## 如果条件失败，抛出 AssertionError 。

template doAssert(cond: bool; msg = "")
         ## 等同于 assert，但是总是开启，并且不会受到 --assertions 命令行影响。

template onFailedAssert(msg: expr; code: stmt): stmt {.dirty, immediate.}
         ## 设置一个断言失败的触发器，拦截当前模块中的任何 assert 语句。
         # module-wide policy to change the failed assert
         # exception type in order to include a lineinfo
         onFailedAssert(msg):
             var e = new(TMyError)
             e.msg = msg
             e.lineinfo = instantiationInfo(-2)
             raise e 

proc instantiationInfo(index = - 1; fullPaths = false): tuple[filename: string, line: int] 
                      {.magic: "InstantiationInfo", noSideEffect.}
     ## 提供了访问编译器实例化的栈行信息。对于 meta 编程非常有用（比如 assert template）。  
     import strutils

     template testException(exception, code: expr): stmt =
         try:
             let pos = instantiationInfo()
             discard(code)
             echo "Test failure at $1:$2 with '$3'" % [pos.filename,
                  $pos.line, astToStr(code)]
             assert false, "A test expecting failure succeeded?"
         except exception:
             discard

     proc tester(pos: int): int =
         let
             a = @[1, 2, 3]
         result = a[pos]

     when isMainModule:
         testException(IndexError, tester(30))
         testException(IndexError, tester(1))
         # --> Test failure at example.nim:20 with 'tester(1)'

proc raiseAssert(msg: string) {.noinline, raises: [AssertionError], tags: [].}
proc failedAssertImpl(msg: string) {.raises: [], tags: [].}


```

<span>

```
template stdmsg(): File
         ## 扩充 stdout stderr 。
```