Module system （p & t for bools）
==================================

```
proc `not`(x   : bool): bool {.magic: "Not", noSideEffect.}  ## Boolean not；         ！
proc `and`(x, y: bool): bool {.magic: "And", noSideEffect.}  ## Boolean and；         &&
proc `or` (x, y: bool): bool {.magic: "Or",  noSideEffect.}  ## Boolean or；          ||
proc `xor`(x, y: bool): bool {.magic: "Xor", noSideEffect.}  ## Boolean exclusive or； 
```