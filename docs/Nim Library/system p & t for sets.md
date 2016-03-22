Module system （p & t for sets)
===============================

```
proc incl[T](x: var set[T]; y: T) {.magic: "Incl", noSideEffect.}      
	 ## 添加 y； 等同于 x = x + {y}，但更高效 
proc excl[T](x: var set[T]; y: T) {.magic: "Excl", noSideEffect.}      
     ## 删除 y； 等同于 x = x - {y}，但更高效 

template incl[T](s: var set[T]; flags: set[T])
template excl[T](s: var set[T]; flags: set[T])

proc card[T](x: set[T]): int      {.magic: "Card", noSideEffect.}      
	 ## 获取元素的个数

proc `*`[T](x, y: set[T]): set[T] {.magic: "MulSet",   noSideEffect.}  
     ## 交集

proc `+`[T](x, y: set[T]): set[T] {.magic: "PlusSet",  noSideEffect.}  
     ## 连接

proc `-`[T](x, y: set[T]): set[T] {.magic: "MinusSet", noSideEffect.}  
     ## 差集

proc contains[T](x: set[T];   y: T)    : bool {.magic: "InSet", noSideEffect.} 
proc contains[T](s: Slice[T]; value: T): bool {.noSideEffect,   inline.}
     assert (1..3).contains(1) == true
     assert (1..3).contains(2) == true
     assert (1..3).contains(4) == false
     ## 包含元素
```