
## 分散和聚集

### readv() writev()

```
#include <sys/uio.h>

struct iovec {  
    void   *iov_base;  // 缓冲区
    size_t  iov_len;   // 缓冲区大小
};

ssize_t readv (int fd, const struct iovec *iov, int count);
        // 成功返回读的字节数，出错返回 -1 。

ssize_t writev(int fd, const struct iovec *iov, int count);
        // 成功返回写的字节数，出错返回 -1 。

// 操作成功时，返回的字节数应该等于所有 count 个 iov_len 的和。
//
// POSIX 规定 count 必须大于 0，小于 IOV_MAX （定义在<limits.h>，在 Linux 中值是 1024）。
//
// 1.如果 count == 0，返回 0 。
// 2.如果 count >  IOV_MAX，不会处理任何数据，返回 -1，并把 errno 置为 EINVAL 。
// 3.如果所有 count 个 iov_len 的和 > SSIZE_MAX，则不会处理任何数据，返回 -1，并把 errno 置为 EINVAL 。
```

<span>

```
char foo[32], bar[64], baz[32];
struct iovec iov[3];

iov[0].iov_base = foo;
iov[0].iov_len  = sizeof(foo);
iov[1].iov_base = bar;
iov[1].iov_len  = sizeof(bar);
iov[2].iov_base = baz;
iov[2].iov_len  = sizeof(baz);

ssize_t nr = readv(fd, iov, 3);
if (nr == -1)
    errExit("readv()");
for (i = 0; i < 3; i++)
    printf("%s", (char *)iov[i].iov_base);
```

<span>

```
char *buf[] = {
    "Test 1\n",
    "Test 2\n",
    "Test 3\n"
};
struct iovec iov[3];

for (i = 0; i < 3; i++) {
    iov[0].iov_base = buf[i];
    iov[0].iov_len  = sizeof(buf[i]) + 1;
}

ssize_t nr = writev(fd, iov, 3);
if (nr == -1)
    errExit("writev()");
```

## 多路复用

### select()<br />FD_ZERO() FD_SET() FD_CLR() FD_ISSET()

```
#include  <sys/time.h>

struct timeval {
    long tv_sec;   // 秒 
    long tv_usec;  // 微妙
};

#include  <sys/select.h>

typedef struct {
/* XPG4.2 requires this member name.  Otherwise avoid the name
   from the global namespace.  */
#ifdef __USE_XOPEN
    __fd_mask fds_bits[__FD_SETSIZE / __NFDBITS];
# define __FDS_BITS(set) ((set)->fds_bits)
#else
    __fd_mask __fds_bits[__FD_SETSIZE / __NFDBITS];
# define __FDS_BITS(set) ((set)->__fds_bits)
#endif
} fd_set;

int select(int n, 
           fd_set *restrict readfds, fd_set *restrict writefds, fd_set *restrict exceptfds, 
           struct timeval *restrict timeout);
    // 在给定的文件描述符 IO 就绪前一直阻塞，如果到达超时时间仍未就绪则返回 0 并置空描述符集。
    // 成功返回已经准备好的描述符数，出错返回 -1，并设置 errno 。
    // 如果返回 errno = EINTR，表示捕获了一个信号，可以重新发起调用。
    //
    // n        - 等于所有集合中文件描述符的最大值加 1 。也可以置为 FD_SETSIZE 指定
    //            最大描述符数值，不过对大多数应用而言太大了
    //
    // 监视的文件描述符分为 3 类，分别等待不同的事件。
    // 
    // readfds   - 监视是否有数据可读，即某个读操作是否可以无阻塞完成
    // writefds  - 监视是否有某个写操作是否可以无阻塞完成
    // exceptfds - 监视是否发生异常，或者出现带外数据（只适用于 socket）
    //
    // 指定的集合可能是 NULL，在这种情况下，select() 不会监视该事件。
    // 成功返回时，每个集合都修改成只包含相应类型的 IO 就绪的文件描述符。
    //
    // timeout   - 超时时间，每次调用 select() 都必须重新初始化！！！
    //             timeout == NULL，不超时。
    //             timeout.tv_sec == 0 && timeout.tv_usec == 0，调用立刻返回。
    //             timeout.tv_sec != 0 || timeout.tv_usec != 0，设置超时时间。 

#define FD_SET  (fd, fdsetp)  __FD_SET   (fd, fdsetp)  // 向指定集合中添加一个文件描述符
#define FD_CLR  (fd, fdsetp)  __FD_CLR   (fd, fdsetp)  // 从指定集合中删除一个文件描述符
#define FD_ISSET(fd, fdsetp)  __FD_ISSET (fd, fdsetp)  // 检查一个文件描述符是否在给定集合中，
                                                       #/ 如果是返回非 0，否则返回 0
#define FD_ZERO (fdsetp)      __FD_ZERO  (fdsetp)      // 从指定集合中删除所有文件描述符
                                                       #/ 每次调用 select() 都应该先调用该宏
```

