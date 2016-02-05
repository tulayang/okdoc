# [基于 AST 的重载](http://nim-lang.org/docs/manual.html#ast-based-overloading)

## 参数约束

“参数约束”，也可以用作普通例程的形参，这些约束影响并限制普通的重载解析:

```nim
proc optLit(a : string{lit|`const`}) =
    echo "string literal"
proc optLit(a : string) =
    echo "no string literal"

const
    constant = "abc"

var
    variable = "xyz"

optLit("literal")
optLit(constant)
optLit(variable)
```

然而，约束 `alias` 和 `noalias` 在普通例程中无效。

## Move 优化

约束 `call` 对于实现类型的 move 优化特别有用处，它们是复制语义的：

```nim
proc `[]=`*(t : var Table, key : string, val : string) =
    ## 把一对 (key, value) 放入 `t`。字符串的语法要求采用复制：
    let idx = findInsertionPosition(key)
    t[idx] = key
    t[idx] = val

proc `[]=`*(t : var Table, key : string{call}, val : string{call}) =
    ## 把一对 (key, value) 放入 `t`。优化版本知道：字符串是唯一的，因此不需要采用复制：
    let idx = findInsertionPosition(key)
    shallowCopy t[idx], key
    shallowCopy t[idx], val

var t: Table
# 在这儿，“重载解析”会确保调用优化版本的  []=：
t[f()] = g()
```

