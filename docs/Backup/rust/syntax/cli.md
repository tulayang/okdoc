    $ rustc --version                       // 显示版本号
    
    $ rustc test.rs                         // 编译源文件
    $ cargo build [--release]               // 使用 Cargo 编译源文件 [开启优化]
            
            • Cargo.toml
            
                  [package]

                  name    = "hello_world"
                  version = "0.0.1"
                  authors = [ "Your name " ]

    $ cargo run                             // 使用 Cargo 运行
    $ cargo new myapp --bin                 // 使用 Cargo 建立新项目
            
            myapp
              ├── Cargo.toml
              └── src
                   └── main.rs
                    
    $ cargo test                            // 使用 Cargo 运行测试函数
    
            #[cfg(test)]
            mod tests {
                use super::*;

                #[test]
                #[should_panic(expected = "assertion failed")]
                fn test_a() {
                    assert!(false);
                }

                #[test]
                fn test_b() {
                    assert_eq!(1, 2);
                }
            }