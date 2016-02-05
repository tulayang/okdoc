1. bool

       • true
       • false

       == != < <= > >= and not or xor   // == != < <= > >=  && ! ||

2. char (1 bytes)

       'a'

       == < <= > >=

       var a = chr(1)                   // 获取字符
       var b = ord('a')                 // 获取整数

3. string ('\0') (UTF8) (二进制文件是字节流) (赋值操作复制整个字符串内容) (可变长度) 

       var x = "abc"
       var y = "a" & "b" & x            // 拼接字符串
       var z = repr(true)               // 获取字符串，任意类型
       var m = r"C:\program files\nim"  // 获取字符串，不转义
       var n = """abc"""                // 获取字符串
       var a = $123456                  // 获取字符串

       y.add("c")                       // 添加字符串

       echo len(a)                      // 6  
       echo a[0]                        // 1
       echo a[1..5]                     // 23456

       a[1..5]  = "a"                   // 修改字符串 1a
       a[1..^`] = "a"                   // 修改字符串 1a

       var z:string = nil               // 初始化为空值 (性能好，不能使用字符串操作，默认)
       var z:string = ""                // 初始化为空值 (性能低，堆中创建对象)

4. int

       int  int8  int16  int32  int64 
       uint uint8 uint16 uint32 uint64 

       + - * / div mod 
       == != < <= > >=
       and not or xor                   // 按位 & ! | 
       shl shr                          // 左移位，右移位

       var x = 0
       var y = 0'i8
       var z = 0'u32

       var a = toInt(0.0)

       // 在表达式中使用不同的整形类型时将会执行自动类型转换
       // 如果类型转换丢失信息，就会抛出 EOutOfRange 异常

5. float

       float float32 float64

       var x = 0.0
       var y = 0.0'f32
       var z = 0.0'f64

       var a = toFloat(0)

       + - * / == != < <= > >=

       // 在表达式使用不同的 float 类型将执行自动类型转换：较小的类型转换成更大的类型
       // 整形不能自动转换为 float 类型，反之亦然

6. enum (有序) (默认 0 1 ...)

       type 
           A = enum
                   a, b, c
           B = enum
                   a = 1, b = 6, c = 9

       var x = A.a
       var y = B.a

7. range (整数、枚举范围) (定义操作范围)

       type
           A = range[0..5]              // 0 ~ 5 整数

8. set (序数) (性能) (固定长度)

       var x:set[char] = {'a'..'z', '0'..'9'}
       echo contains(x, 'e')

       * A + B                          // 连接
       * A * B                          // 交集
       * A - B                          // 差集
       * A == B                         // 相等？
       * A <= B                         // A是B的子集？
       * A < B                          // A是B的子集？
       * e in A                         // A 包含元素 e？ 
       * e notin A                      // A 不包含元素e
       * contains(A, e)                 // A 包含元素e？
       * card(A)                        // A 元素个数
       * incl(A, elem)                  // A 添加一个元素
       * excl(A, elem)                  // A 删除一个元素

9. array (固定长度) (赋值操作复制整个数组内容)

       var x:array[0..5, int] = [1, 2, 3, 4, 5, 6]
       for i in low(x)..high(x):
           echo x[i]

       len(x)
       low(x)
       high(x)
       repr(x)

   <span>

       var x:array[1..10, array[0..5, int]]
       x[1][0] = 1

10. seq (可变长度) (堆分配内存)

        var x:seq[int] = @[1, 2, 3, 4, 5, 6]

        len(x)
        low(x)
        high(x)
        repr(x)

        for i, value in @[1, 2, 3] :
            echo i, " : ", value

        var y:seq[int] = nil             // 初始化为空值 (性能好，不能使用序列操作，默认)
        var y:seq[int] = @[]             // 初始化为空值 (性能低，堆中创建空值)

11. openarray (可变长度) (只能用于参数)

        proc f(x: int, y: varargs[int]) =
            for i, value in y:
                echo i, value
            for value in items(y):
                echo value
            for i in low(y)..high(y):
                echo y[i]

12. tuple (名值对)

        var x: tuple[name: string, age: int]
        x = (name: "xiaoming", age: 30)
        x = ("xiaoming", 30)

        echo x[0]
        echo x.name

        var y: tuple[name: string, age: int]
        y = x

    <span>
    
        import os

            var (dir, name, ext) = splitFile("usr/local/nimc.html")   
            var (x, y, z) = (1, 2, 3)

13. object (继承) (信息隐藏)

        type
            Person = ref object of RootObj  // 继承自 RootObj
                     name : string
                     age  : int
            Student = ref object of Person  // 继承自 Person
                      id  : int

        var p : Person
        p = Person(name: "xiaoming", age: 30)
        assert(p of Person)
        echo p[]
        echo repr p

        var s:Student
        s = Student(name: "xiaoming", age: 30, id: 1)
        assert(s of Student)
        echo s[]
        echo repr s

    <span>

        // ref 地址

        type
            A = object
                name: string
            B = object
                a: ref A

        var a : ref A
        new(a)
        a.name = "xiaoming"
        echo repr a                        // ref 0x7fdd45125050 --> [name = 0x7fdd45126050"xiaoming"]

        var b : ref B
        new(b)
        b.a = a
        echo repr b                        // ref 0x7fdd45125068 --> [a = ref 0x7fdd45125050 --> [name = 0x7fdd45126050"xiaoming"]]

    <span>

        // ptr 地址

        type
            A = object
                name: string
            B = object
                a: ptr A

        var a : A
        a.name = "xiaoming"
        echo repr a                        // [name = 0x7f4ac7c8c050"xiaoming"]

        var b : B
        b.a = addr(a)
        echo repr b                        // [a = ref 0x622ea8 --> [name = 0x7f4ac7c8c050"xiaoming"]]

14. ref ptr (指针)

        nil                                // 空引用
        x[]                                // 解引用

    <span>

    * ref 追踪引用 (自动清除内存) (垃圾收集器)

          var x : ref tuple[name : string, age : int]
          new(x)                          // 创建追踪对象 
          x.name = "xiaoming"
          x.age  = 30 

      <span>

          type 
              A = ref B
              B = object
                  name : string
                  age  : int

          var x : A
          new(x)
          x.name = "xiaoming"

      <span>

          var x : ref object of RootObj  // 继承
              name : string
              age : int

    * ptr 非追踪引用 (手动清除内存) (指向手动在内存中分配的目标)

          alloc()
          dealloc()
          realloc()

      <span>

          proc f(x: var int) = 
              x = 2
          
          var x = 1
          f(x)
          echo x                          // 2

          proc g(x: ptr int) = 
              x[] = 2

          var x = 1
          f(addr(x))
          echo x                          // 2                  

15. proc (过程指针) (default=nil)

        proc print(x: int, y = 1) =
            echo(x, y) 

        proc forEach(f: proc(x: int, y: int)) =
            const a = [1, 2, 3]
            for x, y in a:
                f(x, y)

        forEach(print)

    <span>

        proc each() =
            const a = [1, 2, 3]
            const b = 100
            proc print(x: int, y: int) =
                echo(x, y, b) 
            for x, y in a:
                print(x, y)

        each()

16. iterator (yield)

        iterator f(x: int, y: int): int = 
            var i = x
            while i <= y: 
                yield i
                inc i

        for i in f(0, 6):
            echo i

enum，int，char，bool，range (序数)
------------------------------------

    ord(x)                              // 获取 x 的整型值
    inc(x)                              // ++
    inc(x, n)                           // +n
    dec(x)                              // --
    dec(x, n)                           // -n
    succ(x)                             // 获取 x 下一个值   
    succ(x, n)                          // 获取 x 后第 n 个值
    pred(x)                             // 获取 x 前一个值
    pred(x, n)                          // 获取 x 第前 n 个值

类型转换
--------

    var
        x:int8    = int8('a')
        y:int32   = int32(2.5)
        z:float32 = float32(1)
        
<span>

    proc f(x : Person) : int =
        Student(x).id                   // 非 Student 抛出 InvalidObjectConversionError 异常


type (定义新类型)
-----------------

    type
        A = int64
        B = float64
        C = array[0..100, int]
        D = set[char] 
        E = seq[int]
        F = tuple[id : int, name : string]
        G = object
            id   : int
            name : string
    