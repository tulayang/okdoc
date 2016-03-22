
## 文件系统的挂载和卸载

### mount() umount()

```
#include <sys/mount.h>
int mount(const char *source, const char *target, const char *fstype, 
          unsigned long mountflags, const void *data);
    // 成功返回 0，出错返回 -1
int umount(const char *target);
int umount2(const char *target, int flags);
    // 成功返回 0，出错返回 -1
```

## 文件元数据

### stat() fstat() fstatat() lstat()

```
#include <sys/stat.h>

struct timespec {
    time_t tv_sec;              // 秒
    long   tv_nsec;             // 纳秒
};
struct stat {
    dev_t           st_dev;     // 设备号码（文件系统），如果文件不在本地设备，比如网络文件系统，值为 0
    dev_t           st_rdev;    // 特殊文件的设备号码
    ino_t           st_ino;     // inode 号码
    nlink_t         st_nlink;   // 文件的硬链接数
    mode_t          st_mode;    // 位掩码，标识文件类型和文件权限的双重作用
    uid_t           st_uid;     // 属主
    gid_t           st_gid;     // 属组
    off_t           st_size;    // 普通文件时，表示字节数
    struct timespec st_atime;   // 最后被访问的时间
    struct timespec st_mtime;   // 内容最后被修改的时间
    struct timespec st_ctime;   // 状态最后被修改的时间
    blksize_t       st_blksize; // 有效文件 IO 的推荐逻辑块大小，一般是 4096
    blkcnt_t        st_blocks;  // 实际分配给文件的逻辑块数目（不计算空洞的值）  
};

int stat(const char *restrict pathname, struct stat *restrict buf);
int fstat(int fd, struct stat *buf);
int fstatat(int fd, const char *restrict pathname, struct stat *restrict buf, int flag);
int lstat(const char *restrict pathname, struct stat *restrict buf);
    // 成功返回 0，出错返回 -1 。
    // 以上函数都返回文件信息，区别是对于符号链接，lstat() 返回符号链接本身而非所指向的文件。
    // 这些调用，不需要文件权限，需要父目录有执行权限（搜索）。
```

### S_ISXXX()

```
// stat 结构的 st_mode 成员，起标识文件类型和文件权限的双重作用。可以使用如下宏确定文件类型

#include <sys/stat.h>
S_ISREG (st_mode)     // 常规文件？
S_ISDIR (st_mode)     // 目录文件？
S_ISBLK (st_mode)     // 块设备文件？
S_ISCHR (st_mode)     // 字符设备文件？
S_ISFIFO(st_mode)     // FIFO 或者管道？
S_ISSOCK(st_mode)     // 套接字？
S_ISLNK (st_mode)     // 符号链接？

S_TYPEISMQ(st_mode)   // POSIX 消息队列？
S_TYPEISSEM(st_mode)  // POSIX 信号量？
S_TYPEISSHM(st_mode)  // POSIX 共享存储对象
```

<span>

```
struct stat buf;
if (lstat("foo", &buf) == -1)
    errExit("lstat"); 
if (S_ISREG(buf.st_mode)) 
    printf("regular file");
else if (S_ISDIR(buf.st_mode)) 
    printf("directory file");
// ...
```

## 访问权限

### chmod() fchmod() fchmodat()

```
#include <sys/stat.h>
int chmod(const char *pathname, mode_t mode);                       
int fchmod(int fd, mode_t mode);                                    
int fchmodat(int fd, const char *pathname, mode_t mode, int flag);
    // 成功返回 0，出错返回 -1 。
    // 修改文件访问权限。当 fchmodat() 设置 flag |= AT_SYMLINK_NOFOLLOW 时，并且文件是符号链接，
    // fchmodat() 只改变符号链接本身的访问权限。
    // 
    // mode - 权限模式
    // 
    //   ∘ S_ISUID  -  执行时设置＂用户号码＂
    //   ∘ S_ISGID  -  执行时设置＂组号码＂
    //   ∘ S_ISVTX  -  保存正文（粘着位）
    // 
    //   ∘ S_IRWXU  -  用户（所有者）读，写，执行
    //   ∘ S_IRUSR  -  用户（所有者）读
    //   ∘ S_IWUSR  -  用户（所有者）写
    //   ∘ S_IXUSR  -  用户（所有者）执行
    // 
    //   ∘ S_IRWXG  -  组读，写，执行
    //   ∘ S_IRGRP  -  组读
    //   ∘ S_IWGRP  -  组写
    //   ∘ S_IXGRP  -  组执行
    // 
    //   ∘ S_IRWXO  -  其他读，写，执行
    //   ∘ S_IROTH  -  其他读
    //   ∘ S_IWOTH  -  其他写
    //   ∘ S_IXOTH  -  其他执行
```