<span>

```
#define TIMTOUT 5
#define BUFLEN  1024

void main (void) {
    fd_set readfds;
    FD_ZERO(readfds);
    FD_SET(STDIN_FILENO, &readfds);

    struct timeval tv = {.tv_sec=TIMTOUT, .tv_usec=0};

    int ret = select(STDIN_FILENO + 1, &readfds, NULL, NULL, &tv); 
    if (ret == -1)
        errExit("select");
    if (ret != 0)
        errExit("select timeout");

    if (FD_ISSET(STDIN_FILENO, &readfds) != 0) {
        char buf[BUFLEN];
        ssize_t = read(STDIN_FILENO, buf, BUFLEN);
        // ...
    }
}
```

### poll()

```
#include <poll.h>

struct pollfd {
    int   fd;       // 要监听的文件描述符
    short events;   // 请求监听的事件（位掩码）
    short revents;  // 返回时的结果事件（位掩码），内核在返回时会设置该值，
                    // events 请求的所有事件都可能在该变量中返回
}
    // 合法的 events 值：
    // 
    //   * POLLIN      -  有数据可读
    //   * POLLRDNORM  -  有普通数据可读
    //   * POLLRDBAND  -  有优先数据可读
    //   * POLLPRI     -  有高优先数据可读   
    //   * POLLOUT     -  写操作不会阻塞
    //   * POLLWRNORM  -  写普通数据不会阻塞
    //   * POLLWRBAND  -  写优先数据不会阻塞
    //   * POLLMSG     -  有 SIGPOLL 消息可用
    //
    // 此外，revents 可能会返回如下事件：
    //
    //   * POLLER      -  给定的文件描述符出现错误
    //   * POLLHUP     -  给定的文件描述符有挂起事件
    //   * POLLNVAL    -  给定的文件描述符非法
    //
    // POLLIN | POLLPRI     等价于 select() 的读事件，
    // POLLOUT | POLLWRBAND 等价于 select() 的写事件，
    // POLLIN               等价于 POLLRDNORM | POLLRDBAND，
    // POLLOUT              等价于 POLLWRNORM

int poll(struct pollfd *fds, nfds_t nfds, int timeout);
    // 成功返回已经准备好的描述符数，超时返回 0，出错返回 -1，并设置 errno 。
    // 如果返回 errno = EINTR，表示捕获了一个信号，可以重新发起调用。
    //
    // fds     - 文件描述符集合
    // nfds    - 集合数量
    // timeout - 超时时间，单位毫秒
```

<span>

```
struct pollfd fds[2];
fds[0].fd = STDIN_FILENO;
fds[0].events = POLLIN;
fds[1].fd = STDOUT_FILENO;
fds[1].events = POLLOUT;

int ret = poll(fds, 2, 5 * 1000);
if (ret == -1) 
    errExit("poll");
if (ret != 0) 
    errExit("poll timeout");

if (fds[0].revents & POLLIN)
    printf("stdin is readable");
if (fds[1].revents & POLLOUT)
    printf("stdout is writeable");
```

