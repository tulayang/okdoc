

## 套接字

### socket()<br />shutdown() close() 

```
#include <sys/socket.h>

int socket(int domain, int type, int protocol); 
    // 
    // 创建一个新的套接字实例，成功返回套接字描述符，出错返回 -1。
    // 
    // domain - 指定通信的特性，包括地址格式、通信范围（同一主机还是网络）
    //
    //   ∘ AF_UNIX  AF_LOCAL  -  使用 UNIX 域，在同一主机通信  
    //                           绑定地址结构 struct sockaddr_un
    //   ∘ AF_INET            -  使用 IPv4 互联网协议 （ip)   
    //                           绑定地址结构 struct sockaddr_in
    //                           地址格式 = 32 位 IPv4 地址 + 16位端口号
    //   ∘ AF_INET6           -  使用 IPv6 互联网协议 （ipv6)
    //                           绑定地址结构 struct sockaddr_in6
    //                           地址格式 = 128 位 IPv6 地址 + 16位端口号 
    //   ∘ AF_UNSPEC          -  未指定，代表任何域
    //
    //   ∘ AF_IPX             -  IPX - Novell 协议     
    //   ∘ AF_NETLINK         -  内核用户接口设备 （netlink)
    //   ∘ AF_X25             -  ITU-T X.25 / ISO-8208 协议 （x25)
    //   ∘ AF_AX25            -  业余电台 AX.25 协议   
    //   ∘ AF_ATMPVC          -  访问 raw ATM PVCs     
    //   ∘ AF_APPLETALK       -  Appletalk ddp(7)
    //   ∘ AF_PACKET          -  低层包接口
    //
    // type - 指定套接字的类型，进一步确定通信特征
    //
    //   ∘ SOCK_STREAM        -  有序的、可靠的、双向的、面向连接的字节流
    //                           默认协议 TCP
    //   ∘ SOCK_DGRAM         -  固定长度的、无连接的、不可靠的报文传递
    //                           默认协议 UDP
    //   ∘ SOCK_SEQPACKET     -  固定长度的、有序的、可靠的、面向连接的报文传递
    //   ∘ SOCK_RAW           -  IP 协议的数据包接口 （在 POSIX.1 中为可选）
    //
    // protocol - 指定通信协议，通常是 0，表为给定的域和类型选择默认协议。
    //
    //   ∘ IPPROTO_TCP        -  传输控制协议
    //   ∘ IPPROTO_UDP        -  用户数据报协议
    //   ∘ IPPROTO_IP         -  IPv4 网际协议 
    //   ∘ IPPROTO_IPv6       -  IPv6 网际协议 （在 POSIX.1 中为可选）
    //   ∘ IPPROTO_ICMP       -  因特网控制报文协议
    //   ∘ IPPROTO_RAW        -  原始 IP 数据包协议 （在 POSIX.1 中为可选）

int shutdown(int sockfd, int how);
    // 关闭套接字的读写端，成功返回 0，出错返回 -1。
    //
    // 调用 close() 关闭套接字时，实际上只会减少套接字的引用计数，只有计数为 0，才真正关闭套接字。
    // 对于复制套接字（比如 `dup()`），要知道关闭了最后一个引用才会释放这个套接字。
    // 而 shutdown() 允许使一个套接字处于不活动状态，和引用它的文件描述符数目无关。
    // 其次，有时可以很方便的关闭套接字双向传输中的一个方向。
    //
    // shutdown() 并不关闭文件描述符，要关闭文件描述符。必须另外调用 close() 。
    // 
    // how - 关闭方式标志位：
    //
    //   ∘ SHUT_RD    -  关闭读端，无法从套接字读数据
    //   ∘ SHUT_WR    -  关闭写端，无法从套接字写数据
    //   ∘ SHUT_RDWR  -  关闭读写端，无法从套接字读写数据

#include <unistd.h>
int close(int fd);    // 同普通文件一样，可以用来关闭一个套接字描述符。成功返回 0，出错返回 -1
```

### bind()

