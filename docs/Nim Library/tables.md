Module tables                                              
=====================

```
import hashes, math 
```

The tables module implements variants of an efficient hash table (also often named dictionary in other programming languages) that is a mapping from keys to values. Table is the usual hash table, OrderedTable is like Table but remembers insertion order and CountTable is a mapping from a key to its number of occurrences. For consistency with every other data type in Nim these have value semantics(语义学), this means that = performs a copy of the hash table. For reference semantics use the Ref variant: TableRef, OrderedTableRef, CountTableRef.

If you are using simple standard types like int or string for the keys of the table you won't have any problems, but as soon as you try to use a more complex object as a key you will be greeted by a strange compiler error:

```
Error: type mismatch: got (Person)
but expected one of:
hashes.hash(x: openarray[A]): THash
hashes.hash(x: int): THash
hashes.hash(x: float): THash
…
```

What is happening here is that the types used for table keys require to have a hash() proc which will convert them to a THash value, and the compiler is listing all the hash functions it knows. Additionally there has to be a == operator that provides the same semantics(语义学) as its corresponding hash proc.

After you add hash and == for your custom type everything will work. Currently however hash for objects is not defined, whereas system.== for objects does exist and performs a "deep" comparison (every field is compared) which is usually what you want. So in the following example implementing only hash suffices:

```
type
    Person = object
        firstName, lastName: string

proc hash(x: Person): THash =
    ## Piggyback on the already available string hash proc.
    ##
    ## Without this proc nothing works!
    result = x.firstName.hash !& x.lastName.hash
    result = !$result

var
    salaries = initTable[Person, int]()
    p1, p2: Person

p1.firstName = "Jon"
p1.lastName = "Ross"
salaries[p1] = 30_000

p2.firstName = "소진"
p2.lastName = "박"
salaries[p2] = 45_000
```

Types
--------

```
Table[A, B] = object                            ## 泛型哈希表
    data: KeyValuePairSeq[A, B]
    counter: int
TableRef[A, B] = ref Table[A, B]

OrderedTable[A, B] = object                     ## 这个表记忆加入的顺序
    data: OrderedKeyValuePairSeq[A, B]
    counter, first, last: int
OrderedTableRef[A, B] = ref OrderedTable[A, B]

CountTable[A] = object                          ## 这个表计算每个键的数量            
    data: seq[tuple[key: A, val: int]]
    counter: int
CountTableRef[A] = ref CountTable[A]
```

Procs
--------

```
proc rightSize(count: Natural): int {.inline, raises: [], tags: [].}
     ## 返回 initialSize 值，用于计算项。
```

### Table

```
proc len[A, B](t: Table[A, B])   : int
proc len[A, B](t: TableRef[A, B]): int
     ## 获取表中键的数量。

proc `[]`[A, B](t: Table[A, B];    key: A): B
proc `[]`[A, B](t: TableRef[A, B]; key: A): B
     ## 获取 t[key] 的值。如果 key 不在表中，返回一个 B 类型的默认值。使用 hasKey 检查是否存在 key。

proc mget[A, B](t: var Table[A, B]; key: A): var B
proc mget[A, B](t: TableRef[A, B];  key: A): var B
     ## 获取 t[key] 的值。值可以被修改。如果 key 不在表中，抛出 KeyError。

proc mgetOrPut[A, B](t: var Table[A, B]; key: A; val: B): var B
proc mgetOrPut[A, B](t: TableRef[A, B];  key: A; val: B): var B
     ## 获取 t[key] 值（不提供 val），或者加入 val。

proc hasKey[A, B](t: Table[A, B];    key: A): bool
proc hasKey[A, B](t: TableRef[A, B]; key: A): bool
     ## 如果键在表中，返回 true。      

proc hasKeyOrPut[A, B](t: var Table[A, B];    key: A; val: B): bool
proc hasKeyOrPut[A, B](t: var TableRef[A, B]; key: A; val: B): bool
     ## 如果键在表中，返回 true。      

proc `[]=`[A, B](t: var Table[A, B]; key: A; val: B)
proc `[]=`[A, B](t: TableRef[A, B];  key: A; val: B)
     ## 加入 (key, value) 对

proc add[A, B](t: var Table[A, B]; key: A; val: B)
proc add[A, B](t: TableRef[A, B];  key: A; val: B)
     ## 如果键在表中，返回 true。   

proc del[A, B](t: var Table[A, B]; key: A)
proc del[A, B](t: TableRef[A, B];  key: A)
     ## 删除键。   

proc `$`[A, B](t: Table[A, B])   : string
proc `$`[A, B](t: TableRef[A, B]): string
     ## 转换为字符串。

proc `==`[A, B](s, t: Table[A, B])   : bool
proc `==`[A, B](s, t: TableRef[A, B]): bool

proc indexBy[A, B, C](collection: A; index: proc (x: B): C): Table[C, B]
     ## 使用提供的 proc 索引集合。

proc newTableFrom[A, B, C](collection: A; index: proc (x: B): C): TableRef[C, B]
     ## 使用提供的 proc 索引集合

proc initTable[A, B](initialSize = 64): Table[A, B]
     ## 创建一个新的空表。
     ## initialSize 必须是 2 的幂。如果你需要提取运行时的值，可以使用 nextPowerOfTwo 或者 rightSize 。
proc toTable[A, B](pairs: openArray[(A, B)]): Table[A, B]
     ## 创建一个新表，包含给定的键值对。

proc newTable[A, B](initialSize = 64): TableRef[A, B]
     ## 创建一个新的空表。
     ## initialSize 必须是 2 的幂。如果你需要提取运行时的值，可以使用 nextPowerOfTwo 或者 rightSize 。
proc newTable[A, B](pairs: openArray[(A, B)]): TableRef[A, B]
     ## 创建一个新表，包含给定的键值对。     
```

