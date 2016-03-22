Module system （p & t for io）
=================================

```
proc open(f: var File; filename: string; mode: FileMode = fmRead; bufSize: int = - 1): bool
         {.tags: [], gcsafe, locks: 0, raises: [].}
proc open(f: var File; filehandle: FileHandle; mode: FileMode = fmRead): bool 
         {.tags: [], gcsafe, locks: 0, raises: [].}
proc open(filename: string; mode: FileMode = fmRead; bufSize: int = - 1): File 
         {.raises: [Exception, IOError], tags: [].}
     ## 使用给定的模式（默认 readonly）打开文件； 如果文件打不开不会抛出异常


proc reopen(f: File; filename: string; mode: FileMode = fmRead): bool 
           {.tags: [], gcsafe, locks: 0, raises: [].}
     ## 重打开文件； 通常用于 stdin stdout stderr 重定向

proc close(f: File) {.importc: "fclose", header: "<stdio.h>", tags: [].}
     ## 关闭文件

proc endOfFile(f: File): bool {.tags: [], gcsafe, locks: 0, raises: [].}

proc getFileHandle(f: File): FileHandle {.importc: "fileno", header: "<stdio.h>".}
     ## 获取 f 的 OS 文件句柄； 只用于跨平台编程

proc flushFile(f: File) {.importc: "fflush", header: "<stdio.h>", tags: [WriteIOEffect].}

proc getFileSize(f: File): int64 {.tags: [ReadIOEffect], gcsafe, locks: 0, raises: [IOError].}
     ## 获取文件字节数

proc setFilePos(f: File; pos: int64) {.gcsafe, locks: 0, raises: [IOError], tags: [].}
proc getFilePos(f: File): int64      {.gcsafe, locks: 0, raises: [IOError], tags: [].}
```

<span>

```
proc readChar(f: File): char {.importc: "fgetc", header: "<stdio.h>", tags: [ReadIOEffect].}


proc readBytes[](f: File; a: var openArray[int8 | uint8]; start, len: Natural): int 
                {.tags: [ReadIOEffect], gcsafe, locks: 0.}    
proc readChars(f: File; a: var openArray[char]; start, len: Natural): int
              {.tags: [ReadIOEffect], gcsafe, locks: 0, raises: [].}
proc readBuffer(f: File; buffer: pointer; len: Natural): int
               {.tags: [ReadIOEffect], gcsafe, locks: 0, raises: [].}
     ## 读取指定字节数，返回实际读取的字节数

proc readLine(f: File): TaintedString 
             {.tags: [ReadIOEffect], gcsafe, locks: 0, raises: [IOError].}
proc readLine(f: File; line: var TaintedString): bool 
             {.tags: [ReadIOEffect], gcsafe, locks: 0, raises: [].}


proc readAll(file: File): TaintedString 
            {.tags: [ReadIOEffect], gcsafe, locks: 0, raises: [Exception, IOError].}
     ## 读取流中所有数据； 如果出现错误，抛出 IO 异常

proc readFile(filename: string): TaintedString 
             {.tags: [ReadIOEffect], gcsafe, locks: 0, 
               raises: [Exception, IOError, Exception, IOError].}
     ## 打开文件，然后调用 readAll，最后关闭文件
```

<span>

```
proc write(f: File; r: float32)     {.tags: [WriteIOEffect], gcsafe, locks: 0, raises: [].}
proc write(f: File; i: int)         {.tags: [WriteIOEffect], gcsafe, locks: 0, raises: [].}
proc write(f: File; i: BiggestInt)  {.tags: [WriteIOEffect], gcsafe, locks: 0, raises: [].}
proc write(f: File; r: BiggestFloat){.tags: [WriteIOEffect], gcsafe, locks: 0, raises: [].}
proc write(f: File; c: char)        {.tags: [WriteIOEffect], gcsafe, locks: 0, raises: [].}
proc write(f: File; c: cstring)     {.tags: [WriteIOEffect], gcsafe, locks: 0, raises: [].}
proc write(f: File; s: string)   {.tags: [WriteIOEffect], gcsafe, locks: 0, raises: [IOError].}
proc write(f: File; b: bool)     {.tags: [WriteIOEffect], gcsafe, locks: 0, raises: [Exception].}
proc write(f: File; a: varargs[string, `$`]) 
     {.tags: [WriteIOEffect], gcsafe, locks: 0, raises: [Exception].}


proc writeBytes[](f: File; a: openArray[int8 | uint8]; start, len: Natural): int 
                 {.tags: [WriteIOEffect], gcsafe, locks: 0.}
proc writeChars(f: File; a: openArray[char]; start, len: Natural): int 
     		   {.tags: [WriteIOEffect], gcsafe, locks: 0, raises: [Exception].}
proc writeBuffer(f: File; buffer: pointer; len: Natural): int 
                {.tags: [WriteIOEffect], gcsafe, locks: 0, raises: [].}
     ## 写入指定字节数，返回实际写入的字节数

proc writeln[Ty](f: File; x: varargs[Ty, `$`]) 
                {.inline, tags: [WriteIOEffect], gcsafe, locks: 0.}


proc writeFile(filename, content: string) 
              {.tags: [WriteIOEffect], gcsafe, locks: 0, 
                raises: [Exception, IOError, Exception].}
     ## 打开文件，然后写入，最后关闭文件
```

<span>

```
template currentSourcePath(): string
         ## 获取当前资源的文件系统路径。
```

