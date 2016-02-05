# [破坏模式](http://nim-lang.org/docs/manual.html#taint-mode)

Nim 编译器和标准库的大部分，支持破坏模式。在 system 模块中，把输入字符串声明为 `TaintedString` 类型。

如果启用破坏模式（通过 `--taintMode:on` 命令项），那么 `TaintedString` 是一个 `distinct string` 类型，可以帮助输入时验证错误：

```nim
echo "your name: "
var name: TaintedString = stdin.readline
# 在这个地方不进行任何输入验证来输出名字是安全的，因此我们简单地把   `name` 转换程字符串 
echo "hi, ", name.string
```

如果关闭破坏模式，`TaintedString` 只是简单的作为 `string` 的一个别名。