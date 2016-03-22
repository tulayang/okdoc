[Module locks](http://nim-lang.org/docs/locks.html)                                                
=====================

This module contains Nim's support for locks and condition vars.Low level system locks and condition vars.

这个模块定义了低阶的互斥量（锁）、条件变量，对应 POSIX 多线程的 `pthread_mutex_t` 和 `pthread_cond_t`。属于 system module，不需要显式的导入。抽象了两个类型，用来表述互斥量（锁）和条件变量：`TLock`、`TCond`。包含了初始化锁、销毁锁、抢锁和放开锁的过程：`initLock`、`deinitLock`、`tryAcquire`、`acquire`、`release`，以及控制锁抢放的初始化条件变量、销毁条件变量、等待条件变量和发送信号的过程：`initCond`、`deinitCond`、`wait`、`signal`。


Types
--------

```
THandle  = int
TSysCond = THandle
TLock    = TSysLock      ## Nim 锁; whether this is re-entrant or not is unspecified!
TCond    = TSysCond      ## Nim 条件变量
```

Procs
--------

```
proc initLock(lock: var TLock) {.inline, raises: [], tags: [].}
     ## 初始化给定的锁

proc deinitLock(lock: var TLock) {.inline, raises: [], tags: [].
     ## 释放与给定的锁关联的资源

proc tryAcquire(lock: var TLock): bool {.raises: [], tags: [].}
     ## 尝试获取给定的锁。如果成功返回 true。

proc acquire(lock: var TLock) {.raises: [], tags: [].}
     ## 获取给定的锁。

proc release(lock: var TLock) {.raises: [], tags: [].}
     ## 释放给定的锁

proc initCond(cond: var TCond) {.inline, raises: [], tags: [].}
     ## 初始化给定的条件变量

proc deinitCond(cond: var TCond) {.inline, raises: [], tags: [].}
     ## 释放与给定的条件变量（锁）关联的资源

proc wait(cond: var TCond; lock: var TLock) {.inline, raises: [], tags: [].}
     ## 等待条件变量唤醒

proc signal(cond: var TCond) {.inline, raises: [], tags: [].}
     ## 给等待条件变量唤醒的窗口发送信号
```