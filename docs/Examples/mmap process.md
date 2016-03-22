> 多进程共享互斥锁。对于多进程非阻塞 IO 服务器，使用共享锁同步多进程的套接字 accept() 是性能极佳并防止惊群的有效方式。

### Nim


```

import os, memfiles, posix

var 
    mattr: Pthread_mutexattr 
    mutex: ptr Pthread_mutex
    memfile: MemFile 

memfile = memfiles.open(filename = "/dev/zero", 
                        mode = fmReadWrite, 
                        mappedSize = sizeof(Pthread_mutex))
mutex = cast[ptr Pthread_mutex](memfile.mem)

discard mattr.addr().pthread_mutexattr_init()
discard mattr.addr().pthread_mutexattr_setpshared(PTHREAD_PROCESS_SHARED)
discard mutex.pthread_mutex_init(mattr.addr())

proc childs() =
    var pid = fork()
    if pid == 0:  ## child
        while true:
            echo "\n--- lock ", getpid()
            discard mutex.pthread_mutex_lock()
            echo "    get lock ", getpid()
            sleep(1000)
            echo ">>> unlock ", getpid()
            discard mutex.pthread_mutex_unlock()
            sleep(1000)
            
for i in 0..1: childs()
while true: pause()
```

### C

```
#include <pthread.h>
#include <stdio.h>
#include <fcntl.h>
#include <sys/mman.h>

static pthread_mutex_t *mutex;

void childs() {
	int pid = fork();
	if (pid == 0) {
		for (;;) {
			printf("\n--- lock %d\n", getpid());
			pthread_mutex_lock(mutex);
			printf("    get lock %d\n", getpid());
			sleep(1);
			printf(">>> unlock  %d\n", getpid());
			pthread_mutex_unlock(mutex);
			sleep(1);
		}
	}
}

int main(int arc, char **argv) {
	int fd, i;
	pthread_mutexattr_t mattr;

	fd = open("/dev/zero", O_RDWR, 0);
	mutex = mmap(0, sizeof(pthread_mutex_t), 
		         PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	close(fd);

	pthread_mutexattr_init(&mattr);
	pthread_mutexattr_setpshared(&mattr, PTHREAD_PROCESS_SHARED);
	pthread_mutex_init(mutex, &mattr);

	for (i = 0; i <= 1; i++) {
		childs();
	}

	for (;;) {
		pause();
	}
}
```