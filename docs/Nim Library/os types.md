[Module os （types）](http://nim-lang.org/docs/os.html)
==========================================================

This module contains basic operating system facilities like retrieving environment variables, reading command line arguments, working with directories, running shell commands, etc.

```
import strutils, times, winlean 
```

<span>

```
ReadEnvEffect  = object of ReadIOEffect   ## effect，表示读取一个环境变量
WriteEnvEffect = object of WriteIOEffect  ## effect，表示写入一个环境变量
ReadDirEffect  = object of ReadIOEffect   ## effect，表示读取一个目录结构
WriteDirEffect = object of WriteIOEffect  ## effect，表示写入一个目录结构
OSErrorCode    = distinct int32           ## 指定一个 OS 错误代码
FilePermission = enum                     ## 文件访问权限
    fpUserExec,                              ## execute access for the file owner
    fpUserWrite,                             ## write access for the file owner
    fpUserRead,                              ## read access for the file owner
    fpGroupExec,                             ## execute access for the group
    fpGroupWrite,                            ## write access for the group
    fpGroupRead,                             ## read access for the group
    fpOthersExec,                            ## execute access for others
    fpOthersWrite,                           ## write access for others
    fpOthersRead                             ## read access for others
PathComponent = enum                      ## 文件路径组件
    pcFile,                                  ## path refers to a file
    pcLinkToFile,                            ## path refers to a symbolic link to a file
    pcDir,                                   ## path refers to a directory
    pcLinkToDir                              ## path refers to a symbolic link to a directory
DeviceId = int32
FileId   = int64
FileInfo = object                         ## 包含关联信息的文件对象
    id             : tuple[device: DeviceId, file: FileId]
    kind           : PathComponent
    size           : BiggestInt
    permissions    : set[FilePermission]
    linkCount      : BiggestInt
    lastAccessTime : Time
    lastWriteTime  : Time
    creationTime   : Time
```
