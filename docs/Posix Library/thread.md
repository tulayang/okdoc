
## 创建线程

### pthread_create()

```
#include <pthread.h>
int pthread_create(pthread_t *restrict t, const thread_attr_t *restrict attr, 
                   void *(*f)(void *), void *restrict arg);                 
    // 成功返回 0，出错返回错误编号
    // 
    // attr - 线程属性，如果使用默认值可以置为 NULL
    // f    - 线程函数的地址
    // arg  - 传递给线程函数的结构参数，如不需要可以置为 NULL
```

<span>

```
pthread_t t;
pthread_t ret = pthread_create(&t, NULL, f, NULL);
if (ret != 0)
    errExit("pthread_create");
```

### pthread_self() pthread_equal()

```
#include <pthread.h>
pthread_t pthread_self(void);     // 获取当前线程的＂线程号码＂
int       pthread_equal(t1, t2);  // 比较两个＂线程号码＂是同一个线程？ 相等返回非 0，否则返回 0 
```

<span>

```
if (pthread_equal(t1, pthread_self()))
    printf("t1 matches self");
```

### pthread_attr_init() pthread_attr_destroy()

```
#include <pthread.h>
int pthread_attr_init(pthread_attr_t *attr);     // 动态分配线程属性结构的内存，
                                                 // 成功返回 0，出错返回错误编号。
int pthread_attr_destroy(pthread_attr_t *attr);  // 释放动态分配的线程属性结构的内存，
                                                 // 成功返回 0，出错返回错误编号。
```

<span>

```
int createThread(void *(*f)(void *), void *arg) {
    int err;
    pthread_t tid;
    pthread_attr_t attr;

    err = pthread_attr_init(&attr);
    if (err != 0)
        return err;
    err = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    if (err != 0)
        return err;
    err = pthread_create(&tid, &attr, f, arg);
    if (err != 0)
        return err;
    err = pthread_attr_destroy(&attr);
    if (err != 0)
        return err;
    return 0;
}
```

### pthread_attr_getdetachstate() pthread_attr_setdetachstate()

```
#include <pthread.h>

int pthread_attr_getdetachstate(const pthread_attr_t *restrict attr, int *detachstate);
    // 获取线程属性的 detachstate 值，成功返回 0，出错返回错误编号。
    // 第二个参数要么被调用设置为 PTHREAD_CREATE_DETACHED，要么设置为 PTHREAD_CREATE_JOINABLE 。

int pthread_attr_setdetachstate(pthread_attr_t *attr, int *detachstate); 
    // 设置线程属性的 detachstate 值，成功返回 0，出错返回错误编号。
    // 可以把 detachstate 设置成两个合法值之一：
    //
    //   ∘ PTHREAD_CREATE_DETACHED  -  以分离状态启动线程
    //   ∘ PTHREAD_CREATE_JOINABLE  -  正常启动线程，应用程序可以获取线程的终止状态（默认）
```

###  pthread_attr_getguardsize() pthread_attr_setguardsize()

```
#include <pthread.h>

int pthread_attr_getguardsize(const pthread_attr_t *restrict attr, size_t *restrict guardsize);
    // 获取线程属性的 guardsize 值，成功返回 0，出错返回错误编号。

int pthread_attr_setguardsize(pthread_attr_t *attr, size_t *guardsize);
    // 设置线程属性的 guardsize 值，成功返回 0，出错返回错误编号。
```

### pthread_attr_getstack() pthread_attr_setstack()<br />pthread_attr_getstacksize() pthread_attr_setstacksize() 

