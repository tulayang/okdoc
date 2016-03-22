import os, tables, strutils, algorithm

const 
    docIndexname* = "index"
    docExtname* = [".md", ".markdown"]

type
    PathKind* = enum
        pkFile, pkDir

    PathNode* = object
        kind*: PathKind
        parent*: int
        current*: int
        level*: int
        offset*: int
        path*: string

    DocComponentKind* = enum
        dckFile, dckDir

    DocComponent* = object
        parent*: int
        case kind: DocComponentKind
        of dckFile:
            lastModifyTime*: int
            content*: string
        of dckDir:
            childs*: seq[int]
            index*: int
            indexText*: string
        path*: string
        name*: string
        url*: string

    DocCollection* = ref object  ## File data object.
        componentSeq: seq[DocComponent]
        urlTable: Table[string, int] 
        dirname: string
        basename: string

template isDocIndexname*(name: string): bool =
    docIndexname == name

template isDocExtname*(name: string): bool =
    for s in docExtname:
        if s == name:
            return true
    false

proc initPathNode(kind: PathKind; path: string;
                  parent, current, level, offset: int): PathNode =
    result.kind = kind
    result.path = path
    result.parent = parent  
    result.current = current
    result.level = level
    result.offset = offset
    
iterator nodes*(dirname: string, filter: proc(path: string): bool = nil): PathNode =
    var i = 0
    var j = 0
    var list = @[initPathNode(pkDir, dirname, 0, 0, 0, 0)]
    inc(j)
    while i < len(list):
        case list[i].kind
        of pkDir:
            var arr: seq[tuple[kind: PathComponent, path: string]] = @[]
            for kind, path in walkDir(list[i].path):
                add(arr, (kind, path))
            sort(arr, proc (x, y: tuple[kind: PathComponent, path: string]): int = 
                cmp(x.path, y.path))

            var offset = 0
            for node in arr:
                case node.kind
                of pcDir:
                    add(list, initPathNode(pkDir, node.path, i, j, list[i].level + 1, offset))
                    inc(offset)
                    inc(j)
                of pcFile:
                    if isNil(filter) or filter(node.path):
                        add(list, initPathNode(pkFile, node.path, i, j, list[i].level + 1, offset))
                        inc(offset)
                        inc(j)
                else:
                    discard
            yield list[i]
        of pkFile:
            yield list[i]
        inc(i)

proc convertText(s: string): string =
    result = newString(len(s) * 2)
    var j = 0
    for i in 0..<len(s):
        if s[i] == '`':
            result[j] = '\\'
            inc(j)
            result[j] = s[i]
            inc(j)
        elif s[i] == '$':
            result[j] = '\\'
            inc(j)
            result[j] = s[i]
            inc(j)
        elif s[i] == '\\':
            result[j] = '\\'
            inc(j)
            result[j] = s[i]
            inc(j)
        else: 
            result[j] = s[i]
            inc(j)
    if j < len(result):
        setLen(result, j)

proc initDocFile(parent: int; path, name, url: string; lastModifyTime = 0): DocComponent = 
    result.kind = dckFile
    result.parent = parent
    result.path = path
    result.name = name
    result.content = convertText(readFile(path))
    result.lastModifyTime = lastModifyTime
    result.url = url
    # /A/B/C/manuals/a/b/c.md => /manuals/a/b/c.md
    # manuals/a/b/c.md => /manuals/a/b/c.md

proc initDocDir(parent: int; path, name, url: string): DocComponent = 
    result.kind = dckDir
    result.parent = parent
    result.path = path
    result.name = name
    result.childs = @[]
    result.index = -1

proc newDocCollection*(dirname: string): DocCollection =
    if not existsDir(dirname):
        raise newException(IOError, "dirname is not a directory")
    new(result)
    result.componentSeq = @[]
    result.urlTable = initTable[string, int]()
    result.dirname = expandFilename(dirname)
    var (_, name, _) = splitFile(dirname) 
    result.basename = name

proc filter(path: string): bool =
    var (_, _, ext) = splitFile(path)
    isDocExtname(ext)

proc convertUrl(rootpath, rootname, path: string): string =
    if len(rootpath) < len(path):
        joinPath("/", rootname, path[len(rootpath)..high(path)])
    else:
        joinPath("/", rootname)

proc mapDoc*(c: DocCollection) = 
    ## Open a directory and then initialize it to a new `DocCollection`.
    for node in nodes(c.dirname, filter):
        var url = convertUrl(c.dirname, c.basename, node.path)
        var (_, name, _) = splitFile(node.path)
        case node.kind:
        of pkFile:
            if name == "index":
                c.componentSeq[node.parent].index = node.current
            add(c.componentSeq, initDocFile(node.parent, node.path, name, url))
        of pkDir:
            add(c.componentSeq, initDocDir(node.parent, node.path, name, url))
        add(c.componentSeq[node.parent].childs, node.current)
        c.urlTable[url] = node.current

proc reMapDoc*(c: DocCollection) =
    c.componentSeq = @[]
    c.urlTable = initTable[string, int]()
    mapDoc(c)

template hasComponent*(c: DocCollection, url: string): bool =
    hasKey(c.urlTable, url)

template getComponentIndex*(c: DocCollection, url: string): int =
    c.urlTable[url]

template isDocFile*(c: DocCollection, i: int): bool =
    c.componentSeq[i].kind == dckFile

template isDocDir*(c: DocCollection, i: int): bool =
    c.componentSeq[i].kind == dckDir

template getDocFile*(c: DocCollection, i: int): DocComponent = 
    assert c.componentSeq[i].kind == dckFile
    c.componentSeq[i]

template getDocComponent(c: DocCollection, i: int): DocComponent =
    c.componentSeq[i]

proc getDocDirIndexText*(c: DocCollection, i: int): string =
    # * [**name** desc](href title)
    # * [**name** desc](href title)
    # * [**name** desc](href title)
    var index = c.componentSeq[i].index
    if isNil(c.componentSeq[i].indexText):
        if index == -1:
            c.componentSeq[i].indexText = ""
            for j in c.componentSeq[i].childs:
                if i > 0 or j > 0:
                    c.componentSeq[i].indexText &= "* [**" & 
                            getDocComponent(c, j).name & 
                            "**](" & 
                            convertUrl(c.dirname, c.basename, getDocComponent(c, j).path) & 
                            ")\n\n"
        else:
            c.componentSeq[i].indexText = c.componentSeq[index].content
    result = c.componentSeq[i].indexText

proc update*(c: DocCollection, i: int, content: string) =
    assert c.componentSeq[i].kind == dckFile
    writeFile(c.componentSeq[i].path, content)
    c.componentSeq[i].content = convertText(content)