```
#include <netinet/in.h>

#define INADDR_ANY    ((in_addr_t) 0x00000000)

////////////////////// UNIX DOMAIN Address /////////////////////////////

struct sockaddr_un {
    sa_family_t sun_family;        // domain - AF_UNIX
    char        sun_path[108];     // 套接字文件路径
}

////////////////////// IPV 4       Address ////////////////////////////

struct in_addr {
    in_addr_t sa_data[14];         // IPv4 地址
}

struct sockaddr_in {
    sa_family_t    sin_family;     // domain - AF_INET
    in_port_t      sin_port;       // 端口号
    struct in_addr sin_addr;       // IPv4 地址
}

////////////////////// IPV 6       Address ////////////////////////////

struct in6_addr {
    uint8_t s6_addr[16];           // IPv6 地址 
}

struct socraddr_in6 {
    sa_family_t     sin6_family;    // domain - AF_INET6
    in_port_t       sin6_port;      // 端口号
    struct in6_addr sin6_addr;      // IPv6 地址 
    uint32_t        sin6_flowinfo;  // IPv6 流信息
    uint32_t        sin6_scope_id;  // Scope ID (new in 2.4)   
}

//////////////////////////////////////////////////////////////

#include <sys/socket.h>

struct sockaddr {
    sa_family_t sa_family;        // domain
    char        sa_data[14];      // 地址
}

int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
    // 将一个套接字描述符绑定到一个地址上。成功返回 0，出错返回 -1 。
    // 
    // 不同的 domain 会使用不同的地址格式。当调用 bind() 时，会把传递的 addr 在内部转换为
    // 不同的地址结构，以匹配 domain 。
    //
    // addr    - 地址
    // addrlen - 地址长度
    //
    // 如果指定 IP 地址为 INADDR_ANY (<netinet/in.h>)，套接字端点可以被绑定到所有的系统网络
    // 接口上。这意味着可以接收这个系统所安装的任何一个网卡的数据包。
```

### listen()

```
#include <sys/socket.h>
int listen(int sockfd, int backlog);
    // 允许一个流套接字接受来自其它套接字的连接。成功返回 0，出错返回 -1 。
    //
    // backlog - 给出提示：当服务忙碌，无法处理多余连接时，入队列的上限。其实际值由
    // 系统决定，但上限由 SOMAXCONN 指定。在 Linux 2.4.25+，可以通过
    #/ /proc/sys/net/core/somaxconn 文件来修改 SOMAXCONN 值。 
```

### accept()

```
#include <sys/socket.h>
int accept(int sockfd, struct sockaddr *restrict addr, socklen_t *restrict addrlen);
    // 在一个流套接字上监听来自客户端的连接。成功返回客户端的套接字描述符，出错返回 -1 。
    // 如果套接字是非阻塞模式，如果没有连接请求，立刻返回 -1，并将 errno 置为 EAGAIN 或者 EWOULDBLOCK 。
    // 
    // addr    - 客户端的套接字地址，由调用修改
    // addrlen - 客户端的套接字地址长度，初始是 struct sockaddr 的长度，调用会对其修改
    //
    // 如果不关心客户端标识，可以将 addr 和 addrlen 置为 NULL 。
```

### connect()

```
#include <sys/socket.h>
int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
    // 和另一个套接字建立连接。成功返回 0，出错返回 -1 。
    //
    // addr    - 对端套接字地址
    // addrlen - 对端套接字地址长度
```

## 寻址

### htonl() htons() ntohl() ntohs()

```
#include <arpa/in.h>
uint32_t htonl(uint32_t host_uint32)  // 返回以网络字节序表示的 32 位整数
uint16_t htons(uint16_t host_uint16)  // 返回以网络字节序表示的 16 位整数
uint32_t ntohl(uint32_t net_uint32)   // 返回以主机字节序表示的 32 位整数
uint16_t ntohs(uint16_t net_uint16)   // 返回以主机字节序表示的 16 位整数
```

### inet_ntop() inet_pton()

