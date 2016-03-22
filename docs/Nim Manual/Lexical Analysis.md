# [词法分析](http://nim-lang.org/docs/manual.html#lexical-analysis)

## 源文件的编码

Nim 源文件采用 UTF-8 编码，或者是其子集 ASCII 编码，不支持其它编码。支持所有标准平台的行终结符，比如 Unix 的 ASCII `LF`、Windows 的 ASCII `CRLF`、以及旧版 Macintosh 机的 ASCII `CR`。所有这些行终结符在 Nim 中被平等对待，在使用上没有平台区分。

> 译注： LF 通常是 `'\n'` 字符，CRLF 通常是 `"\r\n"`双字符，CR 通常是 `'\r'` 字符。

## 缩进

Nim 是缩进敏感的语言，通过缩进层次控制语言的逻辑结构。缩进只能使用空格符，不能使用制表符。

The indentation handling is implemented as follows: The lexer annotates the following token with the preceding number of spaces; indentation is not a separate token. This trick allows parsing of Nim with only 1 token of lookahead.

The parser uses a stack of indentation levels: the stack consists of integers counting the spaces. The indentation information is queried at strategic places in the parser but ignored otherwise: The pseudo terminal IND{>} denotes an indentation that consists of more spaces than the entry at the top of the stack; IND{=} an indentation that has the same number of spaces. DED is another pseudo terminal that describes the action of popping a value from the stack, IND{>} then implies to push onto the stack.

With this notation we can now easily define the core of the grammar: A block of statements (simplified example): 

```ebnf
ifStmt = 'if' expr ':' stmt
       (IND{=} 'elif' expr ':' stmt)*
       (IND{=} 'else' ':' stmt)?

simpleStmt = ifStmt / ...

stmt = IND{>} stmt ^+ IND{=} DED  # list of statements
   / simpleStmt                 # or a simple statement
```

## 注释

Comments start anywhere outside a string or character literal with the hash character #. Comments consist of a concatenation of comment pieces. A comment piece starts with # and runs until the end of the line. The end of line characters belong to the piece. If the next line only consists of a comment piece with no other tokens between it and the preceding one, it does not start a new comment:

```nim
i = 0     # This is a single comment over multiple lines.
    # The scanner merges these two pieces.
    # The comment continues here.
```

Documentation comments are comments that start with two ##. Documentation comments are tokens; they are only allowed at certain places in the input file as they belong to the syntax tree!

## 标识符和关键字

标识符是字母、数字、下划线组成的字符串，第一个必须是字母。双下划线 **__** 是不允许的。当前，任何数值 `127` 的非 ASCII 的 Unicode 字符被归为一个字母，可以用作标识符。

```ebnf
letter ::= 'A'..'Z' | 'a'..'z' | '\x80'..'\xff'
digit ::= '0'..'9'
IDENTIFIER ::= letter ( ['_'] (letter | digit) )*
``` 

下面的关键字预以保留，不能用作标识符：

```?
addr and as asm atomic
bind block break
case cast concept const continue converter
defer discard distinct div do
elif else end enum except export
finally for from func
generic
if import in include interface is isnot iterator
let
macro method mixin mod
nil not notin
object of or out
proc ptr
raise ref return
shl shr static
template try tuple type
using
var
when while with without
xor
yield
```

## 标识符等价

如果下面的算法返回 `true`，那么这两个标识符就是等价的：

```nim
proc sameIdentifier(a, b: string): bool =
    a[0] == b[0] and
        a.replace(re"_|–", "").toLower == b.replace(re"_|–", "").toLower
```

除了首字母是严格比较的，其余部分采用不严格比较。除了首字母，其余部分不存在大小写区分，下划线会被忽略。这表示 `foo`，`f_Oo`，`f_o_O`，`fOO` 都是等价的标识符。

首字母区分大小写，这样可以容易避开 `var foo: Foo` 这种代码引起的歧义。

## 字符串字面值

在语法中，其终端符号是 **STR_LIT** 。

字符串字面值使用双引号 `"` 包裹，可以包含下列转义字符：

<table>
<tr>
    <th>转义字符</th>
    <th>描述</th>
</tr>
<tr>
    <td>`\n`</td>
    <td>新行符 newline</td>
</tr>
<tr>
    <td>`\r`, `\c`</td>
    <td>回车符 carriage return</td>
