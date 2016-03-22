[Module channels](http://nim-lang.org/docs/channels.html)                                                
=====================

Channel support for threads. Note: This is part of the system module. Do not import it directly. To activate thread support you need to compile with the --threads:on command line switch.

Note: The current implementation of message passing is slow and does not work with cyclic data structures.

这个模块定义了低阶的用于线程通信的信道模型。当前版本，channels 的消息传递较慢，并且存在自引用对象时不工作。抽象了一个类型，用于表示通信信道：`TChannel`。包含了创建和销毁信道的过程：`open`、`close`，发送消息和接收消息的过程：`send`、`recv`、`tryRecv`、`peek`，以及检测信道状态的过程：`ready`。

Types
-------

```
TChannel* {.gcsafe.}[TMsg] = TRawChannel    ## a channel for thread communication
```

Procs
--------

```
proc send*[TMsg](c: var TChannel[TMsg]; msg: TMsg)
     ## 发送一个线程一条消息。msg 是深拷贝。

proc recv*[TMsg](c: var TChannel[TMsg]): TMsg
     ## 从一个 channel c 中接受一条消息。这会阻塞，直到受到消息！你可以使用 peek 避免阻塞。

proc tryRecv*[TMsg](c: var TChannel[TMsg]): tuple[dataAvailable: bool, msg: TMsg]
     ## 尝试从一个 channel c 中接受一条消息。如果无效，返回 (false, default(msg)) 。

proc peek*[TMsg](c: var TChannel[TMsg]): int
     ## 从一个 channel c 中返回当前的消息数量。如果 channel 已经关闭，返回 -1。注意: 使用这个 proc 
     ## 有风险，因为他鼓励竞争。最好使用 tryRecv 代替。

proc open*[TMsg](c: var TChannel[TMsg])
     ## 打开一个 channel c，用于线程通信。

proc close*[TMsg](c: var TChannel[TMsg])
     ## 关闭一个 channel c，释放关联的资源。

proc ready*[TMsg](c: var TChannel[TMsg]): bool
     ## 如果在 channel c 中有线程在等待新的消息，返回true。

```