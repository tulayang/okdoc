Module system （p & t for numbers)
====================================

```
proc ze   (x   : int8) : int   {.magic: "Ze8ToI",        noSideEffect.}
proc ze   (x   : int16): int   {.magic: "Ze16ToI",       noSideEffect.}
proc ze64 (x   : int8) : int64 {.magic: "Ze8ToI64",      noSideEffect.}
proc ze64 (x   : int16): int64 {.magic: "Ze16ToI64",     noSideEffect.}
proc ze64 (x   : int32): int64 {.magic: "Ze32ToI64",     noSideEffect.}
proc ze64 (x   : int)  : int64 {.magic: "ZeIToI64",      noSideEffect.}
	 ## 零扩展一个小整数； x 作为 unsigned 对待

proc toU8 (x   : int)  : int8  {.magic: "ToU8",          noSideEffect.}  ## 后  8 位
proc toU16(x   : int)  : int16 {.magic: "ToU16",         noSideEffect.}  ## 后 16 位
proc toU32(x   : int64): int32 {.magic: "ToU32",         noSideEffect.}  ## 后 32 位
	 ## 转换后 X 位为一个新整数； x 作为 unsigned 对待

proc `+%`[IntMax32] (x, y: IntMax32): IntMax32 {.magic: "AddU",  noSideEffect.}
proc `+%`           (x, y: int64)   : int64    {.magic: "AddU",  noSideEffect.}
	 ## x + y，缩短结果以匹配结果值； 不可能出现溢出；x，y 作为 unsigned 对待

proc `-%`[IntMax32] (x, y: IntMax32): IntMax32 {.magic: "SubU",  noSideEffect.}
proc `-%`           (x, y: int64)   : int64    {.magic: "SubU",  noSideEffect.}
	 ## x - y，缩短结果以匹配结果值； 不可能出现溢出；x，y 作为 unsigned 对待

proc `*%`[IntMax32] (x, y: IntMax32): IntMax32 {.magic: "MulU",  noSideEffect.}
proc `*%`           (x, y: int64)   : int64    {.magic: "MulU",  noSideEffect.}
	 ## x * y，缩短结果以匹配结果值； 不可能出现溢出；x，y 作为 unsigned 对待

proc `/%`[IntMax32] (x, y: IntMax32): IntMax32 {.magic: "DivU",  noSideEffect.}
proc `/%`           (x, y: int64)   : int64    {.magic: "DivU",  noSideEffect.}
	 ## x / y，缩短结果以匹配结果值； 不可能出现溢出；x，y 作为 unsigned 对待

proc `%%`[IntMax32] (x, y: IntMax32): IntMax32 {.magic: "ModU",  noSideEffect.}
proc `%%`           (x, y: int64)   : int64    {.magic: "ModU",  noSideEffect.}
	 ## x % y，缩短结果以匹配结果值； 不可能出现溢出；x，y 作为 unsigned 对待

proc `<=%`[IntMax32](x, y: IntMax32): bool     {.magic: "LeU",   noSideEffect.}
proc `<=%`          (x, y: int64)   : bool     {.magic: "LeU64", noSideEffect.}
	 ## unsigned(x) <= unsigned(y)；x，y 作为 unsigned 对待

proc `<%`[IntMax32] (x, y: IntMax32): bool     {.magic: "LtU",   noSideEffect.}
proc `<%`           (x, y: int64)   : bool     {.magic: "LtU64", noSideEffect.}
	 ## unsigned(x) < unsigned(y)；x，y 作为 unsigned 对待

template `>=%`(x, y: expr): expr {.immediate.}
         ## unsigned(x) >= unsigned(y)

template `>%`(x, y: expr): expr {.immediate.}
         ## unsigned(x) > unsigned(y)

proc `+`  (x   : int)  : int   {.magic: "UnaryPlusI",    noSideEffect.}
proc `+`  (x   : int8) : int8  {.magic: "UnaryPlusI",    noSideEffect.}
proc `+`  (x   : int16): int16 {.magic: "UnaryPlusI",    noSideEffect.}
proc `+`  (x   : int32): int32 {.magic: "UnaryPlusI",    noSideEffect.}
proc `+`  (x   : int64): int64 {.magic: "UnaryPlusI",    noSideEffect.}

proc `-`  (x   : int)  : int   {.magic: "UnaryMinusI",   noSideEffect.}
proc `-`  (x   : int8) : int8  {.magic: "UnaryMinusI",   noSideEffect.}
proc `-`  (x   : int16): int16 {.magic: "UnaryMinusI",   noSideEffect.}
proc `-`  (x   : int32): int32 {.magic: "UnaryMinusI",   noSideEffect.}
proc `-`  (x   : int64): int64 {.magic: "UnaryMinusI64", noSideEffect.}

proc `not`(x   : int)  : int   {.magic: "BitnotI",       noSideEffect.}
proc `not`(x   : int16): int16 {.magic: "BitnotI",       noSideEffect.}
proc `not`(x   : int32): int32 {.magic: "BitnotI",       noSideEffect.}
proc `not`(x   : int64): int64 {.magic: "BitnotI64",     noSideEffect.}

proc `+`  (x, y: int)  : int   {.magic: "AddI",          noSideEffect.}
proc `+`  (x, y: int8) : int8  {.magic: "AddI",          noSideEffect.}
proc `+`  (x, y: int16): int16 {.magic: "AddI",          noSideEffect.}
proc `+`  (x, y: int32): int32 {.magic: "AddI",          noSideEffect.}
proc `+`  (x, y: int64): int64 {.magic: "AddI64",        noSideEffect.}

proc `-`  (x, y: int)  : int   {.magic: "SubI",          noSideEffect.}
proc `-`  (x, y: int8) : int8  {.magic: "SubI",          noSideEffect.}
proc `-`  (x, y: int16): int16 {.magic: "SubI",          noSideEffect.}
proc `-`  (x, y: int32): int32 {.magic: "SubI",          noSideEffect.}
proc `-`  (x, y: int64): int64 {.magic: "SubI64",        noSideEffect.}

proc `*`  (x, y: int)  : int   {.magic: "MulI",          noSideEffect.}
proc `*`  (x, y: int8) : int8  {.magic: "MulI",          noSideEffect.}
proc `*`  (x, y: int16): int16 {.magic: "MulI",          noSideEffect.}
proc `*`  (x, y: int32): int32 {.magic: "MulI",          noSideEffect.}
proc `*`  (x, y: int64): int64 {.magic: "MulI64",        noSideEffect.}

proc `/`  (x, y: int)  : float {.inline,                 noSideEffect, raises: [], tags: [].}

proc `div`(x, y: int)  : int   {.magic: "DivI",          noSideEffect.}
proc `div`(x, y: int8) : int8  {.magic: "DivI",          noSideEffect.}
proc `div`(x, y: int16): int16 {.magic: "DivI",          noSideEffect.}
proc `div`(x, y: int32): int32 {.magic: "DivI",          noSideEffect.}
proc `div`(x, y: int64): int64 {.magic: "DivI64",        noSideEffect.}
	 ## 计算整数除法. 等同于 floor(x/y).
     1 div 2 == 0
     2 div 2 == 1
     3 div 2 == 1

proc `mod`(x, y: int)  : int   {.magic: "ModI",          noSideEffect.}
proc `mod`(x, y: int8) : int8  {.magic: "ModI",          noSideEffect.}
proc `mod`(x, y: int16): int16 {.magic: "ModI",          noSideEffect.}
proc `mod`(x, y: int32): int32 {.magic: "ModI",          noSideEffect.}
proc `mod`(x, y: int64): int64 {.magic: "ModI64",        noSideEffect.}

proc `shr`(x, y: int)  : int   {.magic: "ShrI",          noSideEffect.}
proc `shr`(x, y: int8) : int8  {.magic: "ShrI",          noSideEffect.}
proc `shr`(x, y: int16): int16 {.magic: "ShrI",          noSideEffect.}
proc `shr`(x, y: int32): int32 {.magic: "ShrI",          noSideEffect.}
proc `shr`(x, y: int64): int64 {.magic: "ShrI64",        noSideEffect.}
	 ## 计算按位右移 the shift right

proc `shl`(x, y: int)  : int   {.magic: "ShlI",          noSideEffect.}
proc `shl`(x, y: int8) : int8  {.magic: "ShlI",          noSideEffect.}
proc `shl`(x, y: int16): int16 {.magic: "ShlI",          noSideEffect.}
proc `shl`(x, y: int32): int32 {.magic: "ShlI",          noSideEffect.}
proc `shl`(x, y: int64): int64 {.magic: "ShlI64",        noSideEffect.}
	 ## 计算按位左移 the shift left

proc `and`(x, y: int)  : int   {.magic: "BitandI",       noSideEffect.}
proc `and`(x, y: int8) : int8  {.magic: "BitandI",       noSideEffect.}
proc `and`(x, y: int16): int16 {.magic: "BitandI",       noSideEffect.}
proc `and`(x, y: int32): int32 {.magic: "BitandI",       noSideEffect.}
proc `and`(x, y: int64): int64 {.magic: "BitandI64",     noSideEffect.}
	 ## 计算按位与

proc `or` (x, y: int)  : int   {.magic: "BitorI",        noSideEffect.}
proc `or` (x, y: int8) : int8  {.magic: "BitorI",        noSideEffect.}
proc `or` (x, y: int16): int16 {.magic: "BitorI",        noSideEffect.}
proc `or` (x, y: int32): int32 {.magic: "BitorI",        noSideEffect.}
proc `or` (x, y: int64): int64 {.magic: "BitorI64",      noSideEffect.}
	 ## 计算按位或
	 
proc `xor`(x, y: int)  : int   {.magic: "BitxorI",       noSideEffect.}
proc `xor`(x, y: int8) : int8  {.magic: "BitxorI",       noSideEffect.}
proc `xor`(x, y: int16): int16 {.magic: "BitxorI",       noSideEffect.}
proc `xor`(x, y: int32): int32 {.magic: "BitxorI",       noSideEffect.}
proc `xor`(x, y: int64): int64 {.magic: "BitxorI64",     noSideEffect.}

proc `==` (x, y: int)  : bool  {.magic: "EqI",           noSideEffect.}
proc `==` (x, y: int8) : bool  {.magic: "EqI",           noSideEffect.}
proc `==` (x, y: int16): bool  {.magic: "EqI",           noSideEffect.}
proc `==` (x, y: int32): bool  {.magic: "EqI",           noSideEffect.}
proc `==` (x, y: int64): bool  {.magic: "EqI64",         noSideEffect.}

proc `<=` (x, y: int)  : bool  {.magic: "LeI",           noSideEffect.}
proc `<=` (x, y: int8) : bool  {.magic: "LeI",           noSideEffect.}
proc `<=` (x, y: int16): bool  {.magic: "LeI",           noSideEffect.}
proc `<=` (x, y: int32): bool  {.magic: "LeI",           noSideEffect.}
proc `<=` (x, y: int64): bool  {.magic: "LeI64",         noSideEffect.}

proc `<`  (x, y: int)  : bool  {.magic: "LtI",           noSideEffect.}
proc `<`  (x, y: int8) : bool  {.magic: "LtI",           noSideEffect.}
proc `<`  (x, y: int16): bool  {.magic: "LtI",           noSideEffect.}
proc `<`  (x, y: int32): bool  {.magic: "LtI",           noSideEffect.}
proc `<`  (x, y: int64): bool  {.magic: "LtI64",         noSideEffect.}

proc min  (x, y: int)  : int   {.magic: "MinI",   noSideEffect, raises: [], tags: [].}
proc min  (x, y: int8) : int8  {.magic: "MinI",   noSideEffect, raises: [], tags: [].}
proc min  (x, y: int16): int16 {.magic: "MinI",   noSideEffect, raises: [], tags: [].}
proc min  (x, y: int32): int32 {.magic: "MinI",   noSideEffect, raises: [], tags: [].}
proc min  (x, y: int64): int64 {.magic: "MinI",   noSideEffect, raises: [], tags: [].}

proc max  (x, y: int)  : int   {.magic: "MaxI",   noSideEffect, raises: [], tags: [].}
proc max  (x, y: int8) : int8  {.magic: "MaxI",   noSideEffect, raises: [], tags: [].}
proc max  (x, y: int16): int16 {.magic: "MaxI",   noSideEffect, raises: [], tags: [].}
proc max  (x, y: int32): int32 {.magic: "MaxI",   noSideEffect, raises: [], tags: [].}
proc max  (x, y: int64): int64 {.magic: "MaxI",   noSideEffect, raises: [], tags: [].}

proc abs  (x: int)     : int   {.magic: "AbsI",   noSideEffect, raises: [], tags: [].}
proc abs  (x: int8)    : int8  {.magic: "AbsI",   noSideEffect, raises: [], tags: [].}
proc abs  (x: int16)   : int16 {.magic: "AbsI",   noSideEffect, raises: [], tags: [].}
proc abs  (x: int32)   : int32 {.magic: "AbsI",   noSideEffect, raises: [], tags: [].}
proc abs  (x: int64)   : int64 {.magic: "AbsI64", noSideEffect, raises: [], tags: [].}
```

