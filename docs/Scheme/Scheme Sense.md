
## 安装 （Install）

1. 编译器 (Compiler)
   
       [Petite Chez](http://www.scheme.com/)

       csv
        |_ bin
        |_ boot
        |_ custom
        |    |_ configure
        |    |_ ...
        |_ examples
        |_ Notice
        |_ petite.lic
        |_ ReadMe

2. 安装 （Install）

       【$ sudo aptitude search  libxxx   当缺少链接库时使用】
       【$ sudo aptitude install libxxx   当缺少链接库时使用】
       $ cd custom
       $ ./configure
       $ make install
       $ make
       $ make clean

3. 启动REPL

       $ petite 【"/home/king/test.scm"】

## 数据结构

1. 布尔 （boolean）

       • #t
       • #f

       (boolean?         b)               //  判断 b 是 boolean type

2. 数字 (number)

       • integer         21               //  整型
       • rational        3.14159 22/6     //  有理数
       • real            3.14159 22/6 21  //  实数
       • complex         2+3i             //  复数
       • binary          #b0011           //  2进制
       • octal           #o006            //  8进制
       • hex             #x001F           //  16进制

       (number?          n)               //  判断 n 是 number   type
       (integer?         n)               //  判断 n 是 integer  type
       (rational?        n)               //  判断 n 是 rational type
       (real?            n)               //  判断 n 是 real     type
       (complex?         n)               //  判断 n 是 complex  type
       (exact?           n)               //  判断 n 不是浮点数
       (inexact?         n)               //  判断 n 是浮点数

       (odd?             n)               //  判断 n 是奇数
       (even?            n)               //  判断 n 是偶数
       (positive?        n)               //  判断 n 是正数
       (negative?        n)               //  判断 n 是负数
       (zero?            n)               //  判断 n 是全0

       (=                n1 n2)           //  比较数字
       (>                n1 n2)
       (<                n1 n2)
       (>=               n1 n2)
       (<=               n1 n2)

       (+)                                => 0
       (+ 1 (- 2 0) (/ (* 1 3) 1) 1)      => 7

       (/                9  3)            => 3                  //  整数结果
       (/                2  3)            => 2/3                //  保持
       (quotient         2  3)            => 0                  //  取整
       (exact->inexact   (/ 2 3))         => 0.6666666666666666 //  小数
       (/                3  2)            => 3/2                //  保持
       (quotient         3  2)            => 1                  //  取整
       (exact->inexact   (/ 3 2))         => 1.5                //  小数 

       (modulo           8  10)           => 8                  //  取模
       (modulo           8  -10)          => -2                 //  取模
       (remainder        8  10)           => 8                  //  取余
       (remainder        8  -10)          => 8                  //  取余

       (sin,  cos,  tan, 
        asin, acos, atan 1)                                     //  三角函数

       (max              1  2  3)         => 3
       (min              1  2  3)         => 1
       (abs              3)               => 3
       (abs              -4)              => 4

       (sqrt             9)               => 3                  //  求平方根
       (expt             2  3)            => 8                  //  求幂
       (exp              1)               => 2.718281828459045  //  求指数
       (log              10 10)           => 1.0                //  求对数
       
3. 字符 （char）

       • #\c
       • #\space #\
       • #\tab
       • #\linefeed
       • #\return

       (char?            c)               //  判断 c 是 char type
       (char=?           c1 c2)           //  判断 c1 c2 是相同字符

       (char<?           c1 c2)           //  比较 c1 c2 字符代码的大小
       (char<=           c1 c2)
       (char>            c1 c2) 
       (char>=           c1 c2)

       (char-ci=?        c1 c2)           //  比较 c1 c2 字符代码的大小，对大小写不敏感
       (char-ci<?        c1 c2)
       (char-ci<=?       c1 c2)
       (char-ci>?        c1 c2)
       (char-ci>=?       c1 c2)

       (char-alphabetic? c)               //  判断 c 是字母
       (char-numeric?    c)               //  判断 c 是数字字符
       (char-whitespace? c)               //  判断 c 是空白符
       (char-upper-case? c)               //  判断 c 是大写字母
       (char-lower-case? c)               //  判断 c 是小写字母
       (char-upcase      c)               //  返回 c 对应的大写
       (char-downcase    c)               //  返回 c 对应的小写

       (char->integer    c)               //  转换 c -> 对应的字符代码（character code，整数）
       (integer->char    n)               //  转换 n -> 对应的字符

4. 字符串 （string）

       • "hello"

       (string           #\h #\e #\l 
                         #\l #\o)         //  返回字符组成的字符串 => "hello"
       (make-string      n c)             //  返回 n 个字符 c 组成的字符串，c 可选
       (string-length    s)               //  返回 s 长度

       (string?          s)               //  判断 s 是 string type
       (string=?         s1 s2)           //  判断 s1 s2 是相同字符串

       (string-ref       s  i)            //  返回 s 索引为 i 的字符
       (string-set!      s  i c)          //  设置 s 索引为 i 的字符 -> c
       (substring        s  start end)    //  返回 s 从 start 到 end-1 的子串例如
                                            (substring "abcdefg" 1 4) => "b c d" 
       (string-append    s1 s2 ...)       //  连接 s1 s2 ...
       (string-copy      "abc")           //  返回 s 的副本
       
       (string->number   "16")            //  转换 s -> 数字
       (string->list     "12")            //  转换 s -> 字符构成的表
       (list->string     '(#\\1 #\\2))    //  转换 l -> 字符串
   

5. 向量 （vector）

   * 通过整数索引数据
   * 可以储存不同类型的数据
   * 与表相比，向量更加紧凑且存取时间更短
   * 向量是通过副作用来操作，这样会造成负担

   :

       • '#(0 1 2)                        //  由整数构成的向量
       • '#(a 0 #\a)                      //  由符号、整数、字符构成的向量

       (vector            0  1  2)        //  返回一个向量
       (make-vector       n  o)           //  返回 n 个元素组成的向量，o 可选，默认0
       (vector-length     v)              //  长度

       (vector?           v)              //  判断 v 是 vector type
       
       (vector-ref        v i)            //  返回 v 索引为 i 的元素
       (vector-set!       v i o)          //  设置 v 索引为 i 的元素 -> o
       (vector-fill!      v o)            //  设置 v 的所有元素 -> o

       (vector->list      v)              //  转换 v -> 列表 
       (list->vector      l)              //  转换 l -> 向量

6. 列表 （list）

   Lisp没有指针的原因是因为每一个值，其实概念上来说都是一个指针。当你赋一个值给变量或将这个值存在数据结构中，其实被储存的是指向这个值的指针。当你要取得变量的值，或是存在数据结构中的内容时， Lisp返回指向这个值的指针。

   为了效率的原因， Lisp 有时会选择一个折衷的表示法，而不是指针。举例来说，因为一个小整数所需的内存空间，少于一个指针所需的空间，一个 Lisp 实现可能会直接处理这个小整数，而不是用指针来处理。但基本要点是，程序员预设可以把任何东西放在任何地方。除非你声明你不愿这么做，不然你能够在任何的数据结构，存放任何类型的对象，包括结构本身。

   (cons a d)分配内存空间，一个空间存放指向1的地址car，另一个空间存放指向2的地址cdr。Lisp的惯例是使用car代表列表的第一个元素，而用cdr代表列表的其余的元素。

   * car 寄存器地址部分（Contents of the Address part of the Register）的简称
   * cdr 寄存器减量部分（Contents of the Decrement part of the Register）的简称
   * 这些名字最初来源于：Lisp首次被实现时所使用的硬件环境中内存空间的名字
   * 这些名字表明：**Cons单元的本质就是一个内存空间**
   * cons 术语构造（construction）的简称

   :

       ‘()                                 //  ()      -- 空表
       '(1 . (2))                          //  (1 2)   -- (1->(2))
       '(1 . (2 . (3)))                    //  (1 2 3) -- (1->(2->(3)))

       (set-car!          '((1) 2) 2)      //  ((2) 2)
       (set-cdr!          '((1) 2) 3)      //  ((1) 3)

       (car               '((1 2) 3))      //  (1 2)
       (cdr               '((1 2) 3))      //  (3)

       (caar              '((1 2) 3))      //  1
       (cdar              '((1 2) 3))      //  (2)


       (pare?             p)               //  判断 p 是 pare type （点对）
       (pair?             '(1 . 2))        =>  #t
       (pair?             '(1 2))          =>  #t
       (pair?             '())             =>  #f
       (null?             '())             =>  #t
       (null?             '(1 2))          =>  #f
       (null?             '(1 . 2))        =>  #f
       (list?             l)               //  判断 l 是 list type
       (list?             '(1 2))          =>  #t
       (list?             '(1 . 2))        =>  #f
       
       (cons              o1 o2 ...)       //  返回一个点对（有可能是列表）
       (list              o1 o2 ...)       //  返回一个列表

       (list-ref          l  i)            //  返回 l 索引为 i 的元素
       (list-tail         l  i)            //  返回 l 索引为 i 后的所有元素

7. 符号 （symbol）
   
   * 简单数据类型
   * 简单数据类型都是自运算的，
     如果你在命令提示符后输入了任何类型的数据，运算后会返回和你输入内容是一样的结果
   * symbol被用来作为变量的标识（符），这样可以用于计算变量所承载的值
   
   * this-is-a-symbol
   * i18n
   * <=>
   * $
   * !
   * #
   * *
   * +

   :
   
       'xyz                             //  返回一个符号元素
       (quote             xyz)          //  返回一个符号元素

       (symbol?           sy)           //  判断 sy 是 symbol type

       (string->symbol    str)          //  转换 s -> 符号
       (symbol->string    sym)          //  转换 sy -> 字符串

8. 结构体 （struct）
 
   * 自然分组的数据被称为结构
   * 可以使用Scheme提供的复合数据结构如向量和列表来表示一种结构

   自然分组的数据被称为结构。我们可以使用Scheme提供的复合数据结构如向量和列表来表示一种“结构”。例如：我们正在处理与树木相关的一组数据。数据（或者叫字段field）中的单个元素包括：高度，周长，年龄，树叶形状和树叶颜色共5个字段。这样的数据可以表示为5元向量。这些字段可以利用vector-ref访问，或使用vector-set!修改。尽管如此，我们仍然不希望记忆向量索引编号与字段的对于关系，这将是一个费力不讨好而且容易出错的事情，尤其是随着时间的流逝，一些字段被加进来，而另一些字段会被删掉。

   因此我们使用Scheme的宏defstruct去定义一个结构，基本上你可以把它当作一种向量，不过它提供了很多方法诸如创建结构实例、访问或修改它的字段等等。

9. 哈希表 （hash table）

       (make-hash-table)

       (define ht (make-eq-hashtable))
       (define v (vector 'a 'b 'c))
       (define cell (hashtable-cell ht v 3))
       cell <graphic> (#(a b c) . 3)
       (hashtable-ref ht v 0) <graphic> 3
       (set-cdr! cell 4)
       (hashtable-ref ht v 0) <graphic> 4

10. 过程 （procedure）

    使用代码结构lambda创建自定义过程

       (lambda (x) (+ x 1))
       (lambda (x . z) (+ x 1 (car z) (car (cdr z))))
       (lambda (x) (display "begin") (+ x 1) (display "end") 100)

## 过程 （procedure） 高阶函数

1. 比较 （compare）

       (equal?      '()    '())   => #t  //  比较类似于表或者字符串一类的序列
       (eq?         1      1)     => #t  //  比较两个对象的地址，如果相同的话返回#t
       (eq?         1.0    1.0)   => #f  //  
       (eqv?        1.0    1.0)   => #t  //  比较两个存储在内存中的对象的类型和值，如果相同的话返回#t
       (eqv?        1      1.0)   => #f  //  
       (=           1.0    1.0)   => #t  //  比较两个数字的值，如果相同的话返回#t
       (=           1      1.0)   => #t  //  

       (pair?       '(a))         => #t  //  如果对象为序列则返回#t
       (pair?       '())          => #f
       (list?       '())          => #t  //  如果对象是一个列表则返回#t
       (null?       2)            => #f  //  如果对象是空表’()则返回#t 
       (symbol?     obj)          =>     //  如果对象是一个符号则返回#t

2. 局部作用域 （let letrec）

   * lambda表达式的语法糖，为变量建立了一个作用域
   * 有效域由源代码的编写决定，这叫做词法闭包（lexical closure）

   :

       (let ((x 1) (y 2)) (+ x y))  =>  ((lambda (x y) (+ x y)) 1 2)

       (let ((x 1) (y 2))
         (let ((z 3))
           (+ x y z)))

3. 定义变量 （define）

       (define x 100)
       (define f (lambda (x) (+ x it)))

4. 副作用赋值 （set!）

       (set! x 100)

5. 代码块 （begin）
 
       (begin  (display "1") (display "2") 3)

6. 分支 （if when unless cond）

       (if     (= 1 1)  1  2)
       (when   (= 1 1)  1)
       (unless (= 1 1)  2)
       (cond   ((= 1 1) 1) ((= 1 2) 2) (else 3))

7. 与或非 （and or not）

       (and    #t  1)
       (or     #t  #f)
       (not    #f)

8. 聚合归约 （map reduce）

   * 映射（mapping）
   * 过滤（filtering）
   * 归档（folding）
   * 排序（sorting）

   :

       (sort                  procedure l)
       (sort                  >         '(1 2 3))   => '(3 2 1)
       (map                   procedure l1 l2 ...)
       (for-each              procedure l1 l2 ...)  //  不返回值，用于副作用

       <!-- R5RS未定义，MIT-Scheme提供
       (reduce                procedure l)
       (keep-matching-items   procedure l)
       (delete-matching-items procedure l) -->

9. 借用 （apply）

   * 仅限于求值过程使用, 比如: map, +, ...
   * define, set!, begin, ... 特殊形式不能使用apply

   :

       (apply procedure list)                       //  (procedure ...)
       
       (define square 
         (lambda (x) (* x x)))

       (display "(apply + '(1 2 3)) => ")
       (display  (apply + '(1 2 3)))
       (newline)

       (display "(map square '(1 2 3)) => ")
       (display  (map square '(1 2 3)))
       (newline)

       (display "(apply map (list square '(1 2 3))) => ")
       (display  (apply map (list square '(1 2 3))))
       (newline)

## 列表 结构代码 （list）

1. 二叉树 （binary tree）

       (A (B C) D)
          |   |
          A   ((B C) D)
              |       |
              (B C)   (D)   
              |   |   | |
              B   (C) D ()
                  | |
                  C ()

2. 图元树 （entity tree） 分组 （grouping）

          [    A     ]
         /   /    \   \
       [B]  [C]  [D]  [E]
            /    /  \
          [F]  [G]  [H]
                    /
                  [I]   

        (A B (C F) (D G (H I)) E) 

3. 矩阵 （matrix）

       | 1 2 3 |
       | 4 5 6 |
       | 7 8 9 |

       ((1 2 3) (4 5 6) (7 8 9))

## 异步？ 协程？ （call-with-current-continuation） （call/cc）

`call/cc(call-with-current-cotinuation，调用当前连续)`，这是 scheme 的一个重要特性。scheme 是运行时系统，在程序运行时，解释器在内存中维护着所有的代码。程序存在上下文的联系，语句之间有着紧密的逻辑关系，在一般情况下是顺序执行的，因此它们之间是“连续的”。而 `call/cc` 可以打破这种常规，实现在程序的内存空间中任意跳转的功能。

当在代码的某处调用 `call/cc` 时，产生了一个等待着参数的过程，这个参数是程序在该处之前的过程的内存位置，在参数之后的程序称为“当前连续”。参数可以赋值给一个变量，以便重复使用，也可以直接和当前连续一起求值，一但被求值整个过程就结束。在C语言中，进行循环时可以使用 `break` 中断退出，而 scheme 没有直接提供。利用 `call/cc` 可实现这样的功能。在过程的入口调用 `call/cc`，在需要中途退出的地方，重新调用该过程，通过一求值就跳出的特性，达到 break 的效果。

1. 直接调用
   
       (define m #f)
       (* 2 (+ 1 (call/cc 
            (lambda (f)
       (set! m f)
       (f 1)))))
       (m 2)                              //  6 记忆计算过程，并且中断其他过程
       (m (m 2))                          //  6

2. 放入过程调用，可以制造无限循环（自调用）

       (define i 0)
       (define m #f)
       (define done!
         (lambda ()
           (display "---")
           (display (+ 1 (call/cc
                           (lambda (f)
                             (set! m f)
                             (m 1)))))
           (set! i (+ i 1))
           (display "...")
           (display i)))
       (done!)                             //  ---2...1 记忆从call/cc开始的调用函数栈
       (m 2)                               //  3...2    记忆从call/cc开始的调用函数栈

## 文件输入输出 （file system input output）

1. 输入

       (open-input-file       filename)           //  打开一个文件用于输入，返回输入的端口
       (close-input-port      port)               //  关闭用于输入的端口

       (read                  port)               //  从输入端口中读入下一个符号表达式
       (read-char             port)               //  从输入端口中读取一个字符，当读取到文件结尾（EOF）时，
                                                  //  返回eof-object，你可以使用eof-object?来检查
       (read-line             port)               //  从输入端口中读入下一行数据

       (call-with-input-file  filename procedure) //  打开文件以读取，函数procedure接受
                                                  //  一个输入端口作为参数。文件有可能再次使用，
                                                  //  因此当procedure结束时文件不会自动关闭，
                                                  //  文件应该显式地关闭

       (with-input-from-file  filename procedure) //  将名为filename的文件作为**标准输入**打开，
                                                  //  函数procedure不接受任何参数，
                                                  //  当procedure退出时，文件自动被关闭

2. 输出

       (open-output-file      filename)           //  打开一个文件用作输出，放回输出的端口
       (close-output-port     port)               //  关闭用于输出的端口

       (write                 obj      port)      //  将obj输出至port，字符串被双引号括起而字符
                                                  //  具有前缀#\，
                                                  //  如果port被省略的话，则输出至标准输出
       (display               obj      port)      //  将obj输出至port
       (newline               port)               //  以新行开始
       (write-char            char     port)      //  向port写入一个字符

       (call-with-output-file filename procedure) //  打开文件filename用于输出，并调用过程
                                                  //  procedure，该函数以输出端口为参数

       (with-output-to-file   filename procedure) //  打开文件filename作为标准输出，并调用过程
                                                  //  procedure，该过程没有参数，当控制权从过程
                                                  //  procedure中返回时，文件被关闭

3. 获取标准输入输出端口

       (current-input-port)                       //  获取当前的标准输入端口
       (current-output-port)                      //  获取当前的标准输出端口

4. 加载

       (load                  path)               //  加载文件

5. 普通操作

       (file-exists?          path)               //  判断文件，目录
       (delete-file           path)               //  删除文件
       (file-or-directory-modify-seconds path)    //  返回文件，目录最后修改的时间

## 系统调用 （system calls）

   * 命令成功执行并返回0，它会返回#t
   * 命令执行失败并返回非0值，它会返回#f
   * 命令产生的任何输出都会进入标准的输出

system程序把它的参数字符串当作操作系统命令来执行

    (system "ls")

## 系统环境变量

    (getenv "HOME")
    (getenv "SHELL")

## 系统脚本调用

    ":"//  exec mzscheme $0 "$@"

    (display "Hello, world!")

## 宏 （macro）   

1. 预编译, 宏替换 【模式 -> 预编译替换 -> 生成】
   
       (define-syntax mac
         (syntax-rules ()
           ((mac x ------ y) (+ x y))
           ((mac x y      z) (* x y))))

       (display (mac 1 ------ 2))       //  (+ 1 2) => 3 
       (display (mac 1 2      6))       //  (* 1 6) => 7

       (define-syntax mac
         (syntax-rules (------)         //  ------被忽略, 不匹配过程参数
           ((mac x ------ y) (+ x y))
           ((mac x y      z) (* x y))))

       (display (mac 1 ------ 2))       //  (+ 1 2) => 3
       (display (mac 1 2 6))            //  (* 1 2) => 2

2. 预编译, 宏替换 【(eval, code)解释】

       (define-syntax when
         (syntax-rules ()
           ((when test . branch) 
              (if test
                (eval (cons 'begin 'branch))))))

       (display (when (= 1 1)           //  (if (= 1 1) (begin (display 9) (display 6)))
                   (display 9)          //  => 96#<void>
                  (display 6)))





