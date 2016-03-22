[Module streams](http://nim-lang.org/docs/streams.html)
==========================================================

This module provides a stream interface and two implementations thereof: the FileStream and the StringStream which implement the stream interface for Nim file objects (File) and strings. Other modules may provide other implementations for this standard stream interface.

Types
---------

```
Stream    = ref StreamObj
StreamObj = object of RootObj           ## 流接口，支持读或者写。注意这里的字段，不是直接使用的。
                                        ## 一个流应该重写这些内容。   
    closeImpl       : proc (s: Stream)           {.nimcall, tags: [], gcsafe.}
    atEndImpl       : proc (s: Stream): bool     {.nimcall, tags: [], gcsafe.}
    setPositionImpl : proc (s: Stream; pos: int) {.nimcall, tags: [], gcsafe.}
    getPositionImpl : proc (s: Stream): int      {.nimcall, tags: [], gcsafe.}
    readDataImpl    : proc (s: Stream; buffer: pointer; bufLen: int): int 
                                                 {.nimcall, tags: [ReadIOEffect], gcsafe.}
    writeDataImpl   : proc (s: Stream; buffer: pointer; bufLen: int) 
                                                 {.nimcall, tags: [WriteIOEffect], gcsafe.}
    flushImpl       : proc (s: Stream)           {.nimcall, tags: [WriteIOEffect], gcsafe.}
    

StringStream    = ref StringStreamObj    ## 压缩字符串流
StringStreamObj = object of StreamObj
    data*: string
    pos: int

FileStream      = ref FileStreamObj      ## 文件流
FileStreamObj   = object of StreamObj    
    f: File
```

Procs
----------

```
proc flush(s: Stream) {.raises: [Exception], tags: [WriteIOEffect].}
     ## 冲洗流使用的缓冲区。

proc close(s: Stream)         {.raises: [Exception], tags: [].}
proc close(s, unused: Stream) {.deprecated, raises: [Exception], tags: [].}
     ## 关闭流。

proc atEnd(s: Stream)        : bool {.raises: [Exception], tags: [].}
proc atEnd(s, unused: Stream): bool {.deprecated, raises: [Exception], tags: [].}
     ## 有更多的数据可读？如果所有的数据已经读完，返回 true 。

proc setPosition(s: Stream; pos: int)         {.raises: [Exception], tags: [].}
proc setPosition(s, unused: Stream; pos: int) {.deprecated, raises: [Exception], tags: [].}
     ## 设置流的游标位置。

proc getPosition(s: Stream)        : int {.raises: [Exception], tags: [].}
proc getPosition(s, unused: Stream): int {.deprecated, raises: [Exception], tags: [].}
     ## 获取流的游标位置。
```

<span>

```
proc writeData(s: Stream; buffer: pointer; bufLen: int) 
              {.raises: [Exception], tags: [WriteIOEffect].}
proc writeData(s, unused: Stream; buffer: pointer; bufLen: int) 
              {.deprecated, raises: [Exception], tags: [WriteIOEffect].}
     ## 低阶过程，从缓冲区把一块指定字节的数据写入流。

proc readData(s: Stream; buffer: pointer; bufLen: int): int 
             {.raises: [Exception], tags: [ReadIOEffect].}
proc readData(s, unused: Stream; buffer: pointer; bufLen: int): int 
             {.deprecated, raises: [Exception], tags: [ReadIOEffect].}
     ## 低阶过程，从流读取一块指定字节的数据放入缓冲区。
```

<span>

```
proc write[T](s: Stream; x: T)
     ## 泛型写过程。
     writeData(s, addr(x), sizeof(x))

proc write(s: Stream; x: string) {.raises: [Exception], tags: [WriteIOEffect].}
     ## 把字符串写入流。'\0'终止符不会写入。

proc writeln(s: Stream; args: varargs[string, `$`]) 
            {.raises: [Exception], tags: [WriteIOEffect].}
     ## 把一个或多个字符串（换行符）写入流。'\0'终止符不会写入。

proc readChar(s: Stream): char {.raises: [Exception], tags: [ReadIOEffect].}
     ## 从流读取一个 char。如果出错，抛出 EIO 。

proc readBool(s: Stream): bool {.raises: [Exception, IOError], tags: [ReadIOEffect].}
     ## 从流读取一个 bool。如果出错，抛出 EIO 。

proc readInt8(s: Stream): int8 {.raises: [Exception, IOError], tags: [ReadIOEffect].}
     ## 从流读取一个 int8。如果出错，抛出 EIO 。

proc readInt16(s: Stream): int16 {.raises: [Exception, IOError], tags: [ReadIOEffect].}
     ## 从流读取一个 int16。如果出错，抛出 EIO 。

proc readInt32(s: Stream): int32 {.raises: [Exception, IOError], tags: [ReadIOEffect].}
     ## 从流读取一个 int32。如果出错，抛出 EIO 。

proc readInt64(s: Stream): int64 {.raises: [Exception, IOError], tags: [ReadIOEffect].}
     ## 从流读取一个 int64。如果出错，抛出 EIO 。

proc readFloat32(s: Stream): float32 {.raises: [Exception, IOError], tags: [ReadIOEffect].}
     ## 从流读取一个 float32尔。如果出错，抛出 EIO 。

proc readFloat64(s: Stream): float64 {.raises: [Exception, IOError], tags: [ReadIOEffect].}
     ## 从流读取一个 float64。如果出错，抛出 EIO 。

proc readStr(s: Stream; length: int): TaintedString {.raises: [Exception], tags: [ReadIOEffect].}
     ## 从流读取一个指定长度的字符串。如果出错，抛出 EIO 。

proc readLine(s: Stream; line: var TaintedString): bool 
             {.raises: [Exception], tags: [ReadIOEffect].}
     ## 从流读取一行文本，不能是 nil。可以抛出 IO 。行界限符是 CR、LF、CRLF。换行符不包含在返回文本中。如果
     ## 到达文件末尾，返回 false，否则返回true 。如果返回 false，line 不包含新数据。

proc readLine(s: Stream): TaintedString {.raises: [Exception], tags: [ReadIOEffect].}
     ## 从流读取一行文本。注意：这个过程效率不高。如果出错抛出 EIO 。
```

<span>

```
proc newStringStream(s: string = ""): StringStream {.raises: [], tags: [].}
     ## 从字符串创建一个流。

proc newFileStream(f: File): FileStream {.raises: [], tags: [].}
     ## 从文件对象创建一个流。

proc newFileStream(filename: string; mode: FileMode): FileStream {.raises: [], tags: [].}
     ## 从文件名创建一个流。如果文件不能打开，返回 nil。
```


