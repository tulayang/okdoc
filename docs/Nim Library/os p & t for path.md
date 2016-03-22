[Module os （p & t for path）](http://nim-lang.org/docs/os.html)
=====================================================================

```
proc joinPath(head, tail: string): string 
             {.noSideEffect, gcsafe, extern: "nos$1", raises: [], tags: [].}
     ## 拼接路径。
     assert joinPath("usr",  "lib")  == "usr/lib"
     assert joinPath("usr",  "")     == "usr/"
     assert joinPath("",     "lib")  == "lib"
     assert joinPath("",     "/lib") == "/lib"
     assert joinPath("usr/", "/lib") == "usr/lib"

proc joinPath(parts: varargs[string]): string 
             {.noSideEffect, gcsafe, extern: "nos$1OpenArray", raises: [], tags: [].}
     ## 同 joinPath(head, tail)。

proc `/`(head, tail: string): string {.noSideEffect, raises: [], tags: [].}
     ## 同 joinPath(head, tail)。
     assert "usr"  / "lib"  == "usr/lib"
     assert "usr"  / ""     == "usr/"
     assert ""     / "lib"  == "lib"
     assert ""     / "/lib" == "/lib"
     assert "usr/" / "/lib" == "usr/lib"
```     

<span>


```
proc splitPath(path: string): tuple[head, tail: string] 
              {.noSideEffect, gcsafe, extern: "nos$1", raises: [], tags: [].}
     ## 拆分路径为 (head, tail)。
     assert splitPath("usr/local/bin")  == ("usr/local", "bin")
     assert splitPath("usr/local/bin/") == ("usr/local/bin", "")
     assert splitPath("bin")            == ("", "bin")
     assert splitPath("/bin")           == ("", "bin")
     assert splitPath("")               == ("", "")

proc splitFile(path: string): tuple[dir, name, ext: string] 
              {.noSideEffect, gcsafe, extern: "nos$1", raises: [], tags: [].}
     ## 拆分路径为 (dir, filename, extension)。如果没有扩展名组成，ext 就是空字符串。如果没有
     ## 目录组成，dir 就是空字符串。如果没有文件组成，filename 就是空字符串。
     var (dir, name, ext) = splitFile("usr/local/nimc.html")
     assert dir  == "usr/local"
     assert name == "nimc"
     assert ext  == ".html"
```

<span>

```
proc expandTilde(path: string): string {.tags: [ReadEnvEffect], raises: [].}
     ## 使用"~"扩展路径。
     let configFile = expandTilde("~" / "appname.cfg")
     echo configFile   # C:\Users\amber\appname.cfg
```

<span>

```
proc unixToNativePath(path: string; drive = ""): string 
                     {.noSideEffect, gcsafe, extern: "nos$1", raises: [], tags: [].}
     ## 转换 UNIX-like 路径为本地路径。在 UNIX 系统，这什么都不做。
```