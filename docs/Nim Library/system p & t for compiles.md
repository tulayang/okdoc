Module system (p & t for compiles)
=================================


```
proc defined[expr](x: expr): bool {.magic: "Defined", noSideEffect.}
     ## 特殊的编译器 procedure，检测 x 已经定义。
     when not defined(release):
         # Do here programmer friendly expensive sanity checks.

proc declared[expr](x: expr): bool {.magic: "Defined", noSideEffect.}
     ## 特殊的编译器 procedure，检测 x 已经声明。
     when not declared(strutils.toUpper):
         # provide our own toUpper proc here, because strutils is missing it.

proc declaredInScope[expr](x: expr): bool {.magic: "DefinedInScope", noSideEffect.}
	 ## 特殊的编译器 procedure，检测 x 声明在当前作用域； x 必须是标识符
```

<span>

```
proc compileOption(option: string): bool {.magic: "CompileOption", noSideEffect.}
     when compileOption("floatchecks"):
         echo "compiled with floating point NaN and Inf checks"
proc compileOption(option, arg: string): bool {.magic: "CompileOptionArg", noSideEffect.}
     when compileOption("opt", "size") and compileOption("gc", "boehm"):
         echo "compiled with optimization for size and uses Boehm's GC"
     ## 可以用来确定编译期的配置项是 on|off
```

<span>

```
proc compiles[expr](x: expr): bool {.magic: "Compiles", noSideEffect.}
     ## 编译期检测 x 可以被编译，没有语法错误。可以用于检测一个类型是否支持某些操作。
     when not compiles(3 + 4):
         echo "'+' for integers is available"
```

<span>

```
proc slurp     (filename: string): string {.magic: "Slurp".}
     ## staticRead 的别名。
proc staticRead(filename: string): string {.magic: "Slurp".}
     ## 编译期 readFile，方便资源嵌入。
     const myResource = staticRead"mydatafile.bin"

proc gorge     (command: string; input = ""): string 
               {.magic: "StaticExec", raises: [], tags: [].}
　　  ## staticExec 的别名。
proc staticExec(command: string; input = ""): string 
               {.magic: "StaticExec", raises: [], tags: [].}
     ## 编译期运行一个外部程序。如果 input != "" 会作为标准的 input 传递给这个程序。
     const buildInfo = "Revision " & staticExec("git rev-parse HEAD") &
                       "\nCompiled on " & staticExec("uname -v")
```

<span>

```
proc likely(val: bool): bool {.importc: "likely", nodecl, nosideeffect.}
     ## 提示优化器: val 很可能是 true。可用来布置一个分支条件，在特定平台上可以帮助处理器预测运行哪一个分支。
     for value in inputValues:
         if likely(value <= 100):
             process(value)
         else:
             echo "Value too big!"

proc unlikely(val: bool): bool {.importc: "unlikely", nodecl, nosideeffect.}
　　  ## 提示优化器: val 很可能是 false。可用来布置一个分支条件，在特定平台上可以帮助处理器预测运行哪一个分支。
     for value in inputValues:
         if unlikely(value > 100):
             echo "Value too big!"
         else:
             process(value)
```

<span>

```
proc setControlCHook(hook: proc () {.noconv.} not nil) 
                    {.raises: [Exception], tags: [RootEffect].}
     ## 重写 CTRL+C 信号行为的钩子 
```
