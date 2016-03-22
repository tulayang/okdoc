# [特殊操作符](http://nim-lang.org/docs/manual.html#special-operators)

### 点操作符 

Nim 语言的点操作符非常特别，可以用来重写函数调用和字段访问，指向未声明符号名。它们也可以用来提供一个接口，用于访问动态脚本语言或者动态文件格式（比如 XML、JSON）。

When Nim encounters an expression that cannot be resolved by the standard overload resolution rules, the current scope will be searched for a dot operator that can be matched against a re-written form of the expression, where the unknown field or proc name is converted to an additional static string parameter:

```nim
a.b      # becomes `.`(a, "b")
a.b(c, d)  # becomes `.`(a, "b", c, d)
```

The matched dot operators can be symbols of any callable kind (procs, templates and macros), depending on the desired effect:

```nim
proc `.` (js: PJsonNode, field: string): JSON = js[field]

var js = parseJson("{ x: 1, y: 2}")
echo js.x  # outputs 1
echo js.y  # outputs 2
```

The following dot operators are available:

* `.` - 匹配字段访问和方法调用

* `.()` - 只匹配方法调用，比 `.` 有更高的优先级，允许引发异常（`x.y`，`x.y()`）

* `.=` - 只匹配字段访问     

      a.b = c # becomes `.=`(a, "b", c) 