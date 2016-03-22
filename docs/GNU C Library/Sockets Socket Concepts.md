# [什么是套接字](https://www.gnu.org/software/libc/manual/html_node/Socket-Concepts.html#Socket-Concepts)

创建套接字时，必须指定使用的通信方式---定义了在用户层如何发送数据和接收数据。指定通信方式，如同回答这样的问题：

* **传输的数据，单位是多少？** 一些通信方式把数据作为字节序列；另一些通信方式则把数据打包。

* **正常操作期间，允许丢失数据吗？** 一些通信方式确保所有的数据成功到达目的地（除非系统或网络崩溃）；另一些通信方式偶尔会丢失数据，并且有时送达的包顺序可能是错误的。

  使用不可靠的通信方式，通常会涉及到丢包或包序混乱，为了避免这些错误，需要重发数据。

* **通信是单点的吗？** 一些通信方式像打电话一样---你连接一个远程套接字，然后自由地交换数据。另一些通信方式像邮寄邮件---为发送的每条消息指定一个地址。

此外，必须指定命名空间，以命名套接字。套接字名（“地址”）只在特定的命名空间有意义。实际上，就连套接字名使用的数据类型，可能也依赖命名空间。命名空间也叫“域”，但是我们避免这样叫，因为其他一些技术领域也有“域”这个词---我们不想产生混乱。

最后，必须指定进行通信的协议---协议是基于通信方式而实现的。每个协议只在特定的命名空间和通信方式才有效，因为此，命名空间有时候也称为协议族。

协议的这些规则适用于在两个程序间传输数据，哪怕是不同的机器上。大部分规则是由操作系统处理的，你不需要了解。你需要知道这些：

* 在两个套接字之间通信，必须使用相同的协议。

* 每个协议只在特定命名空间和通信方式有意义，不能混用。比如，TCP 协议只能用在字节流通信，以及因特网命名空间。

* 每个命名空间和通信方式有一个默认协议，只需要指定协议为 `0`。当你需要默认协议时，就可以这么做。

Throughout the following description at various places variables/parameters to denote sizes are required. And here the trouble starts. In the first implementations the type of these variables was simply `int`. On most machines at that time an `int` was 32 bits wide, which created a de facto standard requiring 32-bit variables. This is important since references to variables of this type are passed to the kernel.

Then the POSIX people came and unified the interface with the words "all size values are of type size_t". On 64-bit machines `size_t` is 64 bits wide, so pointers to variables were no longer possible.

The Unix98 specification provides a solution by introducing a type `socklen_t`. This type is used in all of the cases that POSIX changed to use `size_t`. The only requirement of this type is that it be an unsigned type of at least 32 bits. Therefore, implementations which require that references to 32-bit variables be passed can be as happy as implementations which use 64-bit values.  

