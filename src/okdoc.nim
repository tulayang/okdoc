import jester, asyncdispatch, json, markdowndb, strutils, 
       re, os, tpl, cgi, posix

proc normalizePath(s: string): string =
    result = newString(len(s))
    var j = 0
    var backslash = false
    for i in 0..<len(s):
        if backslash:
            if s[i] != '/':
                backslash = false
                result[j] = '/'
                inc(j)
                result[j] = s[i]
                inc(j)
        else:
            if s[i] == '/':
                backslash = true
            else:
                result[j] = s[i]
                inc(j)
    if j != len(s):
        setLen(result, j)

const 
    bindAddr = "127.0.0.1"
    port = 8000

var collection: DocCollection

let workDir = getCurrentDir()
let staticDir = joinPath(workDir, "public")
let docsPath  = joinPath(workDir, "docs")

template initialize() =
    collection = newDocCollection(docsPath)
    mapDoc(collection)

settings:
    staticDir = staticDir
    bindAddr = bindAddr
    port = Port(port)

routes:
    get "/?":
        resp renderHome(getDocDirIndexText(collection, 0))
        discard

    get "/flush/?":
        reMapDoc(collection)
        redirect "/"

    get re"^/docs/(.+)$":
        let url = unixToNativePath(normalizePath(joinPath("/docs/", decodeUrl(request.matches[0])))).replace("\\","/")
        if hasComponent(collection, url):
            let index = getComponentIndex(collection, url)
            if isDocFile(collection, index):
                let docfile = getDocFile(collection, index)
                resp renderArticle(docfile.url, docfile.content,
                                   getDocDirIndexText(collection, docfile.parent))
            elif isDocDir(collection, index):
                resp renderIndex(getDocDirIndexText(collection, index))
            else: 
                halt()
        else: halt()

    post re"^/docs/(.+)$":
        let url = unixToNativePath(normalizePath(joinPath("/docs/", decodeUrl(request.matches[0]))))
        if hasComponent(collection, url):
            let index = getComponentIndex(collection, url)
            if isDocFile(collection, index):
                update(collection, index, request.body)
                resp ""
            else: halt()
        else: halt()
        
initialize()
runForever()