<span>

```
struct stat buf;
if (stat("foo", &buf) == -1)
    errExit("stat");
if (chmod("foo", (buf.st_mode & ~S_IXGRP) | S_ISGID) == -1)
    errExit("chmod");
if (chmod("bar", S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH) == -1)
    errExit("chmod");

```

### umask()

```
#include <sys/stat.h>
mode_t umask(mode_t cmask);  // 返回之前的 umask 值。
                             // umask 掩码，通常是为了限制程序对创建文件的权限设置。
                             // 0400  -  用户读
                             // 0200  -  用户写
                             // 0100  -  用户执行
                             // 0040  -  组读
                             // 0020  -  组写
                             // 0010  -  组执行
                             // 0004  -  其他读
                             // 0002  -  其他写
                             // 0001  -  其他执行
                             // 0000  -  取消屏蔽位
```

<span>

```
umask(0);
if (create("foo", S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | IWOTH) < 0) // => 666
    errExit("create");
umask(S_IRGRP | S_IWGRP | SIROTH | S_IWOTH);
if (create("bar", S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | IWOTH) < 0) // => 600
    errExit("create");
```

<span>

```
$ umask               // 打印当前屏蔽字
002
$ umask -S            // 打印符号格式
u=rwx,g=rwx,o=rx
$ umask 027           // 更改当前屏蔽字
$ umask -S            // 打印符号格式
u=rwx,g=rx,o=
```

### access() faccessat()

```
#include <unistd.h>
int access(const char *pathname, int mode);                     
int faccessat(int fd, const char *pathname, int mode, int flag);  
    // 成功返回 0，出错返回 -1。
    // 验证实际用户能否访问一个给定的文件。这两个调用是按＂实际用户号码＂和＂实际组号码＂进行权限测试的。
    //
    // mode - 如果测试文件已经存在，mode 为 F_OK
    //
    //   ∘ F_OK  -  有这个文件吗？
    //   ∘ R_OK  -  有读权限吗？
    //   ∘ W_OK  -  有写权限吗？
    //   ∘ X_OK  -  有执行权限吗？
```

## 所有权

### chown() fchown() fchownat() lchown()

```
#include <unistd.h>
int chown(const char *pathname, uid_t owner, gid_t group);
int fchown(int fd, uid_t owner, gid_t group);
int fchownat(int fd, const char *pathname, uid_t owner, gid_t group, int flag);
int lchown(const char *pathname, uid_t owner, gid_t group);
    // 成功返回 0，出错返回 -1。
    // 修改文件所有权。区别是对于符号链接，lchown() 只改变符号链接文件本身的所有权。
    // 对于 fchownat() 如果文件是符号链接，改变符号链接指向的文件的所有权。
    // 设置 flag |= AT_SYMLINK_NOFOLLOW 时，同 lchown，否则同 chown。
```

## 文件时间戳

### futimens() utimensat() utimes()

```
#include <sys/stat.h>
struct timespec {
    time_t tv_sec;              // 秒
    long   tv_nsec;             // 纳秒
};
struct timeval {
    time_t tv_sec;              // 秒
    long   tv_usec;             // 微秒
};
int futimens(int fd, const struct timespec times[2]);
int utimensat(int fd, const char *path, const struct timespec times[2], int flag);
int utimes(const char *pathname, const struct timeval times[2]);
    // 成功返回 0，出错返回 -1。
    // 修改文件＂最后访问时间戳＂和＂最后修改时间戳＂。
```

## 目录

### getcwd() chdir() fchdir()

```
#include <unistd.h>
char *getcwd(char *buf, size_t size); // 成功返回 buf，出错返回 NULL。
                                      // 缓冲区 buf必须有足够的长度，以容纳绝对路径名加上一个
                                      // '\0' 终止符，否则出错。
int   chdir(const char *pathname);    // 成功返回 0，出错返回 -1。
int   fchdir(int fd);                 // 成功返回 0，出错返回 -1。
```

<span>

```
if (chdir("/tmp") < 0)
    errExit("chdir");

if (getcwd(ptr, size) == NULL)
    errExit("getcwd");
``` 

### mkdir() mkdirat()

