# [流和多线程](https://www.gnu.org/software/libc/manual/html_node/Streams-and-Threads.html#Streams-and-Threads)

POSIX 标准规定：流操作，默认应该是原子的。每个流在内部维护一把锁，当执行任务时都要先获取该锁---以此来保证操作是原子的。因此，你可以在多线程中使用流，这和你在单线程中使用的方式相同。不过，作为程序员，你应该了解可能存在的并发问题。

## 流的内部锁

常用的流函数，比如 `fgetc()`、`fputc()` 等等，都会在内部先获取锁，然后执行操作。另外，定义了一些函数，可以让你更精细的执行锁控制。

###: #include &lt;stdio.h&gt;

```c
#include <stdio.h>
```

###: flockfile()

```c
void flockfile(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Unsafe lock |
* Function

`flockfile()` 函数获取流 `stream` 的内部锁。当前线程会阻塞，直到锁被取到。必须调用 `funlockfile()` 来释放取到的锁。

###: ftrylockfile()

```c
int ftrylockfile(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Unsafe lock |
* Function

`ftrylockfile()` 函数获取流 `stream` 的内部锁。如果不能立刻取到，则返回，不会阻塞。如果成功取到锁，返回 `0`；否则，返回 `非 0`。

###: funlockfile()

```c
void funlockfile(FILE *stream);
```

* Preliminary: | MT-Safe | AS-Safe | AC-Unsafe lock |
* Function

`funlockfile()` 函数释放流 `stream` 的内部锁。流必须已经被 `flockfile()` 或 `ftrylockfile()` 锁定；否则，调用 `funlockfile()`，当前线程的行为是未知的。此外，内部锁不执行取锁计数。

###

## 如何控制流的内部锁

例子：

```c
FILE *fp;

{
   …
   flockfile(fp);
   fputs("This is test number ", fp);
   fprintf(fp, "%d\n", test);
   funlockfile(fp);
}
```

当一个线程执行 `flockfile()` 之后、`funlockfile()` 之前，另一个线程也执行 `flockfile()` 时就会阻塞。直到第一个线程执行 `funlockfile()` 释放锁，另一个线程获得锁，从阻塞中醒来，继续向下执行。

再看一个例子：

```c
void foo(FILE *fp) {
  ftrylockfile(fp);
  fputs("in foo\n", fp);
  /* This is very wrong!!!  */
  funlockfile(fp);
}
```

上面的例子是非常错误的。如果 `ftrylockfile()` 不能成功取到锁，就无法有效保护下面的操作。正确的写法应该是这样：

```c
void foo(FILE *fp) {
    if (ftrylockfile(fp) == 0) {
        fputs("in foo\n", fp);
        funlockfile(fp);
    }
}
```

## 不安全的流函数

当频繁地执行锁操作时，其消耗是比较昂贵的，比如，在循环中反复地锁定解锁。如果可能的话，我们都希望避免使用锁。为此，POSIX 标准定义了一些特别的流函数，它们的名字带有 “_unlocked”，是同名函数的无锁版本。它们不会在内部获取锁，因此，速度更快。GNU C 库纳入了这些函数。

你应该自己管理这些函数的锁控制，最好的方法是始终在 `flockfile()` 和 `funclockfile()` 之间使用。比如，你可以这样使用它们：

```c
void foo(FILE *fp, char *buf) {
    flockfile(fp);
    while(*buf != '/') {
        putc_unlocked(*buf++, fp);
    }
    funlockfile(fp);
}
```

###: getc_unlocked()

```c
int getc_unlocked(FILE *stream);
```

###: getchar_unlocked()

```c
int getchar_unlocked(void);
```

###: putc_unlocked()

```c
int putc_unlocked(int c, FILE *stream);
```

###: putchar_unlocked()

```c
int putchar_unlocked(int c);
```

###