### OrderedTable

```
proc len[A, B](t: OrderedTable[A, B])   : int {.inline.}
proc len[A, B](t: OrderedTableRef[A, B]): int {.inline.}
     ## 获取表中键的数量。

proc `[]`[A, B](t: OrderedTable[A, B];    key: A): B
proc `[]`[A, B](t: OrderedTableRef[A, B]; key: A): B
     ## 获取 t[key] 的值。如果 key 不在表中，返回一个 B 类型的默认值。使用 hasKey 检查是否存在 key。

proc mget[A, B](t: var OrderedTable[A, B]; key: A): var B
proc mget[A, B](t: OrderedTableRef[A, B];  key: A): var B
## 获取 t[key] 的值。值可以被修改。如果 key 不在表中，抛出 KeyError。

proc mgetOrPut[A, B](t: var OrderedTable[A, B]; key: A; val: B): var B
proc mgetOrPut[A, B](t: OrderedTableRef[A, B];  key: A; val: B): var B
     ## 获取 t[key] 值（不提供 val），或者加入 val。

proc hasKey[A, B](t: OrderedTable[A, B];    key: A): bool
proc hasKey[A, B](t: OrderedTableRef[A, B]; key: A): bool
     ## 如果键在表中，返回 true。      

proc hasKeyOrPut[A, B](t: var OrderedTable[A, B];    key: A; val: B): bool
proc hasKeyOrPut[A, B](t: var OrderedTableRef[A, B]; key: A; val: B): bool
     ## 如果键在表中，返回 true。否则加入 value 。

proc `[]=`[A, B](t: var OrderedTable[A, B]; key: A; val: B)
proc `[]=`[A, B](t: OrderedTableRef[A, B];  key: A; val: B)
     ## 加入 (key, value) 对

proc `$`[A, B](t: OrderedTable[A, B])   : string
proc `$`[A, B](t: OrderedTableRef[A, B]): string
     ## 转换为字符串。

proc add[A, B](t: var OrderedTable[A, B]; key: A; val: B)
proc add[A, B](t: OrderedTableRef[A, B];  key: A; val: B)
     ## 加入一个新的 (key, value)，即使 t[key] 已经存在。

proc sort[A, B](t: var OrderedTable[A, B]; cmp: proc (x, y: (A, B)): int)
proc sort[A, B](t: OrderedTableRef[A, B];  cmp: proc (x, y: (A, B)): int)
     ## sorts t according to cmp. This modifies the internal list that kept the insertion
     ## order, so insertion order is lost after this call but key lookup and insertions 
     ## remain possible after sort (in contrast to the sort for count tables).

proc initOrderedTable[A, B](initialSize = 64): OrderedTable[A, B]
     ## 创建一个新的空表。
     ## initialSize 必须是 2 的幂。如果你需要提取运行时的值，可以使用 nextPowerOfTwo 或者 rightSize 。
proc toOrderedTable[A, B](pairs: openArray[(A, B)]): OrderedTable[A, B]
     ## 创建一个新表，包含给定的键值对。

proc newOrderedTable[A, B](initialSize = 64): OrderedTableRef[A, B]
     ## 创建一个新的空表。
     ## initialSize 必须是 2 的幂。如果你需要提取运行时的值，可以使用 nextPowerOfTwo 或者 rightSize 。
proc newOrderedTable[A, B](pairs: openArray[(A, B)]): OrderedTableRef[A, B]
     ## 创建一个新表，包含给定的键值对。

```

### CountTable

