Module system （consts）
==============================

```
on = true                             ## true 的别名
off = false                           ## false 的别名

appType: string = ""                  ## 描述应用程序类型的 string； 可能值 console | gui | lib
NoFakeVars = false                    ## 如果后台不支持 "fake variables"，
                                         像 var EBADF {.importc.}: cint，为 true 
isMainModule: bool = false            ## 访问 main module 时为 true； 方便在模块中嵌入测试代码
CompileDate: string = "0000-00-00"    ## 编译的日期是 YYYY-MM-DD 格式
CompileTime: string = "00:00:00"      ## 编译的日期是 HH:MM:SS 格式

cpuEndian: Endianness = littleEndian  ## 目标 CPU 的字节序； 用于低阶编程，获取信息
hostOS: string = ""                   ## 描述主机的操作系统； 可能值 
                                      ## "windows" | "macosx"  | "linux" | "netbsd" | "freebsd" |
                                      ## "openbsd" | "solaris" | "aix"   | "standalone"
hostCPU: string = ""                  ## 描述主机的 CPU； 可能值  
                                      ## "i386"  | "alpha" | "powerpc" | "powerpc64" | 
                                      ## "sparc" | "amd64" | "mips"    | "arm"

QuitSuccess = 0                       ## 传递给 quit(code) 的值，表明 success
QuitFailure = 1                       ## 传递给 quit(code) 的值，表明 failure

Inf = inf                             ## IEEE floating point 正无穷大的值
NegInf = -inf                         ## IEEE floating point 负无穷大的值
NaN = nan                             ## contains an IEEE floating point value of Not A Number. 
                                      ## Note that you cannot compare a floating point value to 
                                      ## this value and expect a reasonable result - use the 
                                      ## classify procedure in the module math for checking for
                                      ## NaN

NimMajor: int = 0                     ## Nim 主版本号
NimMinor: int = 11                    ## Nim 副版本号
NimPatch: int = 2                     ## Nim 补丁版本号
NimVersion: string = "0.11.2"         ## Nim 版本号
nativeStackTraceSupported = false
```