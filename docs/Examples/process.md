## 主线程 master

```
import os, osproc, streams

echo "--- CPU nums ", countProcessors()

var x: array[0..2, Process]

proc longtime() =
    for i in 0..200_000_000: discard

for i in 0..2:
    x[i] = startProcess(command = "./mproc_exe")

sleep(1000)

for i in 0..2:
    echo "--- exit code ",       peekExitCode(x[i]), 
         " running? ",           running(x[i]),
         " input handle ",       inputHandle(x[i]),
         " output handle ",      outputHandle(x[i]),
         " error handle ",       errorHandle(x[i]),
    #    " input stream ",  repr inputStream(x[i]),
    #    " output stream ", repr outputStream(x[i]),
    #    " error stream ",  repr errorStream(x[i]),
         " stdout string ",      readStr(outputStream(x[i]), 17),
         " process id ",         processID(x[i])

kill(x[0])
terminate(x[1])
terminate(x[2])

for i in 0..2:
    echo "--- exit code ", waitForExit(x[i]), 
         " running? ",     running(x[i]),
         " process id ",   processID(x[i])
         
for i in 0..2:         
    close(x[i])
```

## 子线程 child

```
import os

while true:
    write(stdout, "...hello world...")
    flushFile(stdout)
    sleep(3000)

```

## 命令行

```
import os

echo extractFilename("./ex_process_child.nim")
echo execShellCmd("./ex_process_child")
```