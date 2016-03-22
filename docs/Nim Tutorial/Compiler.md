* hint
* warning
* error

{.discardable.} (返回值可以丢弃)
------------------------------

Nim 除非过程没有定义返回值，否则不允许丢弃返回值

    proc f(): int = 
        result = 1
    f()                               // ERROR 不能丢弃返回值

编译器会抛出错误，只能

    discard f()                       // GOOD  可以丢弃返回值

或者定义编译器，该过程返回值可丢弃

    proc f(): int {.discardable.} =   // GOOD  定义返回值可以丢弃
        result = 1
    f()


{.deprecated.} (弃用，当符号被使用时，编译器警告这个符号已被弃用)
----------------------------------------------------------

    // 弃用

    proc p() {.deprecated.}
    var x {.deprecated.} : int

    x = 1
    (Warning: x is deprecated [Deprecated])

<span>

    // 重命名 

    type
        File   = int
        Stream = ref int
    {.deprecated: [TFile: File, PStream: Stream].}

    var x:PStream

    (Warning: use Stream instead; PStream is deprecated [Deprecated])

<span>

    type
        File   = object
        Stream = ref object
    {.deprecated: [TFile: File, PStream: Stream].}
    
{.final.} (不能被继承)
---------------------

    type
        Node = ref NodeObj
        NodeObj {.acyclic, final.} = object
          left, right: Node
          data: string

{.shallow.} (浅拷贝)
--------------------

    type
        NodeKind = enum nkLeaf, nkInner
        NodeObj {.final, shallow.} = object
          case kind: NodeKind
          of nkLeaf:
            strVal: string
          of nkInner:
            children: seq[Node]

{.error.} (错误消息)
---------------------

    proc `==`(x, y: ptr int): bool {.error.}

{.compile.} (编译链接 C C++ 文件)
--------------------------------

    {.compile: "myfile.cpp".}

{.link.} (链接文件)
-------------------

    {.link: "myfile.o".}

{.inline.} (向 C 编译器提交内联建议)
----------------------------------

{.raises.} (编译期检测过程的异常)
----------------------------------

    proc complexProc() {.raises : [IOError, ArithmeticError].} = ...