```
#include <arpa/in.h>

const char *inet_ntop(int domain, const void *restrict addr, 
                      char *restrict str, socklen_t len);
            // 将网络字节序的二进制地址转换成文本字符串格式。
            // 成功返回地址字符串指针，出错返回 NULL 。
            //
            // domain - 仅支持 AF_INET 和 AF_INET6
            //
            // addr   - 网络字节序的二进制地址 
            //
            // str    - 指定保存文本字符串的缓冲区
            //
            // len    - 指定保存文本字符串的缓冲区大小。两个常量用来简于工作：INET_ADDRSTRLEN
            //          定义了足够大的空间来存放一个 IPv4 地址的文本字符串，INET6_ADDRSTRLEN
            //          定义了足够大的空间来存放一个 IPv6 地址的文本字符串


int inet_pton(int domain, const char *restrict str, void *restrict addr);
    // 将文本字符串格式转换成网络字节序的二进制地址。
    // 成功返回 1，格式无效返回 0，出错返回 -1 。
    //
    // domain - 仅支持 AF_INET 和 AF_INET6 
    //
    // str    - 文本字符串格式的二进制地址
    //
    // addr   - 指定保存网络字节序二进制地址的缓冲区
    //          1. 如果 domain == AF_INET， addr 需要足够大的空间来存放一个 32 位地址
    //          2. 如果 domain == AF_INET6，addr 需要足够大的空间来存放一个 128 位地址
    //
    // "192.168.1.1"        - IPv4 十进制地址
    // "::1"                - IPv6 十六进制地址
    // "::FFFF:192.168.1.1" - IPv4 映射的 IPv6 地址 
```

## 地址查询

### gethostent() sethostent() endhosent()

```
#inclide <netdb.h>       

// 查找计算机系统的主机信息
struct hostent {
    char  *h_name;       // 主机名
    char **h_aliases;    // 备用主机名列表
    int    h_addrtype;   // 地址类型
    int    h_length;     // 地址长度
    char **h_addr_list;  // 联网地址列表，采用网络字节序
};

struct hostent *gethostent(void);  // 成功返回主机信息，出错返回 NULL 。
                                   // 返回文件中的下一行记录。如果主机数据库文件没有打开，则打开它。

void sethostent(int stayopen);     // 回到文件起始点。如果数据库文件没有打开，则打开它。stayopen 置为
                                   // 非 0 时，调用gethostent() 后，文件保持打开状态。

void endhosent(void);              // 关闭数据库文件。
```

### getnetbyaddr() getnetbyname() getnetent() setnetent() endnetent()

```
#inclide <netdb.h>

// 查找网络名字和网络编号
struct netent {
    char     *n_name;       // 网络名字
    char    **n_aliases;    // 备用网络名列表
    int       n_addrtype;   // 地址类型
    unit_32   n_net;        // 网络编号
};

struct netent *getnetbyaddr(uint32_t net, int type);  // 成功返回网络名字和网络编号，出错返回 NULL 。
struct netent *getnetbyname(const char *name);        // 成功返回网络名字和网络编号，出错返回 NULL 。 
struct netent *getnetent(void);                       // 成功返回网络名字和网络编号，出错返回 NULL 。
                                                      // 返回文件中的下一行记录。如果主机数据库
                                                      // 文件没有打开，则打开它。

void setnetent(int stayopen);  // 回到文件起始点。如果数据库文件没有打开，则打开它。stayopen 置为
                               // 非 0 getnetent() 后，文件保持打开状态。   

void endnetent(void);          // 关闭数据库文件。
```

### getprotoentbynumber() getprotoentbyname() getprotoent() setprotoent() endprotoent()

```
#inclide <netdb.h>

// 查找协议名字和协议编号
struct protoent {
    char  *p_name;       // 协议名字
    char **p_aliases;    // 备用协议名列表
    int    p_proto;      // 协议编号
};

struct protoent *getprotobynumber(int proto);         // 成功返回协议信息，出错返回 NULL 。
struct protoent *getprotobyname(const char *name);    // 成功返回协议信息，出错返回 NULL 。 
struct protoent *getprotoent(void);                   // 成功返回协议信息，出错返回 NULL 。
                                                      // 返回文件中的下一行记录。如果主机
                                                      // 数据库文件没有打开，则打开它。

void setprotoent(int stayopen);  // 回到文件起始点。如果数据库文件没有打开，则打开它。stayopen 置为
                                 // 非 0 getprotoent() 后，文件保持打开状态。   

void endprotoent(void);          // 关闭数据库文件。
```

