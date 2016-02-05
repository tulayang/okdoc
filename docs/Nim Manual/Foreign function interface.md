# [Foreign function interface](http://nim-lang.org/docs/manual.html#foreign-function-interface)

Nim 的外部函数接口非常庞大，这里只是描述了一小部分。

## {.importc.}

表示导入一个 C 语言的函数或者变量。其参数是可选的，应该是一个 C 语言标识符字符串（如果有的话）。如果没有设定参数，对应的 C 语言名字恰好是 Nim 语言标识符的名字：

```nim
proc printf(formatstr: cstring) {.header: "<stdio.h", importc: "printf", varargs.}
```

## {.exportc.}

表示导出一个类型、变量或者函数给 C 语言。枚举和常量不能够被导出。其参数是可选的，应该是一个 C 语言标识符字符串（如果有的话）。如果没有设定参数，对应的 C 语言名字恰好是 Nim 语言标识符的名字：

```nim
proc callme(formatstr: cstring) {.exportc: "callMe", varargs.}
```

## {.extern.}

格式化字符串字面值：

```nim
proc p(s: string) {.extern: "prefix$1".} =
    echo s
```
例子中的 `p` 被设为 `prefixp`。

## {.bycopy.}

可以应用到元组和对象类型，指示编译器对于函数中该类型的形参，为其传递实参的时候，采用按值传递：

```nim
type
    Vector {.bycopy, pure.} = object
        x, y, z: float
```

## {.byref.}

可以应用到元组和对象类型，指示编译器对于函数中该类型的形参，为其传递实参的时候，采用按引用（隐式指针）传递。

## {.varargs.}

只能应用到函数（和函数类型）。指示编译器函数可以把最后指定的形参设定成一些数量可变的参数。

例子，Nim 语言的字符串值会被自动转换为 C 语言的字符串：

```nim
proc printf(formatstr: cstring) {.nodecl, varargs.}

printf("hallo %s", "world")  # "world" 会被解析为 C 语言的字符串
```

## {.union.}

可以应用到任何对象类型。表示所有的对象字段在内存中是重叠的。这个标记生成一个 C/C++ 语言代码的一个 `union` （而不是 `struct`）。对象声明必须没有继承，也不能使用任何 GC 内存。

未来方向：GC 内存应该允许被 union 使用，并且 GC 应该适当地扫描 union。

## {.packed.}

可以应用到任何对象类型。确保所有的对象字段在内存中是一个接着一个。对于存储网络数据包或者消息、硬件驱动以及和 C 语言的交互是很有帮助的。对 `{.packed.}` 标记的对象使用继承是未定义的，并且它不应该使用任何 GC 内存。

未来方向：在 `{.packed.}` 使用 GC 内存会产生编译期错误。使用继承应该是已定义的并且被记录。 

## {.unchecked.}

标记一个命名数组为 unchecked，表示不执行边界检查。对于实现自定义的灵活长度尺寸的数组是有用的。此外，为边界检查的数组被翻译为 C 语言的未指定长度的数组：

```nim
type
    ArrayPart{.unchecked.} = array[0..0, int]
    MySeq = object
        len, cap: int
        data: ArrayPart
```
大致生成 C 语言代码：

```c
typedef struct {
    NI len;
    NI cap;
    NI data[];
} MySeq;
```

这个不执行边界检查的数组的基类性，不能包含 GC 内存，不过当前这并不会被检查。

未来方向：GC 内存应该允许在不检查数组，应该有一个显式的注解 GC 内存如何确定运行期的数组尺寸。

## {.dynlib.}

标记一个函数或者变量，表示从一个动态库导入（Windows 是 .dll 文件，UNIX 是 lib*.so 文件）。参数必须是动态库的名字：

```nim
proc gtk_image_new(): PGtkWidget
    {.cdecl, dynlib: "libgtk-x11-2.0.so", importc.}
```

通常，导入一个动态库不需要任何特定链接器选项或者链接导入的库。这也暗示没有开发包会被安装。

这个导入机制支持版本控制：

```nim
proc Tcl_Eval(interp: pTcl_Interp, script: cstring): int {.cdecl,
    importc, dynlib: "libtcl(|8.5|8.4|8.3).so.(1|0)".}
```

在运行期这个动态库被查找（按照顺序）：

```nim
libtcl.so.1
libtcl.so.0
libtcl8.5.so.1
libtcl8.5.so.0
libtcl8.4.so.1
libtcl8.4.so.0
libtcl8.3.so.1
libtcl8.3.so.0
```

不仅支持常量字符串作为参数，还支持字符串表达式：

```nim
import os

proc getDllName: string =
    result = "mylib.dll"
    if existsFile(result): return
    result = "mylib2.dll"
    if existsFile(result): return
    quit("could not load dynamic library")

proc myImport(s: cstring) {.cdecl, importc, dynlib: getDllName().}
```

注意：`libtcl(|8.5|8.4).so` 模式只支持字符串常量，因为它们是预编译的。

注意：Passing variables to the dynlib pragma will fail at runtime because of order of initialization problems.。

注意：可以使用 `--dynlibOverride:name` 命令项重写 `{.dynlib.}` 语法标记。

## {.dynlib.} 与导出

也可以把一个函数导出到一个动态库。这时候该语法标记没有参数：

```nim
proc exportme(): int {.cdecl, exportc, dynlib.}
```

如果通过命令项 `--app:lib` 作为一个动态库编译时很有帮助。