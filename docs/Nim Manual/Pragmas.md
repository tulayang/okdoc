
# [语法标记](http://nim-lang.org/docs/manual.html#pragmas)

语法标记是 Nim 语言提供的一种机制，给予编译器附加外部命令，不会引入大量新的关键字。语法标记运作在整个语法检查期间。语法标记通过 `{.` 和 `.}` 包裹。语法标记也常常用作实现语言特征的首选，在通过良好的语法来访问特征变得可用之前。

## 基本语法标记

### {.deprecated.}

用来标记一个符号，表示该符号已经弃用：

```nim
proc p() {.deprecated.}
var x {.deprecated.}: char
```

也能用作语句，提供一个重命名列表：

```nim
type
    File = object
    Stream = ref object
{.deprecated: [TFile: File, PStream: Stream].}
```
通过指定这些新的重命名，**nimfix** 工具也可以使用，会自动更新你的代码和重构。

### {.noSideEffect.}

标记一个函数、迭代器，表示没有副作用。形参中没有 `var T`、`ref T` 或者 `ptr T` 类型，意味着没有位置会被修改。如果编译器不能验证该函数、迭代器确实没有副作用，会发出一个静态错误。

作为一个特殊的语法规则，内置 `debugEcho()` 被设定没有副作用，它能用来调试为 `{.noSideEffect.}` 例程。
*译注：打印意味着向标准输出写入数据，而这就完全是副作用的。echo() 无法在 {.noSideEffect.} 标记的例程内使用。debugEcho() 被编译器做了手脚，以使其可以在 {.noSideEffect.} 标记的例程内打印。* 

未来方向：`func` 关键字可以成为一个没有副作用函数、迭代器的语法糖。

```nim
func `+` (x, y: int): int
```

### {.procvar.}

标记一个函数，表示它能被作为例程的参数。

### {.compileTime.}

标记一个函数、迭代器，使它们只能在编译器执行。不会为它们生成新的代码。编译期函数作为宏的辅助是很有用的。从 0.12.0 版本开始使用 system.NimNod 的函数，它的形参类型隐式地声明为 `{.compileTime.}`

```nim
proc astHelper(n: NimNode): NimNode =
    result = n
```
等同于：

```nim
proc astHelper(n: NimNode): NimNode {.compileTime.} =
    result = n
```

### {.noreturn.}

标记一个函数，表示没有返回值。

### {.acyclic.}

标记一个对象类型，表示非循环的（尽管它们看起来是循环的）。这是对 GC 的优化，使其不把此对象作为循环考虑：

```nim
type
    Node = ref NodeObj
    NodeObj {.acyclic, final.} = object
        left, right: Node
        data: string
```
在这个例子中，使用 `Node` 类型声明一个树结构。注意到类型定义是递归的，GC 必须假定这种类型的对象可能来自一个循环图。`{.acyclic.}` 告诉 GC 不能发生这种情况，GC 可能会泄露内存。

未来方向：可以变成一个 `ref` 类型的特性：

```nim
type
    Node = acyclic ref NodeObj
    NodeObj = object
        left, right: Node
        data: string
```

### {.final.}

标记一个对象类型，表示它不能被继承。

### {.shallow.}

使编译器执行浅拷贝。该语法标记会带来严重的语法问题，并破坏内存“安全”。然而，该语法标记能大幅度提高赋值的效能，因为 Nim 语言的语法，对序列和字符串的赋值是进行深拷贝。这可能会是昂贵的，特别是用来构建一个树结构的时候。

```nim
type
    NodeKind = enum nkLeaf, nkInner
    Node {.final, shallow.} = object
        case kind: NodeKind
        of nkLeaf:
            strVal: string
        of nkInner:
            children: seq[Node]
```

### {.pure.}

标记一个对象类型，表示它的字段会被省略运行期的类型识别。这个标记常用于与其他语言的二进制兼容性。

一个枚举类型可以被标记为 `{.pure.}`。访问它的字段总是要求提供命名空间。

### {.asmNoStackFrame.}

标记一个函数，表示编译器不对该函数生成栈框架。生成的 C 语言函数被声明为 ` __declspec(naked)` 或者 `__attribute__((naked))` （依赖使用的 C 语言编译器）。

### {.error.}

用来使编译器输出一个给定的错误消息。这个消息不会造成编译器中止。

也用来标记一个符号（比如函数、迭代器）。对这个符号的使用会触发一个编译期错误。 This is especially useful to rule out that some operation is valid due to overloading and type conversions:

```nim
## check that underlying int values are compared and not the pointers:
proc `==`(x, y: ptr int): bool {.error.}
```

### {.fatal.}

用来使编译器输出一个给定的错误消息。对比 `{.error.}`，`{.fatal.}` 会确保中止编译。

```nim
when not defined(objc):
    {.fatal: "Compile this program with the objc command!".}
```

### {.warning.}

用来使编译器输出一个给定的警告消息。之后编译会继续执行。

### {.hint.}

用来使编译器输出一个给定的提示消息。之后编译会继续执行。

### {.line.}

Can be used to affect line information of the annotated statement as seen in stack backtraces:

```nim
template myassert*(cond: expr, msg = "") =
    if not cond:
        # change run-time line information of the 'raise' statement:
        {.line: InstantiationInfo().}:
            raise newException(EAssertionFailed, msg)
```
If the line pragma is used with a parameter, the parameter needs be a `tuple[filename: string, line: int]`. If it is used without a parameter, `system.InstantiationInfo()` is used.

### {.linearScanEnd.}

指示编译器如何编译一个 `case` 语句。按照语法，它被用作一个语句：

