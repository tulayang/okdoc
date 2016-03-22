# [线程](http://nim-lang.org/docs/manual.html#threads)

要启用线程，请在命令行加入 `--threads:on` 选项。system 模块包含了几个线程原语。低阶线程 API 可以参看 [threads](http://nim-lang.org/docs/threads.html) 和 [channels](http://nim-lang.org/docs/channels.html)。也有高阶的并行结构，参看 [spawn](http://nim-lang.org/docs/manual.html#spawn) 。

Nim 语言中，线程的内存模型和其他的通用编程语言相当不同（Ｃ，Pascal，Java）：每一个线程有自己的（GC）堆内存，以及只能是全局变量的共享内存。这帮助防止条件竞争。GC 的效能得到很多改善：因为 GC 绝不会停止其他线程，也不查看线程之间的引用。内存分配完全不需要锁！这种设计很容易扩展到大规模的多核处理器环境。

## {.thread.}

作为一个新线程执行的函数，请使用 `{.thread.}` 语法标记，以提高可读性。编译器通常会执行无堆共享检查： 从其他线程（线程局部）堆分配的内存构造一个数据结构是无效的。

一个线程函数被传递给 `createThead()` 或者 `spawn()`，并被间接调用。因此，`{.thread.}` 隐含 `{.procvar.}` 。

## GC 安全

调用函数 `p` 是 GC 安全的，当：它没有访问任何使用 GC 内存（`string`、`seq`、`ref` 或者一个闭包）的全局变量，也没有直接或者间接调用 GC 不安全的函数。

`{.gcsafe.}` 语法标记，可以用来注释一个函数是 GC 安全的，否则编译器会对此进行推算。`{.noSideEfect.}` 语法标记隐含 `{.gcsafe.}`。创建线程的唯一途径是通过 `createThead()` 或者 `spawn()`。`spawn()` 通常会是更好的选择！无论哪种方式，调用的函数不能使用 var 形参，参数内也不能含有 `ref` 或者 `closure` 类型。这能保证无堆共享。

从 C 语言导入的例程，总是被假定为 `{.gcsafe.}`。使用命令项 **--threadAnalysis:off** 可以开启关闭 GC 安全检测。这是一个临时解决方案，用来缓解旧代码移植到新的线程模型。

未来方向:
* 可能提供一个 GC 共享堆

*译注：可以突破 Nim 标准库线程的限制，直接使用 C 线程库，比如 Pthreads，此时其线程内存模型完全是由 C 语言决定。*

*译注：本处的 createThead spawn 仅限于使用 Nim 标准库中的 threads 模块和 threadpool 模块。*

## {.threadvar.}

`{.threadvar.}` 用来标记一个全局变量，使其成为一个线程局部变量：

```nim
var checkpoints* {.threadvar.} : seq[string]
```

线程局部变量，不能用 var 初始化（每个线程局部变量，需要在线程被创建时复制）。

## 线程和异常

线程和异常之间的互作用很简单：在一个线程中，受到处理的异常，不影响其它任何线程。然而，如果出现异常却没有处理，会终止整个进程！ 

