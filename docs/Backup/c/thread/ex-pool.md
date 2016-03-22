
pool.h
-------

```
#ifndef _CODE_POOL_H
#define _CODE_POOL_H 

#include <pthread.h>
#include "./list.h"

#define MAX 3

struct handler {
	void              (*callback)(void *);
	void             *arg;
	struct list_head  list;
};

struct pool {
	pthread_mutex_t  mutex;
	pthread_cond_t   cond;
	pthread_t        threads[MAX];
	struct list_head event;
};

struct pool *pool_alloc();
int pool_add(struct pool *pool, void (*callback)(void *), void *arg);
int pool_join(struct pool *pool);

#define pool_signal(pool) pthread_cond_signal(&(pool)->cond)

#endif
```

pool.c
-------

```
#include <stdlib.h>
#include "./pool.h"
#include "./xmalloc.h"

static int pool_emit(struct pool *pool) {
	struct list_head *event = &pool->event;
	struct list_head *curr;
	struct handler   *handler;
	list_for_each(curr, event) {
		handler = list_container(curr, struct handler, list);
		handler->callback(handler->arg);
	}
	return 0;
}

static void *pool_wait(void *arg) {
	struct pool *pool = (struct pool*)arg;
	for (;;) {
		pthread_mutex_lock(&pool->mutex);              // 加锁
		pthread_cond_wait(&pool->cond, &pool->mutex);  // 等待条件信号，解锁 ... (唤醒，加锁)
		pthread_mutex_unlock(&pool->mutex);            // 解锁  
		pool_emit(pool);
	}
}

struct pool *pool_alloc() {
	int          i;
	struct pool *pool = xmalloc(sizeof(struct pool));
	pthread_mutex_init(&pool->mutex, NULL);
	pthread_cond_init(&pool->cond, NULL);
	list_head_init(&pool->event);
	for (i = 0; i < MAX; i++) {
		pthread_create(&pool->threads[i], NULL, &pool_wait, pool);
	}
	return pool;
}

int pool_free(struct pool *pool) {
	struct list_head *event = &pool->event;
	struct list_head *pos;
	struct list_head *n;
	struct handler   *handler;
	list_for_each_safe(pos, n, event) {
		handler = list_container(pos, struct handler, list);
		xfree(handler);
	}
	xfree(pool);
	return 0;
}

int pool_add(struct pool *pool, void (*callback)(void *), void *arg) {
	struct handler *handler = malloc(sizeof(struct handler));
	handler->callback = callback;
	handler->arg = arg; 
	list_add_tail(&pool->event, &handler->list);
	return 0;
}

int pool_join(struct pool *pool) {
	int i;
	for (i = 0; i < MAX; i++) {
		pthread_join(pool->threads[i], NULL);
	}
}
```

test-pool.h
------------

```
#include <stdio.h>
#include <stdlib.h>
#include "../src/pool.h"

void f1(void *arg) {
	printf("f1 doing ...\n");
}
void f2(void *arg) {
	printf("f2 doing ...\n");
}
void f3(void *arg) {
	printf("f3 doing ...\n");
}

int main(int argc, char **argv) {
	struct pool *pool = pool_alloc();

/********************* 添加事件处理器 ********************/

	pool_add(pool, &f1, NULL);
	pool_add(pool, &f2, NULL);
	pool_add(pool, &f3, NULL);

/********************* 发送条件信号 *************×*******/

	sleep(3);
	pool_signal(pool);
	pool_signal(pool);
	pool_signal(pool);

/********************* 等待线程结束 *********************/

	pool_join(pool);
	pool_free(pool);

	exit(0);
}


```