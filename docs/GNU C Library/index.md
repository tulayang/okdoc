# [GNU C Library](https://www.gnu.org/software/libc/manual/html_node/index.html)

* [**01.-- Introduction** 关于 GNU C 标准库](/docs/GNU C Library/Introduction.md)

* [**02.-- Error Reporting** 错误报告](/docs/GNU C Library/Error Reporting.md)

* [**03.01 Virtual Memory Allocation And Paging __ Memory Concepts** 什么是进程内存？](/docs/GNU C Library/VM Memory Concepts.md)

* [**03.02 Virtual Memory Allocation And Paging __ Memory Allocation** 内存分配](/docs/GNU C Library/VM Memory Allocation.md)

* [**03.03 Virtual Memory Allocation And Paging __ Resizing the Data Segment** 内存分配器](/docs/GNU C Library/VM Resizing the Data Segment.md)

* [**03.04 Virtual Memory Allocation And Paging __  Locking Pages** 锁住页，防止页面故障](/docs/GNU C Library/VM Locking Pages.md)

* [**11.-- IO Overview** 输入输出的基本概念](/docs/GNU C Library/IO Overview.md)

* [**12.01 IO Streams __ Streams** 什么是流？](/docs/GNU C Library/IO S Streams.md)

* [**12.02 IO Streams __ Standard Streams** 标准流 stdin stdout stderr](/docs/GNU C Library/IO S Standard Streams.md)

* [**12.03 IO Streams __ Opening Streams** 打开流](/docs/GNU C Library/IO S Opening Streams.md)

* [**12.04 IO Streams __ Closing Streams** 关闭流](/docs/GNU C Library/IO S Closing Streams.md)

* [**12.05 IO Streams __ Streams and Threads** 流和多线程](/docs/GNU C Library/IO S Streams and Threads.md)

* [**12.06 IO Streams __ Streams in Internationalized Applications** 流，字符集，国际化](/docs/GNU C Library/IO S Streams in Internationalized Applications.md)

* [**12.07 IO Streams __ Simple Output by Characters or Lines** 流，输出一个字符，输出一行](/docs/GNU C Library/IO S Simple Output by Characters or Lines.md)

* [**12.08 IO Streams __ Character Input** 流，输入一个字符](/docs/GNU C Library/IO S Character Input.md)

* [**12.09 IO Streams __ Line-Oriented Input** 流，输入一行](/docs/GNU C Library/IO S Line-Oriented Input.md)

* [**12.10 IO Streams __ Unreading** 流，压回字符](/docs/GNU C Library/IO S Unreading.md)

* [**12.11 IO Streams __ Block IO** 流，输入一块，输出一块](/docs/GNU C Library/IO S Block IO.md)

* [**12.12 IO Streams __ Formatted Output** 流，格式化输出](/docs/GNU C Library/IO S Formatted Output.md)

* [**12.14 IO Streams __ Formatted Input** 流，格式化输入](/docs/GNU C Library/IO S Formatted Input.md)

* [**12.15 IO Streams __ End-Of-File and Errors** 流，读到尾部？还是出错？](/docs/GNU C Library/IO S End-Of-File and Errors.md)

* [**12.16 IO Streams __ Recovering from errors** 流，从错误中恢复](/docs/GNU C Library/IO S Recovering from errors.md)

* [**12.17 IO Streams __ Text and Binary Streams** 文本流，二进制流](/docs/GNU C Library/IO S Text and Binary Streams.md)

* [**12.18 IO Streams __ File Positioning** 流，文件位置](/docs/GNU C Library/IO S File Positioning.md)

* [**12.19 IO Streams __ Portable File-Position Functions** 流，文件位置，可移植](/docs/GNU C Library/IO S Portable File-Position Functions.md)

* [**12.20 IO Streams __ Stream Buffering** 流，缓冲区](/docs/GNU C Library/IO S Stream Buffering.md)

* [**13.01 IO Low-Level __ Opening and Closing Files** 打开文件，关闭文件](/docs/GNU C Library/IO LL Opening and Closing Files.md)

* [**13.02 IO Low-Level __ Input and Output Primitives** 输入输出，执行最纯粹的读写](/docs/GNU C Library/IO LL Input and Output Primitives.md)

