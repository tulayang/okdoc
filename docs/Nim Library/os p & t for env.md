[Module os （p & t for env）](http://nim-lang.org/docs/os.html)
================================================================

```
proc getEnv(key: string): TaintedString {.tags: [ReadEnvEffect], raises: [].}
     ## 返回指定环境变量的值。如果不存在，返回 ""。

proc existsEnv(key: string): bool {.tags: [ReadEnvEffect], raises: [].}
     ## 指定环境变量存在？

proc putEnv(key, val: string) {.tags: [WriteEnvEffect], raises: [OSError].}
     ## 添加一条环境变量。如果失败，抛出 OSError 。


```

### example

```
putEnv("MYHELLO", "hello")
echo "env PATH?: ",    existsEnv("PATH")
echo "env PATH: ",     getEnv("PATH")
echo "env MYHELLO?: ", existsEnv("MYHELLO")
echo "env MYHELLO: ",  getEnv("MYHELLO")

// env PATH?    : true
// env PATH     : /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:
//                /sbin:/bin:/usr/games:/usr/local/games:/opt/jdk/bin:
//                /opt/jdk/jre/bin:/home/king/android/android-studio/sdk/tools:
//                /home/king/android/android-studio/sdk/platform-tools:
//                /usr/local/nim-0.11.2/bin:/home/king/.nimble/bin
// env MYHELLO? : true
// env MYHELLO  : hello
```