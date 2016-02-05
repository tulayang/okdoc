# [实现特定的语法标记](http://nim-lang.org/docs/manual.html#implementation-specific-pragmas)

这一章节描述了追加的语法标记，当前的 Nim 语言实现支持但是不应该将其作为语言规范的一部分。

## 基本的语法标记

### {.bitsize.}

标记对象的字段成员。把字段声明为一个 C/C++ 语言的比特字段：

```nim
type
    mybitfield = object
        flag {.bitsize:1.}: cuint
```
生成：
```nim
struct mybitfield {
    unsigned int flag:1;
};
```

### {.volatile.}

只对变量有效。把变量声明一个 C/C++ 语言的 volatile。

注意：这个语法标记在 LLVM 端不存在。

### {.noDecl.}

可以被应用到几乎任何符号（变量、函数、类型、等等），有时与 C 语言的互操作性很有帮助。它告诉 Nim 编译器，不对该符号在生成的 C 语言代码中生成一个声明。例如：

```nim
var
    EACCES {.importc, noDecl.}: cint  # 假定 EACCES 是一个变量，因为
                                      # Nim 不知道它的值
```
不管怎么样，`{.head.}` 语法标记通常比这个是更好的选择。

注意：这个语法标记在 LLVM 端不工作。

### {.header.}

非常类似 `{.noDel.}`，可以被应用到几乎任何符号，并且指定：不对在生成的 C 语言代码中生成一个声明，而是生成包含 `#include` 的代码：

```nim
type
    PFile {.importc: "FILE*", header: "<stdio.h".} = distinct pointer
        # 导入 C 语言的 FILE* 类型； Nim 会将其作为一个新的指针类型对待
```

`{.header.}` 总是期望一个字符串常量。字符串常量包含了 C 语言的头文件。

注意：这个语法标记在 LLVM 端不工作。

### {.incompleteStruct.}

指示编译器不在 `sizeof` 表达式使用潜在的 C 语言 `struct`：

```nim
type
    DIR* {.importc: "DIR", header: "<dirent.h",
           final, pure, incompleteStruct.} = object
```

### {.compile.}

用来为项目编译和链接一个 C/C++ 源文件：

```nim
{.compile: "myfile.cpp".}
```
注意：Nim 计算一个 SHA1 校验和，并且只重新编译已经改变的文件。你可以使用 `-f` 命令项，强制对文件重新编译。

### {.link.}

用来为链接一个附加的文件：

```nim
{.link: "myfile.o".}
```

### {.passC.}

用来向 C 语言编译器传递附加的参数，如同使用 `--passC` 命令项完成这个功能：

```nim
{.passC: "-Wall -Werror".}
```
注意：你可以对 system 模块使用 `gorge` 把一些扩展命令嵌入参数：

```nim
{.passC: gorge("pkg-config --cflags sdl").}
```

### {.passL.}

用来向链接器传递附加的参数，如同使用 `--passL` 命令项完成这个功能：

```nim
{.passL: "-lSDLmain -lSDL".}
```
注意：你可以对 system 模块使用 `gorge` 把一些扩展命令嵌入参数：

```nim
{.passL: gorge("pkg-config --libs sdl").}
```

### {.emit.}

用来直接影响编译器的代码生成器的输出。因此，它可能会使你的代码变得不可移植。不过，它对于和 C++ 或者 Object-C 接口编程很有帮助。

例子：

```nim
{.emit: """
static int cvariable = 420;
""".}

{.push stackTrace:off.}
proc embedsC() =
    var nimVar = 89
    # use backticks to access Nim symbols within an emit section:
    {.emit: """fprintf(stdout, "%d\n", cvariable + (int)`nimVar`);""".}
{.pop.}

embedsC()
```

如同例子所示，Nim 语言的符号可以通过引号被关联。

For a toplevel emit statement the section where in the generated C/C++ file the code should be emitted can be influenced via the prefixes /*TYPESECTION*/ or /*VARSECTION*/ or /*INCLUDESECTION*/:

```nim
```

### {.noDecl.}



