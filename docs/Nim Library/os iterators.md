[Module os （iterators）](http://nim-lang.org/docs/os.html)
==============================================================

```
iterator envPairs(): tuple[key, value: TaintedString] {.tags: [ReadEnvEffect], raises: [].}
         ## 迭代所有的环境变量。

iterator parentDirs(path: string; fromRoot = false; inclusive = true): string 
                   {.raises: [], tags: [].}
         ## 迭代给出路径的所有上级目录。如果fromRoot 是 true，会从系统根目录开始迭代。如果 inclusive 是 
         ## true，原始参数会被包含在迭代中。Relative paths won't be expanded by this proc. Instead, 
         ## it will traverse only the directories appearing in the relative path.

iterator walkFiles(pattern: string): string {.tags: [ReadDirEffect], raises: [].}
         ## 迭代所有的匹配模式的文件。在 POSIX 系统，这使用全局调用。

iterator walkDir(dir: string): tuple[kind: PathComponent, path: string] 
                {.tags: [ReadDirEffect], raises: [].}
         ## 迭代目录，返回每个目录或者文件。

iterator walkDirRec(dir: string; filter = {pcFile, pcDir}): string 
                   {.tags: [ReadDirEffect], raises: [].}
         ## 迭代目录，返回每个文件。
         filter         meaning
         pcFile         yield real files
         pcLinkToFile   yield symbolic links to files
         pcDir          follow real directories
         pcLinkToDir    follow symbolic links to directories
```