</tr>
<tr>
    <td>`\l`</td>
    <td>换行符 line feed</td>
</tr>
<tr>
    <td>`\f`</td>
    <td>换页符 form feed</td>
</tr>
<tr>
    <td>`\t`</td>
    <td>制表符 tabulator</td>
</tr>
<tr>
    <td>`\v`</td>
    <td>垂直制表符 vertical tabulator</td>
</tr>
<tr>
    <td>`\\`</td>
    <td>反斜杠 backslash</td>
</tr>
<tr>
    <td>`\"`</td>
    <td>双引号 quotation mark</td>
</tr>
<tr>
    <td>`\'`</td>
    <td>单引号 apostrophe</td>
</tr>
<tr>
    <td>`\ '0'..'9'+`</td>
    <td>十进制数值字符</td>
</tr>
<tr>
    <td>`\a`</td>
    <td>告警符 alert</td>
</tr>
<tr>
    <td>`\b`</td>
    <td>退格符 backspace</td>
</tr>
<tr>
    <td>`\e`</td>
    <td>取消符 escape [ESC]</td>
</tr>
<tr>
    <td>`\x HH`</td>
    <td>十六进制数值字符；刚好两个十六进制数字</td>
</tr>
</table>

Nim 语言的字符串值，可以包含任意的 8 位值，甚至全 0 。不过，有些操作可能会把第一个二进制 0 作为结束符。

> 译注： `var s = "a\0\0\0\0\0\0"` 这是含有 6 个二进制 0 的字符串，其长度是 7 。某些函数，特别是 C 语言中的一些，会将第一个 `'\0'` 作为字符串的终止符。

## 三引号字符串字面值

在语法中，其终端符号是 **TRIPLESTR_LIT** 。

三引号字符串值使用 `"""` 包裹。可以包含多个行。和普通的字符串字面值不同，语法解析器不对三引号字符串字面值中的字符进行转义，比如：

```nim
""""long string within quotes
Then""""
```
会被生成值

```nim
"long string within quotes\nThen"
```

## 原生字符串字面值

在语法中，其终端符号是 **RSTR_LIT** 。

原生字符串字面值，是在字符串字面值前面加 `r` 或者 `R` 作为修饰符。语法解析器也不对其进行转义。举例，对于拼写 Windows 路径很有帮助：

```nim
var f = openFile(r"C:\texts\text.txt")  # \t 不会被转义为制表符
```

也可以包裹一个双引号：
```nim
r"a""b"
```
生成：
```nim
a"b
```

`r"""` 和 `"""` 是等价的，所以 `r""""` 没什么意义。



## 通用原生字符串字面值

在语法中，其终端符号是 **GENERALIZED_STR_LIT、GENERALIZED_TRIPLESTR_LIT** 。

**identifier"string literal"** 表示通用原生字符串字面值，是**identifier(r"string literal")** 的简写形式。通用原生字符串字面值，常用来嵌入某些语言特性，比如正则表达式。

**identifier"""string literal"""** 也是存在的，它是 **identifier("""string literal""")** 的简写形式。



## 字符字面值

字符字面值使用单引号 `'` 包裹，也可以包含和字符串字面值相同的转义字符（除了新行符 `'\n'` --- 在某些平台该字符可能是一个宽字符，比如 `CRLF`）。

<table>
<tr>
    <th>转义字符</th>
    <th>描述</th>
</tr>
<tr>
    <td>`\r`, `\c`</td>
    <td>回车符 carriage return</td>
</tr>
<tr>
    <td>`\l`</td>
    <td>换行符 line feed</td>
</tr>
<tr>
    <td>`\f`</td>
    <td>换页符 form feed</td>
</tr>
<tr>
    <td>`\t`</td>
    <td>制表符 tabulator</td>
</tr>
<tr>
    <td>`\v`</td>
    <td>垂直制表符 vertical tabulator</td>
</tr>
<tr>
    <td>`\\`</td>
    <td>反斜杠 backslash</td>
</tr>
<tr>
    <td>`\"`</td>
    <td>双引号 quotation mark</td>
</tr>
<tr>
    <td>`\'`</td>
    <td>单引号 apostrophe</td>
</tr>
<tr>
    <td>`\ '0'..'9'+`</td>
    <td>十进制数值字符</td>
</tr>
<tr>
    <td>`\a`</td>
    <td>告警符 alert</td>
