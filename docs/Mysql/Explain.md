# [流，输入一块，输出一块](https://www.gnu.org/software/libc/manual/html_node/Block-Input_002fOutput.html#Block-Input_002fOutput)

本节描述如何以块为单位读写数据。你可以用这些函数读写二进制数据，以及固定长度的文本。

Binary files are typically used to read and write blocks of data in the same format as is used to represent the data in a running program. In other words, arbitrary blocks of memory—not just character or string objects—can be written to a binary file, and meaningfully read in again by the same program. 

以二进制格式存储数据，通常比格式化更加高效。此外，对于浮点数，二进制可以避免精度丢失。另一方面，许多标准文件工具（比如文本编辑器）不能预先检查或修改二进制，而且在不用的语言、或不同的系统，二进制无法移植。

###: #include &lt;stdio.h&gt; 

```c
#include <stdio.h>
```

###: fread()

```c
size_t fread(void *data, size_t size, size_t count, FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

`fread()` 函数通过流 `stream` 读取数据，存储到数组 `data` 中的各个对象。`size` 指定对象的大小，`count` 指定对象的个数。返回读取的对象个数，可能会少于 `count`---如果出错或 end-of-file。如果指定 `size` 或 `count` 是 `0`，返回 `0`。

如果读取到 end-of-file 时，正好在一个对象中间，那么，返回已经读完的对象个数，丢弃未完成的对象。

```c
float data[64];
if(fread(&data[2], sizeof(float), 4, fp) != 4)
    errExit("fread");
```

<span>

```c
struct {
  int id;
  char name[NAMESIZE];
} data;

if (fread(&data, sizeof(data), 1, fp) != 1)
    errExit("fread");
```

###: fread_unlocked()

```c
size_t fread_unlocked(void *data, size_t size, size_t count, FILE *stream);
```

* Preliminary: | MT-Safe race:stream | AS-Unsafe corrupt | AC-Unsafe corrupt |
* Function

`fread_unlocked()` 函数类似 `fread()` 函数，但是不会在内部锁定流。

> `fread_unlocked()` 函数是一个 GNU 扩展。

###: fwrite()

```c
size_t fwrite(void *data, size_t size, size_t count, FILE *stream);
```

* Preliminary: | MT-Safe | AS-Unsafe corrupt | AC-Unsafe lock corrupt |
* Function

`fwrite()` 函数通过流 `stream` 写入数据。`data` 指定写入的对象数组，`size` 指定对象的大小，`count` 指定对象的个数。返回写入的对象个数，通常是 `count`，任何其他值表示出现错误。

```c
float data[10];
if(fwrite(&data[2], sizeof(float), 4, fp) != 4)
    errExit("fwrite");
```

<span>

```c
struct {
  int id;
  char name[NAMESIZE];
} data;

if (fwrite(&data, sizeof(data), 1, fp) != 1)
    errExit("fwrite");
```

###: fwrite_unlocked()

```c
size_t fwrite_unlocked(void *data, size_t size, size_t count, FILE *stream);
```

* Preliminary: | MT-Safe race:stream | AS-Unsafe corrupt | AC-Unsafe corrupt |
* Function

`fwrite_unlocked()` 函数类似 `fwrite()` 函数，但是不会在内部锁定流。

> `fwrite_unlocked()` 函数是一个 GNU 扩展。

###