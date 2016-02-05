```
Global.Buffer
```

Buffer → String
----------------

```
• 'ascii'      7 位 ASCII 格式数据
• 'utf8'       多字节 Unicode
• 'utf16le'    2 | 4 字节，LE Unicode，支持 U+10000 ~ U+10FFFF 
• 'ucs2'       'utf16le'的别名
• 'base64'     Base64 字符串编码
• 'hex'        每个字节编码成 2 个十六进制字符
```

Global.Buffer 用户缓冲区
-----------------------

```
new Buffer(size)
new Buffer(array)
new Buffer(str, [encoding])

buffer.length                                         // 分配的缓冲区长度

buffer.toString([encoding], [start], [end])           // 缓冲区数据转换成字符串
buffer.toJSON()                                       // 缓冲区数据转换成 JSON

buffer[i]                                             // 获取、设置 i 位置的字符
                                                      // 有效值：0x00～0xFF，或者 0～255

buffer.copy(targetBuffer, [targetStart], 
            [sourceStart], [sourceEnd])               // 拷贝缓冲区数据
buffer.slice([start], [end])                          // 提取缓冲区数据，返回一个新 Buffer (共用内存)

buffer.fill(value, [offset], [end])                   // 使用 value 填充缓冲区     

buffer.write(string, [offset], [length], [encoding])  // 把字符串写入缓冲区 
                                                      // 当超过缓冲区长度，只写入部分
       
       • offset         // 缓冲区偏移量，default=0
       • length         // 要写入的字符串的字节长度
       • encoding       // 编码，default='utf8'           

/**************************************************************************************/
/** unsigned 8 bit integer 和 signed 8 bit integer 一样的返回，**************************/
/** 除非 buffer 中包含了有作为 2 的补码的有符号值 ******************************************/       

buffer.readInt8(offset, [noAssert])                   // 读取一个 signed 8 bit integer
buffer.readUInt8(offset, [noAssert])                  // 读取一个 unsigned 8 bit integer

buffer.readInt16LE(offset, [noAssert])                // 读取一个 signed 16 bit integer
buffer.readInt16BE(offset, [noAssert])
buffer.readUInt16LE(offset, [noAssert])               // 读取一个 unsigned 16 bit integer
buffer.readUInt16BE(offset, [noAssert])               
                    
buffer.readInt32LE(offset, [noAssert])                // 读取一个 signed 32 bit integer
buffer.readInt32BE(offset, [noAssert])                                                      
buffer.readUInt32LE(offset, [noAssert])               // 读取一个 unsigned 32 bit integer
buffer.readUInt32BE(offset, [noAssert])               

buffer.readFloatLE(offset, [noAssert])                // 读取一个 32 bit float
buffer.readFloatBE(offset, [noAssert])                

buffer.readDoubleLE(offset, [noAssert])               // 读取一个 64 bit double
buffer.readDoubleBE(offset, [noAssert])               

buffer.writeInt8(value, offset, [noAssert])           // 写入 value，合法 signed 8 bit integer
buffer.writeUInt8(value, offset, [noAssert])          // 写入 value，合法 unsigned 8 bit integer

buffer.writeInt16LE(value, offset, [noAssert])        // 写入 value，合法 signed 16 bit integer
buffer.writeInt16BE(value, offset, [noAssert])
buffer.writeUInt16LE(value, offset, [noAssert])       // 写入 value，合法 unsigned 16 bit integer
buffer.writeUInt16BE(value, offset, [noAssert])

buffer.writeInt32LE(value, offset, [noAssert])        // 写入 value，合法 signed 32 bit integer
buffer.writeInt32BE(value, offset, [noAssert])
buffer.writeUInt32LE(value, offset, [noAssert])       // 写入 value，合法 unsigned 32 bit integer
buffer.writeUInt32BE(value, offset, [noAssert])

buffer.writeFloatLE(value, offset, [noAssert])        // 写入 value，合法 32 bit float
buffer.writeFloatBE(value, offset, [noAssert])

buffer.writeDoubleLE(value, offset, [noAssert])       // 写入 value，合法 64 bit double
buffer.writeDoubleBE(value, offset, [noAssert])

       • offset            // 缓冲区偏移量
       • noAssert          // 设置 true 时忽略验证 offset 和 value，
                           // 这意味着 offset 可能会超出 buffer 的末尾，
                           // 或者 value 可能过大，
                           // default=false

/***************************************************************************************/
```

SlowBuffer 不被缓冲区管理的 Buffer
----------------------------------
