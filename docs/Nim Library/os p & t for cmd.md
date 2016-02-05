[Module os （p & t for cmd）](http://nim-lang.org/docs/os.html)
=====================================================================

```
proc extractFilename(path: string): string 
                    {.noSideEffect, gcsafe, extern: "nos$1", raises: [], tags: [].}
     ## 运行一个文件，启动一个进程。

proc execShellCmd(command: string): int 
                 {.gcsafe, extern: "nos$1", tags: [ExecIOEffect], raises: [].}
     ## 运行一个 shell 命令。当完成时，返回错误代码。进程完成前，不返回。要运行一个程序，而不使用 shell，使用
     ## execProcess 过程。

proc sleep(milsecs: int) {.gcsafe, extern: "nos$1", tags: [TimeEffect], raises: [].}
     ## 睡眠一些时间
```

<span>

```
proc commandLineParams(): seq[TaintedString] {.raises: [], tags: [ReadIOEffect].}
     ## 转换命令行参数为组件。只返回参数，如果你想获取运行文件名，调用 getAppFilename() 。

proc paramCount(): int {.tags: [ReadIOEffect], raises: [].}
     ## 返回命令行参数的数量。如果你的二进制程序调用时没有参数，返回 0 。

proc paramStr(i: int): TaintedString {.tags: [ReadIOEffect], raises: [].}
     ## 返回命令行参数。

proc parseCmdLine(c: string): seq[string] 
                 {.noSideEffect, gcsafe, extern: "nos$1", raises: [], tags: [].}  
     ## 拆分命令行为组件。在 POSIX 系统，组成使用空白分割，除非使用 " ' 引用。
```

### example

```
import os

echo "params: ",      commandLineParams()
echo "param count: ", paramCount()
echo "param 1: ",     paramStr(1)
echo "cmds: ",        parseCmdLine("mysql -u root -p --port 3306 --host 127.0.0.1")

echo "exe name: ",    extractFilename("./ex_process_child.nim")
echo "output: ",      execShellCmd("./ex_process_child")

# $ nim c -r test.nim -u root -p --port 3306 --host 127.0.0.1
# 
# params      : @[-u, root, -p, --port, 3306, --host, 127.0.0.1]
# param count : 7
# param 1     : -u
# cmds        : @[mysql, -u, root, -p, --port, 3306, --host, 127.0.0.1]
# exe name    : ex_process_child.nim
# ...hello world... 
```