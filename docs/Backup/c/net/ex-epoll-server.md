```
#include <sys/types.h>
#include <sys/socket.h>  
#include <sys/epoll.h>
#include <netinet/in.h> 
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <fcntl.h>
#include <malloc.h>
#include <errno.h>

#define BUFSIZE   1024
#define MAXEVENTS 10
#define SENDDATA  "0101010101010101"

int                 server_fd;                  // 服务器套接字描述符
int                 client_fd;                  // 客户端描述符
int                 epoll_fd;                   // 事件描述符
struct epoll_event  event_buffer;               // 事件对象
struct epoll_event  event_notifies[MAXEVENTS];  // 事件组

void event_listen() {
    struct sockaddr_in  addr;                   // 服务器地址参数

    // 配置服务器主机，端口号
    addr.sin_family = AF_INET;                  // 地址方式 IPv4
    addr.sin_port   = htons(10000);             // 端口号 10000
    inet_aton("127.0.0.1", &(addr.sin_addr));   // 格式化网络地址 127.0.0.1

    // 配置服务器套接字，启动服务器    
    server_fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    bind(server_fd, (struct sockaddr *)&addr, sizeof(addr));
    listen(server_fd, 100);
    printf("→ Event listen.\n");
}

void event_accept(int fd) {
    struct sockaddr_in  addr;                   // 客户端地址参数
    socklen_t           addr_size;              // 客户端地址结构尺寸
    client_fd = accept(fd, (struct sockaddr *)&addr, &addr_size);
    fcntl(client_fd, F_SETFL, O_NONBLOCK);
}

void event_add(int fd, uint32_t type) {
    event_buffer.data.fd = fd;
    event_buffer.events  = type;
    epoll_ctl(epoll_fd, EPOLL_CTL_ADD, fd, &event_buffer);
    printf("→ Event add fd %d.\n", fd);
}

void event_mod(int fd, uint32_t type) {
    event_buffer.data.fd = fd;
    event_buffer.events  = type;
    epoll_ctl(epoll_fd, EPOLL_CTL_MOD, fd, &event_buffer);
    printf("→ Event mod fd %d.\n", fd);
}

void event_del(int fd) {
    epoll_ctl(epoll_fd, EPOLL_CTL_DEL, fd, NULL);
    close(fd);
    printf("→ Event del fd %d.\n", fd);
}

void event_create() {
    epoll_fd = epoll_create1(EPOLL_CLOEXEC);
    printf("→ Event create.\n");
}

void event_wait(int *nums) {
    printf("\n→ Event waiting ...\n");
    *nums = epoll_wait(epoll_fd, event_notifies, MAXEVENTS, -1);
}

void event_receive(int fd) {
    printf("→ Event receiving fd %d ...\n", fd);
    char    buffer[BUFSIZE];
    ssize_t bytes;
    ssize_t bytes_all = 0;
    int     i = 0;
    for (;;) {
        bytes = read(fd, buffer, BUFSIZE);
        if (bytes == 0) {
            printf("→ Event receive fd %d finish.\n", fd);
            event_del(fd);
            return;
        }
        if (bytes == EOF) {
            if (errno == EAGAIN) {
                break;
            }
            printf("\n→ Event receive fd %d error...\n", fd);
            exit(1);
        }
        bytes_all += bytes;
        printf("→ Event receive fd %d ", fd);
        for (; i < bytes_all; i++) {
            if (buffer[i] == '\n') {
                putchar('\\');
                putchar('n');
            } else if (buffer[i] == '\r') {
                putchar('\\');
                putchar('r');
            } else {
                putchar(buffer[i]);
            }
        }
        printf(".\n");
    }
    printf("→ Event receive fd %d %zdbytes.\n", fd, bytes_all);
}

void event_send(int fd) {
    printf("→ Event writing fd %d ...\n", fd);
    char    buffer[BUFSIZE];
    ssize_t bytes;
    bytes = write(fd, SENDDATA, strlen(SENDDATA));
}

int main(int argc, char **argv) {
    uint32_t notify_type;
    int      notify_fd;
    int      nums;          // 事件数量
    int      n;             // 事件编号

    event_listen();
    event_create();
    event_add(server_fd, EPOLLIN | EPOLLET);
    for (;;) {
        event_wait(&nums);
        for (n = 0; n < nums; n++) {
            notify_fd   = event_notifies[n].data.fd;
            notify_type = event_notifies[n].events;
            if (notify_fd == server_fd) {
                event_accept(notify_fd);
                event_add(client_fd, EPOLLIN |EPOLLET);
            } else if (notify_type & EPOLLIN) {
                event_receive(notify_fd);
                event_mod(notify_fd, EPOLLOUT |EPOLLET);
            } else if (notify_type & EPOLLOUT) {
                event_send(notify_fd);
                event_mod(notify_fd, EPOLLIN |EPOLLET);
            } else if (notify_type & EPOLLHUP) {
                event_del(notify_fd);
            } else if (notify_type & EPOLLERR) {
                event_del(notify_fd);
            } else {
                event_del(notify_fd);
            }
        }
    }
}
```

How to epoll (IO 多路复用的构建)
---------------------------

1. 为内核注册描述符，交给内核托管 → 睡眠 → 等待内核发出通知

       epoll_create1();
       epoll_ctl();

       for (;;) {
           epoll_wait();
           for (i < nums) {
               switch(fd) {
                   dothing();
                   epoll_ctl();
               }
           }
       }
       
2. 边缘触发ET

   每当描述符的事件状态切换的时候，才发出通知（提高IO通知效率）
   
       event.events = X | EPOLLET;
   
3. 非阻塞IO

   通过读写非阻塞，防止描述符占用额外的等待时间
   
       fcntl(fd, F_GETFL, O_NONBLOCK);
   
4. 哈希表记录变动描述符，防止描述符饥饿

   `饥饿：如果某个fd持续有数据可读，在返回EAGAIN之前一直在该fd上调用read就会使其他描述符等待过长时间。`

   理论上，当1000个客户端同时发送10000个字符，而内核每次的“瞬间”读取量只有1000，那么可以采用哈希表记录请求描述符。
   
   1) 当内核发出通知以后，记录新的描述符。<br />
   2) 迭代记录描述符，对描述符依次进行操作，比如读取1000个字符。<br />
   3) 完成之后，对描述符状态检查（删除或者切换状态）<br />
   4) 交给操作系统控制权，进入新的监听
