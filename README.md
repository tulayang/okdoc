# okdoc

[okdoc](http://101.200.163.149) 是一个开源的文档管理器，包括一个后端文档服务器（Nim 语言编写）、一个前端 markdown 编辑器（JavaScript 语言编写）、一个 html 渲染程序。okdoc 收录了许多英文文档的中文译文，包括 [GNU C Library](http://101.200.163.149/docs/GNU%20C%20Library)、[Nim Manual](http://101.200.163.149/docs/Nim%20Manual)、[...](http://101.200.163.149)

现在，[okdoc](http://101.200.163.149) 运行在云服务器上，你可以通过 http://101.200.163.149 访问。很遗憾没有域名，中国特色的备案制度，HEHE ...

欢迎修改译文的绕口、错误，以及增加新译文。只需要 **fork -> 修改 -> pull request**。

### 部署在本地

```sh
$ git clone https://github.com/tulayang/okdoc.git
$ cd okdoc
$ nimble install
$ nim c -r:release src/okdoc.nim
```
