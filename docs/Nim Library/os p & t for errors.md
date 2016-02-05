[Module os （p & t for errors）](http://nim-lang.org/docs/os.html)
=====================================================================

```
proc `==`(err1, err2: OSErrorCode): bool {.borrow.}

proc `$`(err: OSErrorCode): string {.borrow.}

proc osErrorMsg(errorCode: OSErrorCode): string {.raises: [], tags: [].}
     ## 把错误代码转换为可读的字符串。可以使用 osLastError 获取错误代码。如果失败，或者 errorCode 是 0，
     ## 返回 "" 。

proc raiseOSError(errorCode: OSErrorCode) {.raises: [OSError], tags: [].}
     ## 抛出一个 OSError 。错误代码会确定消息。osErrorMsg 可以用来获取消息。如果错误代码是 0，或者不能检索
     ## 到消息，会使用 unknown OS error 作为消息。

proc osLastError(): OSErrorCode {.raises: [], tags: [].}
     ## 获取上一次操作系统的错误代码。当操作系统出现失败操作时，这是很有用的。返回一个描述失败原因的错误代码。
     ## oSErrorMsg 可以用来把这个错误代码转换成消息。警告：在 Windows 和 POSIX 系统中，这个调用的行为是
     ## 不同的。在 Windows 中一些系统调用可以重置错误代码为 0，使这个调用返回 0 。因此，操作系统操作一旦失败，
     ## 立刻调用这个过程。在 POSIX 系统中，没有这个问题。
```

### example

```
echo "os last error: ", osErrorMsg(osLastError())

// os last error: 
```