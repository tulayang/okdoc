# [效应系统](http://nim-lang.org/docs/manual.html#effect-system)

### 异常追踪 

Nim 语言支持异常追踪。语法标记 `{.raises.}`，可以显式地在定义函数、迭代器、“多方法”、转换器时，为它们指定允许引发哪些异常。编译器是这样验证的:

```nim
proc p(what: bool) {.raises : [IOError, OSError].} =
    if what: raise newException(IOError, "IO")
    else: raise newException(OSError, "OS")
```

一个空的异常列表 `raises: []`，表示不会引发异常：

```nim
proc p(): bool {.raises: [].} =
  try:
      unsafeCall()
      result = true
  except:
      result = false
```

异常列表也可以附加到函数类型上，这同时影响类型的兼容性:

```nim
type
    Callback = proc (x : string) {.raises : [IOError].}
var
    c: Callback

proc p(x : string) =
    raise newException(OSError, "OS")

c = p  # 类型错误！
```

对于例程 `p`，编译器会推导其所能引发的异常集合，算法规则如下：

1. Every indirect call via some proc type T is assumed to raise system.Exception (the base type of the exception hierarchy) and thus any exception unless T has an explicit raises list. However if the call is of the form f(...) where f is a parameter of the currently analysed routine it is ignored. The call is optimistically assumed to have no effect. Rule 2 compensates for this case.

2. Every expression of some proc type within a call that is not a call itself (and not nil) is assumed to be called indirectly somehow and thus its raises list is added to p's raises list.
    
3. Every call to a proc q which has an unknown body (due to a forward declaration or an importc pragma) is assumed to raise system.Exception unless q has an explicit raises list.
    
4. Every call to a method m is assumed to raise system.Exception unless m has an explicit raises list.
    
5. For every other call the analysis can determine an exact raises list.

6. For determining a raises list, the raise and try statements of p are taken into consideration.

Rules 1-2 ensure the following works:

```nim
proc noRaise(x: proc()) {.raises: [].} =
    # 未知调用，可能引发任何异常，不过是有效的：
    x()

proc doRaise() {.raises: [IOError].} =
    raise newException(IOError, "IO")

proc use() {.raises: [].} =
    # 不能编译！引发 IOError ！
    noRaise(doRaise)
```

So in many cases a callback does not cause the compiler to be overly conservative in its effect analysis.

*译：谁能告诉我，这到底在说啥？*

### 标签追踪

异常追踪是 Nim 语言效应系统的一部分。引发一个异常，即是一个“效应”。还可以定义其他的“效应”。用户定义“效应”，是给例程打上一个标签，然后针对此标签进行检查：

```nim
type IO = object  ## input/output 效应
proc readLine() : string {.tags : [IO].}

proc no_IO_please() {.tags : [].} =
    # 编译器阻止：
    let x = readLine()
```

一个标签，必须是一个类型的名字。一个标签列表类似一个异常列表，也能附加到函数类型上，同时影响类型的兼容。

对标签追踪的推导，类似推导异常追踪。

### 读写追踪

注意：读写追踪还没有实现！

### 效应语法标记

语法标记 `{.effects.}`，用来帮助程序员进行效应分析。它是一个语句，使编译器在该位置输出所有推导出来的“效应”:

```nim
proc p(what: bool) =
    if what:
        raise newException(IOError, "IO")
        {.effects.}
    else:
        raise newException(OSError, "OS")
```

编译器产生一条 hint 消息：“IOError 可以被引发”。OSError 没有被列出，因为在 `{.effects.}` 出现的分支上，它无法抛出。