### getservbyport() getservbyname() getservent() setservent() endservent()

```
#include <netdb.h>

// 查找服务名字和端口号
struct servent {
    char  *s_name;       // 服务名字
    char **s_aliases;    // 备用服务名列表
    int    s_port;       // 端口号
    char  *s_proto;      // 协议名
};

struct servent *getservbyport(int proto);         // 成功返回服务信息，出错返回 NULL 。
struct servent *getservbyname(const char *name);  // 成功返回服务信息，出错返回 NULL 。 
struct servent *getservent(void);                 // 成功返回服务信息，出错返回 NULL 。
                                                  // 返回文件中的下一行记录。如果主机
                                                  // 数据库文件没有打开，则打开它。

void setservent(int stayopen);  // 回到文件起始点。如果数据库文件没有打开，则打开它。stayopen 置为
                                // 非 0 getservent() 后，文件保持打开状态。   

void endservent(void);          // 关闭数据库文件。
```

### getaddrinfo() freeaddrinfo() gai_strerro()<br />getnameinfo() getsockname() getpeername()

```
#include <sys/socket.h>
#include <netdb.h>

struct addrinfo {
    int               ai_flags;      // 自定义行为 
    int               ai_family;     // 地址族      AF_* 
    int               ai_socktype;   // 套接字的类型 SOCK_* 
    int               ai_protocol;   // 通信协议    IPPROTO_* 
    socklen_t         ai_addrlen;    // 地址字节长度
    struct sockaddr  *ai_addr;       // 地址
    char             *ai_canonname;  // 标准主机名
    struct addrinfo  *ai_next;       // 下一项记录
};

int getaddrinfo(const char *restrict host, const char *restrict service,
                const struct addrinfo *restrict hints, struct addrinfo **restrict result);
    // 将一个主机名和服务名映射成一个地址。成功返回 0，出错返回错误编号。
    // 
    // host - 主机名，或者 IPv4 十进制字符串地址，或者 IPv6 十六进制字符串地址
    //
    //        "192.168.1.1"        - IPv4 十进制地址
    //        "::1"                - IPv6 十六进制地址
    //        "::FFFF:192.168.1.1" - IPv4 映射的 IPv6 地址 
    //
    // service - 服务名或者十进制端口号
    //
    // hints - 指定返回地址的结构，只能设置 ai_flags ai_family ai_socktype ai_protocol，其他字段
    //         必须置 0 或者 NULL 。如果不需要指定 hints，可以置为 NULL 
    //
    //         ai_family    -  指定返回的地址族
    //         ai_socktype  -  指定返回的套接字类型
    //         ai_protocol  -  指定返回的协议
    //         ai_flags     -  标志位，指定函数行为
    //
    //           * AI_ADDRCONFIG   -  在本地系统至少配置了一个 IPv4 地址时返回 IPv4 地址 
    //                                （不是 IPv4 环回地址），在本地系统至少配置了一个 IPv6 
    //                                地址时返回 IPv6 地址 （不是 IPv6 环回地址）。
    //           * AI_ALL          -  参见 AI_V4MAPPEND 。
    //           * AI_CANONNAME    -  如果 host != NULL，返回一个包含主机规范名的字符串，此
    //                                字符串会包含在 result.ai_canonname 字段。
    //           * AI_NUMERICHOST  -  强制将 host 解释成一个数值地址字符串。用于在不必要解析
    //                                主机名时禁止解析，因为名字解析可能会花费较长时间。
    //           * AI_NUMERICSERV  -  强制将 service 解释成一个数值端口号。用于在防止调用任意
    //                                的名字解析服务，因为当 service 是一个数值字符串时解析是
    //                                没有必要的。
    //           * AI_PASSIVE      -  返回一个适合被动式打开（即监听套接字）的套接字地址结构。在
    //                                这种情况下，host 应该是 NULL，返回的 result.ai_addr
    //                                将会包含一个通配 IP 地址（即 INADDR_ANY 或 IN6ADDR_ANY_INT）。
    //                                如果没有设置这个标记，result.ai_addr 则可用于 connect()
    //                                和 sendto()；如果 host 是 NULL，返回的 result.ai_addr
    //                                中的 IP 地址将会被设置成环回 IP 地址 （根据所处的域，其值为
    //                                INADDR_LOOPBACK 或 IN6ADDR_LOOPBACK_INIT）。 
    //           * AI_V4MAPPEND    -  如果在 hints 的 ai_family 指定了 AF_INET6，那么在没有找到
    //                                匹配的 IPv6 地址时，返回的 result.ai_addr 包含 IPv4 映射
    //                                的 IPv6 地址。如果同时指定了 AI_ALL 和 AI_V4MAPPEND，那么
    #/                                result 中同时返回 IPv4 和 IPv6 地址，其中 IPv4 地址会被
    //                                映射成 IPv6 地址。host 可以被置为 NULL，此外 service 也可以
    #/                                置为 NULL，在这种情况下，返回的 result.ai_addr 包含的端口号
    //                                会被置为 0 。然而无法将 host 和 service 同时指定为 NULL ！！！

void freeaddrinfo(struct addrinfo *ai);  
     #/ getaddrinfo() 会动态地为 result 分配内存，当不需要 result 时，使用 freeaddrinfo() 释放内存。 

const char *gai_strerro(int error);
            // 当 getaddrinfo() 出错时不能使用 perror() 或者 strerror() 生成错误消息，而要调用
            // gai_strerro() 将返回的错误编号转换成错误消息。 

int getnameinfo(const struct sockaddr *restrict addr, socklen_t addrlen,
                char *restrict host, socklen_t hostlen,
                char *restrict service, socklen_t servlen, int flags);
    // 将一个地址映射成主机名和服务名。成功返回 0，出错返回错误编号。
    // 
    // host    - 存放返回的主机名的缓冲区
    // service - 存放返回的服务名的缓冲区
    // flags   - 行为标志
    //
    //   * NI_DGRAM         -  服务基于数据报而非流
    //   * NI_NAMEREQD      -  如果找不到主机名，将其作为一个错误对待
    //   * NI_NOFQDN        -  对于本地主机，仅返回全限定域名的节点名部分
    //   * NI_NUMERICHOST   -  返回主机地址的数字形式，而非主机名
    //   * NI_NUMERICSCOPE  -  对于 IPv6，返回范围 ID 的数字形式，而非名字
    //   * NI_NUMERICSERV   -  返回服务地址的数字形式（即端口号），而非名字

int getsockname(int sockfd, struct sockadd *addr, socklen_t *addrlen);
    // 获取本端套接字的地址。成功返回 0，出错返回 -1 。

int getpeername(int sockfd, struct sockadd *addr, socklen_t *addrlen);
    // 获取对端套接字的地址。成功返回 0，出错返回 -1 。
```

