♈ 内联函数 (pointer & static inline)
---------------------------------

    typedef struct node Node;
    struct node {
        Node  *next;
        Node **prevNext;    //  prevNext node1.next 地址
                            // *prevNext node1.next 保存的值 == node2 地址
    };
    
    static inline __setNode(Node *prev, Node *next, Node *want) {
        want->prevNext = &prev->next;
        want->next     = next;
        prev->next     = want;
        next->prevNext = &want->next;
    }
    

♈ 内存地址 (typeof & containerOf)
-------------------------------

    typeof(foo)                                                    // 可以是普通数据、地址、...
    
<span>
    
    #define offsetof(TYPE, MEMBER) ((size_t)&((TYPE *)0)->MEMBER)  // TYPE结构中MEMBER的地址偏移量 
	#define containerOf(ptr, type, member) ({                      \
            const typeof( ((type *)0)->member ) *__mptr = (ptr);   \
            (type *)( (char *)__mptr - offsetof(type, member) );   \
        })
    
♈ {...} & do {...} while(0)
--------------------------

    int f() {
      // ...
      do {
          if (fd    = open(...))  break;
          if (rsize = read(...))  break;
          if (wsize = weite(...)) break;
          // ...
          return 1;
      } while (0)
      
      printf("error, f()");
      exit(1);
    }
    
<span>

    #define g(x, y) { x = 1; y = 1; }
    #define f(x, y) do { x = 1; y = 1; } while(0)
    
    if (1)
        f(x, y);
    else 
        printf("not true")

♈ 多平台编译 (compile multi platform)
------------------------------------

多文件引用同一个头文件，并被编译成一个文件时，使头文件内容只被包含一次<br />
针对不同的操作系统导入不同的头文件

    #ifndef __CONFIG_H
    #define __CONFIG_H
    
    #ifdef __APPLE__                      // Apple 系统
    #include <AvailabilityMacros.h>        
    #endif
    
    #ifdef __linux__                      // Linux 系统
    #include <linux/version.h>
    #include <features.h>
    #endif
    
    #if defined(__APPLE__) && !defined(MAC_OS_X_VERSION_10_6)
    #define redis_fstat fstat64
    #define redis_stat  stat64
    #else
    #define redis_fstat fstat
    #define redis_stat  stat
    #endif
    
    #ifdef __linux__
    #define HAVE_PROC_STAT 1
    #define HAVE_PROC_MAPS 1
    #define HAVE_PROC_SMAPS 1
    #define HAVE_PROC_SOMAXCONN 1
    #endif
    
    #if defined(__APPLE__)
    #define HAVE_TASKINFO 1
    #endif
    
    ......
    
    #endif
    
数值替换
     
    #if   defined(HAVE_MALLOC_SIZE)               
    #define PREFIX_SIZE (0)
    #elif defined(__sun) || defined(__sparc) || defined(__sparc__)
    #define PREFIX_SIZE (sizeof(long long))
    #else
    #define PREFIX_SIZE (sizeof(size_t))
    #endif
    
版本替换
    
    #if   defined(__ATOMIC_RELAXED)
    #define update_zmalloc_stat_add(__n) __atomic_add_fetch(&used_memory, (__n), __ATOMIC_RELAXED)
    #define update_zmalloc_stat_sub(__n) __atomic_sub_fetch(&used_memory, (__n), __ATOMIC_RELAXED)
    #elif defined(HAVE_ATOMIC)
    #define update_zmalloc_stat_add(__n) __sync_add_and_fetch(&used_memory, (__n))
    #define update_zmalloc_stat_sub(__n) __sync_sub_and_fetch(&used_memory, (__n))
    #else
    #define update_zmalloc_stat_add(__n) do {     \
        pthread_mutex_lock(&used_memory_mutex);   \
        used_memory += (__n);                     \
        pthread_mutex_unlock(&used_memory_mutex); \
    } while(0)  
    #define update_zmalloc_stat_sub(__n) do {     \
        pthread_mutex_lock(&used_memory_mutex);   \
        used_memory -= (__n);                     \
        pthread_mutex_unlock(&used_memory_mutex); \
    } while(0)
    #endif