[Module os （p & t for fs）](http://nim-lang.org/docs/os.html)
=====================================================================

```
proc existsFile(filename: string): bool 
               {.gcsafe, extern: "nos$1", tags: [ReadDirEffect], raises: [].}
proc fileExists(filename: string): bool 
               {.inline, raises: [], tags: [ReadDirEffect].}
     ## 文件存在？

proc existsDir(dir: string): bool 
              {.gcsafe, extern: "nos$1",tags: [ReadDirEffect], raises: [].}
proc dirExists(dir: string): bool 
              {.inline, raises: [], tags: [ReadDirEffect].}
     ## 目录存在？

proc symlinkExists(link: string): bool 
                  {.gcsafe, extern: "nos$1", tags: [ReadDirEffect], raises: [].}
     ## 符号链接（文件、目录）存在？

proc isRootDir(path: string): bool 
              {.noSideEffect, gcsafe, extern: "nos$1", raises: [], tags: [].}
     ## 主目录？

proc cmpPaths(pathA, pathB: string): int 
             {.noSideEffect, gcsafe, extern: "nos$1", raises: [], tags: [].}
     ## 路径相同？

proc isAbsolute(path: string): bool 
               {.gcsafe, noSideEffect, extern: "nos$1", raises: [], tags: [].}
     ## 绝对路径？

proc sameFile(path1, path2: string): bool 
             {.gcsafe, extern: "nos$1", tags: [ReadDirEffect], raises: [OSError].}
     ## 同一个物理文件/目录？ 如果失败，抛出 OSError 。如果给出两个硬链接或者符号链接指向相同文件/目录，
     ## 返回 true。

proc sameFileContent(path1, path2: string): bool 
                    {.gcsafe, extern: "nos$1", tags: [ReadIOEffect], raises: [Exception].}
     ## 文件二进制内容完全相同？

proc isHidden(path: string): bool {.raises: [], tags: [].}
     ## 给出的路径是隐藏的？如果不存在，返回 false 。给出的路径，必须在当前目录中可进入。在 Windows 系统，
     ## 一个隐藏的文件通过设置 hidden 属性。在 Unix-like 系统，一个文件通过 '.xxx' 隐藏。
```

<span>

```
proc getLastModificationTime(file: string): Time 
                            {.gcsafe, extern: "nos$1", raises: [OSError], tags: [].}
     ## 返回上次文件修改时间。

proc getLastAccessTime(file: string): Time 
                      {.gcsafe, extern: "nos$1", raises: [OSError], tags: [].}
     ## 返回上次文件访问时间。

proc getCreationTime(file: string): Time 
                    {.gcsafe, extern: "nos$1", raises: [OSError], tags: [].}
     ## 返回文件创建时间。注意，在 POSIX 系统，可能返回的是文件属性的最后修改时间。

proc fileNewer(a, b: string): bool {.gcsafe, extern: "nos$1", raises: [OSError], tags: [].}
     ## a 的修改时间比 b 的修改时间晚？（a 更新）
```

<span>

```
proc getFileSize(file: string): BiggestInt 
                {.gcsafe, extern: "nos$1", tags: [ReadIOEffect], raises: [OSError].}
     ## 返回文件尺寸。如果失败，抛出 OSError 。

proc findExe(exe: string): string {.tags: [ReadDirEffect, ReadEnvEffect], raises: [].}
     ## 查找当前工作目录的 exe ，然后在 PATH 环境变量中列出目录。

proc getFileInfo(handle: FileHandle): FileInfo {.raises: [OSError], tags: [].}
proc getFileInfo(file: File)        : FileInfo {.raises: [IOError, OSError], tags: [].}
proc getFileInfo(path: string; followSymlink = true): FileInfo 
                                               {.raises: [OSError], tags: [].}
     ## 返回文件信息。如果失败，抛出 OSError 。
     
proc getHomeDir(): string {.gcsafe, extern: "nos$1", tags: [ReadEnvEffect], raises: [].}
     ## 返回当前用户的用户目录。
     
proc getConfigDir(): string {.gcsafe, extern: "nos$1", tags: [ReadEnvEffect], raises: [].}
     ## 返回当前用户的应用程序配置目录。

proc getTempDir(): string {.gcsafe, extern: "nos$1", tags: [ReadEnvEffect], raises: [].}
     ## 返回当前用户的用于应用程序存储的临时目录。

proc getAppFilename(): string 
                   {.gcsafe, extern: "nos$1", tags: [ReadIOEffect], raises: [Exception].}
     ## 返回运行文件名。

proc getAppDir(): string {.gcsafe, extern: "nos$1", tags: [ReadIOEffect], raises: [Exception].}
     ## 返回运行文件的目录名。注意：在 BSD 中工作不可靠。

proc parentDir(path: string): string 
              {.noSideEffect, gcsafe, extern: "nos$1", raises: [], tags: [].}
     ## 返回上级目录。
     parentDir("/usr/local/bin")  == "/usr/local"
     parentDir("/usr/local/bin/") == "/usr/local"

proc `/../`(head, tail: string): string {.noSideEffect, raises: [], tags: [].}
     ## 同 parentDir(head) / tail，除非没有上级目录。

proc getCurrentDir(): string {.gcsafe, extern: "nos$1", tags: [], raises: [OSError].}
     ## 返回当前工作目录。

proc setCurrentDir(newDir: string) {.inline, tags: [], raises: [OSError].}
     ## 设置当前工作目录。如果目录不能设置，抛出 OSError 。

proc expandFilename(filename: string): string 
                   {.gcsafe, extern: "nos$1", tags: [ReadDirEffect], raises: [OSError].}
     ## 返回文件名的绝对路径。如果出现错误，抛出 OSError 。

proc changeFileExt(filename, ext: string): string 
                  {.noSideEffect, gcsafe, extern: "nos$1", raises: [], tags: [].}
     ## 修改文件扩展名。如果文件没有扩展名，则加入。如果 ext == ""，则移除扩展名。ext 不应该使用 '.'，
     ## 因为一些文件系统可能使用不同的字符。

proc addFileExt(filename, ext: string): string 
               {.noSideEffect, gcsafe, extern: "nos$1", raises: [], tags: [].}
     ## 添加一个文件扩展名，除非文件已经有了扩展名。ext 不应该使用 '.'，因为一些文件系统可能使用不同的字符。
```     
<span>

```
proc getFilePermissions(filename: string): set[FilePermission] 
                       {.gcsafe, extern: "nos$1", tags: [ReadDirEffect], raises: [OSError].}
     ## 获取文件权限。如果失败，抛出 OSError 。在 Windows，只检测只读，其他任何权限都是有效的。

proc setFilePermissions(filename: string; permissions: set[FilePermission]) 
                       {.gcsafe, extern: "nos$1", tags: [WriteDirEffect], raises: [OSError].}
     ## 设置文件权限。如果失败，抛出 OSError 。在 Windows，只设置只读，其他任何权限都是有效的。

proc inclFilePermissions(filename: string; permissions: set[FilePermission]) 
                        {.gcsafe, extern: "nos$1", 
                          tags: [ReadDirEffect, WriteDirEffect], raises: [OSError].}
     ## 一个方便的过程，用来：
        setFilePermissions(filename, getFilePermissions(filename) + permissions)
  
proc exclFilePermissions(filename: string; permissions: set[FilePermission]) 
                        {.gcsafe, extern: "nos$1", 
                          tags: [ReadDirEffect, WriteDirEffect], raises: [OSError].}
     ## 一个方便的过程，用来：
        setFilePermissions(filename, getFilePermissions(filename) - permissions)
```

<span>

```
proc copyFile(source, dest: string) 
             {.gcsafe, extern: "nos$1", tags: [ReadIOEffect, WriteIOEffect], raises: [OSError].}
     ## 拷贝文件。如果失败，抛出 OSError 。在 Windows，也会拷贝源文件的文件属性。在其他平台，需要手动使用 
     ## getFilePermissions() 和 setFilePermissions() 拷贝一些文件属性（或者使用 
     ## copyFileWithPermissions() 过程）。否则，目标文件会使用默认的权限。如果目标文件已经存在，文件属性会
     ## 被覆盖。

proc copyFileWithPermissions(source, dest: string; ignorePermissionErrors = true) 
                            {.raises: [OSError], tags: [ReadIOEffect, WriteIOEffect].}
     ## 拷贝文件，保留权限。如果失败，抛出 OSError 。在 Windows 系统，这是 copyFile() 包装器。在其他系统，
     ## 这是一个 copyFile()，getFilePermissions() 和 setFilePermissions() 的包装器。这时的拷贝不是原子
     ## 操作，可能引起数据竞争。如果 ignorePermissionErrors 是 true，读写属性的错误会被忽略。否则，抛出 
     ## OSError 。

proc moveFile(source, dest: string) 
             {.gcsafe, extern: "nos$1", tags: [ReadIOEffect, WriteIOEffect], raises: [OSError].}
     ## 移动文件。如果失败，抛出 OSError 。

proc removeFile(file: string) 
               {.gcsafe, extern: "nos$1", tags: [WriteDirEffect], raises: [OSError].}
     ## 删除文件。如果失败，抛出 OSError 。如果文件从来不存在，不会失败。在 Windows，忽略只读属性。

proc removeDir(dir: string) {.gcsafe, extern: "nos$1", gcsafe, locks: 0, 
                              tags: [WriteDirEffect, ReadDirEffect], raises: [OSError].}
     ## 递归删除子目录、文件以及目录。如果失败，抛出 OSError 。

proc createDir(dir: string) {.gcsafe, extern: "nos$1", 
                              tags: [WriteDirEffect], raises: [OSError].}
     ## 创建目录。目录可以包含几个还不存在的子目录。如果失败，抛出 OSError 。如果目录已经存在的话，不会失败。

proc copyDir(source, dest: string) {.gcsafe, extern: "nos$1", gcsafe, locks: 0, 
                                     tags: [WriteIOEffect, ReadIOEffect], raises: [OSError].}
     ## 拷贝目录。如果失败，抛出 OSError 。在 WIndows，会拷贝目录属性。在其他平台，使用继承的默认属性。要递归
     ## 拷贝文件属性、目录属性使用 copyDirWithPermissions() 过程。

proc copyDirWithPermissions(source, dest: string; ignorePermissionErrors = true) 
                            {.gcsafe, extern: "nos$1", gcsafe, locks: 0, 
                              tags: [WriteIOEffect, ReadIOEffect], raises: [OSError].}
     ## 拷贝目录，保留权限。如果失败，抛出 OSError 。在 Windows 系统，这是 copyDir() 的包装器。在其他系统，
     ## 这是一个 copyDir() 和 copyFileWithPermissions() 的包装器。这时的拷贝不是原子操作，可能
     ## 引起数据竞争。如果 ignorePermissionErrors 是 true，读写属性的错误会被忽略。否则，抛出 OSError 。

proc createSymlink(src, dest: string) {.raises: [OSError], tags: [ReadDirEffect].}
     ## 创建一个符号链接。警告：在一些系统（比如 Windows）限制到管理员的符号链接。

proc createHardlink(src, dest: string) {.raises: [OSError], tags: [].}
     ## 创建一个硬连接。警告：大部分操作系统限制到管理员的硬连接。
```