# [模块](http://nim-lang.org/docs/manual.html#modules)

Nim 语言支持模块的概念：把一个程序拆分成多个部分。每个模块需要放入一个独立的文件，有自己的命名空间。模块启用信息隐藏和独立编译。在一个模块中可以导入另一个模块的符号，获得访问权限。递归的模块依赖是允许的，但是有一些细微的变化。只有使用 `*` 标记的顶层符号被导出。有效的模块名必须是有效的标识符，模块文件名就是 `identifier.nim`。

编译模块的算法：

* 通常逐个编译 `import` 语句后面的整个模块
* 如果存在循环，只会导入已经解析完成的符号（那些可导出的），如果出现一个未知的标识符就中止

举例如下：

```nim
# 模块 A
type
    T1* = int  # 模块 A 导出类型 ``T1``
import B       # 编译器开始解析 B

proc main() =
    var i = p(3) # 可以工作，因为对 B 的解析已经完成

main()
```

<span>

```nim
# 模块 B
import A  # A 在这里不会被解析！只会导入已经可知的符号 A。

proc p*(x: A.T1): A.T1 =
    # 可以工作，因为编译器已经把 T1 加入到 A 接口的符号表
    result = x + 1
```

## import 语句

`import` 语句之后是一个模块名列表。模块名后面可以跟随一个 `except` 列表，来禁止导入一些符号：

```nim
import strutils except `%`, toUpper

# 不能工作：
echo "$1" % "abc".toUpper
```

不会检查 `except` 列表是否已经在模块中导出。

## include 语句

`include` 语句和导入模块是两码事，它只是导入一个文件的内容。`include` 语句常用来把一个大的模块划分成多个文件：

```nim
include fileA, fileB, fileC
```

## 导入的模块名

导入模块时，可以使用 `as` 关键字为模块名起一个别名：

```nim
import strutils as su, sequtils as qu

echo su.format("$1", "lalelu")
```

然后原始的模块名就是不可理解的。可以使用 `path/to/module`、`path.to.module` 或者 `"path/to/module"` 这样的写法，来关联位于子目录的模块：

```nim
import lib.pure.strutils, lib/pure/os, "lib/pure/times"
```

在这种写法中，模块名仍然是 `strutils` 而不是 `lib.pure.strutils`：

```nim
import lib.pure.strutils
echo lib.pure.strutils
```

像下面这样起的别名意义不大，因为模块的名字本来就是 `strutils`：

```nim
import lib.pure.strutils as strutils
```

## from import 语句

`from` 语句后跟随一个模块名，之后再跟随一个 `import` 符号列表，可以只导入需要的符号：

```nim
from strutils import `%`

echo "$1" % "abc"
# 总是有效：命名空间条件：
echo strutils.replace("abc", "a", "z")
```
 
`from module import nil` 是可以的，当只想导入模块但是不想访问模块的任何符号时使用。

## export 语句

`export` 语句可以用来符号代理，这样客户模块就不需要导入一个模块的依赖：

```nim
# 模块 B
type MyObject* = object
```

<span>

```nim
# 模块 A
import B
export B.MyObject

proc `$`*(x: MyObject): string = "my object"
```

<span>

```nim
# 模块 C
import A

# B.MyObject 已经被隐式地导入：
var x: MyObject
echo($x)
```

## 路径名的问题

如果在模块名中 `/` 后以数字开始，那么必须用双引号包裹（转义）模块名。比如：

```nim
import "gfx/3d/somemodule"
```

## 作用域规则

标识符是有效的：从它们声明的地方开始，直到声明块结束。标识符可知的范围称为标识符的作用域。一个标识符的作用域依赖它声明的方式。

## 块作用域

在一个块内声明的变量的有效作用域是：从声明开始的地方，直到块结束。如果块内包含了第 2 个块，在其内该标识符被重新声明，在这个块中，第 2 次声明是有效的。一个标识符不允许在同一块被重新定义，除了函数或者迭代器重载。

## 元组、对象作用域

在元组、对象定义的字段，其在以下情况是有效的：

* 定义语句块之内
* Field designators of a variable of the given tuple/object type
* 对象类型的所有子孙类型

## 模块作用域

一个模块的所有标识符是有效的，从声明开始直到模块尾部。来自间接依赖的模块的标识符是无效的。system 模块会被自动导入到每个模块。

如果一个模块导入了两个不同的模块，它们定义了同样的一个标识符，该标识符只能是函数、迭代器重载，此时会发生重载解析：

```nim
# 模块 A
var x*: string
```

<span>

```nim
# 模块 B
var x*: int
```
 
<span>

```nim
# 模块 C
import A, B
write(stdout, x) # error: x is ambiguous
write(stdout, A.x) # no error: qualifier used

var x = 4
write(stdout, x) # not ambiguous: uses the module C's x
```