```
#include <pthread.h>

int pthread_attr_getstack(const pthread_attr_t *restrict attr, 
                          void **restrict stackaddr, size_t *restrict stacksize);
    // 获取线程属性的 stackaddr 和 stacksize，成功返回 0，出错返回错误编号。
int pthread_attr_setstack(pthread_attr_t *attr, void *stackaddr, size_t stacksize);
    // 设置线程属性的 stackaddr 和 stacksize，成功返回 0，出错返回错误编号。

int pthread_attr_getstacksize(const pthread_attr_t *restrict attr, size_t *restrict stacksize);
int pthread_attr_setstacksize(pthread_attr_t *attr, size_t stacksize);
    // 成功返回 0，出错返回错误编号。
    // 如果希望改变默认的栈大小，但又不想自己处理线程栈的分配问题时非常有用。

// 对于遵循 POSIX 标准的系统来说，不一定要支持线程栈属性，但是对于遵循 SUS XSI 选项的系统来说，则必须
// 支持线程栈属性。可以在编译期使用 _POSIX_THREAD_ATTR_STACKADDR 和 _POSIX_THREAD_ATTR_STACKSIZE
// 符号来检查系统是否支持线程栈属性。也可以在运行期调用 `sysconf()` 
// 传入 _SC_THREAD_ATTR_STACKADDR 和 _SC_THREAD_ATTR_STACKSIZE 来检查系统是否支持线程栈属性。
```

## 终止线程

### pthread_exit()

```
#include <pthread.h>

void pthread_exit(void *retval);   
     // retval - 指定线程返回值，可由另一线程通过 pthread_join() 获取
```

### pthread_cancel()<br />pthread_setcancelstate() pthread_setcanceltype()<br />pthread_testcancel()

```
#include <pthread.h>

int pthread_cancel(pthread_t t);  
    // 向指定线程发送一个请求，要求其立刻退出。成功返回 0，出错返回错误编号。

int pthread_setcancelstate(int state, int *oldstate);
    // 设置线程的取消状态，成功返回 0，出错返回错误编码。
    // 
    // state - 取消状态
    //
    //   ∘ PTHREAD_CANCEL_DISABLE  -  不允许取消。线程收到取消请求，会将请求挂起放入队列，直到允许取消
    //   ∘ PTHREAD_CANCEL_ENABLE   -  允许取消。默认值
    //
    // oldstate - 成功调用时旧的取消状态会保存到 oldstate。应该总是为 oldstate 设置一个非 NULL 值
    
int pthread_setcanceltype(int type, int *oldtype);
    // 设置线程的取消类型，成功返回 0，出错返回错误编码。
    // 如果线程的取消状态为允许取消， 那么对取消请求的处理则取决于线程的取消类型。
    //
    // type - 取消类型
    //
    //   ∘ PTHREAD_CANCEL_ASYNCHRONOUS  -  异步取消。可能会在任何时间取消线程（也许是立刻取消，但不一定）
    //   ∘ PTHREAD_CANCEL_DEFERRED      -  延迟取消。取消请求保持挂起状态，直到到达取消点。默认值
    //
    // oldtype - 成功调用时旧的取消类型会保存到 oldtype。应该总是为 oldtype 设置一个非 NULL 值。
    //
    // 取消点 - 如果将线程的取消状态和取消类型分别置为 `PTHREAD_CANCEL_ENABLE` 和 
    // `PTHREAD_CANCEL_DEFERED`，只有当线程抵达某个取消点时，取消请求才会起作用。
    // 取消点是对由实现定义的一组函数的调用，表示要终止调用方的安全点。

void pthread_testcancel(void);
     // 产生一个取消点。当线程执行的代码未包含取消点时，可以周期性的调用 pthread_testcancel(),
     // 以确保对其他线程向其发送的取消请求作出及时响应。
```

<span>

```
// 线程 t2 执行
int unused;
if (pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, &unused) != 0)
    errExit("pthread_setcancelstate");
if (pthread_setcanceltype(PTHREAD_CANCEL_DEFERRED, &unused) != 0)
    errExit("pthread_setcanceltype");

// 线程 t1 执行
if (pthread_cancel(t2))
    errExit("pthread_cancel");
```

### pthread_cleanup_push() pthread_cleanup_pop()

