Build Rust
------------

* g++ 4.7 or clang++ 3.x
* python 2.6 or later (but not 3.x)
* GNU make 3.81 or later
* curl
* git

Install Rust
---------------

    $ curl -L https://static.rust-lang.org/rustup.sh | sudo sh

    or

    $ git clone https://github.com/rust-lang/rust.git
    $ cd rust
    $ ./configure [--prefix=/{path}] 
    $ make && make install

Remove Rust
---------------

    $ sudo /usr/local/lib/rustlib/uninstall.sh  
    
Install Cargo
---------------

    $ ./configure [--prefix=/{path}] [--local-rust-root=/{ructc-path}]
    $ make && make install

[→ Cargo](http://doc.crates.io/index.html)<br />
[→ Rust Book ZHN](http://kaisery.gitbooks.io/rust-book-chinese/content/index.html)<br />
[→ Rust Book EN](http://doc.rust-lang.org/stable/book/README.html)<br />
[→ Rust STD](https://doc.rust-lang.org/stable/std/)<br />