
## 错误处理

### perror()

```
#include <stdio.h>
void perror(const char *str);  // 向 stderr 打印 "{str}: errno message"。
```

<span>

```
if (close(fd) == -1)
    perror("close");
```

### strerror() strerror_r()

```
#include <string.h>

char *strerror(int errnum);
      // 返回错误编号描述的文本。该函数不是线程安全的，返回的文本可以被后续的 perror() strerror() 修改。

int   strerror_r(int errnum, char *buf, size_t len);
      // 返回错误编号描述的文本。该函数是线程安全的，返回的文本被写入提供的缓冲区中。
      // 成功返回 1，出错返回 -1，并设置 errno 。
```

