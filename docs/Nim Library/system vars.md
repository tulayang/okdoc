Module system （vars）
=======================


```
programResult: int
	## 修改这个变量，来指定程序在正常情况下退出代码。当使用 quit() 提前退出时，这个值会被忽略
                     
globalRaiseHook: proc (e: ref Exception): bool {.nimcall, gcsafe, locks: 0.}
	## 使用这个钩子，你可以在全局级别影响异常操作。如果不是 nil，每个 raise 语句都会调用这个钩子结束。永远
	## 不要在普通应用程序代码中设置这个钩子！设置这个钩子时，你最好知道你在做什么。如果 globalRaiseHook(e)
	## 返回 false，这个异常会被抛出，并且不会通过栈进一步传播。

localRaiseHook: proc (e: ref Exception): bool {.nimcall, gcsafe, locks: 0.}
	## 使用这个钩子，你可以在一个线程局部影响异常操作。如果不是 nil，每个 raise 语句都会调用这个钩子结束。永远
	## 不要在普通应用程序代码中设置这个钩子！设置这个钩子时，你最好知道你在做什么。如果 localRaiseHook(e) 
	## 返回false，这个异常会被抛出，并且不会通过栈进一步传播。

outOfMemHook: proc () {.nimcall, tags: [], gcsafe, locks: 0.}
	## 设置这个钩子，提供一个 procedure，当内存溢出（事件）时会被调用。这个标准的触发器，会打印错误消息并且
	## 结束程序。可以用来抛出一个异常，像这样:
    var gOutOfMem: ref EOutOfMemory
    new(gOutOfMem) ## need to be allocated *before* OOM really happened!
    gOutOfMem.msg = "out of memory"

    proc handleOOM() =
        raise gOutOfMem

    system.outOfMemHook = handleOOM
	## 如果这个触发器没有抛出异常，普通控制流继续，并且结束程序。

stdin : File  ## 标准输入流
stdout: File  ## 标准输出流
stderr: File  ## 标准错误流

errorMessageWriter: (proc (msg: string) {.tags: [WriteIOEffect], gcsafe, locks: 0.})
	## 当打印栈追踪时，代替 stdmsg.write 被调用的函数。不稳定的 API
```