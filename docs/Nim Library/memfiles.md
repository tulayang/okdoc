[Module memfiles](http://nim-lang.org/docs/memfiles.html)                                                
=====================

This module provides support for memory mapped files (Posix's mmap) on the different operating systems.

```
import winlean, os 
```


Types
--------

```
MemFile = object             ## 表示一个内存映射文件
    mem*: pointer               ## a pointer to the memory mapped file. The pointer
                                ## can be used directly to change the contents of the
                                ## file, if it was opened with write access.
    size*: int                  ## size of the memory mapped file
    when defined(windows): 
        fHandle: int
        mapHandle: int

    else: 
        handle: cint
```

Procs
--------

```
proc mapMem(m: var MemFile; mode: FileMode = fmRead; mappedSize = -1; offset = 0): pointer 
           {.raises: [OSError], tags: [].}

proc unmapMem(f: var MemFile; p: pointer; size: int) {.raises: [OSError], tags: [].}
     ## 取消对区域 (p, <p+size) 的内存映射。如果内存映射文件使用可写模式打开，所有的改变会写入文件系统。
     ## size 必须与 mapMem 的相同。

proc open(filename: string; mode: FileMode = fmRead; mappedSize = - 1; 
          offset = 0; newFileSize = - 1): MemFile {.raises: [OSError], tags: [].}
     ## 打开一个内存映射文件。如果失败，抛出 EOS 。如果文件不存在，只有在写模式（比如 fmReadWrite）才能打开。
     ## 例子：
        var 
            mm, mm_full, mm_half: MemFile

        mm = memfiles.open("/tmp/test.mmap", mode = fmWrite, newFileSize = 1024) 
        mm.close()

        # Read the whole file, would fail if newFileSize was set
        mm_full = memfiles.open("/tmp/test.mmap", mode = fmReadWrite, mappedSize = -1)

        # Read the first 512 bytes
        mm_half = memfiles.open("/tmp/test.mmap", mode = fmReadWrite, mappedSize = 512)

proc close(f: var MemFile) {.raises: [OSError], tags: [].}
     ## 关闭内存映射文件。如果使用写模式打开，所有的改变会写入文件系统。
```