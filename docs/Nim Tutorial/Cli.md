Build
--------

    $ nim c [-d:release] demo.nim           
    $ ./demo

    $ nim c -r [-d:release] demo.nim

<span>

    $ nimble c -r [-d:release] demo.nim
    $ ./demo
    
    $ nimble build


Benchmark
----------

    $ time ./main

App
-----

    $ nimble init demo
    
             [Package]
             name          = "demo"
             version       = "0.1.0"
             author        = "WT"
             description   = "My Demo"
             license       = "MIT"
             bin           = "demo"

             [Deps]
             Requires: "nim >= 0.10.0"

Debug
---------

```
$ nim c -r --debugger:native test.nim

$ nim c -r -d:debug --lineDir:on --debuginfo test.nim
```

<span>

```
$ gdb test
```

Gdb

commond|description|example              
-------|-----------|-------
file <文件名>| 加载被调试的可执行程序文件。|(gdb) file gdb-sample
r |           Run的简写，运行被调试的程序。如果此前没有下过断点，则执行<br />完整个程序；如果有断点，则程序暂停在第一个可用断点处。| (gdb) r
b <行号><br/>b <函数名称><br/>b *<函数名称><br/>b *<代码地址><br/> |           Breakpoint的简写，设置断点。两可以使用“行号”“函数名称”“执行<br />地址”等方式指定断点位置。| (gdb) b 8<br />(gdb) b main<br />(gdb) b *main<br />(gdb) b *0x804835c
d [编号]|      Delete breakpoint的简写，删除指定编号的某个断点，或删除所<br />有断点。断点编号从1开始递增。| (gdb) d
c|            Continue的简写，继续执行被调试程序，直至下一个断点或程序<br />结束。| (gdb) c  
s|            Step的简写。执行一行源程序代码，如果此行代码中有函数调用，<br />则进入该函数。| (gdb) s
n|            Next的简写执行一行源程序代码，此行代码中的函数调用也一<br />执行。| (gdb) n
up|           跳到制定的位置。| (gdb) up 6
p|            Print的简写，显示指定变量（临时变量或全局变量）的值。| (gdb) p i<br /> (gdb) p nGlobalVar
l|            List的简写，显示相关的信息。｜ (gdb) list
bt| Backtrace 的简写，回溯程序运行信息。｜ (gdb) bt
display |  设置程序中断后欲显示的数据及其格式。<br />例如，如果希望每次程序中断后可以看到即将被执行的下一条汇编指<br />令，可以使用命令 “display /i $pc” 其中 $pc 代表当前汇编<br />指令，/i 表示以十六进行显示。当需要关心汇编代码时，此命令相<br />当有用。 | (gdb) display /i $pc 
undisplay | 取消先前的display设置，编号从1开始递增。| (gdb) undisplay 1
i| Info的简写，用于显示各类信息，详情请查阅“help i”。| (gdb) i r
q| Quit的简写，退出GDB调试环境。| (gdb) q
help| GDB帮助命令，提供对GDB名种命令的解释说明。| (gdb) help display

### [What makes Nim practical](http://hookrace.net/blog/what-makes-nim-practical/#debugging-nim)


