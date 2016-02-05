# [转换器](http://nim-lang.org/docs/manual.html#converters)

转换器和普通函数差不多，但是，它能为类型关系提供隐式地转换：

```nim
# 糟糕的编码风格: Nim 不是 C.
converter toBool(x: int): bool = 
  x != 0

if 4:  # 隐式地类型转换
    echo "compiles"
```

你也可以显式调用转换器，以提供可读性。注意，隐式转换器不支持链调用: 如果 A 可以转换到 B，Ｂ 可以转换到 C，A 并不能够直接转换到 C。