```
#include <sys/stat.h>

int mkdir(const char *pathname, mode_t mode);
int mkdirat(int fd, const char *pathname, mode_t mode);
    // 创建一个新的空目录。成功返回 0，出错返回 -1。

// mkdir mkdirat 创建一个新的空目录。. 和 .. 目录项是自动创建的，
// 指定的文件访问权限 mode 由进程的＂文件模式屏蔽字＂修改。

// 空目录是只包含 . 和 .. 的目录。
```

### rmdir()

```
int rmdir(const char *pathname);
    // 删除一个新的空目录。成功返回 0，出错返回 -1。
```

### opendir() fdopendir() readdir() rewinddir() rewinddir() closedir() telldir() seekdir()

```
#include <dirent.h>

struct dirent {
    ino_t          d_ino;            // i 节点号码。
    off_t          d_off;            // 目录＂偏移量＂。
    unsigned short d_reclen;         // 记录长度。
    unsigned char  d_type;           // 文件类型。
    char           d_name[256];      // 目录中的单个文件名，应该连续调用 readdir，逐个获取每个文件名。
};

DIR *opendir(const char *pathname);  // 打开目录。成功返回指针，出错返回 NULL。
DIR *fdopendir(int fd);              // 转换为目录。成功返回指针，出错返回 NULL。

struct dirent *readdir(DIR *dp);     // 读取目录，每次读取一个文件名。成功返回指针，出错或者目录已经读完
                                     // 返回 NULL。errno 只有一个值 EBADF，表示目录无效，对许多应用
                                     // 程序而言，没有必要检查错误，直接假定 NULL 表示目录读完。

int closedir(DIR *dp);               // 关闭目录。成功返回 0，出错返回 -1。

void rewinddir(DIR *dp);             // 
long telldir(DIR *dp);               // 返回目录位置。
void seekdir(DIR *dp, long loc);     //
```

## 链接

### symlink() symlinkat() readlink() readlinkat()

```
#include <unistd.h>

int symlink(const char *actualpath, const char *sympath);
int symlink(const char *actualpath, int fd, const char *sympath);
    // 成功返回 0，出错返回 -1

int readlink(const char *restrict pathname, char *restrict buf, size_t bufsize);
int readlinkat(int fd, const char *restrict pathname, char *restrict buf, size_t bufsize);
    // 成功返回读取的字节数，出错返回 -1

// 任何用户都可以创建指向目录的符号链接。符号链接一般用于将一个文件或者整个目录结构移到
// 系统另一个位置。每个符号链接，有自己的 i 表节点和数据块，开销比硬连接要大，但是可以跨文件系统。
```

### link() linkat() remove()

```
#include <unistd.h>

int unlink(const char *pathname);
int unlinkat(int fd, const char *pathname, int flag);
    // 成功返回 0，出错返回 -1。

#include <stdio.h>
int remove(const char *pathname);
    // 对于文件，功能同 `unlink`。对于目录，功能同 `rmdir`。成功返回 0，出错返回 -1。
```

## 拷贝和移动文件

### rename() renameat() 

```
#include <stdio.h>
int rename(const char *oldname, const char *newname);
int rename(int oldfd, const char *oldname, int newfd, const char *newname);
    // 成功返回 0，出错返回 -1．
```

## 监视文件事件

### inotify_init1

```
#include <sys/inotify.h>
int inotify_init1(int flags);
    // 初始化 inotify，成功返回一个文件描述符，出错返回 -1。
    //
    // flags - 监视模式
    //
    //   * IN_CLOEXEC   -  对新文件描述符设置执行后关闭（close-on-exec）
    //   * IN_NONBLOCK  -  对新文件描述符设置非阻塞
```

<span>

```
int fd = inotify_init1(0);
if (fd == -1)
    errExit("inotify_init1");
```

### inotify_add_watch()

> 进城完成初始化后，会设置监视。监视是由监视描述符表示，由一个标准 UNIX 路径以及一组相关联的监视掩码组成。监视掩码会通知内核，该进程关心哪些事件。

> inotify 可以监视文件和目录。当监视目录时，inotify 会报告目录本身和该目录下的所有文件事件（但不包括监视目录的子目录下的文件---监视不是递归的）。

<span>

```
#include <sys/inotify.h>
int inotify_add_watch(int fd, const char *pathname, unit32_t mask);
    // 添加一个新的监视，成功返回新建的监视描述符，出错返回 -1。
    //
    // mask - 监视掩码，由一个或者多个 inotify 事件的二进制或运算生成
    //
    //   * IN_ACCESS  -  从文件中读取
    //   * IN_MODIFY  -  写入文件中
    //   * IN_ ATTRIB -  文件的元数据（属主、权限、扩展属性）发生变化       
    //   * ........ 更多待记录 《LINUX 系统编程》        
```