## 数据传输

### recv() recvfrom() recvmsg()

```
#include <sys/socket.h>

ssize_t recv(int sockfd, const void *buf, size_t nbytes, int flags); 
        // 成功返回接收的字节数，如果无可用数据或对方已经按序结束返回 0，出错返回 -1 。

ssize_t recvfrom(int sockfd, void *buf, size_t nbytes, int flags, 
                 struct sockaddr *addr, socklen_t addrlen);  
        // 成功返回接收的字节数，如果无可用数据或对方已经按序结束返回 0，出错返回 -1 。
        // 通过无连接的套接字发送报文。
        //
        // addr     - 目标地址
        // addrlen  - 目标地址长度

struct msghdr {
    void         *msg_name;        // 可选地址 
    socklen_t     msg_namelen;     // 可选地址长度
    struct iovec *msg_iov;         // 向量缓冲区   
    int           msg_iovlen;      // 向量缓冲区个数
    void         *msg_control;     // 辅助数据缓冲区
    socklen_t     msg_controllen;  // 辅助数据缓冲区长度
    int           msg_flags;       // 接收标志位  
};
ssize_t recvmsg(int sockfd, struct msghdr *msg, int flags);
        // 成功返回接收的字节数，如果无可用数据或对方已经按序结束返回 0，出错返回 -1 。
        // 用于进程间传递描述符。        
        
// flags - 位掩码，行为标志
```
<table>
<tr>
  <th class="ta-c" style="min-width:160px">标志</th>
  <th class="ta-c" style="min-width:90px">描述</th>
  <th class="ta-c" style="min-width:70px">POSIX.1</th>
  <th class="ta-c" style="min-width:70px">FreeBSD<br/>8.0</th>
  <th class="ta-c" style="min-width:70px">Linux<br />3.2.0</th>
  <th class="ta-c" style="min-width:80px">Mac OS X<br />10.6.8</th>
  <th class="ta-c" style="min-width:70px">Solaris<br />10</th>
