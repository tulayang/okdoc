[Module osproc](http://nim-lang.org/docs/osproc.html)
==========================================================

This module implements an advanced facility for executing OS processes and process communication.

```
import strutils, os, strtabs, streams, cpuinfo, winlean 
```

Types
---------

```
Process       = ref ProcessObj      ## 表述一个操作系统进程
ProcessOption = enum                ## 传递给 startProcess 的配置
    poEchoCmd,                      ## echo the command before execution
    poUsePath,                      ## Asks system to search for executable using PATH 
                                    ## environment variable. On Windows, this is the default.
    poEvalCommand,                  ## Pass `command` directly to the shell, without quoting.
                                    ## Use it only if `command` comes from trused source.
    poStdErrToStdOut,               ## merge stdout and stderr to the stdout stream
    poParentStreams                 ## use the parent's streams
```

Consts
---------

```
poUseShell   = poUsePath            ## poUsePath 的别名
```

Procs
----------

```
proc quoteShellWindows(s: string): string 
                      {.noSideEffect, gcsafe, extern: "nosp$1", raises: [], tags: [].}
     ## Quote s, so it can be safely passed to Windows API. Based on Python's 
     ## subprocess.list2cmdline See http://msdn.microsoft.com/en-us/library/17w5ykft.aspx.

proc quoteShellPosix(s: string): string 
                    {.noSideEffect, gcsafe, extern: "nosp$1", raises: [], tags: [].}
     ## Quote s, so it can be safely passed to POSIX shell. Based on Python's pipes.quote.

proc quoteShell(s: string): string 
               {.noSideEffect, gcsafe, extern: "nosp$1", raises: [], tags: [].}
     ## Quote s, so it can be safely passed to shell.
```

<span>

```
proc countProcessors(): int {.gcsafe, extern: "nosp$1", 
                              raises: [OverflowError, ValueError], tags: [ReadEnvEffect].}
     ## 返回当前机器的处理器/核数量。如果无法检测，返回 0 。
```

<span>

```
proc execProcesses(cmds: openArray[string]; 
                   options = {poStdErrToStdOut, poParentStreams}; 
                   n = countProcessors(); beforeRunEvent: proc (idx: int) = nil): int 
                   {.gcsafe, extern: "nosp$1", raises: [Exception], 
                     tags: [ExecIOEffect, TimeEffect, ReadEnvEffect, RootEffect].}
     ## 使用并行的方式，运行命令，启动 n 个进程。返回进程中值最高的。运行每个命令前，运行 beforeRunEvent 。

proc execProcess(command: string; 
                 args: openArray[string] = []; env: StringTableRef = nil; 
                 options: set[ProcessOption] = {poStdErrToStdOut, poUsePath, poEvalCommand})
                 : TaintedString 
                 {.gcsafe, extern: "nosp$1", 
                   raises: [Exception], tags: [ExecIOEffect, ReadIOEffect].}
     ## 一个方便的，通过 startProcess 运行命令启动进程。返回输出。警告：为了向后兼容，这个过程默认使用
     ## poEvalCommand 。确保你要明确的传递配置。

proc execCmd(command: string): int 
            {.gcsafe, extern: "nosp$1", tags: [ExecIOEffect], raises: [OSError].}
     ## 运行命令启动进程，并返回错误代码。从调用进程继承其标准输入、输出、错误。这个操作也常常调用系统。
     
proc execCmdEx(command: string; 
               options: set[ProcessOption] = {poStdErrToStdOut, poUsePath})
               : tuple[output: TaintedString, exitCode: int] 
               {.gcsafe, raises: [OSError, Exception], tags: [ExecIOEffect, ReadIOEffect].}
      ## 一个方便的，运行命令启动进程。返回所有的输出和错误代码。

proc startProcess(command: string; workingDir: string = ""; 
                  args: openArray[string] = []; env: StringTableRef = nil; 
                  options: set[ProcessOption] = {poStdErrToStdOut}): Process 
                  {.gcsafe, extern: "nosp$1", 
                    raises: [OSError, Exception], tags: [ExecIOEffect, ReadEnvEffect].}
     ## 启动一个进程。command 是可执行文件，workingDir 是进程的工作目录。如果 workingDir == ""，当前目录
     ## 使用命令行传递的参数。在许多操作系统，第一个命令行参数是运行者的名字，参数中不应该包括这个名字。env 
     ## 是传递给进程的环境变量。如果 env == nil，环境变量继承自父进程。options 是附加配置。ProcessOption 
     ## 文档包含了这些配置的细节。当完成的时候，你需要关闭这个进程。
     ##
     ## 注意如果你使用 poEvalCommand 配置，你就不能传递任何参数。这会调用系统 shell 运行指定的命令。这种
     ## 情况，你必须小心的转义引用字符串，手动的关联参数。每个系统 shell 可能会有不同的转义规则。
     ##
     ## 返回值：创建的新进程对象。如果出错不会返回 nil，而是抛出 EOS。

proc close(p: Process) {.gcsafe, extern: "nosp$1", tags: [], raises: [].}
     ## 当进程已经运行完成时，清除相关资源
     
proc waitForExit(p: Process; timeout: int = - 1): int 
                {.gcsafe, extern: "nosp$1", tags: [], raises: [].}
     ## 等待进程直到完成，返回进程的错误代码。警告：当进程配置不是 poParentStreams 的时候要小心，因为他们
     ## 可能会填充输出缓冲区，引起死锁。

proc peekExitCode(p: Process): int {.tags: [], raises: [].}
     ## 返回进程的退出代码。如果进程仍在运行，返回 -1 。

proc suspend(p: Process) {.gcsafe, extern: "nosp$1", tags: [], raises: [].}
     ## 挂起进程

proc resume(p: Process) {.gcsafe, extern: "nosp$1", tags: [], raises: [].}
     ## 恢复进程

proc terminate(p: Process) {.gcsafe, extern: "nosp$1", tags: [], raises: [].}
     ## 停止进程，在 POSIX 系统会发送 SIGTERM 给进程，在 Windows win32 调用 TerminateProcess()。

proc kill(p: Process) {.gcsafe, extern: "nosp$1", tags: [], raises: [].}
     ## 停止进程，在 POSIX 系统会发送 SIGKILL 给进程，在 Windows win32 调用 terminate()。
````

<span>

```
proc running(p: Process): bool {.gcsafe, extern: "nosp$1", tags: [], raises: [].}
     ## 进程仍在运行？翻译注释：我发现这个过程有个 bug ,需要跟 peekExitCode 一起使用才能返回正确状态。　

proc processID(p: Process): int {.gcsafe, extern: "nosp$1", raises: [], tags: [].}
     ## 返回进程ID
```

<span>

```
proc inputHandle(p: Process) : FileHandle {.gcsafe, extern: "nosp$1", tags: [], raises: [].}
     ## 返回进程的输入文件表示，用来写入。警告：返回的 TFileHandle 不应手动关闭，因为当进程关闭时会跟随关闭。

proc outputHandle(p: Process): FileHandle {.gcsafe, extern: "nosp$1", tags: [], raises: [].}
     ## 返回进程的输出文件表示，用来读取。警告：返回的 TFileHandle 不应手动关闭，因为当进程关闭时会跟随关闭。

proc errorHandle(p: Process) : FileHandle {.gcsafe, extern: "nosp$1", tags: [], raises: [].}
     ## 返回进程的错误文件表示，用来读取。警告：返回的 TFileHandle 不应手动关闭，因为当进程关闭时会跟随关闭。

proc inputStream(p: Process) : Stream {.gcsafe, extern: "nosp$1", tags: [], raises: [].}
     ## 返回进程的可写流。警告：返回的 PStream 不应手动关闭，因为当进程关闭时会跟随关闭。

proc outputStream(p: Process): Stream {.gcsafe, extern: "nosp$1", tags: [], raises: [].}
     ## 返回进程的可读流。警告：返回的 PStream 不应手动关闭，因为当进程关闭时会跟随关闭。

proc errorStream(p: Process) : Stream {.gcsafe, extern: "nosp$1", tags: [], raises: [].}
     ## 返回进程的错误流。警告：返回的 PStream 不应手动关闭，因为当进程关闭时会跟随关闭。
```

<span>

```
proc select(readfds: var seq[Process]; timeout = 500): int {.raises: [OSError], tags: [].}
     ## Nim 提供的 select 接口。timeout 单位是毫秒。可以指定 -1 表示不超时。返回可读就绪的进程数量。
     ## 将要被读的进程，会从 readfds 删除。警告：在 Windows 中，这个过程可能会得出错误的结果。
```