```
proc len[A](t: CountTable[A])   : int
proc len[A](t: CountTableRef[A]): int
     ## 获取表中键的数量。

proc `[]`[A](t: CountTable[A];   key: A) : int
proc `[]`[A](t: CountTableRef[A]; key: A): int

proc mget[A](t: var CountTable[A]; key: A): var int
proc mget[A](t: CountTableRef[A];  key: A): var int
     ## 获取 t[key] 的值。值可以被修改。如果 key 不在表中，抛出 KeyError。

proc hasKey[A](t: CountTable[A];    key: A): bool
proc hasKey[A](t: CountTableRef[A]; key: A): bool
     ## 如果键在表中，返回 true。      

proc `[]=`[A](t: var CountTable[A]; key: A; val: int)
proc `[]=`[A](t: CountTableRef[A];  key: A; val: int)
     ## 加入 (key, value) 对

proc `$`[A](t: CountTable[A])   : string
proc `$`[A](t: CountTableRef[A]): string
     
proc sort[A](t: var CountTable[A])
proc sort[A](t: CountTableRef[A])
     ## sorts t according to cmp. This modifies the internal list that kept the insertion
     ## order, so insertion order is lost after this call but key lookup and insertions 
     ## remain possible after sort (in contrast to the sort for count tables).

proc merge[A](s: var CountTable[A]; t: CountTable[A])
proc merge[A](s, t: CountTableRef[A])
     ## 把第二个表合并到第一个中。
proc merge[A](s, t: CountTable[A]): CountTable[A]
     ## 合并两个表，生成一个新表。

proc inc[A](t: var CountTable[A]; key: A; val = 1)
proc inc[A](t: CountTableRef[A];  key: A; val = 1)
     ## 增加值。

proc smallest[A](t: CountTable[A])   : tuple[key: A, val: int]
proc smallest[A](t: CountTableRef[A]): (A, int)
     ## 获取最小键值对。

proc largest[A](t: CountTable[A])   : tuple[key: A, val: int]
proc largest[A](t: CountTableRef[A]): (A, int)
     ## 获取最大键值对。

proc initCountTable[A](initialSize = 64): CountTable[A]
     ## 创建一个新的空表。
     ## initialSize 必须是 2 的幂。如果你需要提取运行时的值，可以使用 nextPowerOfTwo 或者 rightSize 。
proc toCountTable[A](keys: openArray[A]): CountTable[A]
     ## 创建一个新表，包含给定的键值对。

proc newCountTable[A](initialSize = 64): CountTableRef[A]
     ## 创建一个新的空表。
     ## initialSize 必须是 2 的幂。如果你需要提取运行时的值，可以使用 nextPowerOfTwo 或者 rightSize 。
proc newCountTable[A](keys: openArray[A]): CountTableRef[A]
      ## 创建一个新表，包含给定的键值对。
```

Iterators
------------

```
iterator pairs[A, B](t: Table[A, B])          : (A, B)
iterator pairs[A, B](t: TableRef[A, B])       : (A, B)
iterator pairs[A, B](t: OrderedTable[A, B])   : (A, B)
iterator pairs[A, B](t: OrderedTableRef[A, B]): (A, B)
iterator pairs[A]   (t: CountTable[A])        : (A, int)
iterator pairs[A]   (t: CountTableRef[A])     : (A, int)
         ## 迭代表中每一项键值对。

iterator mpairs[A, B](t: var Table[A, B])       : (A, var B)
iterator mpairs[A, B](t: TableRef[A, B])        : (A, var B)
iterator mpairs[A, B](t: var OrderedTable[A, B]): (A, var B)
iterator mpairs[A, B](t: OrderedTableRef[A, B]) : (A, var B)
iterator mpairs[A]   (t: var CountTable[A])     : (A, var int)
iterator mpairs[A]   (t: CountTableRef[A])      : (A, var int)
         ## 迭代表中每一项键值对。并且可以修改。

iterator keys[A, B](t: Table[A, B])          : A
iterator keys[A, B](t: TableRef[A, B])       : A
iterator keys[A, B](t: OrderedTable[A, B])   : A
iterator keys[A, B](t: OrderedTableRef[A, B]): A
iterator keys[A]   (t: CountTable[A])        : A
iterator keys[A]   (t: CountTableRef[A])     : A
         ## 迭代表中每一项键。

iterator values[A, B](t: Table[A, B])          : B
iterator values[A, B](t: TableRef[A, B])       : B
iterator values[A, B](t: OrderedTable[A, B])   : B
iterator values[A, B](t: OrderedTableRef[A, B]): B
iterator values[A]   (t: CountTable[A])        : int
iterator values[A]   (t: CountTableRef[A])     : int
         ## 迭代表中每一项值。

iterator mvalues[A, B](t: var Table[A, B])       : var B
iterator mvalues[A, B](t: TableRef[A, B])        : var B
iterator mvalues[A, B](t: var OrderedTable[A, B]): var B
iterator mvalues[A, B](t: OrderedTableRef[A, B]) : var B
iterator mvalues[A]   (t: CountTable[A])         : var int
iterator mvalues[A]   (t: CountTableRef[A])      : var int
         ## 迭代表中每一项值。并且可以修改。

iterator allValues[A, B](t: Table[A, B]; key: A): B
         ## 迭代表中给出键的每一项值。
```