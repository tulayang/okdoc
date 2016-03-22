Module system （iterators）
=============================

```
iterator countdown[T](a, b: T; step = 1): T {.inline.}
         ## 使用给定的 step， 从 a 到 b 计算递减的顺序值。T 必须是 ordinal 类型。
         for i in countdown(9, 0): echo i

iterator countup[S, T](a: S; b: T; step = 1): T {.inline.}
         ## 使用给定的 step， 从 a 到 b 计算递减的顺序值。T 必须是 ordinal 类型。
         for i in countdown(0, 9): echo i

iterator `..`[S, T](a: S; b: T): T {.inline.}
         ## countup 的别名。

iterator `||`[S, T](a: S; b: T; annotation = ""): T {.inline, magic: "OmpParFor", sideEffect.}
         ## parallel loop iterator. Same as .. but the loop may run in parallel. annotation is 
         ## an additional annotation for the code generator to use. Note that the compiler maps 
         ## that to the #pragma omp parallel for construct of OpenMP and as such isn't aware of
         ## the parallelism in your code! Be careful! Later versions of || will get proper 
         ## support by Nim's code generator and GC.
```

<span>

```
iterator items[T]    (a: openArray[T])  : T      {.inline.}
iterator items[IX, T](a: array[IX, T])  : T      {.inline.}
iterator items[T]    (a: seq[T])        : T      {.inline.}
iterator items       (a: string)        : char   {.inline, raises: [], tags: [].}
iterator items       (a: cstring)       : char   {.inline, raises: [], tags: [].}

iterator items[T]    (a: set[T])        : T      {.inline.}
iterator items[]     (E: typedesc[enum]): E:type
iterator items[T]    (s: Slice[T])      : T
         ## 迭代 a 的每一项。

iterator mitems[T]    (a: var openArray[T]): var T    {.inline.}
iterator mitems[IX, T](a: var array[IX, T]): var T    {.inline.}
iterator mitems[T]    (a: var seq[T])      : var T    {.inline.}
iterator mitems       (a: var string)      : var char {.inline, raises: [], tags: [].}
iterator mitems       (a: var cstring)     : var char {.inline, raises: [], tags: [].}
         ## 迭代 a 的每一项。可以修改 yielded 值。
```

<span>

```
iterator pairs[T]    (a: openArray[T]): tuple[key: int, val: T]    {.inline.}
iterator pairs[IX, T](a: array[IX, T]): tuple[key: IX,  val: T]    {.inline.}
iterator pairs[T]    (a: seq[T])      : tuple[key: int, val: T]    {.inline.}
iterator pairs       (a: string)      : tuple[key: int, val: char] {.inline, raises: [], tags: [].}
iterator pairs       (a: cstring)     : tuple[key: int, val: char] {.inline, raises: [], tags: [].}
         ## 迭代 a 的每一项的索引值对（index, a[index]）。

iterator mpairs[T]    (a: var openArray[T]): tuple[key: int, val: var T]    {.inline.}
iterator mpairs[IX, T](a: var array[IX, T]): tuple[key: IX, val: var T]     {.inline.}
iterator mpairs[T]    (a: var seq[T])      : tuple[key: int, val: var T]    {.inline.}
iterator mpairs       (a: var string)      : tuple[key: int, val: var char] {.inline, raises: [], tags: [].}
iterator mpairs       (a: var cstring)     : tuple[key: int, val: var char] {.inline, raises: [], tags: [].}
         ## 迭代 a 的每一项的索引值对（index, a[index]）。可以修改 yielded 值 a[index]。
```

<span>

```
iterator fields[T](x: T): RootObj {.magic: "Fields", noSideEffect.}
iterator fields[S, T](x: S; y: T): tuple[a, b: expr] {.magic: "Fields", noSideEffect.}
         ## 迭代 x 的每一个字段。警告: 这会转换并展开为 for 。当前的实现有一个 bug，影响循环体内的符号绑定。

iterator fieldPairs[T](x: T): RootObj {.magic: "FieldPairs", noSideEffect.}
         ## 迭代 x 的每一个字段，返回名值。当你迭代一个对象的不同字段类型时，你必须使用编译期 when 代替运行期
         ## if ，来选择你想要运行哪一个类型。进行比较使用 is 操作符。

         type
             Custom = object
                 foo: string
                 bar: bool

         proc `$`(x: Custom): string =
             result = "Custom:"
             for name, value in fieldPairs(x):
                 when value is bool:
                     result.add("\n\t" & name & " is " & $value)
                 else:
                     if value.isNil:
                         result.add("\n\t" & name & " (nil)")
                     else:
                         result.add("\n\t" & name & " '" & value & "'")
         
         ## 警告: 这会转换并展开为 for 。当前的实现有一个 bug，影响循环体内的符号绑定。

iterator fieldPairs[S, T](x: S; y: T): tuple[a, b: expr] {.magic: "FieldPairs", noSideEffect.}
         ## 迭代 x y 的每一个字段，返回名值。警告: 这会转换并展开为 for 。当前的实现有一个 bug，影响循环
         ## 体内的符号绑定。
```

<span>

```
iterator lines(filename: string): TaintedString 
              {.tags: [ReadIOEffect], raises: [Exception, IOError].}
         ## 迭代文件的每一行。如果文件不存在，抛出 EIO 。换行符会在迭代中去掉。
         import strutils

         proc transformLetters(filename: string) =
             var buffer = ""
             for line in filename.lines:
                 buffer.add(line.replace("a", "0") & '\x0A')
             writeFile(filename, buffer)

iterator lines(f: File): TaintedString 
              {.tags: [ReadIOEffect], raises: [].}
         ## 迭代文件的每一行。换行符会在迭代中去掉。
         proc countZeros(filename: File): tuple[lines, zeros: int] =
         for line in filename.lines:
             for letter in line:
                 if letter == '0':
                     result.zeros += 1
             result.lines += 1
```