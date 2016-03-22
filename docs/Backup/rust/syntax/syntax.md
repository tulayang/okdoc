[Rust Book](https://www.gitbook.com/book/kaisery/rust-book-chinese/details)


Data Type (数据类型)
--------------------

1. bool (布尔)

       • true
       • false

   <span>

      let x:bool = true;

2. char (Unicode 4bytes)

       let x:char = 'x';
       let y:char = '💕';

3. number (数字)

   有符号数采用“补码”表示.

       • i8                //  8位有符号整数
       • i16               // 16位有符号整数
       • i32               // 32位有符号整数
       • i64               // 64位有符号整数
       
       • u8                //  8位无符号整数
       • u16               // 16位无符号整数
       • u32               // 32位无符号整数
       • u64               // 64位无符号整数

       • f32               // 32位单精度浮点数
       • f64               // 64位双精度浮点数
        
       • isize             // 有符号可变长数字
       • usize             // 无符号可变长数字

   <span>

      let x:i32 = 16;

4. str (可变长度字符串)

   * &str
   * string
   
   <span>

       let s     = "Hello";              // 静态分配 &'static str
                                         // 固定大小，不能改变

       let mut s = "Hello".to_string();  // 堆分配内存
                                         // 可变 

       fn foo(s:&str) {
           println!("{}", s);
       }

       fn main() {
           let s = "Hello".to_string();  // 堆分配内存
           foo(&s);                      // 复制地址
       } 

   <span>

       let s = "忠犬ハチ公";

       // 229, 191, 160, 231, 138, 172, 227, 131, 143, 227, 131, 129, 229, 133, 172
       for b in s.as_bytes() {
           print!("{}, ", b);
       }

       // 忠, 犬, ハ, チ, 公
       for c in s.chars() {
           print!("{}, ", c);
       }

       let d = s.chars().nth(1);

   <span>

       let a = "Hello ".to_string();
       let b = "world!";
       let c = a + b;

       let a = "Hello ".to_string();
       let b = "world!".to_string();
       let c = a + &b;

5. array (固定长度列表)

       • [T; N]            // [初始值; 长度]

       let x = [1, 2, 3];
       let y = [0; 20];

       x[0]                // 获取元素
       x.len()             // 获取长度
       x.iter()            // 获取迭代器
        
6. slices (array 指针)

       let x = [1, 2, 3, 4, 5, 6];
       let y = &a[1..3];   // 获取[1][2]地址偏移 (编译器自带边界检查)
  
7. tuples (固定长度多类型列表)

       let x:(i32, &str) = (1, "hello");
           x.0;
           x.1;

       let y = (1, 2);
       let z = (2, 3);
           y = z;

       let (a, b, c) = (1, 'b', "c");

8. vector (矢量数组，堆分配内存)

       let v = vec![1, 2, 3];  // Vec<i32>
       let v = vec![0; 10];    // Vec<i32> 10 个 0

           v[0];

       for i in v      {}
       for i in &v     {}
       for i in &mut v {}

9. function (函数)

       fn foo(x:i32) -> i32 {
           x + 1
       }

       let bar:fn(i32)->i32 = foo;

10. structure (结构)
  
       struct Point {
           x: i32,
           y: i32
       }

       fn main() {
           let origin = Point { x:0, y:0 };
           println!("The origin is at ({}, {})", origin.x, origin.y);

           let mut point = Point { x: 0, y: 0 };
           point.x = 6;
           point = Point { y: 1, .. point };
       }

   <span>

       struct Point(i32, i32);

       fn main() {
           let origin = Point(0, 0);
       }

   <span>

       struct Point;  // 空结构体

   impl (self - &self - &mut self)

       impl Point {
           fn foo(&self, x:i32) -> i32 {
               self.x + x
           }

           fn bar(&self) -> Point {
               Point {
                   x: self.x, 
                   y: self.y + 1
               }
           }

           fn zoo(&mut self, x:i32) -> &mut Point {
               self.x = x + 1;
               self
           }

           fn new(x:i32, y:i32) -> Point {
               Point {
                   x: x, 
                   y: y
               }
           }
       }

       let point = Point {x:0, y:0};
       point.bar().foo(1);

       let origin = Point::new(0, 0);
       origin.bar().foo(1);
       origin.zoo(1).foo(1);

11. enum (枚举)

       enum Message {
           Quit,
           Change(i32, i32, i32),
           Move { x:i32, y:i32 }   
       }

       fn main() {
           let x:Message = Message::Move { x:1, y:1 };
       }
...
-------

1. if

       if x == 5 {
           println!("x is five");
       } else if x == 6 {
           println!("x is six");
       } else {
           println!("x is not five not six");
       }

       let y = if x == 5 {10} else {15};

2. for - break; continue;

       for x in 0..10 {}

3. while - break; continue;

       while x < 10 {}       
       while true   {}
       loop         {}

4. match

       let x = 1;

       match x {
           0 | 1                       => println!("0 or 1"),
           2 ... 6                     => println!("2 ~ 6"),
           e @ 7 ... 9 | e @ 11 ... 16 => println!("{}", e),
           _                           => println!("...")
       }

   <span>

       let x = 1;

       let y = match x {
           1 => "one",
           2 => "two",
           _ => "more"
       } 

   <span>

       let x = '💅';

       match x {
           'a' ... 'j' => println!("early letter"),
           'k' ... 'z' => println!("late letter"),
           _           => println!("something else")
       }

   <span>

       enum Message {
           Quit,
           Change(i32, i32),
           Move { x:i32, y:i32 }
       }

       fn quit() {}
       fn change(r:i32, g:i32, b:i32) {}
       fn move(x:i32, y:i32) {}

       fn f(msg:Message) {
           match msg {
               Message::Quit              => quit(),
               Message::Change(r, g, b)   => change(r, g, b),
               Message::Move { x:x, y:y } => move(x, y)
           };    
       }

   <span>

       enum A {
           Value(i32),
           Missing,
       }

       let x = A::Value(6);

       match x {
           A::Value(i) if i > 2 => println!("Got an int bigger than two!"),
           A::Value(..)         => println!("Got an int!"),
           A::Missing           => println!("No such luck."),
       }

   <span>

       struct Point {
           x:i32,
           y:i32,
       }

       let origin = Point { x:0, y:0 };

       match origin {
           Point { x:x, y:y } => println!("({},{})", x, y)
       }

       match origin {
           Point { x:x, .. } => println!("({})", x)
       }

   <span>

       match x {
           Foo { x:Some(ref name), y:None } => println!("{}", x)
       }

Mutable
--------

    let mut x = 1;
    let     y = &x;      // 只读
    
<span>
    
    let mut x = 1;
    let     y = &mut x;  // 可写
           *y = 2;
    
<span>
  
    
    let mut x = 1;
    let mut y = &mut x;  // 可写可变
           *y = 2;
            y = &6;
            
<span>

    let (mut x, y) = (1, 2);
    
    fn foo(mut x:i32) {
    }
    
    fn foo(x:&mut i32) {
    }

Owenship
----------

```
fn f<'a>(x:&'a mut i32) {
}

fn args<T:ToCStr>(&mut self, args: &[T]) -> &mut Command {
}
fn args<'a, 'b, T:ToCStr>(&'a mut self, args: &'b [T]) -> &'a mut Command {
}
```

Option<T> (泛型)
----------------

    enum Option<T> {
        Some(T),
        None
    }

    let x:Option<i32> = Some(6);  // Option<i32>

<span>
 
     struct Point<T> {
         x:T,
         y:T
     }

     let a = Point { x:0,   y:0 };
     let b = Point { x:0.0, y:0.0 };

<span>

    fn foo<T, U>(x:T, y:U) {
        println!("{}, {}", x, y);
    }    

    foo(1:i32, 2.0:f64);

Trait (接口)
-------------
    
    trait Area {
        fn f(&self) -> i32;
    }

    struct Point {
        x:i32,
        y:i32
    }

    impl Area for Point {
        fn f(&self) -> i32 {
            self.x + self.y
        }
    }

    struct Square {
        x:i32,
        y:i32
    }

    impl Area for Square {
        fn f(&self) -> i32 {
            self.x - self.y
        }
    }

    fn foo<T:Area>(shape:T) {
        println!("{}", shape.f());
    } 

    let a = Point  {x:1, y:1};
    let b = Square {x:1, y:1};
    foo(a);                     // 编译时生成多个副本
    foo(b);

<span>

    trait Debug {
        fn g(&self) -> i32;
        fn h($sefl) {
            println!("101");
        }
    }

    fn bar<T:Area + Debug>(shape:T) {
        println!("{}", shape.f());
        println!("{}", shape.g());
    }

<span>

    trait C:Area {
        fn ff(&self) -> i32;
    }

<span>

    fn foo(shape:&Area) {
        shape.f();
    } 

    let a = Point {x:1, y:1};
    foo(&a as &Area);           // 运行时类型转换

<span>

    trait Foo {
        fn f(&self);
    }

    trait Bar {
        fn f(&self);
    }

    struct Baz;

    impl Foo for Baz {
        fn f(&self) { println!("Baz’s impl of Foo"); }
    }

    impl Bar for Baz {
        fn f(&self) { println!("Baz’s impl of Bar"); }
    }

    let a = Baz;
    Foo::f(&a);
    Bar::f(&a);
    <Baz as Foo>::f(&a);
    <Baz as Bar>::f(&a);

lambda
---------

    let f = |x:i32| x + 1;
    let g = |x:i32| {
        let y = 2;
        x + y
    };

    let a = 5;
    let f = move |x:i32| x + a;
    f(5);                        // a = 10

    let mut a = 5;
    { 
        let mut f = move |x:i32| a += x;
        f(5);                    // a = 10
    }
    a;                           // a = 5 

<span>

    fn foo<F:Fn(i32)->i32>(f:F) -> i32 {
        f(1)
    }

    let a = foo(|x| x + 2);      // 静态分发，栈分配内存

<span>

    fn foo(f: &Fn(i32)->i32) -> i32 {
        f(1)
    }

    let a = foo(&|x| x + 2);     // & 动态分发，堆分配内存

<span>

    fn f() -> Box(Fn(i32)->Vec<i32>) {
        let vec = vec![1, 2, 3];

        Box::new(move |n| vec.push(n))
    }

    let g = f();
    let a = f(4);

    assert_eq!(vec![1, 2, 3, 4], a);

crate module (模块)
----------------------
    
    +---------+
    | phrases |
    +---------+
         |     +---------+
         |-----| english |
         |     +---------+
         |          |     +-----------+
         |          |-----| greetings |
         |          |     +-----------+
         |          |     +-----------+
         |          |-----| farewells |
         |                +-----------+
         |     +----------+
         |-----| japanese |
               +----------+
                    |     +-----------+
                    |-----| greetings |
                    |     +-----------+
                    |     +-----------+
                    |-----| farewells |
                          +-----------+
         
     $ cargo new phrases
     $ cd phrases
     $ vi src/lib.rs

          pub mod english {
              pub mod greetings {

              }
              pub mod farewells {

              }
          }

          pub mod japanese {
              pub mod greetings {

              }
              pub mod farewells {

              }
          }

          or

          pub mod english;        // english.rs  | english/mod.rs
          pub mod japanese;       // japanese.rs | japanese/mod.rs

     $ cargo build
       Compiling phrases v0.0.1 (file:///home/you/projects/phrases)

     $ tree .

            .
            ├── Cargo.lock
            ├── Cargo.toml
            ├── src
            │   ├── english
            │   │   ├── farewells.rs
            │   │   ├── greetings.rs
            │   │   └── mod.rs
            │   ├── japanese
            │   │   ├── farewells.rs
            │   │   ├── greetings.rs
            │   │   └── mod.rs
            │   └── lib.rs
            └── target
                └── debug
                    ├── build
                    ├── deps
                    ├── examples
                    ├── libphrases-a7448e02a0468eaa.rlib
                    └── native

    $ vi main.rs

         extern crate phrases;

         use phrases::english::greetings;

         fn main() {
             phrases::english::greetings::foo();
             phrases::english::farewells::bar();
             phrases::japanese::greetings::foo();
             phrases::japanese::farewells::bar();
             greetings:foo();
         }

type
-------

    type Num = i32;
    let x:i32 = 5;
    let y:Num = 5;
    x == y;              // true

<span>

    type Result<T> = std::result::Result<T, ConcreteError>;




    