```
void pthread_cleanup_push(void (*f)(void *), void *arg);
void pthread_cleanup_pop(int execute);
     // 当线程执行以下动作时，清理函数会被调用 
     //
     //   1.调用 pthread_exit() 时
     //   2.收到取消请求时
     //   3.用非零 execute 参数调用 pthread_cleanup_pop() 时
     //
     // 调用 pthread_cleanup_pop() 将删除上次 pthread_cleanup_push() 注册的清理函数，并且：
     //
     //   ∘ 如果 execute == 0，清理函数将不被调用
     //   ∘ 如果 execute != 0，清理函数将被调用
```

<span>

```
void f(void *arg) {
    printf("cleanup: %s", (char *)arg);
}

pthread_cleanup_push(f, "thread 1 first handler");
pthread_cleanup_push(f, "thread 1 second handler");
pthread_cleanup_pop(0);
```

## 加入线程和分离线程

### join() detach()

```
#include <pthread.h>

int pthread_join(pthread_t t, void **retval);  
    // 成功返回 0，出错返回错误编号。
    // 成功调用时，调用线程会阻塞，直到指定的线程终止。一旦线程终止，调用线程就会醒来。如果 
    // retval 不为 NULL，被等待线程传递给 pthread_exit() 或者其退出时的返回值会被放到 retval 。

int pthread_deatch(pthread_t t);  
    // 成功返回 0，出错返回错误编号。
```

<span>

```
pthread t1, t2;
const char *message1 = "Thing 1";
const char *message2 = "Thing 2"; 

pthread_create(&t1, NULL, f, (void *) message1);
pthread_create(&t1, NULL, f, (void *) message2);

pthread_join(t1, NULL);
pthread_join(t2, NULL);
```

## 互斥量

### PTHREAD_MUTEX_INITIALIZER<br />pthread_mutex_init() pthread_mutex_destroy()

```
#include <pthread.h>

#define PTHREAD_MUTEX_INITIALIZER { { 0, 0, 0, 0, 0, 0, { 0, 0 } } }
    // 静态分配互斥量内存。

int pthread_mutex_init(pthread_mutex_t *restrict mutex, 
                       const pthread_mutexattr_t *restrict attr); 
    // 动态分配互斥量内存，成功返回 0，出错返回错误编号。
    // 要用默认的属性初始化互斥量，只需要把 attr 置为 NULL 。

int pthread_mutex_destroy(pthread_mutex_t *mutex); 
    // 释放动态分配的互斥量内存，成功返回 0，出错返回错误编号。
```

### pthread_mutexattr_init() pthread_mutexattr_destroy()

```
#include <pthread.h>

int pthread_mutexattr_init(pthread_mutexattr_t *attr);
    // 动态分配互斥量属性结构的内存，成功返回 0，出错返回错误编号。

int pthread_mutexattr_destroy(pthread_mutexattr_t *attr);
    // 释放动态分配的互斥量属性结构的内存，成功返回 0，出错返回错误编号。
```

### pthread_mutexattr_getpshared() pthread_mutexattr_setpshared()

```
#include <pthread.h>

int pthread_mutexattr_getpshared(const pthread_mutexattr_t *restrict attr, 
                                 int *restrict pshared);
    // 获取互斥量属性的进程共享值。成功返回 0，出错返回错误编号。

int pthread_mutexattr_setpshared(pthread_mutexattr_t *attr, int *pshared);
    // 设置互斥量属性的进程共享值。成功返回 0，出错返回错误编号。
```

### pthread_mutexattr_getrobust() pthread_mutexattr_setrobust()<br />pthread_mutex_consistent

