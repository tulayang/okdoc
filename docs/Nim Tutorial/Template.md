
`模板带来编译期的代码逻辑审查，可以大幅减少不必要的运行时判断`

基础模板
--------

```
template `!=` (a, b: expr): expr =
    not (a == b)
 
assert(5 != 6)
```

编译期判断模板
------------

当 debug 为 false 的时候，运行期会运行 log() 参数

```
const debug = true
 
proc log(msg : string) {.inline.} =
    if debug : 
        stdout.writeln(msg)
 
var x = 1
log("x has the value: " & $x)
```

使用模板，则运行期不会运行 log() 参数

```
const debug = true
 
template log(msg : string) =
    if debug : 
        stdout.writeln(msg)
 
var x = 1
log("x has the value: " & $x)
```

模板表达式
-----------

```
template withFile(fd: expr, filename: string, mode: FileMode,
                  body: stmt): stmt {.immediate.} =
    let name = filename
    var fd: File
    if open(fd, name, mode):
        try:
            body
        finally:
            close(fd)
    else:
        quit("cannot open: " & name)
 
withFile(txt, "ttempl3.txt", fmWrite):
    txt.writeln("line 1")
    txt.writeln("line 2")
```