### epoll_create() epoll_create1()<br />epoll_ctl() epoll_wait()

```
#include <sys/epoll.h>

int epoll_create (int size);   // 已废弃，使用 epoll_create1() 。size 只需要 >0 。 
int epoll_create1(int flags);  
    // 成功时创建新的 epoll 实例，并返回和该实例关联的文件描述符，出错返回 -1 。
    //
    // flags - 行为标识。当前只有 EPOLL_CLOEXEC 是合法标识，表示进程被替换时关闭文件描述符

struct epoll_event {
    __u32 events;   
    union {
        void *ptr;
        int   fd;
        __u32 u32;
        __u64 u64;
    } data;
};
    //
    // events - 请求监听的事件【位掩码】，合法的 events 值：
    // 
    //   * EPOLLIN       -  文件未阻塞，可读 
    //   * EPOLLOUT      -  文件未阻塞，可写
    //   * EPOLLPRI      -  存在高优先级的带外数据可读
    //   * EPOLLERR      -  文件出错。即使没有设置，这个事件也是被监听的
    //   * EPOLLHUP      -  文件被挂起。即使没有设置，这个事件也是被监听的  
    //   * EPOLLET       -  在监听文件上开启边缘触发，默认是水平触发
    //   * EPOLLONESHOT  -  在事件生成并处理后，文件不会再被监听。必须通过 EPOLL_CTL_MOD 指定
    //                      新的事件掩码，以便重新监听文件
    //
    // data - 用户私有数据。当接收到请求的事件后，data 会被返回给用户。通常的用法是
    //        把 event.data.fd 设置成 fd，这样可以很容易查看哪个文件描述符触发了事件
    //
int epoll_ctl(int epollfd, int option, int fd, struct epoll_event *event);
    // 在 epoll 实例中添加、删除文件描述符及其事件，成功返回 0，出错返回 -1
    //
    // option - 操作类型
    //
    //   * EPOLL_CTL_ADD  -  把文件描述符 fd 指向的文件添加到 epollfd 的监听集合
    //   * EPOLL_CTL_DEL  -  把文件描述符 fd 指向的文件从 epollfd 的监听集合删除
    //   * EPOLL_CTL_MOD  -  修改 epollfd 监听集合中的 fd 监听事件
    //
    // event - 请求监听的事件结构体

int epoll_wait(int epollfd, struct epoll_event *events, int maxevents, int timeout);
    // 等待 epoll 实例上的事件，如果到达指定时间仍没有事件返回 0。成功时，events 指向
    // 描述每个事件的 epoll_event 结构体的内存，且最多可以有 maxevents 个事件，返回
    // 值是事件数；出错时返回 -1 。
    //
    // 如果返回 errno = EINTR，表示捕获了一个信号，可以重新发起调用。
    //
    // events    - 用于内核修改的事件集合
    // maxevents - 指定返回的最大事件数
    // timeout   - 超时时间，单位毫秒。置为 -1 则不设置超时
```   

<span>

```
#define MAXEVENTS 64

int epollfd = epoll_create1(0);
if (epollfd == -1)
    errExit("epoll_create1");

struct epoll_event event;
event.events = EPOLL | EPOLLOUT;
event.data.fd = STDIN_FILENO;

if (epoll_ctl(epollfd, EPOLL_CTL_ADD, STDIN_FILENO, &event) == -1)
    errExit("epoll_ctl");

struct epoll_event *events = malloc(sizeof(struct epoll_event) * MAXEVENTS);
if (events == NULL)
    errExit("malloc");

int nr = epoll_wait(epollfd, events, MAXEVENTS, -1);
if (nr < 0)
    errExit("epoll_wait");

for (i = 0; i < nr; i++)
    if (events[i].events & POLLIN)
        // readable
    else if (events[i].events & POLLOUT)
        // writeable
    else if (events[i].events & EPOLLERR || events[i].events & EPOLLHUP)
        // error
```