```
#include <pthread.h>

int pthread_mutexattr_getrobust(const pthread_mutexattr_t *restrict attr, int *restrict robust);
    // 获取互斥量属性的健壮值，成功返回 0，出错返回错误编号。

int pthread_mutexattr_setrobust(pthread_mutexattr_t *attr, int *robust);
    // 设置互斥量属性的健壮值，成功返回 0，出错返回错误编号。

int pthread_mutex_consistent(pthread_mutex_t *mutex);  
    // 成功返回 0，出错返回错误编号。
    //
    // 如果应用状态无法恢复，在线程对互斥量解锁后，该互斥量将处于永久不可用状态。为了避免这样的
    // 问题，线程可以调用 pthread_mutex_consistent() 指明与该互斥量相关的状态在互斥量解锁前
    // 是一致的。
    //
    // 如果线程没有先调用 pthread_mutex_consistent() 就对互斥量进行解锁，那么其他试图获取该
    // 互斥量的阻塞线程就会得到错误码 ENOTRECOVERABLE 。如果发生这种情况，互斥量将不再可用。
    // 线程通过提前调用 pthread_mutex_consistent() ，能让互斥量正常工作，这样它就可以持续被使用。 
```

### pthread_mutexattr_gettype() pthread_mutexattr_settype() 

```
#include <pthread.h>

int pthread_mutexattr_gettype(const pthread_mutexattr_t *restrict attr, int *restrict type);
    // 获取互斥量属性的类型值，成功返回 0，出错返回错误编号。

int pthread_mutexattr_settype(pthread_mutexattr_t *attr, int *type);
    // 设置互斥量属性的类型值，成功返回 0，出错返回错误编号。
```

### pthread_mutex_lock() pthread_mutex_trylock() pthread_mutex_timedlock()<br />pthread_mutex_unlock()

```
#include <pthread.h>

int pthread_mutex_lock(pthread_mutex_t *mutex);
    // 对互斥量加锁。如果互斥量已经上锁，调用线程将阻塞直到互斥量被解锁。
    // 成功返回 0，出错返回错误编号。

int pthread_mutex_trylock(pthread_mutex_t *mutex);
    // 尝试对互斥量加锁。如果互斥量未上锁，那么将锁住互斥量，否则就会失败，立刻返回错误 EBUSY 。
    // 成功返回 0，出错返回错误编号。

int pthread_mutex_timedlock(pthread_mutex_t *restrict mutex, 
                            const struct timespec *restrict tp);
    // 对互斥量加锁。如果互斥量已经上锁，调用线程将阻塞直到互斥量被解锁，如果到达指定时间
    // 仍未锁住互斥量，则返回错误 ETIMEDOUT。
    // 成功返回 0，出错返回错误编号。

int pthread_mutex_unlock(pthread_mutex_t *mutex);  
    // 解锁，成功返回 0，出错返回错误编号。
```

<span>

```
// 全局锁使得锁语义变得复杂，尤其是对于死锁避免

static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

int decMoney(struct account *account, int amount) {
    pthread_mutex_lock(&mutex);
    if (account->money < amount) {
        pthread_mutex_unlock(&mutex);
        return -1;
    }
    account->money -= amount;
    pthread_mutex_unlock(&mutex);
    return 0;
}
```

<span>

```
// 避免全局锁！在数据中定义锁！

int decMoney(struct account *account, int amount) {
    pthread_mutex_lock(&account->mutex);
    if (account->money < amount) {
        pthread_mutex_unlock(&account->mutex);
        return -1;
    }
    account->money -= amount;
    pthread_mutex_unlock(&account->mutex);
    return 0;
}
```

## 读写锁

### PTHREAD_RWLOCK_INITIALIZER<br />pthread_rwlock_init() pthread_rwlock_destroy()

```
#include <pthead.h>

#define PTHREAD_RWLOCK_INITIALIZER { { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } }
    // 静态分配读写锁内存。

int pthread_rwlock_init(pthread_rwlock_t *restrict rwlock, 
                        const pthread_rwlockattr_t *restrict attr); 
    // 动态分配读写锁内存，成功返回 0，出错返回错误编号。
    // 要用默认的属性初始化读写锁，只需要把 attr 置为 NULL 。

int pthread_rwlock_destroy(pthread_rwlock_t *rwlock);
    // 释放动态分配的读写锁内存，成功返回 0，出错返回错误编号。
    //
    // 如果调用 pthread_rwlock_init() 为读写锁分配了资源，pthread_rwlock_destroy() 将释放这些资源。
    // 如果在调用 pthread_rwlock_destroy() 前就释放了读写锁占用的内存空间，那么分配给
    // 这个锁的资源就会＂丢失＂。
```

