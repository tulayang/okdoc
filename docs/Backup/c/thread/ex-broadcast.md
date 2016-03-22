```
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

/********************* 初始化锁和条件 ********************/

static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;  
static pthread_cond_t  cond  = PTHREAD_COND_INITIALIZER;
static int             c     = 1;

/******************************************************/

void *f(void *arg) {
    pthread_mutex_lock(&mutex);             // 加锁
    while (c) {
        pthread_cond_wait(&cond, &mutex);   // 等待条件信号，解锁 ... (唤醒，加锁)
    }
    c = 0;
    printf("F1 do something.\n");           // .........  
    pthread_mutex_unlock(&mutex);           // 解锁           
}

int main(int argc, char **argv) {

/********************* 启动2个线程 **********************/

    pthread_t t1;
    pthread_t t2;

    pthread_create(&t1, NULL, &f, NULL);
    pthread_create(&t2, NULL, &f, NULL);

/******************* 发送信号，唤醒全部条件 ***************/

    sleep(3);
    c = 0;                           
    pthread_cond_broadcast(&cond);          

/********************* 等待2个线程 **********************/

    pthread_join(t1, NULL);
    pthread_join(t2, NULL);

    exit(0);
}
```