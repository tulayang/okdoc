
## 进程时间

### times()

```
#include <sys/time.h>
struct tms {
    clock_t tms_utime;    // 用户 CPU 时间
    clock_t tms_stime;    // 系统 CPU 时间
    clock_t tms_cutime;   // 用户 CPU 时间，用于等待子进程
    clock_t tms_cstime;   // 系统 CPU 时间，用于等待子进程
};
clock_t times(struct tms *buff);  // 成功返回墙上时钟时间，出错返回 -1
```

## 日历时间

### time() gmtime() localtime() mktime()

```
#include <time.h>
struct tm {
    int tm_sec;   // 秒 0-60
    int tm_min;   // 分 0-59
    int tm_hour;  // 时 0-23
    int tm_mday;  // 天 1-31 
    int tm_mon;   // 月 0-11
    int tm_year;  // 年 >=1900
    int tm_wday;  // 星期？ 0-6
    int tm_yday;  // 年的第几天？ 0-365
    int tm_isdst; // 时令？ <0，0，>0
};
time_t time(time *ptr);                   // 成功返回时间值，出错返回 -1
struct tm *gmtime(const time_t *ptr);     // 成功返回协调时间，出错返回 NULL
struct tm *localtime(const time_t *ptr);  // 成功返回本地时间，出错返回 NULL
time_t mktime(struct tm *ptr);            // 成功返回时间值，出错返回 -1
```

### clock_gettime() clock_getres() clock_settime() gettimeofday()

```
#include <sys/time.h>

struct timespec{
    time_t tv_sec;   // 秒
    long   tv_nsec;  // 纳秒
};
int clock_gettime(clockid_t clock_id, struct timespec *tsp);  
    // 获取指定时钟的时间．成功返回 0，出错返回 -1
int clock_getres(clockid_t clock_id, struct timespec *tsp);
    // 获取指定时钟的时间．成功返回 0，出错返回 -1

int clock_settime(clockid_t clock_id, const struct timespec *tsp);
    // 设置指定时钟的时间．成功返回 0，出错返回 -1

struct timeval {
    time_t tv_sec;  // 秒
    long   tv_usec; // 微妙 
};
int gettimeofday(struct timeval *restrict tp, void *restruct tzp);
    // 获取时间，精度更高，可到微妙．总是返回 0．`tzp` 只能是 `NULL`．
```
