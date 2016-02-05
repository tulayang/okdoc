# [文本流，二进制流](https://www.gnu.org/software/libc/manual/html_node/Binary-Streams.html#Binary-Streams)

GNU 系统和其他 POSIX 兼容的系统，将文件组织为统一的字符序列。不过，一些别的系统则有些差别，甚至不同于 ISO C 。本节将告诉你，如何为这些系统编写可移植的程序。

当你打开流，可以指定是文本流，也可以指定是二进制流。调用 `fopen()` 函数时，指定 `opentype = b`，则是一个二进制流；否则，是一个文本流。

文本流和二进制流有几点不同：

* 通过文本流读数据，可以通过换行符 `'\n'` 划分为多行；通过二进制流读数据，则是一个单纯的字符序列。在一些系统，通过文本流读数据，当行字符超过 `254` 个时（包括换行符），可能会发生错误。 

* 在一些系统，文本文件可以包含打印字符、水平制表符、换行符。文本流可能无法支持其中的某些字符。然而，二进制流可以处理任何字符。

* 通过文本流写入的空白符，有可能在文件再次被读时丢失。

* 对于大多数需求，并不需要流到文件的读写按照一对一的字符对应，文本流常常这么干。

因此，比起文本流，二进制流常常更给力，更容易掌控。你可能也想知道文本流有嘛用处？干脆直接用二进制流干所有的活不行吗？答案是，在上面提到的操作系统，它们的文本流和二进制流使用不同的文件格式，如果你想和面向文本的程序协同工作（比如文本编辑器），只能通过文本流。
