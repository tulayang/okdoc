一个典型的 POSIX 线程池如下：

```
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

static pthread_mutex_t xlock = PTHREAD_MUTEX_INITIALIZER;  
static pthread_cond_t  xcond = PTHREAD_COND_INITIALIZER;

void *f(void *arg) {
    pthread_mutex_lock(&xlock);             // 抢锁，保证每个锁都有机会收到信号
    pthread_cond_wait(&xcond, &xlock);      // 解锁，等待条件信号 ... (唤醒，抢锁)
    printf("do something");                 // .........  
    pthread_mutex_unlock(&xlock);           // 解锁
    printf("do something");                 // .........
}

int main(int argc, char `argv) {
    pthread_t t1;
    pthread_t t2;

    pthread_create(&t1, NULL, &f, NULL);
    pthread_create(&t2, NULL, &f, NULL);

    sleep(3);
    pthread_mutex_lock(&xlock);             // 抢锁
    pthread_cond_signal(&xcond);            // 发送信号
    pthread_mutex_unlock(&xlock);           // 解锁

    sleep(3);
    pthread_mutex_lock(&xlock);             // 抢锁
    pthread_cond_signal(&xcond);            // 发送信号
    pthread_mutex_unlock(&xlock);           // 解锁

    pthread_join(t1, NULL);
    pthread_join(t2, NULL);

    exit(0);
}
```

一个 Nim 线程池如下：

```
import threadpool, locks

var 
    xlock: TLock
    ylock: TLock
    x {.guard: xlock.} = 100  # 账户 x 的金额 100
    y {.guard: ylock.} = 100  # 账户 y 的金额 100

proc longtime() =
    for i in 0..200_000_000: discard

proc read() =
    echo "--- Read begin"
    longtime()
    echo ">>> Read finish"

proc response() =
    echo "--- Response begin"
    longtime()
    echo ">>> Response finish"

template lock(x: TLock, y: TLock, body: stmt) =
    acquire(x)
    acquire(y)
    {.locks: [x, y].}: body
    release(y)
    release(x)

proc update() = 
    # 启动一个事务
    lock(xlock, ylock): 
        # 把账户 x 减少 1
        echo "--- Decrease begin with x " & $x
        longtime()     
        dec(x, 1)
        echo ">>> Decrease finish with x " & $x
        # 把账户 y 增加 1
        echo "--- Increase begin with y " & $y
        longtime()
        inc(y, 1)
        echo ">>> Increase finish with y " & $y

proc work() {.thread.} = 
    read()
    update()
    response()

initLock(xlock)
initLock(ylock)

while true:
    longtime()
    longtime()
    for i in 0..2:
        spawn work()

sync()
deinitLock(xlock)
deinitLock(ylock)
```