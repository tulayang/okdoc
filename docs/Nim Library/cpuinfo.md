Module cpuinfo
===============

```
import strutils, os 
```

Procs
----------

```
proc countProcessors(): int {.gcsafe, extern: "ncpi$1", 
                              raises: [OverflowError, ValueError], tags: [ReadEnvEffect].}
     ## 获取处理器/核的数量。如果无法检测到，返回 0 。
```