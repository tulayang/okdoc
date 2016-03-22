Module system (p & t for widestrings)
======================================


```
proc cstringArrayToSeq(a: cstringArray; len: Natural): seq[string] {.raises: [], tags: [].}
proc cstringArrayToSeq(a: cstringArray): seq[string] {.raises: [], tags: [].}

proc allocCStringArray(a: openArray[string]): cstringArray {.raises: [Exception], tags: [].}
proc deallocCStringArray(a: cstringArray)                  {.raises: [Exception], tags: [].}
     ## 创建一个 NULL 终结符的 cstringArray。结果必须用 deallocCStringArray 释放。

proc len(w: WideCString): int {.raises: [], tags: [].}
     ## 获取 widestring 的长度； 扫描整个字符串直到 '\0'

proc `$`(w: WideCString; estimate: int): string {.raises: [], tags: [].}
proc `$`(s: WideCString)               : string {.raises: [], tags: [].}
```

<span>

```
proc newWideCString(source: cstring; L: int): WideCString {.raises: [], tags: [].}
proc newWideCString(s: cstring)             : WideCString {.raises: [], tags: [].}
proc newWideCString(s: string)              : WideCString {.raises: [], tags: [].}
```


