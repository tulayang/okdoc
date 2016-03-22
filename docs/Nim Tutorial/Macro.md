`如果外部接口在编译期不可用，就必须用 Nim 写宏`

编写宏
------

1. 表达式

       import macros

       macro debug(n : varargs[expr]) : stmt =
           # `n` is a Nim AST that contains a list of expressions;
           # this macro returns a list of statements:
           result = newNimNode(nnkStmtList, n)
           for i in 0..len(n)-1:
               result.add(newCall("write",   newIdentNode("stdout"), toStrLit(n[i])))
               result.add(newCall("write",   newIdentNode("stdout"), newStrLitNode(": ")))
               result.add(newCall("writeln", newIdentNode("stdout"), n[i]))

       var
           a: array[0..10, int]
           x = "some string"
       a[0] = 42
       a[1] = 45
        
       debug(a[0], a[1], x)
       ```

       => 

       ```
       write  (stdout, "a[0]")
       write  (stdout, ": ")
       writeln(stdout, a[0])
        
       write  (stdout, "a[1]")
       write  (stdout, ": ")
       writeln(stdout, a[1])
        
       write  (stdout, "x")
       write  (stdout, ": ")
       writeln(stdout, x)

2. 声明

       macro case_token(n: stmt): stmt =
           discard
           
       case_token : 
       of r"[A-Za-z_]+[A-Za-z_0-9]*" : return tkIdentifier
       of r"0-9+"                    : return tkInteger
       of r"[\+\-\*\?]+"             : return tkOperator
       else                          : return tkUnknown  

手动创建抽象语法树AST
-------------------