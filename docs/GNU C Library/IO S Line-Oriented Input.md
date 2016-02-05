# [流，输入一行](https://www.gnu.org/software/libc/manual/html_node/Line-Input.html#Line-Input)

有许多程序以行来组织输入，因此，有一些读行的流函数会非常有帮助。

标准 C 已经有一些读行函数，但是它们不是特别安全：不带终止符，有的有溢出的风险（`gets()`）。为此，GNU C 库提供了非标准的 `getline()` 函数，它非常方便，并且可靠。

另外一个 GNU C 扩展是 `getdelim()` 函数，它是 `getline()` 的广义版本。你要为它指定一个定界符，每次读到定界符。

###: #include &lt;stdio.h&gt; 

```c
#include <stdio.h>
```

###: getline()

```c
ssize_t getline(char **lineptr, size_t *n, FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt heap | AC-Unsafe lock corrupt mem |
* Function

`getline()` 函数通过流 `stream` 读取一行，并把它（包含换行符和终止符）存储到缓冲区。

调用 `getline()` 前，你应该使用 `malloc()` 分配一个缓冲区，长度是 `*n`，并将 `*lineptr` 指向缓冲区的地址。如果缓冲区足够长，以至于可以容纳一整行，`getline()` 就会把行存储到缓冲区；否则，`getline()` 调用 `realloc()`，增加调整缓冲区长度，把行存储到缓冲区，并把新的缓冲区地址存储到 `*lineptr`，把增长的长度存储到 `*n`。

如果指定 `*lineptr` 是一个空指针，并且 `*n` 是 `0`，那么 `getline()` 使用 `malloc()` 分配缓冲区。如果 `getline()` 遇到错误，分配的缓冲区会遗留，并且不能读取任何字节。

无论哪种情况，`getline()` 返回时，`*lineptr` 都是一个 `char *`。

执行成功返回读取字节数（包括换行符，但是不包括终止符）；出错或 end-of-file 返回 `-1`。

> `getline()` 函数是一个 GNU 扩展，不过推荐你用它来读行。 

###: getdelim()

```c
ssize_t getdelim(char **lineptr, size_t *n, int delimiter, FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt heap | AC-Unsafe lock corrupt mem | 
* Function

`getdelim()` 函数类似 `getline()` 函数，但是需要指定定界符 `delimiter`，而不是换行符。它会一直读到定界符，或者 end-of-file 。

读取的内容存储到 `*lineptr`，包括定界符和终止符。和 `getline()` 相同，`getdelim()` 会在适当的情况下重新分配缓冲区。

事实上，`getline()` 是由 `getdelim()` 实现的：

```c
ssize_t getline(char **lineptr, size_t *n, FILE *stream) {
    return getdelim(lineptr, n, '\n', stream);
}
```

###: fgets()

```c
char *fgets(char *s, int count, FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

`fgets()` 函数通过流 `stream` 读取一行，并把它（包含换行符）存储到 `s`，添加一个终止符。`count` 指定 `s` 的长度，不过读取的字节数最多是 `count-1`，必须预留一个字节加入终止符。

调用 `fgets()` 时，如果已经是 end-of-file，那么 `s` 的内容不会发生变化，返回一个空指针。另外，当出现错误时也会返回空指针。否则，返回指针 `s`。

> 警告：如果输入数据有一个终止符，它不会被识别。这种情况下，千万不要用 `fgets()`；除非你确定数据不包含终止符，才使用 `fgets()`。也不要用 `fgets()` 读取用户编辑的文件：如果用户插入了终止符，你应该正确处理终止符，或者打印一条清晰的错误消息。我们推荐你使用 `getline()`。

###: fgets_unlocked()

```c
char * fgets_unlocked(char *s, int count, FILE *stream);
```

* Preliminary: | MT-Safe race:stream | AS-Unsafe corrupt | AC-Unsafe corrupt |
* Macro

`fgets_unlocked()` 函数类似 `fgets()` 函数，但是不会在内部锁定流。

> `fgets_unlocked()` 函数是一个 GNU 扩展。

###: fgetws()

```c
wchar_t *fgetws(wchar_t *ws, int count, FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

`fgetws()` 函数通过流 `stream` 读取一行，并把它（包含换行符）存储到 `ws`，添加一个宽终止符。`count` 指定 `ws` 的长度，不过读取的字节数最多是 `count-1`，必须预留一个字节加入宽终止符。

调用 `fgetws()` 时，如果已经是 end-of-file，那么 `ws` 的内容不会发生变化，返回一个空指针。另外，当出现错误时也会返回空指针。否则，返回指针 `ws`。

> 警告：如果输入数据有一个宽终止符，它不会被识别。这种情况下，千万不要用 `fgetws()`；除非你确定数据不包含宽终止符，才使用 `fgetws()`。也不要用 `fgetws()` 读取用户编辑的文件：如果用户插入了宽终止符，你应该正确处理终止符，或者打印一条清晰的错误消息。

###: fgetws_unlocked()

```c
wchar_t *fgetws_unlocked(wchar_t *ws, int count, FILE *stream);
```

* Preliminary: | MT-Safe race:stream | AS-Unsafe corrupt | AC-Unsafe corrupt |
* Macro

`fgetws_unlocked()` 函数类似 `fgetws()` 函数，但是不会在内部锁定流。

> `fgetws_unlocked()` 函数是一个 GNU 扩展。

###: gets()

```c
char *gets(char *s);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Macro

`gets()` 函数通过流 `stdin` 读取一行，并把它存储到 `s`。换行符被丢弃（注意，这和 `fgets()` 不一样，`fgets()` 会复制换行符）。执行出错或 end-of-file，返回一个空指针；否则，返回 `s`。

> 警告：`gets()` 函数非常的不可靠，无法防止 `s` 溢出。GNU C 库包含它仅仅是为了兼容其它系统。你应该总是采用 `fgets()` 或 `getline()` 函数。当你使用 `gets()` 时，链接器会为此发出一个警告---提醒你不要用 `gets()`。