* [**13.03 IO Low-Level __ Setting the File Position of a Descriptor** 设置文件描述符的文件位置](/docs/GNU C Library/IO LL Setting the File Position of a Descriptor.md)

* [**13.04 IO Low-Level __ Descriptors and Streams** 文件描述符和流的那点事](/docs/GNU C Library/IO LL Descriptors and Streams.md)

* [**13.05 IO Low-Level __ Dangers of Mixing Streams and Descriptors** 混合使用流和文件描述符有风险](/docs/GNU C Library/IO LL Dangers of Mixing Streams and Descriptors.md)

* [**13.06 IO Low-Level __ Fast Scatter-Gather IO** 分散-聚集，妈妈再也不用怕我缓冲区不够用了](/docs/GNU C Library/IO LL Fast Scatter-Gather IO.md)

* [**13.07 IO Low-Level __ Fast Memory-mapped IO** 内存映射 IO，输入输出就是这么直接](/docs/GNU C Library/IO LL Memory-mapped IO.md)

* [**13.08 IO Low-Level __ Waiting for Input or Output** select 多路复用](/docs/GNU C Library/IO LL Waiting for Input or Output.md)

* [**13.09 IO Low-Level __ Synchronizing IO operations** 同步，把脏数据写入磁盘](/docs/GNU C Library/IO LL Synchronizing IO operations.md)

* [**13.11 IO Low-Level __ Control Operations on Files** fcntl 控制输入输出的行为](/docs/GNU C Library/IO LL Control Operations on Files.md)

* [**13.12 IO Low-Level __ Duplicating Descriptors** 复制文件描述符](/docs/GNU C Library/IO LL Duplicating Descriptors.md)

* [**13.13 IO Low-Level __ File descriptor flags** 文件描述符标志](/docs/GNU C Library/IO LL File descriptor flags.md)

* [**13.14 IO Low-Level __ File Status Flags** 文件状态标志](/docs/GNU C Library/IO LL File Status Flags.md)

* [**13.15 IO Low-Level __ File Locks** 文件锁，在进程中锁住文件区域](/docs/GNU C Library/IO LL File Locks.md)

* [**13.18 IO Low-Level __ Interrupt-Driven Input** 嗨，有输入或输出到来！](/docs/GNU C Library/IO LL Interrupt-Driven Input.md)

* [**13.19 IO Low-Level __ Generic IO Control operations** ioctl 控制输入输出的行为](/docs/GNU C Library/IO LL Generic IO Control operations.md)

* [**14.00 File System __ Introduction** 文件系统](/docs/GNU C Library/FS Introduction.md)

* [**14.01 File System __ Working Directory** 什么是工作目录？](/docs/GNU C Library/FS Working Directory.md)

* [**14.02 File System __ Accessing Directories** 访问目录](/docs/GNU C Library/FS Accessing Directories.md)

* [**14.03 File System __ Working with Directory Trees** 目录树](/docs/GNU C Library/FS Working with Directory Trees.md)

* [**14.04 File System __ Hard Links** 硬链接](/docs/GNU C Library/FS Hard Links.md)

* [**14.05 File System __ Symbolic Links** 符号链接](/docs/GNU C Library/FS Symbolic Links.md)

* [**14.06 File System __ Deleting Files** 删除文件](/docs/GNU C Library/FS Deleting Files.md)

* [**14.07 File System __ Renaming Files** 重命名文件](/docs/GNU C Library/FS Renaming Files.md)

* [**14.08 File System __ Creating Directories** 创建目录](/docs/GNU C Library/FS Creating Directories.md)

* [**14.09 File System __ File Attributes** 文件属性](/docs/GNU C Library/FS File Attributes.md)

* [**14.10 File System __ Making Special Files** 创建特殊文件](/docs/GNU C Library/FS Making Special Files.md)

* [**14.11 File System __ Temporary Files** 临时文件](/docs/GNU C Library/FS Temporary Files.md)

* [**15.-- Pipes and FIFOs** 管道和命名管道](/docs/GNU C Library/Pipes and FIFOs.md)

