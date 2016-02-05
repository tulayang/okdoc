Makefile
--------

1. 安装

       $ ./configure --prefix=/usr/local/test
       $ make
       $ make install
       $ make clean 

2. 语法

       target（要生成的文件）: dependencies（被依赖的文件）
           命令1
           命令2
           命令3
           .
           .
           .
           命令n

3. 示例

       CC         = gcc
       GLIB_S     = `pkg-config --cflags --libs glib-2.0`
       CMOCKERY_I = -I/usr/local/cmockery/include/google
       CMOCKERY_L = -L/usr/local/cmockery/lib

       test-common: common.o test-common.o
           $(CC) common.o test-common.o\
                 -o test-common\
                 ${GLIB_S}\
                 -lcmockery\
                 -g

       test-common.o: test-common.c
           $(CC) -c test-common.c\
                 -o test-common.o\
                 ${CMOCKERY_I}\
                 ${CMOCKERY_L}\
                 -g 

       common.o: ../common.h ../common.c 
           $(CC) -c ../common.c\
                 -o common.o\
                 ${GLIB_S}\
                 -g
                 
动态库
-----

* -fPIC
* -shared
* -O2           # 优化级别

example:

```
$ gcc -fPIC -c file1.c
$ gcc -fPIC -c file2.c
$ gcc file1.o file2.o -shared libxxx.so
$ gcc test.c -o test -L. -lxxx

  export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH
```

注释
----

 http://www.linuxidc.com/Linux/2011-03/33432.htm

 一般来说，如果库的头文件不在 /usr/include 目录中，那么在编译的时候需要用 -I 参数指定其路径。由于同一个库在不同系统上可能位于不同的目录下，用户安装库的时候也可以将库安装在不同的目录下，所以即使使用同一个库，由于库的路径的 不同，造成了用 -I 参数指定的头文件的路径也可能不同，其结果就是造成了编译命令界面的不统一。如果使用 -L 参数，也会造成连接界面的不统一。编译和连接界面不统一会为库的使用带来麻烦。

 为了解决编译和连接界面不统一的问题，人们找到了一些解决办法。其基本思想就是：事先把库的位置信息等保存起来，需要的时候再通过特定的工具将其中有用的 信息提取出来供编译和连接使用。这样，就可以做到编译和连接界面的一致性。其中，目前最为常用的库信息提取工具就是下面介绍的 pkg-config。

 pkg-config 是通过库提供的一个 .pc 文件获得库的各种必要信息的，包括版本信息、编译和连接需要的参数等。这些信息可以通过 pkg-config 提供的参数单独提取出来直接供编译器和连接器使用。

 在默认情况下，每个支持 pkg-config 的库对应的 .pc 文件在安装后都位于安装目录中的 lib/pkgconfig 目录下。

 使用 pkg-config 的 --cflags 参数可以给出在编译时所需要的选项，而 --libs 参数可以给出连接时的选项。

 库文件在连接（静态库和共享库）和运行（仅限于使用共享库的程序）时被使用，其搜索路径是在系统中进行设置的。一般 Linux 系统把 /lib 和 /usr/lib 两个目录作为默认的库搜索路径，所以使用这两个目录中的库时不需要进行设置搜索路径即可直接使用。对于处于默认库搜索路径之外的库，需要将库的位置添加到 库的搜索路径之中。设置库文件的搜索路径有下列两种方式，可任选其一使用：

* 在环境变量 LD_LIBRARY_PATH 中指明库的搜索路径
* 在 /etc/ld.so.conf 文件中添加库的搜索路径

ldconfig，简单的说，它的作用就是将/etc/ld.so.conf列出的路径下的库文件 缓存到/etc/ld.so.cache 以供使用。因此当安装完一些库文件，(例如刚安装好glib)，或者修改ld.so.conf增加新的库路径后，需要运行一下/sbin/ldconfig使所有的库文件都被缓存到ld.so.cache中，如果没做，即使库文件明明就在/usr/lib下的，也是不会被使用的，结果编译过程中抱错，缺少xxx库。

 在程序连接时，对于库文件（静态库和共享库）的搜索路径，除了上面的设置方式之外，还可以通过 -L 参数显式指定。因为用 -L 设置的路径将被优先搜索，所以在连接的时候通常都会以这种方式直接指定要连接的库的路径。