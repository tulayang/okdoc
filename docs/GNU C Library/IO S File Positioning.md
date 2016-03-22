# [流，文件位置](https://www.gnu.org/software/libc/manual/html_node/File-Positioning.html#File-Positioning)

流的文件位置，描述了当前读或写的位置。对流执行 IO 操作，会使文件位置前移。在 GNU 系统，文件位置是一个整数，表示从文件开始的字节数。

对于普通文件，在整个 IO 阶段，你可以随时修改文件位置，使得可以读或写文件的任意位置。一些其他文件也支持这种操作。凡是支持这种操作的文件，称为“随机访问文件”。

> 可移植性注解：在非 POSIX 系统，`ftell()`、`ftello()`、`fseek()`、`fseeko()` 可能只对二进制流可靠工作。

###: #include &lt;stdio.h&gt;

```c
#include <stdio.h>
```

###: SEEK_SET

```c
int SEEK_SET
```

* Macro

`SEEK_SET` 常量用于 `fseek()` 或 `fseeko()` 函数，指定 `offset` 相对于文件开始（`0`）。

###: SEEK_CUR

```c
int SEEK_CUR
```

* Macro

`SEEK_CUR` 常量用于 `fseek()` 或 `fseeko()` 函数，指定 `offset` 相对于当前文件位置。

###: SEEK_END

```c
int SEEK_END
```

* Macro

`SEEK_END` 常量用于 `fseek()` 或 `fseeko()` 函数，指定 `offset` 相对于文件尾部。

### SEEK\_... L_... 兼容 BSD

在头文件 `<fcntl.h>` 和 `<sys/file.h>` 定义了 SEEK_... 常量的别名，用来兼容旧的 BSD 系统：

常量|描述
---|---
`L_SET` |`SEEK_SET` 的别名
`L_INCR`|`SEEK_CUR` 的别名
`L_XTND`|`SEEK_END` 的别名

###: ftell()

```c
long int ftell(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

`ftell()` 函数返回流 `stream` 的当前文件位置。

如果流不支持文件位置，或者文件位置不能用 `long int` 表示，都会失败。当失败时，返回 `-1`。

###: ftello()

```c
off_t ftello(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

`ftello()` 函数类似 `ftell()` 函数，除了返回值是 `off_t` 类型。POSIX 指定 `long int` 表示文件位置，但是一些别的系统则使用 `off_t`。`long int` 和 `off_t` 不一定是相同大小。因此，如果系统是基于 POSIX 标准，使用 `ftell()` 可以解决问题；如果 `ftello()` 可用，那么使用 `ftello()` 更可取。

执行成功返回当前文件位置；出错返回 `(off_t)-1`。

> 当源代码通过 `-D_FILE_OFFSET_BITS=64` 或 `#define FILE_OFFSET_BITS 64` 在 32 位机器编译时，`ftello()` 函数实质上是 `ftello64()` 函数。也就是说，LFS 接口（使用 64 位文件长度和文件偏移）透明地替换掉旧的接口。  

<span>

> `ftello()` 是一个 Single UNIX Specification version 2 扩展。

###: ftello64()

```c
off64_t ftello64(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

> `ftello64()` 函数类似 `ftello()` 函数。唯一的不同是：在 32 位系统，打开的文件使用“大文件模式”。在该模式下，文件的最大长度是 <code>2<sup>63</sup>bytes</code>，文件的偏移范围是 <code>-2<sup>63</sup></code> 到 <code>2<sup>63</sup></code>。流 `stream` 必须是用 `fopen64()`、`freopen64()`、`tmpfile64()` 打开的，否则会发生错误。

<span>

> 当源代码通过 `-D_FILE_OFFSET_BITS=64` 或 `#define FILE_OFFSET_BITS 64` 在 32 位机器编译时，`ftello()` 函数实质上是 `ftello64()` 函数。也就是说，LFS 接口（使用 64 位文件长度和文件偏移）透明地替换掉旧的接口。   

###: fseek()

```c
int fseek(FILE *stream, long int offset, int whence);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

`fseek()` 函数修改流 `stream` 的文件位置。`whence` 必须是常量 `SEEK_SET`、`SEEK_CUR`、`SEEK_END` 的一个，表示 `offset` 的相对位置。

执行成功返回 `0`；出错返回 `非 0`。当执行成功时，也会清除流的 end-of-file 状态，丢弃 `ungetc()` 压回的字符。

###: fseeko()

```c
int fseeko(FILE *stream, off_t offset, int whence);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

`fseeko()` 函数类似 `fseek()` 函数，除了 `off_t` 是 `off_t` 类型。POSIX 指定 `long int` 表示文件位置，但是一些别的系统则使用 `off_t`。`long int` 和 `off_t` 不一定是相同大小。因此，如果系统是基于 POSIX 标准，使用 `fseek()` 可以解决问题；如果 `fseeko()` 可用，那么使用 `fseeko()` 更可取。

执行成功返回 `0`；出错返回 `非 0`。当执行成功时，也会清除流的 end-of-file 状态，丢弃 `ungetc()` 压回的字符。

> 当源代码通过 `-D_FILE_OFFSET_BITS=64` 或 `#define FILE_OFFSET_BITS 64` 在 32 位机器编译时，`fseeko()` 函数实质上是 `fseeko64()` 函数，`off_t` 类型实质上是 `off64_t`类型。也就是说，LFS 接口（使用 64 位文件长度和文件偏移）透明地替换掉旧的接口。  

###: fseeko64()

```c
int fseeko64(FILE *stream, off64_t offset, int whence);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

> `fseeko64()` 函数类似 `fseeko()` 函数。唯一的不同是：在 32 位系统，打开的文件使用“大文件模式”。在该模式下，文件的最大长度是 <code>2<sup>63</sup>bytes</code>，文件的偏移范围是 <code>-2<sup>63</sup></code> 到 <code>2<sup>63</sup></code>。流 `stream` 必须是用 `fopen64()`、`freopen64()`、`tmpfile64()` 打开的，否则会发生错误。

<span>

> 当源代码通过 `-D_FILE_OFFSET_BITS=64` 或 `#define FILE_OFFSET_BITS 64` 在 32 位机器编译时，`ftello()` 函数实质上是 `ftello64()` 函数，`off_t` 类型实质上是 `off64_t`类型。也就是说，LFS 接口（使用 64 位文件长度和文件偏移）透明地替换掉旧的接口。   

###: rewind()

```c
void rewind(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

`rewind()` 函数重置流 `stream` 的文件位置到开始。等价于：`fseek(stream, 0L, SEEK_SET)` 或 `fseeko(stream, (off_t)0, SEEK_SET)`。