## 存储映射

### mmap() munmap()

```
#include <sys/mman.h>

void *mmap(void *addr, size_t len, int prot, int flags, int fd, off_t offset);
      // 成功返回映射区域的地址，出错返回 MAP_FAILED，并设置 errno 。
      //
      // addr - 指定映射存储区的最佳地址，但仅仅是作为提示信息，而不是强制性的。大部分用户对该参数
      //        传递 0，这表示由内核选择该映射区的起始地址，函数会返回内存映射区域的真实开始地址
      //
      // len  - 映射的字节数
      // 
      // prot - 描述了对内存区域的访问权限，不能和打开文件的访问模式冲突。比如，如果程序以只读
      //        方式打开文件，prot 参数就不能设置为 PROT_WRITE 。可以是以下标志位的 | 运算值：
      //  
      //   * PROT_READ   -  映射区可读
      //   * PROT_WRITE  -  映射区可读
      //   * PROT_EXEC   -  映射区可读 
      //   * PROT_NONE   -  映射区不可访问（基本不用）
      //
      // flags - 描述了映射的类型及其一些行为。可以是以下标志位的 | 运算值。
      //         MAP_PRIVATE 和 MAP_SHARED 必须指定其中一个，但不能同时指定！！！
      //
      //   * MAP_FIXED      -  表示强制接收参数 addr，而不是作为提示信息。如果内核无法映射文件
      //                       到指定地址，调用失败。如果地址和长度指定的内存和已有映射有重叠区
      //                       域，重叠区的原有内容被丢弃，通过新的内容填充。该选项需要深入了解
      //                       进程的地址空间，不可移植，因此不鼓励使用！！！
      //   * MAP_PRIVATE    -  表示映射区不共享。文件映射采用写时复制，进程对该内存的任何改变不
      //                       影响真正的文件或者其他进程的映射。
      //   * MAP_SHARED     -  表示和所有其他映射该文件的进程共享映射内存。对内存的写操作等效于
      //                       写文件。读该映射区域会受到其他进程的写操作的影响。
      //   * MAP_ANONYMOUS  -  创建一个匿名映射，忽略 fd 和 offset，Linux 特有。
      //
      // fd - 映射文件的描述符，文件映射到虚拟地址空间前，必须先打开该文件。当映射文件描述符时，文
      //      件的引用计数会加 1 。因此，如果映射文件后关闭文件，进程依然可以访问该文件。当你取消
      //      映射或者进程终止时，对应的文件引用计数会减 1 。 
      //
      // offset - 映射字节在文件中的起始偏移量

int munmap(void *addr, size_t len);
    // 取消进程地址空间从 addr 开始，len 字节长度的内存中的所有页映射。一旦映射被取消，之前关联的
    // 内存区域就不再有效。调用 munmap() 并不会使映射区的内容写到磁盘文件上。 
    // 成功返回 0，出错返回 -1，并设置 errno 。

int mprotect(const void *addr, size_t len, int prot);
    // 改变[addr, addr + len) 区域内页的访问权限。成功返回 0，出错返回 -1，并设置 errno 。

int msync(void *addr, size_t len, int flags);
    // 将映射内存中的任何修改写回到磁盘中，从而实现同步内存中的映射和被映射的文件。
    // 成功返回 0，出错返回 -1，并设置 errno 。
    //
    // flags - 行为标志位，MS_SYNC 和 MS_ASYNC 必须指定其一，但是不能共用：
    //
    //   * MS_SYNC        -  同步执行。直到所有页写回到磁盘后，才会返回 
    //   * MS_ASYNC       -  异步执行。更新操作由系统调度，立刻返回
    //   * MS_INVALIDATE  -  指定所有其他的该块映射的拷贝都将失效。后期对该文件的所有映射
    //                       区域上的访问操作都将直接同步到磁盘
```

## 记录锁


### struct flock

