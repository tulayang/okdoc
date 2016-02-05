```
#include <sys/types.h>
#include <sys/socket.h>  
#include <pthread.h>
#include <netinet/in.h> 
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>

void *callback(void *arg) {
    int     clientFD = *(int *)(arg);
    char    buffer[128];
    ssize_t size;
    while ((size = read(clientFD, buffer, 128)) > 0) {
        printf("Read %zd\n", size);
    };
    printf("Hello, %d!\n", clientFD);
    printf("Read %s %zd\n", buffer, strlen(buffer));
}

int main(int argc, char **argv) {

// 初始化服务器参数

    /******************
     * struct in_addr {
     *     uint32_t s_addr;                             // 网络地址，32位
     * }
     *
     * struct sockaddr_in {
     *     sa_family_t     sin_family;                  // 域类型，32位
     *     int_port_t      sin_port;                    // 端口号，16位   (网络字节序) 
     *     struct in_addr  sin_addr;                    // 网络地址       (网络字节序)
     * }
     *
     * struct sockaddr {
     *     sa_family_t     sa_family;                   // 域类型，32位       
     *     char            sa_data[14];                 // 网络参数   
     * }
     *
     *********************************************************************/ 

    struct sockaddr_in  serverAddr;                         // 服务器地址 (结构体)
    serverAddr.sin_family = AF_INET;                        // 设置域类型 (IPv4 IPv6 Unix) 
    serverAddr.sin_port   = htons(10001);                   // 设置端口号，主机字节序 → 网络字节序 (高低位存储方式不一样)
    inet_aton("127.0.0.1", &(serverAddr.sin_addr));         // 字符串 → 网络字节序 
    
    int serverFD;
    serverFD = socket(AF_INET, SOCK_STREAM, 0);             // 初始化套接字 (流)
    bind(serverFD, 
         (struct sockaddr *)&serverAddr, 
         sizeof(serverAddr));                               // 绑定网络地址
    listen(serverFD, 100);                                  // 设置排队长度

// 循环 accept socket

    struct sockaddr_in  clientAddr;                         // 客户端地址 (结构体)
    socklen_t           clientAddrLen;                      // 客户端地址尺寸
    int                 clientFD;                           // 客户端标识符 
    pthread_t           threadID;                           // 线程标识符

    for (;;) {
        clientFD = accept(serverFD,                     
                          (struct sockaddr *)&clientAddr, 
                          &clientAddrLen);                  // 等待套接字请求 (挂起)
        pthread_create(&threadID, 
                       NULL, 
                       &callback, 
                       &clientFD);                          // 创建线程，回调
    }

// 退出进程

    exit(0);
}
```