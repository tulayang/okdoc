# [特殊类型](http://nim-lang.org/docs/manual.html#special-types)

### static[T]

注意: static[T] 仍在开发中。

如同名字所暗示的，必须在编译期知道静态参数：
```nim
proc precompiledRegex(pattern: static[string]): RegEx =
    var res {.global.} = re(pattern)
    return res

precompiledRegex("/d+") 　# 传入一个正则表达式，将其存储在一个全局变量中

precompiledRegex(paramStr(1))  # 错误，在编译期无法获得
```

For the 目的 of code 生成, all static params are treated as generic params - the proc will be compiled separately for each unique supplied value (or combination of values).

静态参数也能出现在泛型类型的名称中：

```nim
type
    Matrix[M,N: static[int]; T: Number] = array[0..(M*N - 1), T]
      # Note how `Number` is just a type constraint here, while
      # `static[int]` requires us to supply a compile-time int value
  
    AffineTransform2D[T] = Matrix[3, 3, T]
    AffineTransform3D[T] = Matrix[4, 4, T]

var m1: AffineTransform3D[float]   # OK
var m2: AffineTransform2D[string]  # Error, `string` is not a `Number`
```

### typedesc

`typedesc` 是一个特殊的类型，允许把类型作为一个编译期的值。（i.e. if types are compile-time values and all values have a type, then typedesc must be their type）。

当用作一个函数的常规参数时，`typedesc` 表现为一个类类型。The proc will be instantiated for each unique type parameter and one can refer to the instantiation type using the param name：

```nim
proc new(T: typedesc): ref T =
    echo "allocating ", T.name
    new(result)

var n = Node.new
var tree = new(BinaryTree[int])
```
当出现多个 `typedesc` 参数时，它们表现为一个 distinct 类类型（它们会自由地绑定不同类型）。To force a bind-once behavior one can use a named alias or an explicit typedesc generic param:

```nim
proc acceptOnlyTypePairs[T: typedesc, U: typedesc](A,B: T; C,D: U)  
```

Once bound, typedesc params can appear in the rest of the proc signature:

```nim
template declareVariableWithType(T: typedesc, value: T) =
    var x: T = value

declareVariableWithType(int, 42)
```

当用于宏和 `{.compileTime.}` 标记的函数时，编译器不需要多次实例化代码，because types then can be manipulated using the unified internal symbol representation。在这样的场景下，`typedesc` 表现为其它的任意类型。可以创建变量，在容器中存储 `typedesc` 值，等等。例如，这里演示了一个如何为 C 语言的“不安全的” `printf` 函数创建一个“类型安全的”包装器：

```nim
macro safePrintF(formatString: string{lit}, args: varargs[expr]): expr =
    var i = 0
    for c in formatChars(formatString):
        var expectedType = case c
            of 'c': char
            of 'd', 'i', 'x', 'X': int
            of 'f', 'e', 'E', 'g', 'G': float
            of 's': string
            of 'p': pointer
            else: EOutOfRange
       
      var actualType = args[i].getType
      inc i
     
      if expectedType == EOutOfRange:
          error c & " is not a valid format character"
      elif expectedType != actualType:
         error "type mismatch for argument ", i, ". expected type: ",
               expectedType.name, ", actual type: ", actualType.name

# keep the original callsite, but use cprintf instead
result = callsite()
result[0] = newIdentNode(!"cprintf")
```

通过下面的 `typedesc` 语法限制类型集合，重载分析会受到更深层的影响：
```nim
template maxval(T: typedesc[int]): int = high(int)
template maxval(T: typedesc[float]): float = Inf  

var i = int.maxval
var f = float.maxval
var s = string.maxval  # Error, maxval is not implemented for string
```

约束可以是 a concrete type or a type class。
