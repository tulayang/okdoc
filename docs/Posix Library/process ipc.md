
## 进程通信支持



## 管道

### pipe()

```
#include <unistd.h>
int pipe(int fd[2]);    // 成功返回 0，出错返回 -1
```

<span>


```
#include <stdio.h>
#include <stdlib.h>

#define BUFFSIZE 6

void doChild(int fds[2]); 
void doParent(int fds[2]);

void main(void) {
    int fds[2];
    pipe(fds);

    pid_t pid = fork();
    
    switch (pid) {
    case -1:
        perror("Counld not fork");
        exit(1);
    case 0:
        doChild(fds);
        exit(0);
    default:
        doParent(fds);
    }

    int status;
    pid = wait(&status);
    printf("*** Parent detects process %d is done ***\n", pid);
    printf("*** Parent exits ***\n");
    exit(0);
}

void doChild(int fds[2]) {
    close(fds[1]);
    char buff[BUFFSIZE];
    read(fds[0], buff, sizeof(buff));
    printf("Recv %s.\n", buff);
    printf("*** Child process is done ***\n");
}

void doParent(int fds[2]) {
    close(fds[0]);
    char buff[BUFFSIZE] = "Hello";
    write(fds[1], buff, sizeof(buff));
    printf("*** Parent is done ***\n");
}
```

![PIPE](http://thinkim.cn/wordpress/wp-content/uploads/2014/12/pipe_fork.png)

## 命名管道

### mkfifo() mkfifoat()

```
#include <sys/stat.h>
int mkfifo(const char *pathname, mode_t mode);
int mkfifoat(int fd, const char *pathname, mode_t mode);
```

<span>

```
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/stat.h>

#define BUFFSIZE 6

void doChild(void); 
void doParent(void);

void main(void) {
    pid_t pid = fork();
    
    switch (pid) {
    case -1:
        perror("Counld not fork");
        exit(1);
    case 0:
        doChild();
        exit(0);
    default:
        doParent();
    }

    int status;
    pid = wait(&status);
    printf("*** Parent detects process %d is done ***\n", pid);
    printf("*** Parent exits ***\n");
    exit(0);
}

void doChild(void) {
    mkfifo("./fifo_file", S_IFIFO | 0666);

    char buff[BUFFSIZE];
    int fd = open("./fifo_file", O_RDONLY);
    read(fd, buff, sizeof(buff));
    printf("Recv %s.\n", buff);

    printf("*** Child process is done ***\n");
}

void doParent(void) {
    mkfifo("./fifo_file", S_IFIFO | 0666);

    char buff[BUFFSIZE] = "Hello";
    int fd = open("./fifo_file", O_WRONLY);
    write(fd, buff, sizeof(buff));
    printf("Write %s.\n", buff);

    printf("*** Parent is done ***\n");
}
```

![FIFO](http://pic002.cnblogs.com/images/2012/413416/2012101010564376.jpg)

## 域套接字


### socketpair()

```
#include <sys/socket.h>
int socketpair(int domain, int type, int protocol, int fds[2]);  // 成功返回 0，出错返回 -1
```

<span>

```
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <netinet/in.h>

#define BUFFSIZE 6

void doChild(int pipefds[2]); 
void doParent(int pipefds[2]);

void main(void) {
    int pipefds[2];
    socketpair(AF_UNIX, SOCK_STREAM, 0, pipefds);

    pid_t pid = fork();
    
    switch (pid) {
    case -1:
        perror("Counld not fork");
        exit(1);
    case 0:
        doChild(pipefds);
        exit(0);
    default:
        doParent(pipefds);
    }

    int status;
    pid = wait(&status);
    printf("*** Parent detects process %d is done ***\n", pid);
    printf("*** Parent exits ***\n");
    exit(0);
}

void doChild(int pipefds[2]) {
    close(pipefds[1]);

    char buff[BUFFSIZE];
    read(pipefds[0], buff, sizeof(buff));
    printf("Child recv %s.\n", buff);

    char buff2[BUFFSIZE] = "OK";
    write(pipefds[0], buff2, sizeof(buff2));
    printf("Child send %s.\n", buff2);

    printf("*** Child process is done ***\n");
}

void doParent(int pipefds[2]) {
    close(pipefds[0]);

    char buff[BUFFSIZE] = "Hello";
    write(pipefds[1], buff, sizeof(buff));
    printf("Parent send %s.\n", buff); 

    char buff2[BUFFSIZE];
    read(pipefds[1], buff2, sizeof(buff2));
    printf("Parent recv %s.\n", buff2);

    printf("*** Parent is done ***\n");
}
```

## 内存映射

### mmap() unmmap

```
#include <sys/mman.h>
void *mmap(void *addr, size_t length, int port, int flags, int fd, off_t offset);
      // 成功返回映射区地址，失败返回 MAP_FAILED
```

<span>

```
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <pthread.h>

#define BUFFSIZE 6

void doChild(void); 
void doParent(void);

struct Data {
    pthread_mutex_t mutex;
    int state;
};

static struct Data *data;

void main(void) {
    int fd;
    pthread_mutexattr_t mattr;

    fd = open("/dev/zero", O_RDWR, 0);
    data = (struct Data *)mmap(0, sizeof(struct Data), 
            PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    close(fd);

    pthread_mutexattr_init(&mattr);
    pthread_mutexattr_setpshared(&mattr, PTHREAD_PROCESS_SHARED);
    pthread_mutex_init(&data->mutex, NULL);
    data->state = 0;

    pid_t pid = fork();
    
    switch (pid) {
    case -1:
        perror("Counld not fork");
        exit(1);
    case 0:
        doChild();
        exit(0);
    default:
        doParent();
    }

    int status;
    pid = wait(&status);
    printf("Parent state %d\n", data->state);
    printf("*** Parent detects process %d is done ***\n", pid);
    printf("*** Parent exits ***\n");
    exit(0);
}

void doChild(void) {
    pthread_mutex_lock(&data->mutex);
    data->state = 1;
    pthread_mutex_unlock(&data->mutex);
    printf("*** Child process is done ***\n");
}

void doParent(void) {
    printf("*** Parent is done ***\n");
}

// 在这个程序中，我们首先定义了一个全局共享数据 `data`，在后面的代码中使用 `mmap()` 对其申请内存，并映射
// 内存页．`open()` 打开了一个 `/dev/zero` 的设备，当从这个设备读取数据时，获得的是字符 `\0`，可以用来
// 初始化一个文件（也可以向这个字符设备写入，字符设备会丢弃数据，什么也不做）．然后我们设置共享数据
// 的 `state` 为 0，初始化线程锁，通过 `pthread_mutexattr_setpshared` 系统调用设置锁的共享属性是
// 进程共享 `PTHREAD_PROCESS_SHARED`．然后调用 `fork()` 创建子进程，在子进程中修改共享数据 `data` 
// 的 `state` 字段为 1．最后在父进程中 `wait` 等待并应答子进程，打印最后的共享数据 `data` 的 `state` 
// 值．你会发现，`state` 已经变为 1，这表示父进程和子进程确实共享了 `data`．
```
