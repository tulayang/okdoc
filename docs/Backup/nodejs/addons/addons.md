Addons Plugin (动态连接库)
--------------------------

* V8 JavaScript (C++ library, v8.h)
* libuv IO (C)
* Internal Node libraries
* ...

Hello world

1. 编写 demo.cc

       #include <node.h>
       #include <v8.h>

       using namespace v8;

       void Method(const v8::FunctionCallbackInfo<Value>& args) {
           Isolate* isolate = Isolate::GetCurrent();
           HandleScope scope(isolate);
           args.GetReturnValue().Set(String::NewFromUtf8(isolate, "Hello world!"));
       }

       void Init(Handle<Object> exports) {
           // 生成函数字符串
           Isolate* isolate = Isolate::GetCurrent();
           exports->Set(String::NewFromUtf8(isolate, "hello"),
                        FunctionTemplate::New(isolate, Method)->GetFunction());
       }

       NODE_MODULE(demo, Init)  // 所有 addons 插件必须输出一个初始化函数

2. 编写 build/binding.gyp

       {
           "targets": [
               {
                   "target_name" : "demo",
                   "sources"     : [ "demo.cc" ]
               }
           ]
       }

3. 编译 → build/Release/demo.node
   
       $ node-gyp configure    // 编译 build/binding.gyp，生成 build/Makefile
       $ node-gyp build        // 生成 build/Release/demo.node
       
       or 

       $ node-gyp rebuild      // 编译 build/binding.gyp，生成 build/Release/demo.node

4. 使用二进制 addons plugin demo.node

       var demo = require('demo');
       demo.hello();