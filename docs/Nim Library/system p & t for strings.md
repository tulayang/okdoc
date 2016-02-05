Module system （p & t for strings）
===========================================

```
proc newString(len: Natural): string 
              {.magic: "NewString", importc: "mnewString", noSideEffect.}
     ## 创建一个新的 string，长度为 len，未初始化。仅用于优化目的。等同于 & 或者 add。

proc newStringOfCap(cap: Natural): string 
                   {.magic: "NewStringOfCap", importc: "rawNewString", noSideEffect.}
     ## 创建一个新的 string，长度为 0，上限为 cap。仅用于优化目的。等同于 & 或者 add。

proc repr[T](x: T): string {.magic: "Repr", noSideEffect.}

proc len(x: string) : int {.magic: "LengthStr", noSideEffect.}
proc len(x: cstring): int {.magic: "LengthStr", noSideEffect.}
     ## 获取长度。约等于 high(T) - low(T) + 1 。

proc xlen(x: string): int {.magic: "XLenStr", noSideEffect, raises: [], tags: [].}
     ## 获取长度，并且不检测 nil。一种用于 nil 问题的优化。

proc setLen(s: var string; newlen: Natural) {.magic: "SetLengthStr", noSideEffect.}
     ### 设置新的长度，如果长度溢出则缩短。s 不能是 nil！ 

proc substr(s: string; first = 0)       : string 
           {.magic: "CopyStr", importc: "copyStr", noSideEffect.}
proc substr(s: string; first, last: int): string 
           {.magic: "CopyStrLast", importc: "copyStrLast", noSideEffect.}
     ## 拷贝 s 的一个切片，返回新的 string。first 和 last 也会拷贝。如果 last 省略，使用  high(s)； 如果 
     ## last >= s.len， 使用 s.len 代替 last。也可以用于缩短 string 的长度。

proc `[]`(s: string; x: Slice[int]): string {.inline, raises: [], tags: [].}
     ## strings 切片操作符

proc `[]=`(s: var string; x: Slice[int]; b: string) {.raises: [], tags: [].}
     var s = "abcdef"
     s[1 .. ^2] = "xyz"
     assert s == "axyzf"
     ## strings 切片赋值操作符

proc `&`(x: string; y: char)  : string {.magic: "ConStrStr", noSideEffect, merge.}
     assert "ab" & 'c' == "abc"
proc `&`(x: char;   y: char)  : string {.magic: "ConStrStr", noSideEffect, merge.}
     assert 'a' & 'b' == "ab"
proc `&`(x: string; y: string): string {.magic: "ConStrStr", noSideEffect, merge.}
     assert "ab" & "cd" == "abcd"
proc `&`(x: char;   y: string): string {.magic: "ConStrStr", noSideEffect, merge.}
     assert 'a' & "bc" == "abc"

proc add(x: var string; y: char) {.magic: "AppendStrCh", noSideEffect.}
     var tmp = ""
     add(tmp, 'a')
     add(tmp, 'b')
     assert tmp == "ab"
proc add(x: var string; y: string) {.magic: "AppendStrStr", noSideEffect.}
     var tmp = ""
     add(tmp, "ab")
     add(tmp, "cd")
     assert(tmp == "abcd")
     ## 向 x 添加 y

proc add(x: var string; y: cstring) {.raises: [], tags: [].}

proc safeAdd(x: var string; y: char) {.raises: [], tags: [].}
proc safeAdd(x: var string; y: string) {.raises: [], tags: [].}

proc insert(x: var string; item: string; i = 0.Natural) {.noSideEffect, raises: [], tags: [].}
     ## 向 string x 添加 item

proc `$`       (x: int)    : string {.magic: "IntToStr",   noSideEffect.}  # => 十进制
proc `$`       (x: int64)  : string {.magic: "Int64ToStr", noSideEffect.}  # => 十进制
proc `$`       (x: float)  : string {.magic: "FloatToStr", noSideEffect.}  # => 十进制
proc `$`       (x: bool)   : string {.magic: "BoolToStr",  noSideEffect.}  # => "false" | "true"
proc `$`       (x: char)   : string {.magic: "CharToStr",  noSideEffect.}  
proc `$`       (x: cstring): string {.magic: "CStrToStr",  noSideEffect.}  
proc `$`       (x: string) : string {.magic: "StrToStr",   noSideEffect.}  # 多用于泛型，比如 $expr
proc `$`[TEnum](x: TEnum)  : string {.magic: "EnumToStr",  noSideEffect.} 
proc `$`       (x: uint64) : string {.noSideEffect, raises: [], tags: [].} # => 十进制
     ## 转换为 string

proc `$`[T](x: T)     : string  
      $(23, 45) == "(23, 45)"
      $() == "()"

proc `$`[T](x: set[T]): string 
      ${23, 45} == "{23, 45}"

proc `$`[T](x: seq[T]): string 
      $(@[23, 45]) == "@[23, 45]"
```