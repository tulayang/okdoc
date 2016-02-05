
# [宏](http://nim-lang.org/docs/manual.html#macros)

宏是一种特殊的底层的模板。宏可以用来实现领域特定语言。和模板相似，宏也有两种：“普通的”和“直接的”。

当宏启用高级编译期代码转换时，它们并不改变 Nim 语言的语法。然而，真的，Nim 语言的语法已经足够灵活了。

编写宏，需要知道 Nim 语言如何把具体的语法转换成抽象语法树。

有两种方式调用宏：

1. 像函数一样调用（表达式宏）
2. 使用特殊的 `macrostmt` 语法（语句宏）

## 表达式宏

下面的例子，实现了一个强力的 `debug` 命令：

```nim
# 要使 Nim 语法树工作，我们需要导入定义在 macros 模块的 API：
import macros

macro debug(n: varargs[expr]) : stmt =
      # `n` 是一个 Nim 语言的抽象语法树，它包含完整的宏调用
      # 这个宏返回一个语句列表：
      result = newNimNode(nnkStmtList, n)
      # 迭代传递给这个宏的每个参数：
      for i in 0..n.len-1:
            # 添加一个 call 语句到语句列表
            # `toStrLit` 把一个 AST （抽象语法树） 转换成字符串形式：
            add(result, newCall("write", newIdentNode("stdout"), toStrLit(n[i])))
            # 添加一个 call 语句到语句列表
            add(result, newCall("write", newIdentNode("stdout"), newStrLitNode(": ")))
            # 添加一个 call 语句到语句列表
            add(result, newCall("writeln", newIdentNode("stdout"), n[i]))

var
    a: array [0..10, int]
    x = "some string"
a[0] = 42
a[1] = 45

debug(a[0], a[1], x)
```

这个宏调用被展开为（预编译替换后）：

```nim
    write(stdout, "a[0]")
    write(stdout, ": ")
    writeln(stdout, a[0])

    write(stdout, "a[1]")
    write(stdout, ": ")
    writeln(stdout, a[1])

    write(stdout, "x")
    write(stdout, ": ")
    writeln(stdout, x)
```

实参被传递给一个 `varargs` 参数，所以 `debug` 可以迭代所有 `n` 的子项。

## bindSym

上面的 `debug` 宏依赖这样一个事实：`write` `writeLine` `stdout` 已经在 system 模块中声明，从而在实例化环境中它们是可见的。提供一种方法，可以用绑定的标识符（符号）替代未绑定的标识符。通过内置 `bindSym()` 可以完成这个工作：

```nim
import macros

macro debug(n : varargs[expr]) : stmt =
    result = newNimNode(nnkStmtList, n)
    for i in 0..n.len-1:
        # 我们可以通过 'bindSym' 在作用域内绑定符号：
        add(result, newCall(bindSym"write", bindSym"stdout", toStrLit(n[i])))
        add(result, newCall(bindSym"write", bindSym"stdout", newStrLitNode(": ")))
        add(result, newCall(bindSym"writeLine", bindSym"stdout", n[i]))

var
    a : array [0..10, int]
    x = "some string"
a[0] = 42
a[1] = 45

debug(a[0], a[1], x)
```

这个宏调用展开为：

```nim
write(stdout, "a[0]")
write(stdout, ": ")
writeLine(stdout, a[0])

write(stdout, "a[1]")
write(stdout, ": ")
writeLine(stdout, a[1])

write(stdout, "x")
write(stdout, ": ")
writeLine(stdout, x)
```

然而在这里，符号 `write` `writeLine` `stdout` 已经绑定，并且不会再次（在实例化时）查找。如同例子所示，`bindSym` 隐式地利用重载符号来工作。

## 语句宏

语句宏的定义类似表达式宏。然而，它们是由一个表达式跟随一个冒号来调用。

下面例子中的宏，从正则表达式生成一个词法分析器：

```nim
import macros

macro case_token(n : stmt) : stmt =
    # 从正则表达式创建一个词法分析器
    # ... (这个实现只是给读者的一个 练习 :-)
    discard

case_token:  # 这个冒号告诉解析器它是一个宏语句
of r"[A-Za-z_]+[A-Za-z_0-9]*":
    return tkIdentifier
of r"0-9+":
    return tkInteger
of r"[\+\-\*\?]+":
    return tkOperator
else:
    return tkUnknown    
```

风格提示：为了代码的可读性，最好尽可能少地使用这种强大的构造语法。所以：

1. 如果可能的话使用普通函数、迭代器
2. 否则：如果可能的话使用泛型函数、迭代器
3. 否则：如果可能的话使用模板
4. 否则：使用宏

## 宏作为语法标记

整个例程（函数、迭代器等等）也能传递给一个模板或者宏，其方法是通过语法标记：

```nim
template m(s: stmt) = discard

proc p() {.m.} = discard
```

这其实是个简单的语法转换：

```nim
template m(s : stmt) = discard

m:
    proc p() = discard
```