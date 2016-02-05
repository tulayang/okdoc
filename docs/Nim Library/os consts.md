[Module os （consts）](http://nim-lang.org/docs/os.html)
==========================================================

```
CurDir  = '.'                  ## 表示操作系统中指向当前目录。比如：POSIX 中是'.'， Macintosh 中是':'。 
ParDir  = ".."                 ## 表示操作系统中指向上级目录。比如：POSIX 中是'..'，Macintosh 中是'::'。
DirSep  = '/'                  ## 表示操作系统中路径分隔符。比如：POSIX 中是'/'， Macintosh 中是':'。 
AltSep  = '/'                  ## 表示操作系统中路径分隔符。
PathSep = ':'                  ## 表示操作系统中搜索分隔符。比如：POSIX 中是':'， Windows 中是';'。 
ExeExt  = ""                   ## 表示本地可执行文件的扩展名。比如：POSIX 中是''， Windows 中是'exe'。
ExtSep  = '.'                  ## 表示基本文件名。比如：在 os.nim 中是'.'。
ScriptExt    = ""              ## 表示脚本文件扩展名。比如：POSIX 中是''， Windows 中是'bat'。
DynlibFormat = "lib$1.so"      ## 用于把一个文件名转换为 DLL 文件
FileSystemCaseSensitive = true ## 文件系统大小写敏感？
```