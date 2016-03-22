# [流，字符集，国际化](https://www.gnu.org/software/libc/manual/html_node/Streams-and-I18N.html#Streams-and-I18N)

ISO C90 引入了新的类型 `wchar_t`，用来处理宽字符集。直接输出 `wchar_t` 可能会丢失字符。你必须使用 `mbstowcs()` 将它们转换成多字节的字符串，然后再执行输出。然而，这样做真的挺烦人，而且代码也变长了。

早期的 Unix （我觉得是 XPG4.2） 为 `printf()` 函数和 `scanf()` 函数引入了两个格式化说明符。`%C` 指定打印和读取一个宽字符，`%S` 指定打印和读取一个宽字符串。它们和 `%c`、`%s` 很相似，除了在宽字符和字符串之间转换。

现在，我们有了一个好的开始，不过还不够好。不使用 `printf()` 和 `scanf()` 的时候怎么办？

ISO C90 的修订稿增加了一些新的函数集，来解决这个问题。新增的宽字符函数和普通流函数，操作同样的流。你必须对流作出选择：要么处理普通字符，要么处理宽字符。一旦确定了，就不能再改变。只能调用 `freopen()` 或 `freopen64()` 重置这个选择---术语叫做 “定向”。有三种方法来决定 “定向”：

* 如果使用了任何普通字符函数（比如 `fgetc()`、`fputc()`），那么流只能处理普通字符。
* 如果使用了任何宽字符函数（比如 `fgetwc()`、`fputwc()`），那么流只能处理宽字符。
* 调用 `fwide()` 函数可以设定定向。

一定不要对同一个流混用普通字符和宽字符的操作。没有办法检测它们。如果你这么做，你的程序要么会发生奇怪的事情，要么就直接崩溃了。你可以在执行操作前，显式地调用 `fwide()` 确定流的定向。


###: #include &lt;wchar.h&gt;

```c
#include <wchar.h>
```

###: fwide()

```c
int fwide(FILE *stream, int mode);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock |
* Function

`fwide()` 函数设置和查询流 `stream` 的定向。如果 `mode` 是正数，则流定向为宽字符；如果是负数，则流定向为普通字符。如果流已经被定向，不能再修改。

如果 `mode` 是 `0`，则只查询流的定向。

返回值如下所示：

* `负数` 普通字符
* `0` 无意义 
* `正数` 宽字符

尽可能早的定向流是一个好主意。这能防止意外，特别是对标准流 `stdin`、`stdout`、`stderr`。记住，如果流被错误地使用，没有错误可以被捕捉到。

当编写不同定向的代码时，在执行操作前先查询流的定向非常重要。例子：

```c
void print_f(FILE *fp) {
    if (fwide(fp, 0) > 0)
        /* 正数，表示宽字符定向  */
        fputwc(L'f', fp);
    else
        fputc('f', fp);
}
```

使用 `wchar_t` 的值，其编码是未指定的，我们不能对其作出任何假设。这意味着，不能直接用流写 `wchar_t` 值。要在外部确定编码，一种是通过当前语言环境的 `LC_CTYPE` 修饰符，一种是通过 `fopen()`、`fopen64()`、`freopen()`、`freopen64()` 指定 `"css=ENCODING"`。