```nim
{.emit: """/*TYPESECTION*/
struct Vector3 {
public:
    Vector3(): x(5) {}
    Vector3(float x_): x(x_) {}
    float x;
};
""".}

type Vector3 {.importcpp: "Vector3", nodecl} = object
    x: cfloat

proc constructVector3(a: cfloat): Vector3 {.importcpp: "Vector3(@)", nodecl}
```

### {.importcpp.}

注意：[c2nim](http://nim-lang.org/docs/c2nim.html) 可以解析一个大的 C++ 语言的子集，并且知道 `importcpp`。

类似 `{.importc.}`，`{.importcpp.}` 用来导入 C++ 语言的方法或者符号。生成的代码使用 C++ 语言方法调用语法：`obj-method(arg)` 。借助 `{.header.}` 和 `{.emit.}`，允许和 C++ 语言写的库交互：

```nim
# 好可怕的例子，不过演示了如何和  C++ 引擎进行接口编程 ... ;-)

{.link: "/usr/lib/libIrrlicht.so".}

{.emit: """
using namespace irr;
using namespace core;
using namespace scene;
using namespace video;
using namespace io;
using namespace gui;
""".}

const
    irr = "<irrlicht/irrlicht.h"

type
    IrrlichtDeviceObj {.final, header: irr,
                        importcpp: "IrrlichtDevice".} = object
    IrrlichtDevice = ptr IrrlichtDeviceObj

proc createDevice(): IrrlichtDevice {.
  header: irr, importcpp: "createDevice(@)".}
proc run(device: IrrlichtDevice): bool {.
  header: irr, importcpp: "#.run(@)".}
```

要让它工作，还需要告诉编译器生成 C++ 代码（使用命令项 `cpp`）。   

###

## 命名空间

这个例子使用了 `{.emit.}` 来生成 `using namespace` 声明。使用 `namespace::identifier` 是一个更好的方案：

```nim
type
    IrrlichtDeviceObj {.final, header: irr,
                        importcpp: "irr::IrrlichtDevice".} = object
```

### {.importcpp.} 与枚举

当 `{.importcpp.}` 应用到一个枚举类型时，数字枚举值需要使用 C++ 语言的枚举类型注解：比如 ` ((TheCppEnum)(3))`。（许多结果证明，这样做是最简单的实现方式。）

```nim

### {.importcpp.} 与函数

注意 `{.importcpp.}` 应用到一个函数时，采用一个奇特的变体：

例子：

```nim
proc cppMethod(this: CppObj, a, b, c: cint) {.importcpp: "#.CppMethod(@)".}
var x: ptr CppObj
cppMethod(x[], 1, 2, 3)
```
生成：

```nim
x-CppMethod(1, 2, 3)
```

As a special rule to keep backwards compatibility(兼容性) with older versions of the importcpp pragma, if there is no special pattern character (any of # ' @) at all, C++'s dot or arrow notation is assumed, 上面的例子可以写作：

```nim
proc cppMethod(this: CppObj, a, b, c: cint) {.importcpp: "CppMethod".}
```

注意，这种模式语言也可以涵盖 C++ 操作符的重载能力：

```nim
proc vectorAddition(a, b: Vec3): Vec3 {.importcpp: "# + #".}
proc dictLookup(a: Dict, k: Key): Value {.importcpp: "#[#]".}
```

An apostrophe(撇号) ' followed by an integer i in the range 0..9 is replaced by the i'th parameter type. The 0th position is the result type. This can be used to pass types to C++ function templates. Between the ' and the digit(数字) an asterisk(星号) can be used to get to the base type of the type.(So it "takes away a star" from the type; T* becomes T.) Two stars can be used to get to the element type of the element type etc.

例子：

```nim
type Input {.importcpp: "System::Input".} = object
proc getSubsystem*[T](): ptr T {.importcpp: "SystemManager::getSubsystem<'*0()", nodecl.}

let x: ptr Input = getSubsystem[Input]()
```

生成：

```nim
x = SystemManager::getSubsystem<System::Input()
```

`#@` is a special case to support a `cnew` operation. It is required so that the call expression is inlined directly, without going through a temporary location. This is only required to circumvent(包围) a limitation of the current code generator.

例子：

```nim
proc cnew*[T](x: T): ptr T {.importcpp: "(new '*0#@)", nodecl.}

# 'Foo' 构造器：
proc constructFoo(a, b: cint): Foo {.importcpp: "Foo(@)".}

let x = cnew constructFoo(3, 4)
```

生成：

```nim
x = new Foo(3, 4)
```

不管怎么样，依赖 `new Foo` 的使用可以包装成：

```nim
proc newFoo(a, b: cint): ptr Foo {.importcpp: "new Foo(@)".}

let x = newFoo(3, 4)
```

### 

## 包装构造器

Since Nim generates C++ directly, any destructor(破坏者) is called implicitly(含蓄地) by the C++ compiler at the scope exits. This means that often one can get away with not wrapping the destructor at all! However when it needs to be invoked explicitly, it needs to be wrapped. But the pattern language already provides everything that is required for that:

```nim
# a better constructor of 'Foo':
proc constructFoo(a, b: cint): Foo {.importcpp: "Foo(@)", constructor.}
```

## 包装解构器

Since Nim generates C++ directly, any destructor(破坏者) is called implicitly(含蓄地) by the C++ compiler at the scope exits. This means that often one can get away with not wrapping the destructor at all! However when it needs to be invoked explicitly, it needs to be wrapped. But the pattern language already provides everything that is required for that:

```nim
proc destroyFoo(this: var Foo) {.importcpp: "#.~Foo()".}
```

### {.importcpp.} 与对象

Generic importcpp'ed objects are mapped to C++ templates. This means that you can import C++'s templates rather easily without the need for a pattern language for object types:

```nim
type
    StdMap {.importcpp: "std::map", header: "<map".} [K, V] = object
proc `[]=`[K, V](this: var StdMap[K, V]; key: K; val: V) {.
    importcpp: "#[#] = #", header: "<map".}

var x: StdMap[cint, cdouble]
x[6] = 91.4
```

生成：
```nim
std::map<int, doublex;
x[6] = 91.4;
```

If more precise control is needed, the apostrophe(省略符号) ' can be used in the supplied pattern to denote(表示) the concrete type parameters of the generic type. See the usage of the apostrophe operator in proc patterns for more details.

```nim
type
    VectorIterator {.importcpp: "std::vector<'0::iterator".} [T] = object

var x: VectorIterator[cint]
```

生成：
```nim
std::vector<int::iterator x;
```

### {.importObjC.}

类似 `{.importc.}` 之于 C 语言，`{.importObjC.}` 可以导入 Object-C 语言的方法。生成的代码使用 Object-C 方法调用语法：`[obj method param1: arg]`。借助 `{.header.}` 和 `{.emit.}`，允许和 Object-C 语言写的库交互：

```nim
# 好可怕的例子，不过演示了如何和  GNUStep 进行接口编程 ...

{.passL: "-lobjc".}
{.emit: """
#include <objc/Object.h
@interface Greeter:Object
{
}

- (void)greet:(long)x y:(long)dummy;
@end

#include <stdio.h
@implementation Greeter

- (void)greet:(long)x y:(long)dummy
{
    printf("Hello, World!\n");
}
@end

#include <stdlib.h
""".}

type
    Id {.importc: "id", header: "<objc/Object.h", final.} = distinct int

proc newGreeter: Id {.importobjc: "Greeter new", nodecl.}
proc greet(self: Id, x, y: int) {.importobjc: "greet", nodecl.}
proc free(self: Id) {.importobjc: "free", nodecl.}

var g = newGreeter()
g.greet(12, 34)
g.free()
```

要让它工作，还需要告诉编译器生成 Object-C 代码（使用命令项 `objc`）。

### {.codegenDecl.}

直接影响 Nim 的代码生成器。它接受一个格式化的字符串，字符串确定变量或者函数如何声明在生成的代码：

```nim
var
    a {.codegenDecl: "$# progmem $#".}: int

proc myinterrupt() {.codegenDecl: "__interrupt $# $#$#".} =
    echo "realistic interrupt handler"
```

### {.injectStmt.}

用于在当前模块的每个其他语句注入一条语句。它只应该被用于调试：

```nim
{.injectStmt: gcInvariants().}

# ... complex code here that produces crashes ...
```

###