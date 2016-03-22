```
#include <netinet/in.h> 网络地址协议族，protocol 在此文件中定义
#include <sys/types.h>  基本系统数据类型的定义

#include <netinet/in.h>
#include <arpa/inet.h>
```

Convert Network （转换网络地址）
-----------------------------

```
uint32_t htonl(uint32_t hostlong)   // 将一个32位数从主机字节顺序转换为网络字节顺序（IP地址）
uint16_t htons(uint16_t hostshort)  // 将一个16位数从主机字节顺序转换为网络字节顺序（端口号）

struct in_addr {                                               
    in_addr_t s_addr;               // 32位二进制网络字节顺序的IPV4地址（网络字节顺序）
}

in_addr_t      inet_addr(const char *str)        ⇒  -1 | 网络地址    // 字符串 → 32位二进制网络字节顺序的IPV4地址，255.255.255.255是无效地址
in_addr_t      inet_network (const char *str)    ⇒  -1 | 网络地址    // 字符串 → 32位二进制主机字节顺序的IPV4地址，255.255.255.255是无效地址
int            inet_aton(const char *str, 
                         struct in_addr *addr)   ⇒  0 | 非0         // 字符串 → 32位二进制网络字节顺序的IPV4地址，255.255.255.255是有效地址
char          *inet_ntoa(struct in_addr addr)    ⇒  NULL | 字符地址  // 32位二进制网络字节顺序的IPV4地址 → 字符串，255.255.255.255是有效地址
in_addr_t      inet_lnaof(struct in_addr addr)   ⇒  -1 | 网络地址    // 32位二进制网络字节顺序的IPV4地址 → 主机位
in_addr_t      inet_netof(struct in_addr addr)   ⇒  -1 | 网络地址    // 32位二进制网络字节顺序的IPV4地址 → 网络位     
struct in_addr inet_makeaddr(int net, int host)  ⇒  -1 | 网络地址    // 网络位 + 主机位 → 32位二进制网络字节顺序的IPV4地址，255.255.255.255是无效地址

```