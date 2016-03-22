# [流，压回字符](https://www.gnu.org/software/libc/manual/html_node/Unreading.html#Unreading)

让我们来解释下什么是 unread。

假定现在有一个流，我们想要通过流读取一个文件，这个文件只有 6 个字符---`"foobar"`。现在，我们读取出 3 个字符，看起来会是这样：

```?
f o o b a r
     ^
```

那么，下一个字符是 `'b'`。

如果我们不取走 `'o'`，而只是 unread --- 把它返还到序列，那么会是这样：

```?
f o o b a r
     |
    o
    ^
```

那么，下一个字符是 `'o'` 而不是 `'b'`。

如果 unread `'9'`，那么会是这样：

```?
f o o b a r
     |
    9
    ^
```

那么，下一个字符是 `'9'` 而不是 `'b'`。

###: #include &lt;stdio.h&gt; 

```c
#include <stdio.h>
```

###: ungetc()

```c
int ungetc(int c, FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

`ungetc()` 函数把字符 `c` 压回流 `stream`。当下一次读流时，第一个字符是 `c`。

如果 `c` 是 `EOF`，`ungetc()` 什么也不做，只是返回 `EOF`。

你压回流的字符，不必是从流中读取的字符。通常，`ungetc()` 只会用来读取流。GNU C 库支持将其用于二进制文件，但是其他系统可能并不支持。

在 GNU C 系统，只支持单次字符压回---换句话说，如果你在读取流前连续 `ungetc()` 两次，那么，第二次不会工作。其它系统可能允许你连续多次压回。

压回字符不会改变文件，只会影响流内部的缓冲区。如果调用文件位置函数（比如 `fseek()`、`rewind()`），任何压回的字符都被忽略。

当流已经是 end-of-file 时，压回字符会清除流的 end-of-file，因为它使流的输入可用。当读取该字符后，在此读取就会 end-of-file 。

例子：

```c
#include <stdio.h>
#include <ctype.h>

void skip_whitespace(FILE *stream) {
    int c;
    do {
        /* No need to check for EOF because it is not
          isspace, and ungetc ignores EOF.  */
        c = getc(stream);
    } while(isspace(c));
    ungetc(c, stream);
}
```

###: ungetwc()

```c
wint_t ungetwc(wint_t wc, FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

`ungetwc()` 函数类似 `ungetc()` 函数，只不过它压回的是宽字符。

