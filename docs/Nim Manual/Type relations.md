# [数据类型的关系](http://nim-lang.org/docs/manual.html#type-relations)

本章聊聊类型的一些关系，编译器在类型检查阶段，会对这些关系进行检查。

### 类型等价

在 Nim 语言中，大多数类型使用结构类型等价；只有对象、枚举和 distinct 类型使用名称等价。下列的伪代码演示了一个算法，描述了类型等价是如何被确定的：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc typeEqualsAux(a, b: PType, s: var HashSet[(PType, PType)]): bool =
    if (a, b) in s: 
        return true
    incl(s, (a,b))
    if a.kind == b.kind:
        case a.kind
        of int, intXX, float, floatXX, char, string, cstring, pointer,
           bool, nil, void:
            # leaf type: kinds 完全相同; 不需要继续检查
            result = true
        of ref, ptr, var, set, seq, openarray:
            result = typeEqualsAux(a.baseType, b.baseType, s)
        of range:
            result = typeEqualsAux(a.baseType, b.baseType, s) and
                     (a.rangeA == b.rangeA) and (a.rangeB == b.rangeB)
        of array:
            result = typeEqualsAux(a.baseType, b.baseType, s) and
                     typeEqualsAux(a.indexType, b.indexType, s)
        of tuple:
            if a.tupleLen == b.tupleLen:
                for i in 0..a.tupleLen-1:
                    if not typeEqualsAux(a[i], b[i], s): 
                        return false
                result = true
        of object, enum, distinct:
            result = a == b
        of proc:
            result = typeEqualsAux(a.parameterTuple, b.parameterTuple, s) and
                     typeEqualsAux(a.resultType, b.resultType, s) and
                     a.callingConvention == b.callingConvention
    elif a.kind == distinct:
        result = typeEqualsOrDistinct(a.baseType, b, s)
    elif b.kind == distinct:
        result = typeEqualsOrDistinct(a, b.baseType, s)

proc typeEquals(a, b: PType): bool =
    var s: HashSet[(PType, PType)] = {}
    result = typeEqualsAux(a, b, s)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

因为该计算会执行循环调用，所以使用了一个哈希集合 `s` 来存储已经计算的结果，以避免重复计算。

### 子类关系 

如果对象 `a` 继承自对象 `b`，`a` 就是 `b` 的子类型。子类型关系被延伸到类型 `var` `ref` `ptr`：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc isSubtype(a, b: PType): bool =
    if a.kind == b.kind:
        case a.kind
        of object:
            var aa = a.baseType
            while aa != nil and aa != b: aa = aa.baseType
            result = aa == b
        of var, ref, ptr:
            result = isSubtype(a.baseType, b.baseType)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

### 转换关系

下面的伪代码算法，描述了类型 `a` 隐式转换到类型 `b` 的必备条件

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
# XXX range types?
proc isImplicitlyConvertible(a, b: PType): bool =
    case a.kind
    of int:     result = b in {int8, int16, int32, int64, uint, uint8, uint16,
                               uint32, uint64, float, float32, float64}
    of int8:    result = b in {int16, int32, int64, int}
    of int16:   result = b in {int32, int64, int}
    of int32:   result = b in {int64, int}
    of uint:    result = b in {uint32, uint64}
    of uint8:   result = b in {uint16, uint32, uint64}
    of uint16:  result = b in {uint32, uint64}
    of uint32:  result = b in {uint64}
    of float:   result = b in {float32, float64}
    of float32: result = b in {float64, float}
    of float64: result = b in {float32, float}
    of seq:
        result = b == openArray and typeEquals(a.baseType, b.baseType)
    of array:
        result = b == openArray and typeEquals(a.baseType, b.baseType)
        if a.baseType == char and a.indexType.rangeA == 0:
            result = b = cstring
    of cstring, ptr:
        result = b == pointer
    of string:
        result = b == cstring
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



下面的伪代码算法，描述了类型 `a` 显式转换到类型 `b` 的必备条件：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
proc isIntegralType(t: PType): bool =
    result = isOrdinal(t) or t.kind in {float, float32, float64}
proc isExplicitlyConvertible(a, b: PType): bool =
    result = false
    if isImplicitlyConvertible(a, b): return true
    if typeEqualsOrDistinct(a, b): return true
    if isIntegralType(a) and isIntegralType(b): return true
    if isSubtype(a, b) or isSubtype(b, a): return true
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



转换关系可对用户定义的类型转换器放宽条件：

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~nim
converter toInt(x: char): int = result = ord(x)
var
    x: int
    chr: char = 'a'
# implicit conversion magic happens here
x = chr
echo x  # =97
# you can use the explicit form too
x = chr.toInt
echo x  # =97
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

如果 `a` 是一个 L-value、并且满足 `typeEqualsOrDistinct(T, type(a))`，那么类型转换 `T(a)` 是一个 L-value。

### 赋值兼容性

如果表达式 a 的结果值是一个 l-value、并且满足 `isImplicitlyConvertible(b.typ, a.typ)`，那么表达式 b 可以作为值赋给表达式 a。