锁状态|请求读锁|请求写锁
----|---|---
无锁|允许|允许
有一把或多把读锁|允许|拒绝
有一把写锁|拒绝|拒绝

> 以上规则仅适用不同进程提出的锁请求，不适用于单个进程提出的多个锁请求。比如，一个进程对一个文件区间已经有了一把锁，后来又企图在同一文件区间再加一把锁，那么新锁将替换已有锁。因此，若一进程在 16~32 字节区间有一把写锁，然后又试图在 16~32 字节区间加一把读锁，那么该请求将成功执行，原来的写锁会被替换为读锁。

<span>

```
#include <fcntl.h>

struct flock {
    short l_type;    // 锁类型
                     //   * F_RDLCK  -  共享读锁，多个进程在一个给定的字节上可以有一把共享的读锁
                     //   * F_WRLCK  -  独占性写锁，在一个给定的字节上只能有一个进程有一把写锁
                     //   * F_UNLCK  -  解锁一个区域
    short l_whence;  // 锁区域的偏移标志位： 
                     //   * SEEK_SET  -  起始位置
                     //   * SEEK_CUR  -  当前位置
                     //   * SEEK_END  -  文件尾端
    off_t l_start;   // 锁区域的偏移置
    off_t l_len;     // 锁区域的长度，0 表示直到文件尾端
    pid_t l_pid;     // 持有锁的进程号码
};

int fcntl(int fd, int cmd, .../*struct flock *flockptr*/);
    // 加读锁时，文件描述符必须是读打开。加写锁时，文件描述符必须是写打开。
    //
    // cmd -
    //
    //   * F_GETLK   -  判断 flockptr 指定的锁是否会被另外一把所排斥（阻塞）。
    //   * F_SETLK   -  设置锁。如果试图获得一把读锁或者写锁，如果请求的读写锁因为另一个进程已经占用
    //                  而不能被授予时，立刻出错返回，并把 errno 置为 EACCES 或者 EAGAIN 。
    //   * F_SETLKW  -  设置锁。F_SETLK 的阻塞版本，如果请求的读写锁因为另一个进程已经占用而不能被
    //                  授予，那么调用进程会进入休眠，直到请求的锁已经可用，或者被信号中断。
```

<span>

```
int lockReg(int fd, int cmd, int type, off_t offset,  int whence, off_t len) {
    struct flock lock;
    lock.l_type   = type;
    lock.l_whence = whence;
    lock.l_start  = offset;
    lock.l_len    = len;
    return fcntl(fd, cmd, &lock);
}

#define readLock(fd, offset, whence, len) \
        lockReg((fd), F_SETLK, F_RDLCK, (offset), (whence), (len))
#define readwLock(fd, offset, whence, len) \
        lockReg((fd), F_SETLKW, F_RDLCK, (offset), (whence), (len))
#define writeLock(fd, offset, whence, len) \
        lockReg((fd), F_SETLK, F_WRLCK, (offset), (whence), (len))
#define writewLock(fd, offset, whence, len) \
        lockReg((fd), F_SETLK, F_WRLCK, (offset), (whence), (len))
#define unlock(fd, offset, whence, len) \
        lockReg((fd), F_SETLK, F_UNLCK, (offset), (whence), (len))
```

<span>

```
pid_t lockTest(int fd, int type, off_t offset,  int whence, off_t len) {
    struct flock lock;
    lock.l_type   = type;
    lock.l_whence = whence;
    lock.l_start  = offset;
    lock.l_len    = len;
    if (fcntl(fd, F_GETLK, &lock) == -1)
        errExit("fcntl");
    if (lock.l_type == F_UNLCK)
        return 0;
    return lock.l_pid;
}

#define isReadLockable(fd, offset, whence, len) \
        (lockTest((fd), F_RDLCK, (offset), (whence), (len)) == 0)
#define isWriteLockable(fd, offset, whence, len) \
        (lockTest((fd), F_WRLCK, (offset), (whence), (len)) == 0)
```