<span>

```
proc `+` (x   : float)  : float   {.magic: "UnaryPlusF64",  noSideEffect.}
proc `+` (x   : float32): float32 {.magic: "UnaryPlusF64",  noSideEffect.}

proc `-` (x   : float)  : float   {.magic: "UnaryMinusF64", noSideEffect.}
proc `-` (x   : float32): float32 {.magic: "UnaryMinusF64", noSideEffect.}

proc `+` (x, y: float)  : float   {.magic: "AddF64",        noSideEffect.}
proc `+` (x, y: float32): float32 {.magic: "AddF64",        noSideEffect.}

proc `-` (x, y: float)  : float   {.magic: "SubF64",        noSideEffect.}
proc `-` (x, y: float32): float32 {.magic: "SubF64",        noSideEffect.}

proc `*` (x, y: float)  : float   {.magic: "MulF64",        noSideEffect.}
proc `*` (x, y: float32): float32 {.magic: "MulF64",        noSideEffect.}

proc `/` (x, y: float)  : float   {.magic: "DivF64",        noSideEffect.}
proc `/` (x, y: float32): float32 {.magic: "DivF64",        noSideEffect.}

proc `==`(x, y: float)  : bool    {.magic: "EqF64",         noSideEffect.}
proc `==`(x, y: float32): bool    {.magic: "EqF64",         noSideEffect.}

proc `<=`(x, y: float)  : bool    {.magic: "LeF64",         noSideEffect.}
proc `<=`(x, y: float32): bool    {.magic: "LeF64",         noSideEffect.}

proc `<` (x, y: float)  : bool    {.magic: "LtF64",         noSideEffect.}
proc `<` (x, y: float32): bool    {.magic: "LtF64",         noSideEffect.}

proc min (x, y: float)  : float   {.magic: "MinF64", noSideEffect, raises: [], tags: [].}
proc max (x, y: float)  : float   {.magic: "MaxF64", noSideEffect, raises: [], tags: [].}

proc abs (x   : float)  : float   {.magic: "AbsF64", noSideEffect, raises: [], tags: [].}
```

<span>

```
proc toFloat       (i: int)         : float        
                   {.magic: "ToFloat",        noSideEffect, importc: "toFloat".}
proc toBiggestFloat(i: BiggestInt)  : BiggestFloat 
                   {.magic: "ToBiggestFloat", noSideEffect, importc: "toBiggestFloat".}
	 ## 转换整数到浮点数； 如果失败，抛出 EInvalidValue； 大多数平台不会失败
 
proc toInt         (f: float)       : int          
                   {.magic: "ToInt",          noSideEffect, importc: "toInt".}
proc toBiggestInt  (f: BiggestFloat): BiggestInt   
                   {.magic: "ToBiggestInt",   noSideEffect, importc: "toBiggestInt".}
	 ## 转换浮点数到整数； 如果失败，抛出 EInvalidValue；
```