</tr>
<tr>
    <td>`\b`</td>
    <td>退格符 backspace</td>
</tr>
<tr>
    <td>`\e`</td>
    <td>取消符 escape [ESC]</td>
</tr>
<tr>
    <td>`\x HH`</td>
    <td>十六进制数值字符；刚好两个十六进制数字</td>
</tr>
</table>

一个字符字面值占用一个字节，其并非是 Unicode 字符。这么设定是为了效率：根据多年开发经验，使用 Unicode 字符的程序经常需要手动操作；此外这样可以使 Nim 语言支持 `array[char, int]` 或者 `set[char]` 来实现某些高效的算法。Rune 类型用来定义 Unicode 字符，查看 unicode module 了解更多细节。


## 数字常量

数字常量的语法规则如下：

```ebnf
    hexdigit = digit | 'A'..'F' | 'a'..'f'
    octdigit = '0'..'7'
    bindigit = '0'..'1'
    HEX_LIT = '0' ('x' | 'X' ) hexdigit ( ['_'] hexdigit )*
    DEC_LIT = digit ( ['_'] digit )*
    OCT_LIT = '0' ('o' | 'c' | 'C') octdigit ( ['_'] octdigit )*
    BIN_LIT = '0' ('b' | 'B' ) bindigit ( ['_'] bindigit )*

    INT_LIT = HEX_LIT
            | DEC_LIT
            | OCT_LIT
            | BIN_LIT

    INT8_LIT = INT_LIT ['\''] ('i' | 'I') '8'
    INT16_LIT = INT_LIT ['\''] ('i' | 'I') '16'
    INT32_LIT = INT_LIT ['\''] ('i' | 'I') '32'
    INT64_LIT = INT_LIT ['\''] ('i' | 'I') '64'

    UINT_LIT = INT_LIT ['\''] ('u' | 'U')
    UINT8_LIT = INT_LIT ['\''] ('u' | 'U') '8'
    UINT16_LIT = INT_LIT ['\''] ('u' | 'U') '16'
    UINT32_LIT = INT_LIT ['\''] ('u' | 'U') '32'
    UINT64_LIT = INT_LIT ['\''] ('u' | 'U') '64'

    exponent = ('e' | 'E' ) ['+' | '-'] digit ( ['_'] digit )*
    FLOAT_LIT = digit (['_'] digit)* (('.' (['_'] digit)* [exponent]) |exponent)
    FLOAT32_SUFFIX = ('f' | 'F') ['32']
    FLOAT32_LIT = HEX_LIT '\'' FLOAT32_SUFFIX
                | (FLOAT_LIT | DEC_LIT | OCT_LIT | BIN_LIT) ['\''] FLOAT32_SUFFIX
    FLOAT64_SUFFIX = ( ('f' | 'F') '64' ) | 'd' | 'D'
    FLOAT64_LIT = HEX_LIT '\'' FLOAT64_SUFFIX
                | (FLOAT_LIT | DEC_LIT | OCT_LIT | BIN_LIT) ['\''] FLOAT64_SUFFIX
```

如上所述，数字常量可以用下划线增加可读性。整数和浮点数的值可以是十进制（无前缀）、二进制（前缀 `0b`）、八进制（前缀 `0o` 或者 `0c`）、十六进制（前缀 `0x`）。

`0B0_10001110100_0000101001000111101011101111111011000101001101001001'f64`，根据 IEEE 浮点数规则，其值大约等于 `1.72826e35` 。

数字常量受到边界检查影响，以使它们符合对应的数据类型。非十进制数值，主要用于标志位和位模式，因此，边界检查基于位宽而不是值的范围。如果一个数值适合数据类型的位宽，就可以通过边界检查。比如 `0b10000000'u8 == 0x80'u8 == 128` 是允许的，但是 `0b10000000'i8 == 0x80'i8 == -1` 则会引起溢出。



## 操作符

Nim 语言允许用户定义操作符。操作符，是下列字符的任意组合：

```nim
=     +     -     *     /     <     >
@     $     ~     &     %     |
!     ?     ^     .     :     \
```

这些关键字也同样是操作符： 

```?
and   or   not   xor   shl   shr   div   mod   in   notin   is   isnot   of
```



## 其他符号


```?
`   (     )     {     }     [     ]     ,  ;   [.    .]  {.   .}  (.  .)
```