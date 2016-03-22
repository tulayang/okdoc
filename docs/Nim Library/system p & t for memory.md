Module system （p & t for memory）
=======================================

```
proc new[T](a: var ref T) {.magic: "New", noSideEffect.}
proc new[] (T: typedesc ): ref T
proc new[T](a: var ref T; finalizer: proc (x: ref T) {.nimcall.}) 
           {.magic: "NewFinalize", noSideEffect.}
	 ## 创建类型 T 的新对象（堆内存），返回一个安全（追踪）引用。当垃圾收集器释放对象时，finalizer 会被调用。

proc unsafeNew*[T](a: var ref T, size: Natural) {.magic: "New", noSideEffect.}
     ## 创建类型 T 的新对象（堆内存），返回一个安全（追踪）引用。当传递 size 分配对象内存时，是 unsafe 的！
     ## 仅用于优化目的，你应该知道你在做什么。
```

<span>

```
proc alloc (size: Natural): pointer {.noconv, gcsafe, tags: [], locks: 0, raises: [Exception].}
	 ## 分配一块内存，至少 size 字节。这个内存块必须使用 realloc(block, 0)，dealloc(block) 释放。内存块
	 ## 不初始化。分配的内存属于分配线程。

proc alloc0(size: Natural): pointer {.noconv, gcsafe, tags: [], locks: 0, raises: [Exception].}
	 ## 分配一块内存，至少 size 字节。这个内存块必须使用 realloc(block, 0)，dealloc(block) 释放。内存块
	 ## 使用 0 初始化。分配的内存属于分配线程。

proc realloc(p: pointer; newSize: Natural): pointer 
     {.noconv, gcsafe, tags: [], gcsafe, locks: 0, raises: [Exception].}
	 ## 增加|缩小内存块的大小。如果 p 是 nil，分配一块新的内存。如果 newSize == 0， p ！= nil 会
	 ## 调用 dealloc(p)。分配的内存属于分配线程。

proc dealloc(p: pointer) {.noconv, gcsafe, tags: [], gcsafe, locks: 0, raises: [Exception].}
	 ## 释放 alloc，alloc0，realloc 分配的内存。如果忘记了释放内存，会引起内存泄露！释放的内存属于分配线程。
```

<span>

```
proc allocShared (size: Natural): pointer 
                 {.noconv, gcsafe, gcsafe, locks: 0, raises: [Exception], tags: [].}
	 ## 分配一块内存，至少 size 字节。这个内存块必须使用 reallocShared(block, 0)，deallocShared(block) 
	 ## 释放。内存块不初始化。分配的内存属于共享堆。

proc allocShared0(size: Natural): pointer 
                 {.noconv, gcsafe, gcsafe, locks: 0, raises: [Exception], tags: [].}
	 ## 分配一块内存，至少 size 字节。这个内存块必须使用 reallocShared(block, 0)，deallocShared(block) 
	 ## 释放。内存块使用 0 初始化。分配的内存属于共享堆。

proc reallocShared(p: pointer; newSize: Natural): pointer 
                  {.noconv, gcsafe, gcsafe, locks: 0, raises: [Exception], tags: [].}
	 ## 增加|缩小内存块的大小。如果 p 是 nil，分配一块新的内存。如果 newSize == 0， p ！= nil 会
	 ## 调用 deallocShared(p)。分配的内存属于共享堆。

proc deallocShared(p: pointer) 
                  {.noconv, gcsafe, gcsafe, locks: 0, raises: [Exception], tags: [].}
	 ## 释放 allocShared，allocShared0，reallocShared 分配的内存。如果忘记了释放内存，会引起内存泄露！
	 ## 释放的内存属于共享堆。
```

<span>

```
proc createU[](T: typedesc; size = 1.Positive): ptr T:type {.inline, gcsafe, locks: 0.}
	 ## 分配一块内存，至少 T.sizeof * size 字节。这个内存块必须使用 resize(block, 0)，free(block) 释放。
	 ## 内存块不初始化。分配的内存属于分配线程。

proc create[] (T: typedesc; size = 1.Positive): ptr T:type {.inline, gcsafe, locks: 0.}
	 ## 分配一块内存，至少 T.sizeof * size 字节。这个内存块必须使用 resize(block, 0)，free(block) 释放。
	 ## 内存块使用 0 初始化。分配的内存属于分配线程。

proc resize[T](p: ptr T; newSize: Natural): ptr T {.inline, gcsafe, locks: 0.}
	 ## 增加|缩小内存块的大小。如果 p 是 nil，分配一块新的内存。如果 newSize == 0， p ！= nil 会
	 ## 调用 free(p)。分配的内存属于分配线程。

proc free[T](p: ptr T) {.inline, gcsafe, locks: 0.}
	 ## 释放 createU，create，resize 分配的内存。如果忘记了释放内存，会引起内存泄露！释放的内存属于分配线程。
```

<span>

```
proc createSharedU[](T: typedesc; size = 1.Positive): ptr T:type {.inline, gcsafe, locks: 0.}
	 ## 分配一块内存，至少 T.sizeof * size 字节。这个内存块必须使用 resizeShared(block, 0)，
	 ## freeShared(block) 释放。内存块不初始化。分配的内存属于共享堆。

proc createShared[] (T: typedesc; size = 1.Positive): ptr T:type {.inline, gcsafe, locks: 0.}
	 ## 分配一块内存，至少 T.sizeof * size 字节。这个内存块必须使用 resizeShared(block, 0)，
	 ## freeShared(block) 释放。内存块使用 0 初始化。分配的内存属于共享堆。

proc resizeShared[T](p: ptr T; newSize: Natural)    : ptr T      {.inline.}
	 ## 增加|缩小内存块的大小。如果 p 是 nil，分配一块新的内存。如果 newSize == 0， p ！= nil 会
	 ## 调用 free(p)。分配的内存属于共享堆。

proc freeShared[T](p: ptr T)                                     {.inline, gcsafe, locks: 0.}
	 ## 释放 createSharedU，createShared，resizeShared 分配的内存。如果忘记了释放内存，会引起内存泄露！
	 ## 释放的内存属于共享堆。
```

