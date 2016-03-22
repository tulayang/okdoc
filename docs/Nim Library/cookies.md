Module cookies
===============

```
import strtabs, times 
```

Procs
----------

```
proc parseCookies(s: string): StringTableRef {.raises: [], tags: [].}
     ## cookies => string table

proc setCookie(key, value: string; domain = ""; path = ""; expires = ""; noName = false;
               secure = false; httpOnly = false): string {.raises: [], tags: [].}
     ## 创建一个命令，文本格式: Set-Cookie: key=value; Domain=...; ...   

proc setCookie(key, value: string; expires: TimeInfo; domain = ""; path = ""; noName = false;
               secure = false; httpOnly = false): string {.raises: [ValueError], tags: [].}   
     ## 创建一个命令，文本格式: Set-Cookie: key=value; Domain=...; ...
     ## 注意: expires 假定使用 UTC 时区。
```