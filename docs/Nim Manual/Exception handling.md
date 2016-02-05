# [异常处理](http://nim-lang.org/docs/manual.html#exception-handling)

## 如何制造异常

### try 语句

例子：

```nim
# 读取一个文本文件的前两行，这两行应该包含数字，尝试对这些数字做加法
var
    f: File
if open(f, "numbers.txt"):
    try:
        var a = readLine(f)
        var b = readLine(f)
        echo("sum: " & $(parseInt(a) + parseInt(b)))
    except OverflowError:
        echo("overflow!")
    except ValueError:
        echo("could not convert string to integer")
    except IOError:
        echo("IO error!")
    except:
        echo("Unknown exception!")
    finally:
        close(f)
```

`try` 内的语句会顺序执行，除非引发一个异常。当引发异常时，如果该异常类型在后续 `except` 提供的异常参考列表中，就会转入该 `except` 并执行其对应的代码。`except` 子句也成为“异常处理器”。

如果找不到合适的 `except`，就会执行空的 `except`。类似 `if` 语句中的 `else` 。

如果有 `finally`，那么它在最后总是会执行。

异常发生在“异常处理器”中。然而，一个“异常处理器”可能会引发另一个异常。如果这个异常没有被处理，它会向上传播直到调用栈。

### try 表达式

`try` 可以作为表达式使用，`try` 分支的类型需要匹配 `except` 分支，但是 `finally` 分支总是 `void` 类型：

```nim
let x = try: parseInt("133a")
        except: -1
        finally: echo "hi"
```

语法解析有一个限制，以避免引发歧义：如果 `try` 在一个 `(` 内，它必须写作一行：

```nim
let x = (try: parseInt("133a") except: -1)
```

### except 字句

在 except 字句中，可以调用 `getCurrentException()` 获取当前引发的异常：

```nim
try:
    # ...
except IOError:
    let e = getCurrentException()
    # Now use "e"
```

注意，`getCurrentException()` 总是返回一个 `ref Exception` 类型。如果需要一个精确的异常类型（比如 `IOError`），最好对其显式转换：

```nim
try:
    # ...
except IOError:
    let e = (ref IOError)(getCurrentException())
    # "e" 现在是需要的类型
```

不过，很少需要这样做。最普遍的情况是从 `e` 提取错误消息，此时调用 `getCurrentExceptionMsg()` 就足够了：

```nim
try:
    # ...
except IOError:
    echo "I/O error: " & getCurrentExceptionMsg()
```

### defer 语句

可以使用 `defer` 语句来替代 `try finally` 语句。

任何跟随在 `defer` 后面并且和 `defer` 在同一个块的语句，会被隐式地改写成 `try` 块：

```nim
var f = open("numbers.txt")
defer: close(f)
f.write "abc"
f.write "def" 
```

被改写为：

```nim
var f = open("numbers.txt")
try:
    f.write "abc"
    f.write "def"
finally:
    close(f)
```

### raise 语句

例子：

```nim
raise newEOS("operating system failed")
```

如同数组索引、内存分配等等作为（编译器）内置操作体系的一部分，`raise` 语句是主动引发一个异常的唯一手段。

如果没有给出异常名字，则重新引发当前的异常。如果没有可以重新引发的异常，则引发 `ReraiseError` 异常。这确保 `raise` 语句总是会引发一个异常（除非已经提供了一个 raise 钩子）。

###

## 异常层级

在 system 模块中定义了异常树：

* [Exception](http://nim-lang.org/docs/system.html#Exception)
  * [AccessViolationError](http://nim-lang.org/docs/system.html#AccessViolationError)
  * [ArithmeticError](http://nim-lang.org/docs/system.html#ArithmeticError)
    * [DivByZeroError](http://nim-lang.org/docs/system.html#DivByZeroError)
    * [OverflowError](http://nim-lang.org/docs/system.html#OverflowError)
  * [AssertionError](http://nim-lang.org/docs/system.html#AssertionError)
  * [DeadThreadError](http://nim-lang.org/docs/system.html#DeadThreadError)
  * [FloatingPointError](http://nim-lang.org/docs/system.html#FloatingPointError)
    * [FloatDivByZeroError](http://nim-lang.org/docs/system.html#FloatDivByZeroError)
    * [FloatInexactError](http://nim-lang.org/docs/system.html#FloatInexactError)
    * [FloatInvalidOpError](http://nim-lang.org/docs/system.html#FloatInvalidOpError)
    * [FloatOverflowError](http://nim-lang.org/docs/system.html#FloatOverflowError)
    * [FloatUnderflowError](http://nim-lang.org/docs/system.html#FloatUnderflowError)
  * [FieldError](http://nim-lang.org/docs/system.html#FieldError)
  * [IndexError](http://nim-lang.org/docs/system.html#IndexError)
  * [ObjectAssignmentError](http://nim-lang.org/docs/system.html#ObjectAssignmentError)
  * [ObjectConversionError](http://nim-lang.org/docs/system.html#ObjectConversionError)
  * [ValueError](http://nim-lang.org/docs/system.html#ValueError)
    * [KeyError](http://nim-lang.org/docs/system.html#KeyError)
  * [ReraiseError](http://nim-lang.org/docs/system.html#ReraiseError)
  * [RangeError](http://nim-lang.org/docs/system.html#RangeError)
  * [OutOfMemoryError](http://nim-lang.org/docs/system.html#OutOfMemoryError)
  * [ResourceExhaustedError](http://nim-lang.org/docs/system.html#ResourceExhaustedError)
  * [StackOverflowError](http://nim-lang.org/docs/system.html#StackOverflowError)
  * [SystemError](http://nim-lang.org/docs/system.html#SystemError)
    * [IOError](http://nim-lang.org/docs/system.html#IOError)
    * [OSError](http://nim-lang.org/docs/system.html#OSError)
      * [LibraryError](http://nim-lang.org/docs/system.html#LibraryError)
