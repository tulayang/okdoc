```
#include <sys/types.h>
#include <sys/socket.h>  
#include <pthread.h>
#include <netinet/in.h> 
#include <stdlib.h>

int main(int argc, char **argv) {

// 初始化服务器参数

    struct sockaddr_in serverAddr;                          // 服务器地址 (结构体)
    serverAddr.sin_family = AF_INET;                        // 设置域类型 (IPv4 IPv6 Unix) 
    serverAddr.sin_port   = htons(10001);                   // 设置端口号，主机字节序 → 网络字节序 (高低位存储方式不一样)
    inet_aton("127.0.0.1", &(serverAddr.sin_addr));         // 字符串 → 网络字节序 

// 连接服务器

    int  clientFD;
    char buffer[4] = "010";    
    connect(clientFD, 
            (struct sockaddr*)&serverAddr, 
            sizeof(struct sockaddr));                       // 连接服务器
    write(clientFD, buffer, 4);                             // 写入字符

// 退出进程

    exit(0);
}
```