

## 系统信息

### uname()

```
#include <sys/utsname.h>
struct utsname {
    char sysname[];   // 操作系统名
    char nodename[];  // 节点名 
    char release[];   // 发布号
    char version[];   // 版本号
    char machine[];   // 硬件信息
};
int uname(struct utsname *name);  // 成功返回非负，出错返回 -1
```

### gethostname() sethostname()

```
#include <unistd.h>
int gethostname(char *name, int namelen);  // 获取主机名．成功返回 0，出错返回 -1
int sethostname();
```

提供 `name` 缓冲区和 `namelen` 缓冲区长度，函数将主机名填写到 `name`．最大主机名的长度是 `HOST_NAME_MAX`：

<table>
<tr>
  <th rowspan="2">接口</th>
  <th colspan="4" class="ta-c">最大名字长度</th>
</tr>
<tr>
  <th>FreeBSD 8.0</th>
  <th>Linux 3.2.0</th>
  <th>Mac OS X 10.6.8</th>
  <th>Solaris 10</th>
</tr>
<tr>
  <td>`uname()`</td>
  <td class="ta-c">256</td>
  <td class="ta-c">65</td>
  <td class="ta-c">256</td>
  <td class="ta-c">257</td>
</tr>
<tr>
  <td>`gethostname()`</td>
  <td class="ta-c">256</td>
  <td class="ta-c">64</td>
  <td class="ta-c">256</td>
  <td class="ta-c">256</td>
</tr>
</table>

## 系统限制

### sysconf()

```
#include <unistd.h>

long sysconf(int name);   
     // 成功返回限制值，否则返回 -1（如果出错同时把 errno 置为 EINVAL，表示 name 无效）
```

<span>

```
#include <unistd.h>
#include <stdio.h>

errno = 0;
long lim = sysconf(_SC_ARG_MAX);
if (lim == -1) {
    if (errno == 0)
        printf("Limit indeterminate");  // 不存在
    else
        errEixt("sysconf");             // 出错
} else {
    printf("Limit: %ld\n", lim);
}
```

### pathconf() fpathconf()

```
#include <unistd.h>

long pathconf(const char *pathname, int name);  // 成功返回限制值，否则返回 -1
long fpathconf(int fd, int name);               // 成功返回限制值，否则返回 -1
```

<span>

```
int fd = STDIN_FILENO;
int name = _PC_NAME_MAX;
lim = fpathconf(fd, name);
```