</tr>
<tr>
  <td class="ta-l">MSG_OOB</td>
  <td>在套接字上接受带外数据</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
</tr>
<tr>
  <td class="ta-l">MSG_PEEK</td>
  <td>从套接字缓冲区中获取一份请求自己的副本，不降请求的字节从缓冲区中实际移除。这份数据稍后可以由其他<br />recv() read() 调用重新读取</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
</tr>
<tr>
  <td class="ta-l">MSG_WAITALL</td>
  <td>直到返回的字节数 == nbytes 才返回，否则一直阻塞。以下情况会打破阻塞：<br />a.捕获到一个信号<br />b.流式套接字的对端终止了连接<br />c.遇到了带外数据字节<br />d.从数据报套接字接收到的消息长度小于<br />nbytes
<br />e.套接字上出现了错误</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
</tr>
<tr>
  <td class="ta-l">MSG_CMSG_CLOEXEC</td>
  <td>为 UNIX 域套接字上接收的文件描述符设置<br />close-on-exec</td>
  <td class="ta-c"></td>
  <td class="ta-c"></td>
  <td class="ta-c">•</td>
  <td class="ta-c"></td>
  <td class="ta-c"></td>
</tr>
<tr>
  <td class="ta-l">MSG_DONTWAIT</td>
  <td>启用非阻塞操作</td>
  <td class="ta-c"></td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c"></td>
  <td class="ta-c">•</td>
</tr>
<tr>
  <td class="ta-l">MSG_ERRQUEUE</td>
  <td>接收错误信息作为辅助数据</td>
  <td class="ta-c"></td>
  <td class="ta-c"></td>
  <td class="ta-c">•</td>
  <td class="ta-c"></td>
  <td class="ta-c"></td>
</tr>
<tr>
  <td class="ta-l">MSG_TRUNC</td>
  <td>即使数据报被截断，也返回数据报的真实长度</td>
  <td class="ta-c"></td>
  <td class="ta-c"></td>
  <td class="ta-c">•</td>
  <td class="ta-c"></td>
  <td class="ta-c"></td>
</tr>

</table>

### send() sendto() sendmsg()
  
```
#include <sys/socket.h>

ssize_t send(int sockfd, const void *buf, size_t nbytes, int flags);
        // 成功返回发送的字节数，出错返回 -1 。

ssize_t sendto(int sockfd, const void *buf, size_t nbytes, int flags, 
               const struct sockaddr *addr, socklen_t addrlen);  
        // 成功返回发送的字节数，出错返回 -1 。通过无连接的套接字发送报文。
        //
        // addr     - 目标地址
        // addrlen  - 目标地址长度

struct msghdr {
    void         *msg_name;        // 可选地址 
    socklen_t     msg_namelen;     // 可选地址长度
    struct iovec *msg_iov;         // 向量缓冲区   
    int           msg_iovlen;      // 向量缓冲区个数
    void         *msg_control;     // 辅助数据缓冲区
    socklen_t     msg_controllen;  // 辅助数据缓冲区长度
    int           msg_flags;       // 接收标志位  
};
ssize_t sendmsg(int sockfd, const struct msghdr *msg, int flags);
        // 成功返回发送的字节数，出错返回 -1 。用于进程间传递描述符。
        
// flags - 位掩码，发送行为标志
```
<table>
<tr>
  <th class="ta-c" style="min-width:160px">标志</th>
  <th class="ta-c" style="min-width:90px">描述</th>
  <th class="ta-c" style="min-width:70px">POSIX.1</th>
  <th class="ta-c" style="min-width:70px">FreeBSD<br/>8.0</th>
  <th class="ta-c" style="min-width:70px">Linux<br />3.2.0</th>
  <th class="ta-c" style="min-width:80px">Mac OS X<br />10.6.8</th>
  <th class="ta-c" style="min-width:70px">Solaris<br />10</th>
