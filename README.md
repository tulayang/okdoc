# okdoc

okdoc 是一个开源的文档管理器，包括一个后端文档服务器（Nim 语言编写）、一个前端 markdown 编辑器（JavaScript 语言编写）、一个 html 渲染程序。okdoc 收录了许多英文文档的中文译文，包括 GNU C Library、Nim Manual、...

### 部署在本地

```sh
$ git clone https://github.com/tulayang/okdoc.git
$ cd okdoc
$ nimble install
$ nim c -r -d:release src/okdoc.nim
```