### pthread_rwlockattr_init() pthread_rwlockattr_destroy()

```
#include <pthead.h>

int pthread_rwlockattr_init(pthread_rwlockattr_t *attr);
    // 动态分配读写锁属性的内存，成功返回 0，出错返回错误编号。

int pthread_rwlockattr_destroy(pthread_rwlockattr_t *attr);
    // 释放动态分配的读写锁属性的内存，成功返回 0，出错返回错误编号。
```

### pthread_rwlockattr_getpshared() pthread_rwlockattr_setpshared()

```
#include <pthread.h>

int pthread_rwlockattr_getpshared(const pthread_rwlockattr_t *restrict attr, 
                                  int *restrict pshared);
    // 获取读写锁属性的进程共享值，成功返回 0，出错返回错误编号。

int pthread_rwlockattr_setpshared(pthread_rwlockattr_t *attr, int *pshared);
    // 设置读写锁属性的进程共享值，成功返回 0，出错返回错误编号。
```

### pthread_rwlock_rdlock() pthread_rwlock_tryrdlock()<br />pthread_rwlock_timedrdlock()<br />pthread_rwlock_wrlock() pthread_rwlock_trywdlock()<br />pthread_rwlock_timedwdlock()<br />pthread_rwlock_unlock()

```
#include <pthead.h>

int pthread_rwlock_rdlock(pthread_rwlock_t *rwlock);  
    // 使用读模式加锁。如果已经上锁，调用线程将阻塞直到解锁。
    // 成功返回 0，出错返回错误编号。

int pthread_rwlock_tryrdlock(pthread_rwlock_t *rwlock);  
    // 尝试使用读模式加锁。如果未上锁，那么将锁住，否则就会失败，立刻返回错误 EBUSY 。
    // 成功返回 0，出错返回错误编号。

int pthread_rwlock_timedrdlock(pthread_rwlock_t *restrict rwlock, 
                               const struct timespec *restrict tp);
    // 使用读模式加锁。如果已经上锁，调用线程将阻塞直到解锁，如果到达指定时间
    // 仍未锁住，则返回错误 ETIMEDOUT。
    // 成功返回 0，出错返回错误编号。

int pthread_rwlock_wrlock(pthread_rwlock_t *rwlock);  
    // 使用写模式加锁。如果已经上锁，调用线程将阻塞直到解锁。
    // 成功返回 0，出错返回错误编号。

int pthread_rwlock_trywdlock(pthread_rwlock_t *rwlock); 
    // 尝试使用读模式加锁。如果未上锁，那么将锁住，否则就会失败，立刻返回错误 EBUSY 。
    // 成功返回 0，出错返回错误编号。

int pthread_rwlock_timedwdlock(pthread_rwlock_t *restrict rwlock, 
                               const struct timespec *restrict tp);
    // 使用写模式加锁。如果已经上锁，调用线程将阻塞直到解锁，如果到达指定时间
    // 仍未锁住，则返回错误 ETIMEDOUT。
    // 成功返回 0，出错返回错误编号。

int pthread_rwlock_unlock(pthread_rwlock_t *rwlock);  
    // 解锁，成功返回 0，出错返回错误编号。
```

## 条件变量

### PTHREAD_COND_INITIALIZER<br />pthread_cond_init() pthread_cond_destroy()

