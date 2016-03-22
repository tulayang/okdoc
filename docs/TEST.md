## abcdefg

abcdefg

### abcdefg

abcdefg


a|b
--|--
a|b
c|d
e|f


# 使用 syslog 记录消息

许多系统有一个称为 “syslog” 的工具。它允许程序向管理员提交消息，而且可以配置成多样的提交方式。比如直接在控制台打印、用邮件发送给某个人，或者记录到一个日志文件作为备案。

---------------------------------------------------------

---------------------------------------------------------

# 使用 syslog 记录消息

系统管理员需要对付大量不同分类的消息，这些消息都是来自各个子系统。比如：FTP 服务器在有连接请求时可能想要报告，内核遇到磁盘失败时可能想报告硬件故障，DNS 服务器可能想定期报告自己的监控状态。

## 概述

系统管理员需要对付大量不同分类的消息，这些消息都是来自各个子系统。比如：FTP 服务器在有连接请求时可能想要报告，内核遇到磁盘失败时可能想报告硬件故障，DNS 服务器可能想定期报告自己的监控状态。

这些消息，其中的一部分需要立刻通知管理员。当然，也可能不是管理员，而是主要负责相关事务的系统管理者。其它的一些消息可能只需要记录下来，以备将来查找问题。还有一些消息可能只是一些自动化程序的信息提取，用来生成月报。

### 系统支持

为了对付这么多消息，从 4.2 BSD 开始，提供一个称为 “syslog” 的工具来简化消息记录。所有从 BSD 派生的系统都支持该系统记录。Single UNIX Specification XSI 扩展包括了 “syslog” 函数。

#### 情况第一

为了对付这么多消息，从 4.2 BSD 开始，提供一个称为 “syslog” 的工具来简化消息记录。所有从 BSD 派生的系统都支持该系统记录。Single UNIX Specification XSI 扩展包括了 “syslog” 函数。

#### 情况第二

为了对付这么多消息，从 4.2 BSD 开始，提供一个称为 “syslog” 的工具来简化消息记录。所有从 BSD 派生的系统都支持该系统记录。Single UNIX Specification XSI 扩展包括了 “syslog” 函数。

```nim
type
    M = object
        a: char  #  0 - 后面填充
        b: int   #  8
        c: char  #  16
        d: char

    N = object {.packed.}
        a: char  #  0
        b: int   #  1
        c: char  #  9

    O = object
        a: int   #  0
        b: char  #  8
        c: char  #  9

    A = object
        a: char  #  0
        b: char  #  1 - 后面填充
        c: int   #  8

var m = M(a:'a', b:1, c:'c')

echo repr addr(m.a)   #  0
echo repr addr(m.b)   #  8
echo repr addr(m.c)   # 16 
echo repr addr(m.d)   # 17 

echo "--------------------------"

var n = N(a:'a', b:1, c:'c')

echo repr addr(n.a)   #  0
echo repr addr(n.b)   #  1
echo repr addr(n.c)   #  9 

echo "--------------------------"

var o = O(a:1, b:'b', c:'c')

echo repr addr(o.a)   #  0
echo repr addr(o.b)   #  8
echo repr addr(o.c)   #  9 

echo "--------------------------"

var a = A(a:'a', b:'b', c:1)

echo repr addr(a.a)   #  0
echo repr addr(a.b)   #  1
echo repr addr(a.c)   #  8 
```