```
import Events from 'events';
```

Events.EventEmitter (事件对象)

```
• 'newListener'    (type, listener)            // 添加 listener 时会发生该事件
• 'removeListener' (type, listener)            // 移除 listener 时会发生该事件

emitter.addListener(type, listener)            // 添加事件触发器
emitter.on(type, listener)                     // 添加事件触发器  
emitter.once(type, listener)                   // 添加事件触发器 (触发 1 次)

emitter.removeListener(type, listener)         // 移除事件触发器
emitter.removeAllListeners([type])             // 移除事件触发器 (全部) 

emitter.listeners(type)                        // 获取指定事件的 listener 数组 

emitter.emit(type, [arg1], [arg2], [...])      // 触发事件

emitter.setMaxListeners(n)                     // 设置最大事件触发器数量，default=10
```

<span>

```
EventEmitter.defaultMaxListeners               // 设置 default 最大触发器数量
EventEmitter.listenerCount(emitter, type)      // 获取指定事件的 listener 个数
```