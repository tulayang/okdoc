```
import Fs from 'fs';
```

debug
------

```
$ env NODE_DEBUG=fs node script.js

Fs.js:66
        throw err;
              ^
Error: EISDIR, read
    at rethrow (Fs.js:61:21)
    at maybeCallback (Fs.js:79:42)
    at Object.Fs.readFile (Fs.js:153:18)
    at bad (/path/to/script.js:2:17)
    at Object.<anonymous> (/path/to/script.js:5:1)
    <etc.>
```

Fs Module (同步版本使用 try { methodSync(); } catch (e) {})
-----------------------------------------------------------------------

```
Fs.rename(oldPathname, newPathname, callback(err))               // 移动重命名文件

Fs.ftruncate(fd, len, callback(err))                             // 修改文件大小为 len (超出部分删掉)
Fs.truncate(pathname, len, callback(err))             

Fs.fchown(fd, uid, gid, callback(err))                           // 修改文件用户组
Fs.chown(pathname, uid, gid, callback(err))           
Fs.lchown(pathname, uid, gid, callback(err))                     // 修改符号链接文件用户组

Fs.fchmod(fd, mode, callback(err))                               // 修改文件权限
Fs.chmod(pathname, mode, callback(err))
Fs.lchmod(pathname, mode, callback(err))                         // 修改符号链接文件权限

Fs.futimes(fd, atime, mtime, callback(err))                      // 修改文件访问时间和修改时间
Fs.utimes(pathname, atime, mtime, callback(err))     

Fs.fstat(fd, callback(err, stats))                               // 获取文件属性
Fs.stat(pathname, callback(err, stats))                  
Fs.lstat(pathname, callback(err, stats))                         // 获取符号文件属性

   • stats : Fs.Stats 

     ∘ stats.isFile()              // 文件？
     ∘ stats.isDirectory()         // 目录？
     ∘ stats.isBlockDevice()       // 块设备？
     ∘ stats.isCharacterDevice()   // 字符设备？
     ∘ stats.isSymbolicLink()      // 符号链接文件？
     ∘ stats.isFIFO()              // FIFO？
     ∘ stats.isSocket()            // 套接字？

     ∘ stats { 
           dev: 2114,                                
           ino: 48064969,
           mode: 33188,
           nlink: 1,
           uid: 85,
           gid: 100,
           rdev: 0,
           size: 527,
           blksize: 4096,
           blocks: 8,
           atime: Mon, 10 Oct 2011 23:24:11 GMT,      // 访问时间
           mtime: Mon, 10 Oct 2011 23:24:11 GMT,      // 更改内容时间
           ctime: Mon, 10 Oct 2011 23:24:11 GMT,      // 更改属性时间
           birthtime: Mon, 10 Oct 2011 23:24:11 GMT   // 创建时间
       }

Fs.readlink(pathname, callback(err, linkString))                 // 读取链接的内容
Fs.unlink(pathname, callback(err))                               // 解除一个硬、符号连接 
Fs.link(srcPathname, dstPathname, callback(err))                 // 创建一个硬连接
Fs.symlink(srcPathname, dstPathname, [type], callback(err))      // 创建一个符号链接

   • type : String // 'dir' | 'file' | 'junction'

Fs.rmdir(pathname, callback(err))                                // 删除目录
Fs.readdir(pathname, callback(err, names))                       // 读取目录
Fs.mkdir(pathname, [mode], callback(err))                        // 创建目录
    
   • mode : Number // 权限，default=0777

Fs.realpath(pathname, [cache], callback(err, resolvedPathname))  // 将相对路径转换成绝对路径

/**************************************** IO *******************************************/

Fs.open(pathname, flags, [mode], callback(err, fd))              // 打开文件，返回一个描述符

   • flags : String
     ∘ 'r'      // 只读，文件不存在则失败
     ∘ 'r+'     // 读写，文件不存在则失败
     ∘ 'rs'     // 只读，打开 NFS 挂载的文件
     ∘ 'rs+'    // 读写，打开 NFS 挂载的文件
     ∘ 'w'      // 只写，文件不存在则创建
     ∘ 'wx'     // 只写，文件存在则失败
     ∘ 'w+'     // 读写，文件不存在则创建
     ∘ 'wx+'    // 读写，文件存在则失败
     ∘ 'a'      // 附加，文件不存在则创建，新写入的数据会附加在原来的文件内容之后
     ∘ 'ax'     // 附加，文件存在则失败
     ∘ 'a+'     // 读取附加，文件不存在则创建
     ∘ 'ax+'    // 读取附加，文件存在则失败

   • mode : Number // 权限，default=0666

Fs.close(fd, callback(err))                                     // 关闭文件描述符

Fs.fsync(fd, callback(err))                                     // 同步磁盘，包括文件和文件属性

Fs.exists(pathname, callback(exists))                           // 检查文件、目录存在

Fs.read(fd, buffer, offset, length, position, callback(err, bytesRead, buffer))   // 读取描述符

   • buffer   : Buffer // 缓冲区
   • offset   : Number // 缓冲区偏移位置
   • length   : Number // 读取的字节数
   • position : Number // 文件偏移位置

   • written  : Number // 写入的字节数
   • buffer   : Buffer // 缓冲区

Fs.readFile(filename, [options], callback(err, data))                             // 读取文件

   • options {
         encoding : default='utf8',
         flag     : default='r'
     }

Fs.write(fd, buffer, offset, length, [position], callback(err, written, buffer))  // 写入描述符

   • buffer   : Buffer // 缓冲区
   • offset   : Number // 缓冲区偏移位置
   • length   : Number // 写入的字节数
   • position : Number // 文件偏移位置

   • written  : Number // 写入的字节数
   • buffer   : Buffer // 缓冲区

Fs.write(fd, data, [position], [encoding], callback(err, written, string))       // 写入描述符

   • written  : Number // 写入的字符串长度
   • string   : Buffer // 写入的字符串

Fs.writeFile(filename, data, [options], callback(err))                           // 写入文件

   • options {
         encoding : default='utf8',
         flag     : default='w',
         mode     : default=0666
     }

Fs.appendFile(filename, data, [options], callback(err))             // 写入文件，内容追加到尾部

Fs.createReadStream(pathname, [options])                            // 创建一个读取流

   • options { 
         flags     : default='r',
         encoding  : default=null,
         fd        : default=null,
         mode      : default=0666,
         autoClose : default=true,    // 发生错误时，自动关闭文件描述符
         start     : 90               // 读取文件的起始位置 
         end       : 99               // 读取文件的结束位置 
     }

Fs.ReadStream()

   • 'open' (fd)    // 当流创建时触发

Fs.createWriteStream(pathname, [options])                           // 创建一个写入流

   • options { 
         flags     : default='w',
         encoding  : default=null,
         mode      : default=0666 
     }

Fs.WriteStream()

   • 'open' (fd)    // 当流创建时触发

   stream.bytesWritten   // 已写的字节数

/***************************************************************************************/

Fs.watchFile(filename, [options], listener(curr, prev)) // 监视文件的改变
   
   • options {
         persistent : default=true,  // 进程是否应该在文件被监视时继续运行
         interval   : default=5007   // 目标文件被查询的间隔，以毫秒为单位
     }
   
   • curr : Fs.Stat
   • prev : Fs.Stat

Fs.unwatchFile(filename, [listener])                    // 停止监视文件

Fs.watch(filename, [options], [listener])               // 监视文件、目录的改变

   • options {
         persistent : default=true   // 进程是否应该在文件被监视时继续运行
     }

   • listener(event, filename)
     ∘ event      : 'rename' | 'change'
     ∘ filename   : 触发事件的文件名

Fs.FSWatcher()

   • 'change'
   • 'error'
```