* [**16.00 Sockets __ Introduction** 套接字](/docs/GNU C Library/Sockets Introction.md)

* [**16.01 Sockets __ Socket Concepts** 什么是套接字](/docs/GNU C Library/Sockets Socket Concepts.md)

* [**16.02 Sockets __ Communication Styles** 通信方式](/docs/GNU C Library/Sockets Communication Styles.md)

* [**16.03 Sockets __ Socket Addresses** 套接字地址](/docs/GNU C Library/Sockets Socket Addresses.md)

* [**16.04 Sockets __ Interface Naming** 接口命名](/docs/GNU C Library/Sockets Interface Naming.md)

* [**16.05 Sockets __ The Local Namespace** 本机命名空间](/docs/GNU C Library/Sockets The Local Namespace.md)

* [**16.06 Sockets __ The Internet Namespace** 因特网命名空间](/docs/GNU C Library/Sockets The Internet Namespace.md)

* [**16.07 Sockets __ Other Namespaces** 其他命名空间](/docs/GNU C Library/Sockets Other Namespaces.md)

* [**16.08 Sockets __ Opening and Closing Sockets** 打开套接字，关闭套接字](/docs/GNU C Library/Sockets Opening and Closing Sockets.md)

* [**16.09 Sockets __ Using Sockets with Connections** 使用套接字连接](/docs/GNU C Library/Sockets Using Sockets with Connections.md)

* [**16.10 Sockets __ Datagram Socket Operations** 数据报套接字](/docs/GNU C Library/Sockets Datagram Socket Operations.md)

* [**16.11 Sockets __ The inetd Daemon** 守护进程 inetd](/docs/GNU C Library/Sockets The inetd Daemon.md)

* [**16.12 Sockets __ Socket Options** 套接字选项](/docs/GNU C Library/Sockets Socket Options.md)

* [**16.13 Sockets __ Networks Database** 网络数据库](/docs/GNU C Library/Sockets Networks Database.md)

* [**18.-- Syslog** 提交消息，生成日志](/docs/GNU C Library/Syslog.md)

* [**26.00 Processes __ Introduction** 进程](/docs/GNU C Library/Processes Introduction.md)

* [**26.01 Processes __ Running a Command** 运行一条命令](/docs/GNU C Library/Processes Running a Command.md)

* [**26.02 Processes __ Process Creation Concepts** 进程创建的概念](/docs/GNU C Library/Processes Process Creation Concepts.md)

* [**26.03 Processes __ Process Identification** 进程标识](/docs/GNU C Library/Processes Process Identification.md)

* [**26.04 Processes __ Creating a Process** 创建进程](/docs/GNU C Library/Processes Creating a Process.md)

* [**26.05 Processes __ Executing a File** 执行程序](/docs/GNU C Library/Processes Executing a File.md)

* [**26.06 Processes __ Process Completion** 进程结束](/docs/GNU C Library/Processes Process Completion.md)

* [**26.07 Processes __ Process Completion Status** 进程结束状态](/docs/GNU C Library/Processes Process Completion Status.md)

* [**26.08 Processes __ BSD Process Wait Functions** BSD 版本的进程应答函数](/docs/GNU C Library/Processes BSD Process Wait Functions.md)

* [**26.09 Processes __ Process Creation Example** 进程创建例子](/docs/GNU C Library/Processes Process Creation Example.md)

* [**30.00 Users and Groups __ Introduction** 用户和组](/docs/GNU C Library/UG Introduction.md)

* [**30.01 Users and Groups __ User and Group IDs** 用户号和组号](/docs/GNU C Library/UG User and Group IDs.md)

* [**30.02 Users and Groups __ The Persona of a Process** 进程的角色](/docs/GNU C Library/UG The Persona of a Process.md)

* [**30.03 Users and Groups __ 30.3 Why Change the Persona of a Process?** 为什么修改进程的角色？](/docs/GNU C Library/UG Why Change the Persona of a Process.md)

* [**Daemon** 如何编写守护进程？](/docs/GNU C Library/Daemon.md)

* [**Symmary of OS** 操作系统词条](/docs/GNU C Library/Symmary of OS.md)