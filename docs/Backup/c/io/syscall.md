```
#include <fcntl.h>
#include <unistd.h>
```

Define
-------

```
#define F_OK          0
#define R_OK          4
#define W_OK          2
#define X_OK          1

#define SEEK_SET      0
#define SEEK_CUR      1
#define SEEK_END      2

#define STDIN_FILENO  0 
#define STDOUT_FILENO 1
#define STDERR_FILENO 2

#define MAXPATHLEN    1024
```

open → fcntl→ lseek → read ↻ → write ↻  → close
-----------------------------------------

```
int open(const char *filename, int flags, [mode_t mode])  ⇒  -1(errno) | fd  // 打开文件，生成描述符
    
    • flags
      ∘ O_RDONLY       // 只读
      ∘ O_WRONLY       // 只写 
      ∘ O_RDWR         // 读写
      ∘ 扩展 ... 
        ∘ O_CREAT      // 文件不存在时创建
        ∘ O_EXCL       // 如果要创建的文件已存在，则返回 -1，并且修改 errno 的值
        ∘ O_NOCTTY     // 如果路径名指向终端设备，不要把这个设备用作控制终端
        ∘ O_TRUNC      // 当以可写方式打开时，文件清0
        ∘ O_APPEND     // 每次写操作都写入文件的末尾
        ∘ O_NONBLOCK   // 以非阻塞方式打开文件，如果没有数据可供读写, 立即返回进程
        ∘ O_DSYNC      // 同步磁盘，不等待文件属性同步
        ∘ O_SYNC       // 同步磁盘，包括文件属性同步
        ∘ O_RSYNC      // 同步磁盘，等待同一区域的写操作
        ∘ O_NOFOLLOW   // 禁止符号链接
        ∘ O_DIRECTORY  // 禁止目录

int create(const char *filename, mode_t mode)  ⇒  -1(errno) | fd      // 创建文件，生成描述符
int close(int fd)                              ⇒  -1(errno) | 0       // 关闭文件描述符
int fcntl(int fd, int cmd, /*...*/)            ⇒  -1(errno) | 依赖cmd  // 改变打开文件的属性
    
    • cmd
      ∘ F_DUPFD        // 查找 >= 参数arg的最小且仍未使用的文件描述符
      ∘ F_GETFD        // 获取 close-on-exec 的flags
      ∘ F_SETFD        // 设置 close-on-exec 的flags
      ∘ F_GETFL        // 获取文件描述符的flags
      ∘ F_SETFL        // 设置文件描述符的flags，只能是O_APPEND，O_NONBLOCK，O_ASYNC
      ∘ F_GETLK        // 获取文件描述符的锁定状态
      ∘ F_SETLK        // 设置文件描述符的锁定状态，无法建立锁定时，不等待锁定完成
      ∘ F_SETLKW       // 设置文件描述符的锁定状态，无法建立锁定时，等待锁定完成

ssize_t read(int fd, void *buffer, size_t length)                        ⇒  -1(errno) | 0(尾部) | 实际读取的字节数
ssize_t pread(int fd, void *buffer, size_t length, off_t offset)         ⇒  -1(errno) | 0(尾部) | 实际读取的字节数

ssize_t write(int fd, const void *buffer, size_t length)                 ⇒  -1(errno) | 实际写入的字节数
ssize_t pwrite(int fd, const void *buffer, size_t length, off_t offset)  ⇒  -1(errno) | 实际写入的字节数

off_t   lseek(int fd, off_t offset, int origin)                          ⇒  -1(errno) | 新的偏移量  // 设置游标

        • origin
          ∘ SEEK_CUR       // 当前位置
          ∘ SEEK_END       // 文件尾端
          ∘ SEEK_SET       // 文件开始

int  fsync(int fd)          ⇒  -1(errno) | 0      // 同步，立刻把 fd 的脏数据（数据部分和文件属性）写到磁盘 
int  fdatasync(int fd)      ⇒  -1(errno) | 0      // 同步，立刻把 fd 的脏数据（数据部分）写到磁盘
void sync(void)             ⇒                     // 同步，立刻把所有的脏数据（数据部分和文件属性）写到磁盘

int  dup (int oldfd)              ⇒  -1(errno) | 新 fd  // 拷贝生成一个新的描述符
int  dup2(int oldfd, int newfd2)  ⇒  -1(errno) | 新 fd  // 拷贝生成一个新的描述符  
```