```
#include <pthread.h>

#define PTHREAD_COND_INITIALIZER { { 0, 0, 0, 0, 0, (void *) 0, 0, 0 } }
    // 静态分配条件变量内存。

int pthread_cond_init(pthread_cond_t *restrict cond, const pthread_condattr_t *restrict attr);
    // 动态分配条件变量内存，成功返回 0，出错返回错误编号。
    // 要用默认的属性初始化条件变量，只需要把 attr 设为 NULL 。

int pthread_cond_destroy(pthread_cond_t *cond);
    // 释放动态分配的条件变量内存，成功返回 0，出错返回错误编号。
```

### pthread_condattr_init() pthread_condattr_destroy()

```
#include <pthead.h>

int pthread_condattr_init(pthread_condattr_t *attr);
    // 动态分配条件变量属性的内存，成功返回 0，出错返回错误编号。

int pthread_condattr_destroy(pthread_condattr_t *attr);
    // 释放动态分配的条件变量属性的内存，成功返回 0，出错返回错误编号。
```

### pthread_condattr_getpshared() pthread_condattr_setpshared()

```
#include <pthead.h>

int pthread_condattr_getpshared(const pthread_condattr_t *restrict attr, int *restrict pshared);
    // 获取条件变量属性的进程共享值，成功返回 0，出错返回错误编号。
int pthread_condattr_setpshared(pthread_condattr_t *attr, int *pshared);
    // 设置条件变量属性的进程共享值，成功返回 0，出错返回错误编号。
```

### pthread_condattr_getclock() pthread_condattr_setclock()

```
#include <pthread.h>
int pthread_condattr_getclock(const pthread_condattr_t *restrict attr, int *restrict clock_id);
    // 获取条件变量属性的时钟值，成功返回 0，出错返回错误编号。
int pthread_condattr_setclock(pthread_condattr_t *attr, int *clock_id);
    // 设置条件变量属性的时钟值，成功返回 0，出错返回错误编号。
```

### pthread_cond_wait() pthread_cond_timedwait()

```
#include <pthread.h>

int pthread_cond_wait(pthread_cond_t *restrict cond, pthread_mutex_t *restrict mutex);
    // 使当前线程进入睡眠，等待条件信号。成功返回 0，出错返回错误编号。

int pthread_cond_timedwait(pthread_cond_t *restrict cond, pthread_mutex_t *restrict mutex, 
                           const struct timespec *restrict tp);
    // 使当前线程进入睡眠，等待条件信号。如果到达指定时间时仍没有信号，立刻返回错误 ETIMEDOUT 。
    // 成功返回 0，出错返回错误编号。
```

### pthread_cond_signal() pthread_cond_broadcast()

```
#include <pthread.h>
int pthread_cond_signal(pthread_cond_t *cond);
    // 随机唤醒一个沉睡的线程，成功返回 0，出错返回错误编号。 

int pthread_cond_broadcast(pthread_cond_t *cond);
    // 唤醒全部沉睡的线程，成功返回 0，出错返回错误编号。

// pthread_cond_signal() 比 pthread_cond_broadcast () 更有效率，切可以避免惊群。
```

<span>

```
struct message {
    struct message *next;
    // ...  
};

struct message *workq;

pthread_cond_t cond = PTHREAD_COND_INITIALIZER;
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

void processMessage(void) {
    struct message *mp;
    for (;;) {
        pthread_mutex_lock(&mutex);
        while (workq == NULL)
            pthread_cond_wait(&cond, &mutex);
        mp = workq;
        workq = workq->next;
        pthread_mutex_unlock(&mutex);
    }
}

void enqueueMessage(struct message *mp) {
    pthread_mutex_lock(&mutex);
    mp->next = workq;
    workq = mp;
    pthread_mutex_unlock(&mutex);
    pthread_cond_signal(&cond);
}
```

## 自旋锁

## 屏障

### pthread_barrier_int() pthread_barrier_destroy()

