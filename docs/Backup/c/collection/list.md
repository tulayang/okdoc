```
#include "list.h"
```

List (列表)
-----------

```
#ifndef _CODE_LIST_H
#define _CODE_LIST_H 

// #define NULL         ((void *) 0x0) 
#define LIST_POISON1 ((void *) 0x00100100)
#define LIST_POISON2 ((void *) 0x00200200)

struct list_head {
    struct list_head *next;
    struct list_head *prev;
};

#define LIST_HEAD_INITIALIZER(name) { &(name), &(name) }  

static inline void list_head_init(struct list_head *want) {
    want->prev = want;
    want->next = want;
}

static inline void __list_add(struct list_head *prev, 
                              struct list_head *next,
                              struct list_head *want) {
    want->prev = prev;
    want->next = next;
    prev->next = want;
    next->prev = want;
}

static inline void list_add(struct list_head *head, struct list_head *want) {
    __list_add(head, head->next, want);
}

static inline void list_add_tail(struct list_head *head, struct list_head *want) {
    __list_add(head->prev, head, want);
}

static inline void __list_del(struct list_head * prev, struct list_head * next)
{
    next->prev = prev;
    prev->next = next;
}

static inline void list_del(struct list_head *want) {
    __list_del(want->prev, want->next);
    want->next = LIST_POISON1;
    want->prev = LIST_POISON2;
}

static inline void list_replace(struct list_head *old, struct list_head *want) {
    want->next      = old->next;
    old->next->prev = want;
    want->prev      = old->prev;
    old->prev->next = want;
}

static inline int list_is_last(const struct list_head *head,
                               const struct list_head *want) {
    return want->next == head;
}

static inline int list_is_empty(const struct list_head *head) {
    return head->next == head && head->prev == head;
}

#define container_of(ptr, type, member) ({                     \
        const typeof( ((type *)0)->member ) *__mptr = (ptr);   \
        (type *)( (char *)__mptr - offsetof(type, member) );   \
    })

#define list_container(ptr, type, member) \
    container_of(ptr, type, member)

#define list_first_container(ptr, type, member) \
    list_container((ptr)->next, type, member)

#define list_last_container(ptr, type, member) \
    list_container((ptr)->prev, type, member)

#define list_first_container_or_null(ptr, type, member) \
    (!list_is_empty(ptr) ? list_first_container(ptr, type, member) : NULL)

#define list_for_each(pos, head) \
    for (pos = (head)->next; pos != (head); pos = pos->next)

#define list_for_each_reverse(pos, head) \
    for (pos = (head)->prev; pos != (head); pos = pos->prev)

#define list_for_each_safe(pos, n, head)                   \
    for (pos = (head)->next, n = pos->next; pos != (head); \
        pos = n, n = pos->next)

#define list_for_each_safe_reverse(pos, n, head) \
    for (pos = (head)->prev, n = pos->prev;      \
         pos != (head);                          \
         pos = n, n = pos->prev)

#define list_for_each_container(pos, head, member)                           \
    for (pos = list_first_container(head, typeof(*pos), member);             \
         &pos->member != (head);                                             \
         pos = list_container((pos)->member.next, typeof(*(pos)), member))

#define list_for_each_container_reverse(pos, head, member)                   \
    for (pos = list_last_container(head, typeof(*pos), member);              \
         &pos->member != (head);                                             \
         pos = list_container((pos)->member.prev, typeof(*(pos)), member))

#define list_for_each_container_safe(pos, n, head, member)                   \
    for (pos = list_first_container(head, typeof(*pos), member),             \
         n = list_container((pos)->member.next, typeof(*(pos)), member);     \
         &pos->member != (head);                                             \
         pos = n, n = list_container((n)->member.next, typeof(*(n)), member))

#define list_for_each_container_safe_reverse(pos, n, head, member)           \
    for (pos = list_last_container(head, typeof(*pos), member),              \
         n = list_container((pos)->member.prev, typeof(*(pos)), member);     \
         &pos->member != (head);                                             \
         pos = n, n = list_container((n)->member.prev, typeof(*(n)), member))
         
```

HList (哈希列表)
---------------

```

/*
 * Double linked lists with a single pointer list head.
 * Mostly useful for hash tables where the two pointer list head is
 * too wasteful.
 * You lose the ability to access the tail in O(1).
 */

struct hlist_head {
    struct hlist_node *first;
};

struct hlist_node {
    struct hlist_node *next, **pprev;
};

#define HLIST_HEAD_INITIALIZER { .first = NULL }

static inline void hlist_node_init(struct hlist_node *want) {
    want->next  = NULL;
    want->pprev = NULL;
}

static inline int hlist_is_unhashed(const struct hlist_node *want) {
    return !want->pprev;
}

static inline int hlist_is_noempty(const struct hlist_head *head) {
    return !head->first;
}

static inline void __hlist_del(struct hlist_node *want) {
    struct hlist_node *next   = want->next;
    struct hlist_node **pprev = want->pprev;
    if (pprev) {
        *pprev = next;
    }
    if (next) {
        next->pprev = pprev;
    }
}

static inline void hlist_del(struct hlist_node *want) {
    __hlist_del(want);
    want->next  = LIST_POISON1;
    want->pprev = LIST_POISON2;
}

static inline void hlist_add_head(struct hlist_head *head, struct hlist_node *want) {
    struct hlist_node *first = head->first;
    want->next = first;
    if (first) {
        first->pprev = &want->next;
    }
    head->first = want;
    want->pprev = &head->first;
}

/* next must be != NULL */
static inline void hlist_add_before(struct hlist_node *next, 
                                    struct hlist_node *want) {
    want->pprev    = next->pprev;
    want->next     = next;
    next->pprev    = &want->next;
    *(want->pprev) = want;
}

static inline void hlist_add_behind(struct hlist_node *prev, 
                                    struct hlist_node *want) {
    want->next  = prev->next;
    prev->next  = want;
    want->pprev = &prev->next;
    if (want->next) {
        want->next->pprev = &want->next;
    }
}

static inline void hlist_add_fake(struct hlist_node *want) {
    want->pprev = &want->next;
}

static inline void hlist_move_list(struct hlist_head *old,
                                   struct hlist_head *want) {
    want->first = old->first;
    if (want->first) {
        want->first->pprev = &want->first;
    }
    old->first = NULL;
}

#define hlist_container(ptr, type, member) container_of(ptr,type,member)

#define hlist_for_each(pos, head) \
    for (pos = (head)->first; pos ; pos = pos->next)

#define hlist_for_each_safe(pos, n, head)                     \
    for (pos = (head)->first; pos && ({ n = pos->next; 1; }); \
         pos = n)

#define hlist_container_safe(ptr, type, member)                 \
    ({ typeof(ptr) ____ptr = (ptr);                             \
       ____ptr ? hlist_container(____ptr, type, member) : NULL; \
    })

#define hlist_for_each_container(pos, head, member)                             \
    for (pos = hlist_container_safe((head)->first, typeof(*(pos)), member);     \
         pos;                                                                   \
         pos = hlist_container_safe((pos)->member.next, typeof(*(pos)), member))

#define hlist_for_each_container_safe(pos, n, head, member)                      \
    for (pos = hlist_container_safe((head)->first, typeof(*pos), member);        \
         pos && ({ n = pos->member.next; 1; });                                  \
         pos = hlist_container_safe(n, typeof(*pos), member))

#endif



```