</tr>
<tr>
  <td class="ta-l">MSG_OOB</td>
  <td>在套接字上接受带外数据</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
</tr>
<tr>
  <td class="ta-l">MSG_EOR</td>
  <td>标记记录结束</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
</tr>
<tr>
  <td class="ta-l">MSG_DONTWAIT</td>
  <td>启用非阻塞操作</td>
  <td class="ta-c"></td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
</tr>
<tr>
  <td class="ta-l">MSG_DONTROUTE</td>
  <td>不将数据包路由出本地网络</td>
  <td class="ta-c"></td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
</tr>
<tr>
  <td class="ta-l">MSG_NOSIGNAL</td>
  <td>在写无连接的套接字时不产生 SIGPIPE 信号</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c">•</td>
  <td class="ta-c"></td>
  <td class="ta-c"></td>
</tr>
<tr>
  <td class="ta-l">MSG_EOF</td>
  <td>发送数据包后关闭套接字的发送端</td>
  <td class="ta-c"></td>
  <td class="ta-c">•</td>
  <td class="ta-c"></td>
  <td class="ta-c">•</td>
  <td class="ta-c"></td>
</tr>
<tr>
  <td class="ta-l">MSG_CONFIRM</td>
  <td>提供链路层反馈以保持地址映射有效</td>
  <td class="ta-c"></td>
  <td class="ta-c"></td>
  <td class="ta-c">•</td>
  <td class="ta-c"></td>
  <td class="ta-c"></td>
</tr>
<tr>
  <td class="ta-l">MSG_MORE</td>
  <td>延迟发送数据包允许写更多数据</td>
  <td class="ta-c"></td>
  <td class="ta-c"></td>
  <td class="ta-c">•</td>
  <td class="ta-c"></td>
  <td class="ta-c"></td>
</tr>
</table>

## 套接字配置

### getsockopt() setsockopt()

```
#include <sys/socket.h>

int getsockopt(int sockfd, int level, int optname, void *optval, socklen_t *optlen);
    // 获取套接字配置。成功返回 0，出错返回 -1 。

int setsockopt(int sockfd, int level, int optname, const void *optval, socklen_t optlen);
    // 设置套接字配置。成功返回 0，出错返回 -1 。
    //
    // level - 指定套接字选项适用的协议，比如 IP 或者 TCP 。如果作为通用选项，将其置为 SOL_SOCKET 。
    //         否则，设置为控制此选项的协议编号。比如，TCP 的 level 是 IPPROTO_TCP，IP 的 level 
    //         是 IPPROTO_IP 。
    // 
    // optname - 选项
    // optval  - 选项缓冲区，根据不同的选项的指向一个数据结构或者一个整数。
    //           如果整数非 0 则启用选项，如果整数为 0 则禁用选项
    // optlen  - 选项缓冲区长度  

```

optname|optval 的类型|描述
---|---|---
SO_ACCEPTCON|int|返回信息表示该套接字是否能被监听 （仅用于 getsockopt()）
SO_BROADCAST|int|如果 *optval != 0，启用广播
SO_DEBUG|int|如果 *optval != 0，启用网络驱动调试功能
SO_DONTROUTE|int|如果 *optval != 0，绕过常用理由直接发送
SO_ERROR|int|返回挂起的套接字错误并清除 （仅用于 getsockopt()）
SO_KEEPALIVE|int|如果 *optval != 0，启用周期性 keep-alive 报文，发送“保持活动”包
SO_LINGER|struct linger|套接字关闭时如果还有未发数据，则延迟时间
SO_OOBINLINE|int|如果 *optval != 0，将带外数据放在普通数据中
SO_RCVBUF|int|接收缓冲区的字节长度
SO_RCVLOWAT|int|接收调用中返回的最小数据字节数
SO_RCVTIMEO|struct timeval|套接字接收调用的超时值
SO_REUSEADDR|int|如果 *optval != 0，重用 bind() 中的地址
SO_SNDBUF|int|发送缓冲区的字节长度
SO_SNDLOWAT|int|发送调用中返回的最小数据字节数
SO_SNDTIMEO|struct timeval|套接字发送调用的超时值
SO_TYPE|int|标识套接字类型 （仅用于 getsockopt()）

