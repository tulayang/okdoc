# [项重写宏](http://nim-lang.org/docs/manual.html#term-rewriting-macros)

项重写宏是宏或者模板，它不只有名字，还有模式。编译器执行语法检查后，能搜索到它的模式。也就是说，它提供了一个简单的方案，可以利用用户定义的优化，来增强编译。

```nim
template optMul{`*`(a, 2)}(a: int): int = a + a

let x = 3
echo x * 2
```

编译器现在把 `x * 2` 重写为 `x + x` 。`{}` 中的代码表示一个模式匹配。在模式中操作符 `*` `**` `|` `~` 有特殊的意义，f they are written in infix notation, so to match verbatim against * the ordinary function call syntax needs to be used.

不过优化很难准确地实施，甚至这个小例子也会错误:

```nim
template optMul{`*`(a, 2)}(a : int): int = a + a

var x = 1

proc f() : int =
    echo "side effect!"
    inc(x)
    result = 55

echo f() * 2  # "side effect!" "side effect!" 110
echo x        # 3
```

如果 `a` 表示一个有副作用的表达式，我们无法正确复制它！好在 Nim 语言支持副作用验证:

```nim
template optMul{`*`(a, 2)}(a : int{noSideEffect}): int = a + a

var x = 1

proc f() : int =
    echo "side effect!"
    inc(x)
    result = 55

echo f() * 2  # "side effect!" 110
echo x        # 2
```

那么 `2 * a` 会是什么情况？我们应该告诉编译器，`*` 是可交换的。然而我们无法那么做。像下面的代码只是单纯交换参数:

```nim
template mulIsCommutative{`*`(a, b)}(a, b: int): int = b * a
```

优化器真正需要的是规范化:

```nim
template canonMul{`*`(a, b)}(a: int{lit}, b: int): int = b * a
```

`int{lit}` 参数模式匹配一个 int 类型，但是只能是个字面值。

## 参数约束

参数约束表达式可以使用 `|` (or)，`&` (and)，`~` (not) 和下列的谓词:

谓词     |  描述
-|-
atom            | The matching node has no children.
lit             | The matching node is a literal like "abc", 12.
sym             | The matching node must be a symbol (a bound identifier).
ident           | The matching node must be an identifier (an unbound identifier).
call            | The matching AST must be a call/apply expression.
lvalue          | The matching AST must be an lvalue(左值).
sideeffect      | The matching AST must have a side effect.
nosideeffect    | The matching AST must have no side effect.
param           | A symbol which is a parameter.
genericparam    | A symbol which is a generic parameter.
module          | A symbol which is a module.
type            | A symbol which is a type.
var             | A symbol which is a variable.
let             | A symbol which is a let variable.
const           | A symbol which is a constant.
result          | The special result variable.
proc            | A symbol which is a proc.
method          | A symbol which is a method.
iterator        | A symbol which is an iterator(迭代器).
converter       | A symbol which is a converter.
macro           | A symbol which is a macro.
template        | A symbol which is a template.
field           | A symbol which is a field in a tuple(元组) or an object.
enumfield       | A symbol which is a field in an enumeration(列举).
forvar          | A for loop variable.
label           | A label (used in block statements).
nk*             | The matching AST must have the specified kind. (Example: nkIfStmt denotes an if statement.)
alias           | States that the marked parameter needs to alias with some other parameter.
noalias         | States that every other parameter must not alias with the marked parameter.

alias 和 noalias 谓词不止匹配 AST ，也匹配绑定参数，需要出现在普通 AST 谓词后面:

```nim
template ex{a = b + c}(a : int{noalias}, b, c : int) =
# this transformation is only valid if 'b' and 'c' do not alias 'a':
a = b
inc a, c
```

## 模式操作符

在模式中，操作符 `*` `**` `|` `~` 作为中缀时有特殊的作用。
* `|`
  创建一个顺序选择项:

