```
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

/********************* 初始化锁和条件 ********************/

static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;  
static pthread_cond_t  cond  = PTHREAD_COND_INITIALIZER;

/******************************************************/

void *f(void *arg) {
    pthread_mutex_lock(&mutex);             // 抢锁，保证每个锁都有机会收到信号
    pthread_cond_wait(&cond, &mutex);       // 解锁，等待条件信号 ... (唤醒，抢锁)
    printf("F1 do something.\n");           // .........  
    pthread_mutex_unlock(&mutex);           // 解锁           
}

int main(int argc, char **argv) {

/********************* 启动2个线程 **********************/

    pthread_t t1;
    pthread_t t2;

    pthread_create(&t1, NULL, &f, NULL);
    pthread_create(&t2, NULL, &f, NULL);

/******************* 发送信号，唤醒一个条件 ***************/

    sleep(3);
    pthread_mutex_lock(&mutex);             // 抢锁
    pthread_cond_signal(&cond);             // 发送信号
    pthread_mutex_unlock(&mutex);           // 解锁

/********************* 等待2个线程 **********************/

    pthread_join(t1, NULL);
    pthread_join(t2, NULL);

    exit(0);
}
```