# [type 块](http://nim-lang.org/docs/manual.html#type-sections)

例子：

```nim
type  # 演示一些互相递归的类型
    Node = ref NodeObj   # 一个指向 NodeObj 的追踪指针
    NodeObj = object
        le, ri: Node     # 左子树和右子树
        sym: ref Sym     # 指向 Sym 的树叶
    Sym = object         # 一个符号
        name: string     # 符号名字
        line: int        # 符号声明时所在的行
        code: Node       # 该符号的抽象语法树
```

`type` 块，使用关键字 `type` 开始，含多个类型定义。每个类型定义绑定一个类型名。类型定义可以递归、甚至互相递归。互相递归的类型，只可能出现在同一个 `type` 块。对象、枚举类型，只能在 `type` 块中定义。 　
