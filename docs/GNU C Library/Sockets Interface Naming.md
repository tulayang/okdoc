# [接口命名](https://www.gnu.org/software/libc/manual/html_node/Interface-Naming.html#Interface-Naming)

每个网络接口有一个名字。通常由字母组成，表示接口类型，并且，如果机器有多于一个该类型的接口，后面还会跟随一个数字。比如，lo （环回接口） 和 eth0 （第一个以太网接口）。

尽管这些名字对人类来讲很方便，但是对于机器就比较笨拙了，需要采用接口索引的方法来引用接口。

###: #include &lt;net/if.h&gt;

```c
#include <net/if.h>
```

###: IFNAMSIZ

```c
int IFNAMSIZ
```

* Macro

`IFNAMSIZ` 常量定义：可以容纳一个接口名字的缓冲区的最小长度，包括终止符。

###: if_nametoindex()

```c
unsigned int if_nametoindex(const char *ifname);
```

* Preliminary: | MT-Safe | AS-Unsafe lock | AC-Unsafe lock fd |
* Function

`if_nametoindex()` 函数根据接口的名字 `ifname` 返回索引。如果指定的 `ifname` 不存在，返回 `0`。

###: if_indextoname()

```c
char *if_indextoname(unsigned int ifindex, char *ifname);
```

* Preliminary: | MT-Safe | AS-Unsafe lock | AC-Unsafe lock fd |
* Function

`if_indextoname()` 函数根据接口的索引 `ifindex` 映射它的名字。返回的名字存储在 `ifname`---必须最少 `IFNAMSIZ` 长度。如果 `ifindex` 是无效的，返回一个空指针；否则返回 `ifname`。

###: struct if_nameindex

```c
struct if_nameindex
```

* Data Type

`struct if_nameindex` 用来存储一个接口的信息。它的成员如下：

* `unsigned int if_index;` 接口索引。

* `char *if_name;` 有终止符的名字。

###: if_nameindex()

```c
struct if_nameindex *if_nameindex(void);
```

* Preliminary: | MT-Safe | AS-Unsafe heap lock/hurd | AC-Unsafe lock/hurd fd mem |
* Function

`if_nameindex()` 函数返回一个 `struct if_nameindex` 数组，每一项对应一个现有的接口。最后一项是索引 0，名字是一个空指针。如果出现错误，返回一个空指针。

返回的结构指针，必须用 `if_freenameindex()` 释放。

###: if_freenameindex()

```c
void if_freenameindex(struct if_nameindex *ptr);
```

* Preliminary: | MT-Safe | AS-Unsafe heap | AC-Unsafe mem |
* Function

`if_freenameindex()` 函数用来释放 `if_nameindex()` 函数返回的指针。

