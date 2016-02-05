```
import Stream from 'stream';
```


Stream.Readable (可读流)
-----------------------

```
• 'readable' ()                                     // 内核缓冲区有数据可读时，触发事件
• 'data'     (data)                                 // 从内核缓冲区拷贝到用户缓冲区一块数据时，触发事件
• 'end'      ()                                     // 从内核缓冲区拷贝到用户缓冲区完成时，触发事件
• 'close'    ()                                     // 当底层数据源（ex:源头的文件描述符）被关闭时触发
• 'error'    (error)                                // 当数据拷贝发生错误时触发

readable.read([size])                               // 从内部缓冲区拷贝到用户缓冲区一块数据
                                                    // 当流暂停时 (pause)，此方法可以单点拷贝数据
                                                    // 当流开始时 (resume)，此方法被内部调用
                                                    // ⇒ null | String | Buffer

readable.pipe(writeStream, [options])               // 使用管道，从内核缓冲区拷贝到用户缓冲区，直到完成 
                                                    // 自动控制流量以避免目标被快速读取的可读流所淹没

         • writeStream                              // 写入的目标流
         • options {
               end: default=true                    // 在读取者结束时结束写入者
           }     

readable.unpipe([writeStream])                      // 移除管道
                                                    // 如果不指定目标，所有管道都会被移除

readable.unshift(chunk)                             // 拷贝数据块到内部缓冲区头部 

readable.setEncoding(encoding)                      // 设置数据编码

readable.resume()                                   // 让流切换到流动模式
readable.pause()                                    // 让流切换到暂停模式
```

Stream.Writable (可写流)
-----------------------

```

• 'drain'  ()                                       // 用户缓冲区清空，可以写入数据时，触发该事件
• 'finish' ()                                       // 数据写入完毕时，触发该事件
• 'pipe'   (writeStream)                            // 数据通过管道写入时，触发该事件
• 'unpipe' (writeStream)                            // 数据移除管道写入时，触发该事件
• 'error'  (error)                                  // 数据写入发生错误时，触发该事件


writable.write(chunk, [encoding], [callback(err)])  // 写入数据块
writable.end([chunk], [encoding], [callback])       // 当没有更多数据会被写入到流时调用此方法
                                                    // 触发 finish 事件
                                                    
         • chunk    : Buffer | String
         • encoding : String
                                                   
writable.cork()                                     // 停止写入
writable.uncork()                                   // 继续写入
```

Stream.Duplex (可读可写流)
-----------------------

* tcp
* zlib
* crypto
* ...

Stream.Transform (转换流)
-----------------------

* zlib
* crypto
* ...