## Example

```
static int Connect(const char *host, const char *service, int type) {
    struct addrinfo hints;
    struct addrinfo *result, *rp;

    memset(&hints, 0, sizeof(struct addrinfo));
    hints.ai_canonname = NULL;
    hints.ai_addr      = NULL;
    hints.ai_next      = NULL;
    hints.ai_socktype  = type;
    hints.ai_family    = AF_UNSPEC;                    ## 适用 IPv4 和 IPv6      

    if (getaddrinfo(host, service, &hints, &result) != 0) {
        errno = ENOSYS;
        return -1;
    }

    int optval = 1;  ## 启用 SO_REUSEADDR
    int sockfd;

    for (rp = result; rp != NULL; rp = rp->ai_next) {
        sockfd = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
        if (sockfd != -1) {
            if (connect(sockfd, ro->ai_addr, rp->ai_addrlen) != -1)
                break;    // 连接地址成功
            close(sockfd);
        }
    }

    freeaddrinfo(result);
    return (rp == NULL) ? -1 : sockfd;
}

static int Socket(const char *service, int type, socklen_t *addrlen, 
                         int doListen, int backlog) {
    struct addrinfo hints;
    struct addrinfo *result, *rp;

    memset(&hints, 0, sizeof(struct addrinfo));
    hints.ai_canonname = NULL;
    hints.ai_addr      = NULL;
    hints.ai_next      = NULL;
    hints.ai_socktype  = type;
    hints.ai_family    = AF_UNSPEC;                    ## 适用 IPv4 和 IPv6
    hints.ai_flags     = AI_PASSIVE | AI_NUMERICSERV;  ## 不解析端口号         

    if (getaddrinfo(NULL, "80", &hints, &result) != 0)
        return -1;

    int optval = 1;  ## 启用 SO_REUSEADDR
    int sockfd;

    for (rp = result; rp != NULL; rp = rp->ai_next) {
        sockfd = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
        if (sockfd != -1) {
            if (doListen) {
                if (setsockopt(spckfd, SOL_SOCKET, SO_REUSEADDR, 
                               &optval, sizeof(optval)) == -1) {
                    close(sockfd);
                    freeaddrinfo(result);
                    return -1;
                }
                if (bind(sockfd, ro->ai_addr, rp->ai_addrlen) == 0) 
                    break;    // 绑定地址成功
                close(sockfd);
            }
        }
    }

    if(rp != NULL) {
        if (doListen) {
            if (listen(sockfd, backlog, backlog) == -1) {
                close(sockfd);
                freeaddrinfo(result);
                return -1;
            }
        }
        if (addrlen != NULL) {
            *addrlen = rp->ai_addrlen;
        }
        freeaddrinfo(result);
        return sockfd;
    }

    freeaddrinfo(result);
    return -1;
}

int Listen(const char *service, int backlog, socklen_t *addrlen) {
    return Socket(service, SOCK_STREAM, addrlen, 1, backlog);
}

int Bind(const char *service, int type, socklen_t *addrlen) {
    return Socket(service, type, addrlen, 0, 0);
}

char *AddressStr(const struct sockaddr *addr, socklen_t addrlen, 
                 char *addrStr, int addrStrlen) {
    char host[NI_MAXHOST], service[NI_MAXSERV];

    if (getnameinfo(addr, addrlen, host, NI_MAXHOST, service, NI_MAXSERV) == 0)
        snprintf(addrStr, addrStrlen, "(%s, %s)", host, service);
    else 
        snprintf(addrStr, addrStrlen, "(?UNKNOWN?)");
    addrStr[addrStrlen - 1] = ' ';
    return addrStr;
}

```