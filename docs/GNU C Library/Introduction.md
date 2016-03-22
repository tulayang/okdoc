# [关于 GNU C 标准库](https://www.gnu.org/software/libc/manual/html_node/Introduction.html#Introduction)

C 语言的内置工具中，并没有提供 IO、内存管理、字符串处理等等类似的功能。相反，这些工具被定义在一个标准库中，你的程序应该编译并链接它们。

GNU C 库，也就是本文档所描述的库，定义了所有的 ISO C 标准制定的库函数，同时还有 POSIX 标准制定的库函数，其它 UNIX 衍生的操作系统定义的一些函数，以及 GNU 系统自己的一些扩展。

本文档的目的是指导你如何使用 GNU C 库中的这些宝贝。我们会在适当的地方提醒你它属于哪一个标准，来帮助你分辨评估的可移植性。

## 开始吧

本文档假定你熟悉 C 语言编程，有基本的编程概念，理解 ISO C 标准而不是土渣渣的 C 习惯。

GNU C 库含有几个头文件，每个都提供相关宝贝的定义和声明，当处理你的程序时 C 编译器会需要这些信息。举个例子，头文件 `stdio.h` 声明了执行 IO 的工具，头文件 `string.h` 声明了字符串处理的工具。

GNU C 库的函数非常多，让自己记住每个的用法不大现实。与之相比，熟悉每个宝贝的用途更有意义，这样你写程序时能够立刻知道应该用哪一个宝贝来解决问题，而且能立马从文档中找到你需要的宝贝。

## 标准和兼容性

现在来聊聊各个不同的标准和 GNU C 库建立的基础。GNU C 库建立在 ISO C 标准、POSIX 标准、System V 和 Berkeley 实现的基础上。

这个文档的主要目的是指导你更有效的使用 GNU C 库的宝贝儿。但是如果你很想自己的程序有更高的兼容性，那么使用 GNU C 库就要注意一些技巧。在关系到兼容性的地方，本文档会提醒你。

* [ISO C](https://www.gnu.org/software/libc/manual/html_node/ISO-C.html#ISO-C)
* [POSIX](https://www.gnu.org/software/libc/manual/html_node/POSIX.html#POSIX)
* [Berkeley Unix](https://www.gnu.org/software/libc/manual/html_node/Berkeley-Unix.html#Berkeley-Unix)
* [SVID](https://www.gnu.org/software/libc/manual/html_node/SVID.html#SVID)
* [XPEG](https://www.gnu.org/software/libc/manual/html_node/XPG.html#XPG)

## 使用 GNU C 库

这里描述了使用 GNU C 库涉及到的一些非常实际的问题，你得懂得。

* [Header Files](https://www.gnu.org/software/libc/manual/html_node/Header-Files.html#Header-Files)
* [Macro Definitions](https://www.gnu.org/software/libc/manual/html_node/Macro-Definitions.html#Macro-Definitions)
* [Reserved Names](https://www.gnu.org/software/libc/manual/html_node/Reserved-Names.html#Reserved-Names)
* [Feature Test Macros](https://www.gnu.org/software/libc/manual/html_node/Feature-Test-Macros.html#Feature-Test-Macros)


