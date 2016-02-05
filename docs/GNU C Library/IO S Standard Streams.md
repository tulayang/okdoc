# [标准流](https://www.gnu.org/software/libc/manual/html_node/Standard-Streams.html#Standard-Streams)

当你程序中的 `main()` 函数被调用时，程序已经拥有三个预打开的流。它们作为标准流，用于进程的输入输出。

在 GNU C 库，`stdin`、`stdout`、`stderr` 是普通变量，你可以把它们设置为其它值。例子：

```c
fclose (stdout);
stdout = fopen ("standard-output-file", "w");
```

然而，注意，在其他系统中，`stdin`、`stdout`、`stderr` 可能是宏常量，你不能用上面的方式修改它们。

## API

###: #include &lt;stdio.h&gt;

```c
#include <stdio.h>
```

###: stdin

```c
FILE *stdin
```

* Variable

标准输入流，程序的常用输入。

###: stdout

```c
FILE *stdout
```

* Variable

标准输出流，程序的常用输出。

###: stderr

```c
FILE *stderr
```

* Variable

标准错误流，程序的错误输出。

