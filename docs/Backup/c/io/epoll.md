```
#include <sys/epoll.h>
```

create → ctl → wait ↻ → close
----------------------------

```
int epoll_create (int size)               ⇒ -1(errno) | epoll 描述符  // 创建一个 epoll 对象
int epoll_create1(int flags)              ⇒ -1(errno) | epoll 描述符  // 创建一个 epoll 对象
       
    • flags: EPOLL_CLOEXEC

int epoll_ctl(int efd, 
              int op, 
              int fd, 
              struct epoll_event *event)  ⇒ -1(errno) | 0            // 配置事件属性
      
    • efd                           // epoll 描述符
    • op:                           // 动作
      ∘ EPOLL_CTL_ADD               // 把 fd 注册到 epoll，并链接相应的事件 event
      ∘ EPOLL_CTL_MOD               // 修改 fd 监听的事件 event
      ∘ EPOLL_CTL_DEL               // 从 epoll 中删除 fd，event 被忽略，可以是 NULL
    • fd                            // 要监听的文件描述符
    • event                         // 事件配置
      struct epoll_event {
          uint32_t     events;      // 事件类型
          epoll_data_t data;        // 用户数据变量
      } 
      ∘ events:
        ∘ EPOLLIN                   // 关联的 fd 可以读（包括对端SOCKET正常关闭）
        ∘ EPOLLOUT                  // 关联的 fd 可以写
        ∘ EPOLLPRI                  // 关联的 fd 有紧急的数据可读（这里应该表示有带外数据到来）
        ∘ EPOLLERR                  // 关联的 fd 发生错误
        ∘ EPOLLHUP                  // 关联的 fd 被挂断
        ∘ EPOLLET                   // 设置为边缘触发模式(Edge Triggered)
        ∘ EPOLLONESHOT              // 只监听一次事件
      ∘ typedef union epoll_data {
            void     *ptr;
            int       fd;
            uint32_t  u32;
            uint64_t  u64;
        } epoll_data_t;

int epoll_wait(int efd, 
               struct epoll_event *events, 
               int maxevents, 
               int timeout)               ⇒ 0（超时） | 需要处理的事件数  // 监听，等待事件(内核发送通知)
   
    • efd                          // epoll 描述符
    • events                       // 从内核得到的事件集合
    • maxevents                    // 事件集合最大值，不高于 epoll_create() 的 size
    • timeout                      // 超时时间（ms，0会立即返回，-1将不确定，也有说法是永久阻塞）

int epoll_pwait(int efd, 
                struct epoll_event *events, 
                int maxevents, 
                int timeout, 
                const sigset_t *sigmask);

（注：当对一个非阻塞流的读写发生缓冲区满或缓冲区空，write/read会返回-1，并设置errno=EAGAIN。
     而 epoll 只关心缓冲区非满和缓冲区非空的事件。）

int close(int fd)                         ⇒ -1(errno) | 0
```