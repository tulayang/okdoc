```
#include <sys/types.h>
#include <sys/socket.h> 
```

socket → bind → listen → accept ↻ & socket → connect
--------------------------------------------------

```
int socket(int family, int type, int protocol)  ⇒  -1(errno) | fd  // 创建一个通信端点，并返回描述符

    • family               // 采用的通信域，地址格式
      ∘ AF_UNIX, AF_LOCAL  // 本地通信 （unix）
      ∘ AF_INET            // IPv4 互联网协议 （ip)
      ∘ AF_INET6           // IPv6 互联网协议 （ipv6)
      ∘ AF_IPX             // IPX - Novell 协议     
      ∘ AF_NETLINK         // 内核用户接口设备 （netlink)
      ∘ AF_X25             // ITU-T X.25 / ISO-8208 协议 （x25)
      ∘ AF_AX25            // 业余电台 AX.25 协议   
      ∘ AF_ATMPVC          // 访问 raw ATM PVCs     
      ∘ AF_APPLETALK       // Appletalk   ddp(7)
      ∘ AF_PACKET          // 低层包接口
    
    • type                 // 采用的通信语义，套接字类型
      ∘ SOCK_STREAM        // 提供一个有序的、可靠的、全双工的、基于连接的字节流支持带外的数据传输
      ∘ SOCK_DGRAM         // 支持数据包(无连接、不可靠并有长度限制的消息)
      ∘ SOCK_SEQPACKET     // 提供有序的、可靠的、全双工的基于连接的数据报传输，每个数据报有一个最大长度；
                           // 在每一个输入系统调用里，一次消耗要求读取所有包内容
      ∘ SOCK_RAW           // 提供裸网络协议的访问
      ∘ SOCK_RDM           // 提供一个可靠的但不保证顺序的数据报层
      ∘ SOCK_PACKET        // 古老的并且不应该在新程序里使用
    
    • protocol             // 采用的协议方式
      ∘ IPPROTO_TCP
      ∘ IPPROTO_UDP
      ∘ IPPROTO_STCP
      ∘ IPPROTO_TIPC      
      
int bind(int sockfd, const struct sockaddr *addr, socklen_t length)  ⇒  -1(errno) | 0  // 绑定一个通信端点
    
    • addr                 // 网络地址
      ∘ IPv4
        struct sockaddr_in {
            sa_family_t     sin_family;    // AF_INET
            int_port_t      sin_port;      // 端口号
            struct in_addr {
                uint32_t    s_addr;        
            }               sin_addr;      // 网络地址
        }
      ∘ IPv6
        struct sockaddr_in6 {
            sa_family_t     sin6_family;   // AF_INET
            int_port_t      sin6_port;     // 端口号
            uint32_t        sin6_flowinfo; // IPv6 流信息
            uint32_t        sin6_scope_id; // Scope ID (new in 2.4)
            struct in6_addr {
                uint32_t    s6_addr[16];
            }               sin6_addr;     // 网络地址
        } 
      ∘ ...
      
int listen (int sockfd, int backlog)  ⇒ -1(errno) | 0
    
    • backlog              // 当有多个客户端程序和服务端相连时，允许的排队长度
    
int connect(int sockfd, const struct sockaddr *addr, socklen_t length)  ⇒ -1(errno) | 0
int accept (int sockfd, struct sockaddr *addr, socklen_t *length)       ⇒ -1(errno) | fd
```

recv & send
-------------

```
ssize_t recv(int sockfd, void *buffer, size_t length, intflags)         ⇒  -1(errno) | 0(尾部) | 实际读取的字节数
ssize_t recvmsg(int sockfd, struct msghdr *msg, int flags)              ⇒  -1(errno) | 0(尾部) | 字节数
ssize_t recvfrom(int sockfd, 
                 void *buffer, size_t length, 
                 int flags, 
                 struct sockaddr *addr, socklen_t length)

ssize_t send(int sockfd, const void *buffer, size_t length, int flags)  ⇒  -1(errno) | 字节数

        • flags
          ∘ MSG_CONFIRM      // 提供链路层反馈
          ∘ MSG_DONTROUTE    // 不降数据包路由出本地网络
          ∘ MSG_DONTWAIT     // 允许非阻塞，等价于 O_NONBLOCK
          ∘ MSG_EOF          // 发送数据后关闭套接字发送端
          ∘ MSG_EOR          // 标记记录结束
          ∘ MSG_MORE         // 延迟发送数据包允许写更多数据
          ∘ MSG_NOSIGNAL     // 写无连接的套接字时不产生SIGPIPE信号
          ∘ MSG_OOB          // 发送带外数据

ssize_t sendmsg(int sockfd, const struct msghdr *msg, int flags)       ⇒  -1(errno) | 字节数  

        • msg
          struct msghdr {
              void         *msg_name,        // 目的地址 
              socklen_t     msg_namelen;     // 目的地址长度   
              struct iovec *msg_iov;         // 
              int           msg_iovlen;
              void         *msg_control;    
              socklen_t     msg_controllen;   
              int           msg_flags;       
          } 

ssize_t sendto(int sockfd, 
               const void *buffer, size_t length, 
               int flags, 
               const struct sockaddr *addr, socklen_t length)
```
