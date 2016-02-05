Module system （p & t for raises）
===========================================

```
proc getCurrentException(): ref Exception 
                        {.compilerproc, inline, gcsafe, locks: 0, raises: [], tags: [].}
     ## 获取当前的异常，如果没有，返回 nil 。

proc getCurrentExceptionMsg(): string {.inline, gcsafe, locks: 0, raises: [], tags: [].}
     ## 获取当前的异常附加的错误消息，如果没有，返回 "" 。

proc setCurrentException(exc: ref Exception) {.inline, gcsafe, locks: 0, raises: [], tags: [].}
     ## 设置当前异常。警告: 当你确切知道在做什么时，才使用。

proc onRaise(action: proc (e: ref Exception): bool {.closure.}) {.raises: [], tags: [].}
     ## 可以用于 try 语句内部，启动一个类似 Lisp 的条件系统: 
     ## 使用 action 代替 raise 语句。如果 action 返回 false，异常会被触发，不会向调用栈传播。

template newException[](exceptn: typedesc; message: string): expr
     ## 创建一个 exceptn 的异常对象。
```