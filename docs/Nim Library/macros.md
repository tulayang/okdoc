[Module macros](nim-lang.org/docs/macros.html)                          
==================

这个模块提供编译器的抽象语法树 AST 的编程接口。你可以利用宏来操作语法树。

## The AST in Nim

这个章节描述了如何使用 Nim 类型系统构造 AST 。AST 由节点 （**NimNode**） 构成，在该节点中同时包含子节点，这些子节点的数量是可变的。每个节点拥有一个 **kind** 字段，用于描述节点的类型

```
type
    NimNodeKind = enum       ## 表示一个节点的类型
        nnkNone,             ## 无效(invalid)节点
        nnkEmpty,            ## 空(empty)节点 
        nnkIdent,            ## 包含一个标识符(identifier)的节点 
        nnkIntLit,           ## 包含一个整型值(int literal)的节点 (example: 10)
        nnkStrLit,           ## 包含一个字符串值(string literal)的节点 (example: "abc")
        nnkNilLit,           ## 包含一个 nil literal 的节点 (example: nil)
        nnkCaseStmt,         ## 表示一个 case 语句
        ...                  ## many more
    
    NimNode = ref NimNodeObj
    NimNodeObj = object
        case kind: NimNodeKind             ## the node's kind
        of nnkNone, nnkEmpty, nnkNilLit:
            discard                        ## node contains no additional fields
        of nnkCharLit..nnkUInt64Lit:
            intVal: BiggestInt             ## the int literal
        of nnkFloatLit..nnkFloat64Lit:
            floatVal: BiggestFloat         ## the float literal
        of nnkStrLit..nnkTripleStrLit:
            strVal: string                 ## the string literal
        of nnkIdent:
            ident: NimIdent                ## the identifier
        of nnkSym:
            symbol: NimSymbol              ## the symbol (after symbol lookup phase)
        else:
            sons: seq[NimNode]             ## the node's sons (or children)
``` 