```
#include <pthread.h>

int pthread_barrier_int(pthread_barrier_t *restrict barrier, 
                        const pthread_barrierattr_t *restrict attr, unsigned int count);
    // 动态分配屏障内存，成功返回 0，出错返回错误编号。
    // 要用默认的属性初始化屏障，只需要把 attr 设为 NULL 。
    // count - 在允许所有线程继续运行前，必须到达的线程数目。

int pthread_barrier_destroy(pthread_barrier_t *barrier);
    // 释放动态分配的屏障内存，成功返回 0，出错返回错误编号。
```

### pthread_barrierattr_init() pthread_barrierattr_destroy()

```
#include <pthead.h>

int pthread_barrierattr_init(pthread_barrierattr_t *attr);
    // 动态分配屏障属性的内存，成功返回 0，出错返回错误编号。

int pthread_barrierattr_destroy(pthread_barrierattr_t *attr);
    // 释放动态分配的屏障属性的内存，成功返回 0，出错返回错误编号。
```

### pthread_condattr_getpshared() pthread_condattr_setpshared()

```
#include <pthead.h>

int pthread_condattr_getpshared(const pthread_condattr_t *restrict attr, int *restrict pshared);
    // 获取屏障的进程共享属性值，成功返回 0，出错返回错误编号。

int pthread_condattr_setpshared(pthread_condattr_t *attr, int *pshared);
    // 设置屏障的进程共享属性值，成功返回 0，出错返回错误编号。
```

### pthread_barrier_wait()

```
#include <pthread.h>
int pthread_barrier_wait(pthread_barrier_t *barrier);
    // 成功返回 PTHREAD_BARRIER_SERIAL_THREAD 或者 0，出错返回错误编号。
    //
    // 调用线程完成工作，等待所有其他线程到达。调用线程在屏障计数未满足条件时，会进入
    // 休眠状态。如果该线程是最后一个调用 pthread_barrier_wait() 的线程，并且满足了
    // 屏障计数，那么所有休眠的线程都被唤醒。对于第一个完成工作的线程，pthread_barrier_wait()
    // 返回 PTHREAD_BARRIER_SERIAL_THREAD，剩下的线程看到的返回值是 0 。
    // 这使得一个线程可以作为主线程，它可以工作在其他所有线程已完成的工作结果上。
    //
    // 一旦达到屏障计数值，而且线程处于非阻塞状态，屏障就可以被重用。但是除非在调用了
    // pthread_barrier_destroy() 之后，又调用 pthread_barrier_int() 
    // 对计数器进行初始化，否则屏障计数不会改变。
```

## 只初始化一次

### pthread_once()

```
#include <pthread.h>

#define PTHREAD_ONCE_INIT 0

int pthread_once(pthread_once_t *once, void (*init)(void));
    // 成功返回 0，出错返回错误编码。
    //
    // once - 必须指向初始化为 PTHREAD_ONCE_INIT 的静态变量
```

<span>

```
void init(void) {
    // ...
}

pthread_once_t once = PTHREAD_ONCE_INIT;

if (pthread_once(once, init) != 0)
    errExit("pthread_once");
```

## 线程持有数据

### pthread_key_create()

```
#include <pthread.h>
int pthread_key_create(pthread_key_t *key, void (*destructor)(void *));
    // 创建一个新键，成功返回 0，出错返回错误编码。
    // 因为进程中的所有线程都可使用键 key，所以参数 key 应该指向一个全局变量。
    //
    // key        - 返回的新键
    // destructor - 解构函数，只要线程终止时与 key 的关联值不为 NULL，会自动执行该解构函数，
    //              并将与 key 的关联值作为参数传入解构函数。如果无需结构，可置为 NULL
```

### pthread_getspecific() pthread_setspecific()

```
#include <pthread.h>

void *pthread_getspecific(pthread_key_t key);
      // 获取与 key 关联的数据块，成功返回数据，出错返回 NULL

int pthread_setspecific(pthread_key_t key, const void *value);
    // 设置与 key 关联的数据块，成功返回 0，出错返回错误编码。
```