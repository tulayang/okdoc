```
#include <sys/time.h>
```

time.h
--------


```
int gettimeofday(struct timeval *tv, [struct timezone *tz])  ⇒ 非0（errno） | 0  // 提取从1970-1-1 00:00:00（UTC时间）到现在所经过的微秒数 
    
    • struct timeval {
          long int tv_sec;      // 秒数
          long int tv_usec;     // 微秒数
      }

    • struct timezone {
          int tz_minuteswest;   // 格林威治时间往西方的时差
          int tz_dsttime;       // DST时间的修正方式
      }
```