```nim
template t{0|1}() : expr = 3
let a = 1
# outputs 3:
echo a
```

  编译器执行完一些优化后（像常量合并），才会执行匹配。所以下面的代码不能工作:

```nim
template t{0|1}(): expr = 3
# outputs 1:
echo 1
```

  这是因为编译器已经为 `echo` 语句把 `1` 转换为 `"1"` 。无论何时，一个项重写宏不应该以任何方式改变语义。不过可以通过 `--patterns:off` 命令行选项或者 `{.patterns.}` 使此限制变得无效。

* `{}`
  模式表达式能够通过 `expr{param}` 绑定到一个模式参数:

```nim
template t{(0|1|2){x}}(x : expr) : expr = x + 1
let a = 1
# outputs 2:
echo a
```

* `~`
  在模式中表示 `not` 操作符：

```nim
template t{x = (~x){y} and (~x){z}}(x, y, z : bool) : stmt =
    x = y
    if x : x = z

var
    a = false
    b = true
    c = false
a = b and c
echo a
```

* `*`
  用于转换嵌套的二元表达式，比如 a & b & c 转为 &(a, b, c):

```nim
var
    calls = 0

proc `&&`(s: varargs[string]): string =
    result = s[0]
    for i in 1..len(s)-1: result.add s[i]
    inc calls

template optConc{ `&&` * a }(a: string): expr = &&a

let space = " "
echo "my" && (space & "awe" && "some " ) && "concat"

# check that it's been optimized properly:
doAssert calls == 1      
```

 The second operator of * must be a parameter; it is used to gather all the arguments. The expression "my" && (space & "awe" && "some " ) && "concat" is passed to optConc in a as a special list (of kind nkArgList) which is flattened into a call expression; thus the invocation of optConc produces:

```nim
`&&`("my", space & "awe", "some ", "concat")
```

* `**`
  The ** is much like the * operator, except that it gathers not only all the arguments, but also the matched operators in reverse polish notation:

```nim
import macros

type
    Matrix = object
        dummy: int

proc `*`(a, b: Matrix): Matrix = discard
proc `+`(a, b: Matrix): Matrix = discard
proc `-`(a, b: Matrix): Matrix = discard
proc `$`(a: Matrix): string = result = $a.dummy
proc mat21(): Matrix =
    result.dummy = 21

macro optM{ (`+`|`-`|`*`) ** a }(a: Matrix): expr =
    echo treeRepr(a)
    result = newCall(bindSym"mat21")

var x, y, z: Matrix

echo x + y * z - x
```
  This passes the expression `x + y * z - x` to the `optM` macro as an `nnkArgList` node containing:

```nim
Arglist
    Sym "x"
    Sym "y"
    Sym "z"
    Sym "*"
    Sym "+"
    Sym "x"
    Sym "-"
```
  (Which is the reverse polish notation of x + y * z - x.)

## 参数

模式中的参数在匹配过程中会进行类型检查。如果一个参数是 `varargs` ，可以匹配多个 AST 实参。

```nim
template optWrite{
    write(f, x)
    ((write|writeln){w})(f, y)
}(x, y : varargs[expr], f : File, w : expr) =
    w(f, x, y)
```

## 例子： partial evaluation


```nim
proc p(x, y : int; cond : bool) : int =
    result = if cond: x + y else: x - y

template optP1{p(x, y, true)} (x, y : expr) : expr = x + y
template optP2{p(x, y, false)}(x, y : expr) : expr = x - y
```

## 例子: Hoisting


```nim
import pegs

template optPeg{peg(pattern)}(pattern : string{lit}) : Peg =
    var gl {.global, gensym.} = peg(pattern)
    gl

for i in 0 .. 3 :
    echo match("(a b c)", peg"'(' @ ')'")
    echo match("W_HI_Le", peg"\y 'while'")
```

The optPeg template optimizes the case of a peg constructor with a string literal, so that the pattern will only be parsed once at program startup and stored in a global gl which is then re-used. This optimization is called hoisting because it is comparable to classical loop hoisting.