# [网络数据库](https://www.gnu.org/software/libc/manual/html_node/Networks-Database.html#Networks-Database)

许多系统提供一个数据库，用来记录网络工作。通常存储在 */etc/networks* 文件，或者由一个命名服务器提供。你可以使用 `<netdb.h>` 的工具，访问网络数据库。

###: #include &lt;netdb.h&gt;

```c
#include <netdb.h>
```

###: struct netent

```c
struct netent;
```

* Data Type

`struct netent` 用来存储网络数据库的一条记录。它有以下成员：

* `char *n_name;` 正式的网络名字。

* `char **n_aliases;` 备选的网络名字，一个字符串数组。最后一个成员是一个终止符。

* `int n_addrtype;` 何种网络；对于因特网，总是等于 `AF_INET`。 

* `unsigned long int n_net;` 网络号。以主机字节序表示。

你可以下面的函数获取数据库记录，返回的记录存储在一个静态分配的缓冲区，如果需要保存信息，你必须复制它。

###: getnetbyname()

```c
struct netent *getnetbyname(const char *name);
```

* Preliminary: | MT-Unsafe race:netbyname env locale | AS-Unsafe dlopen plugin heap lock | AC-Unsafe corrupt lock fd mem |
* Function

`getnetbyname()` 函数返回网络名 `name` 的一条记录。如果查找失败，返回一个空指针。

> `getnetbyname()` 函数是不可重入的。

###: getnetbyaddr()

```c
struct netent *getnetbyaddr(uint32_t net, int type);
```

* Preliminary: | MT-Unsafe race:netbyaddr locale | AS-Unsafe dlopen plugin heap lock | AC-Unsafe corrupt lock fd mem |
* Function

`getnetbyaddr()` 函数返回网络号 `net` 的一条记录。`type` 指定何种网络，应该为因特网指定 `AF_INET`。如果查找失败，返回一个空指针。

> `getnetbyaddr()` 函数是不可重入的。

###: setnetent()

```c
void setnetent(int stayopen);
```

* Preliminary: | MT-Unsafe race:netent env locale | AS-Unsafe dlopen plugin heap lock | AC-Unsafe corrupt lock fd mem |
* Function

`setnetent()` 函数打开数据器，准备扫描。

如果 `stayopen` 是 `非 0`，会设定一个标志，后续调用 `getnetbyname()` 或 `getnetbyaddr()` 函数不会关闭数据库（通常它们会关闭数据库）。如果你多次调用这些函数，这个标志可以避免关闭再打开。

> `setnetent()` 函数是不可重入的。

###: getnetent()

```c
struct netent *getnetent(void);
```

* Preliminary: | MT-Unsafe race:netent race:netentbuf env locale | AS-Unsafe dlopen plugin heap lock | AC-Unsafe corrupt lock fd mem |
* Function

`getnetent()` 函数返回数据库的下一条记录。如果没有更多记录，返回一个空指针。

> `getnetent()` 函数是不可重入的。

###: endnetent()

```c
void endnetent(void);
```

* Preliminary: | MT-Unsafe race:netent env locale | AS-Unsafe dlopen plugin heap lock | AC-Unsafe corrupt lock fd mem |
* Function

`endnetent()` 函数关闭数据库。

> `endnetent()` 函数是不可重入的。