```
#include <pthread.h>
```

在 Linux 平台，编译时设置 -pthread 选项，等同于 -lpthread 链接。

线程 (pthread_t & thread_attr_t)
--------------------------------
    
    int       pthread_create(pthread_t *thread, 
                             const thread_attr_t *attr, 
                             void *(*f)(void *), 
                             void *arg)                 ⇒ > 0(errno) | 0   // 创建新的线程
    
    void      pthread_exit(void *result)                                   // 退出线程  
    int       pthread_cancel(pthread_t thread)                             // 取消另一个线程
    
    pthread_t pthread_self(void)                                           // 获取自己的线程标识符
    int       pthread_equal(pthread_t1, pthread_t t2)   ⇒ 0 | !0           // 比较两个线程相同
    
    int       pthread_join(pthread_t t, void **result)  ⇒ > 0(errno) | 0  // 等待线程，并获取返回值
    int       pthread_detach(pthread_t t)               ⇒ > 0(errno) | 0  // 等待线程，不获取返回值

互斥量 (pthread_mutex_t & pthread_mutexattr_t)  
----------------------------------------------      

    pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER                                    // 静态初始化
    int pthread_mutex_init(pthread_mutex_t *mutex, 
                           const pthread_mutexattr_t *attr)    ⇒ > 0(errno) | 0          // 动态初始化
    
    int pthread_mutex_destroy(pthread_mutex_t *mutex)          ⇒ > 0(errno) | 0          // 销毁
    
    int pthread_mutex_lock(pthread_mutex_t *mutex)             ⇒ > 0(errno) | 0          // 加锁
    int pthread_mutex_trylock(pthread_mutex_t *mutex)          ⇒ > 0(errno) | error | 0  // 加锁，如果已经锁定，则立刻返回 EBUSY 错误
    int pthread_mutex_timedlock(pthread_mutex_t *mutex,
                                const struct timespec * time)  ⇒ > 0(errno) | 0          // 加锁，可以指定等待锁定的时间   
    int pthread_mutex_unlock(pthread_mutex_t *mutex)           ⇒ > 0(errno) | 0          // 解锁

条件变量 (pthread_cond_t & pthread_condattr_t)     
----------------------------------------------
  
    pthread_cond_t cond = PTHREAD_COND_INITIALIZER                                       // 静态初始化
    int pthread_cond_init(pthread_cond_t *cond,               
                          pthread_condattr_t *attr)            ⇒ > 0(errno) | 0          // 动态初始化

    int pthread_cond_destroy(pthread_cond_t *cond)             ⇒ > 0(errno) | 0          // 销毁
    
    int pthread_cond_wait(pthread_cond_t *cond, 
                          pthread_mutex_t *mutex)              ⇒ > 0(errno) | 0          // 等待条件信号
    int pthread_cond_timedwait(pthread_cond_t *cond, 
                               const struct timespec * time)   ⇒ > 0(errno) | 0          // 等待条件信号 

    int pthread_cond_signal(pthread_cond_t *cond)              ⇒ > 0(errno) | 0          // 发送条件信号，唤醒一个锁定窗口
    int pthread_cond_broadcast(pthread_cond_t *cond)           ⇒ > 0(errno) | 0          // 发送条件信号，唤醒全部锁定窗口
    
    
    