```nim
case myInt
of 0:
    echo "most common case"
of 1:
    {.linearScanEnd.}
    echo "second most common case"
of 2: echo "unlikely: use branch table"
else: echo "unlikely too: use branch table for ", myInt
```
In the example, the case branches 0 and 1 are much more common than the other cases. Therefore the generated assembler code should test for these values first, so that the CPU's branch predictor has a good chance to succeed (avoiding an expensive CPU pipeline stall). The other cases might be put into a jump table for O(1) overhead, but at the cost of a (very likely) pipeline stall.

The linearScanEnd pragma should be put into the last branch that should be tested against via linear scanning. If put into the last branch of the whole case statement, the whole case statement uses linear scanning.

### {.computedGoto.}

指示编译器如何编译一个在 `while true` 语句中的 `case` 语句。按照语法，它被用作一个循环内的语句：

```nim
type
    MyEnum = enum
        enumA, enumB, enumC, enumD, enumE

proc vm() =
    var instructions: array [0..100, MyEnum]
    instructions[2] = enumC
    instructions[3] = enumD
    instructions[4] = enumA
    instructions[5] = enumD
    instructions[6] = enumC
    instructions[7] = enumA
    instructions[8] = enumB
   
    instructions[12] = enumE
    var pc = 0
    while true:
        {.computedGoto.}
        let instr = instructions[pc]
        case instr
        of enumA:
            echo "yeah A"
        of enumC, enumD:
            echo "yeah CD"
        of enumB:
            echo "yeah B"
        of enumE:
            break
        inc(pc)

vm()
```
这个例子说明了 `{.computedGoto.}` 对于解释器非常有用。如果底层后端（C 编译器）不支持这种计算扩展，这个语法非常简单的被忽略。

### {.unroll.}

指示编译器应该展开一个 `for` 或者 `while` 循环，用于运行期高效能：

```nim
proc searchChar(s: string, c: char): int =
    for i in 0 .. s.high:
        {.unroll: 4.}
        if s[i] == c: return i
    result = -1
```
In the above example, the search loop is unrolled by a factor 4. The unroll factor can be left out too; the compiler then chooses an appropriate unroll factor.

Note: Currently the compiler recognizes but ignores this pragma.

### {.immediate.}

查看普通模板和直接模板。      

###
  
## 编译项语法标记

下面列出的语法标记，可以用来重设对函数、方法、转换器的代码生成的配置。

语法标记|   允许的值 |描述
-|-|-
checks|  on｜off  |Turns the code generation for all runtime checks on or off.
boundChecks| on｜off  |Turns the code generation for array bound checks on or off.
overflowChecks|  on｜off  |Turns the code generation for over- or underflow checks on or off.
nilChecks|   on｜off  |Turns the code generation for nil pointer checks on or off.
assertions|  on｜off  |Turns the code generation for assertions(断言) on or off.
warnings|    on｜off  |Turns the warning messages of the compiler on or off.
hints|   on｜off  |Turns the hint messages of the compiler on or off.
optimization|    none｜speed｜size     |Optimize the code for speed or size, or disable optimization.
patterns|    on｜off  |Turns the term rewriting templates/macros on or off.
callconv|    cdecl｜...   |Specifies the default calling convention for all procedures (and procedure types) that follow.

例子

```nim
{.checks: off, optimization: speed.}
# 编译后的代码不会包含运行期检查。这是一个优化，程序可以获得更好的速度
```

### {.push.} {.pop.}

它们非常类似编译项标记，但是更多是用来临时地重设配置。例子：

```nim
{.push checks: off.}
# 编译这一段代码时，不会包含运行期检查。因为这段代码需要更好的速度
# ... some code ...
{.pop.}  # 恢复原有的配置
```

### {.register.}

只能用于标记变量。提示编译器，变量应该被放置在硬件的寄存器中，以获得更快的访问速度。C 语言编译器通常忽略它，有一个说得过去的原因：通常呢，不用这个它们能把活干的更漂亮。

### {.global.}

用在一个函数的变量指示编译器，这个变量应该当程序加载时在一个全局段存储并初始化：

```nim
proc isHexNumber(s: string): bool =
    var pattern {.global.} = re"[0-9a-fA-F]+"
    result = s.match(pattern)
```

对于 `{.global.}` 标记的函数，对于该函数的每个实例化，只会为此创建一个独一无二的全局变量。

{.deadCodeElim.}

只适用于整个模块。指示编译器，在模块出现该标记的地方开启或者关闭“坏代码淘汰”。

`--deadCodeElim:on` 命令项也能开启关闭这个功能。不管怎么样，对于一些模块，比如 GTK 包装器，总是开启“坏代码淘汰”是有意义的。
例子：

```nim
{.deadCodeElim: on.}
```

### {.pragma.}

用来声明用户定义的语法标记。这很有用，因为 Nim 语言的模板和宏不影响语法标记。用户定义的语法标记，不能被导入到其它模块！
例子：

```nim
when appType == "lib":
    {.pragma: rtl, exportc, dynlib, cdecl.}
else:
    {.pragma: rtl, importc, dynlib: "client.dll", cdecl.}

proc p*(a, b: int): int {.rtl.} =
    result = a+b
```
在这个例子中，定义了一个新的语法标记 `{.rtl.}`，可以从一个动态库导入一个符号，或者导出一个符号。 

禁用特定消息

Nim 编译器会产生一些警告和提示消息。如果它们惹恼了你，编译器也为此提供了一个开启、关闭特定消息的方法：

```nim
{.hint[LineTooLong]: off.}  # 关闭 "too long lines" 提示
```
通常，这比一下子关闭所有警告更好。

### {.experimental.}

用来开启某些语言特征。这个标记主要是为了考虑增加语言的稳定性，以及还未确定的语言特征（以后没准会移除）。
例子：

```nim
{.experimental.}

proc useUsing(dest: var string) =
    using dest
    add "foo"
    add "bar"
```

