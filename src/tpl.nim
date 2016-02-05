proc renderList(list: seq[tuple[name, url: string]]): string =
    result = ""
    for item in list:
        result &= "<li><i class=\"fa fa-plus\"></i><a href=\"" & item.url & "\">" & item.name & "</a></li>"

template renderHome*(gnavText: string): string = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8"/>
    <title>Menual</title>

    <link type="text/css" rel="stylesheet" href="/css/base.css"/>
    <link type="text/css" rel="stylesheet" href="/css/font-awesome/css/font-awesome.css"/>
    <link type="text/css" rel="stylesheet" href="/css/highlight/xcode-a.css"/>

    <script src="/js/highlight.min.js"></script>
    <script src="/js/marked.min.js"></script>
    <script src="/js/renderer.js"></script>

    <style>

    #gnav {
        max-width: 940px;
        margin: 0 auto;
        padding: 20px;
    }
    
    ul li {
        float: left;
        list-style: outside none none;
    }

    ul li:nth-child(odd) {
        margin-right: 80px;
    }

    ul li a {
        display: inline-block;
        width: 400px;
        padding: 6px 0;
    }
    ul li a:last-child {
        border-bottom:  1px solid #E2E2E2!important;
    }

    #gnav .linker {
        line-height: 2.6;
    }
    #gnav .linker a .fa {
        margin-top: 14px;
    }
    </style>
</head>
<body>

<nav id="gnav">
    <nav id="gmenu" class="fixer">
        <a class="btn flush" href="/flush"><i class="fa fa-level-up"></i></a>
        <a class="btn github" href="https://github.com/tulayang/okdoc"><i class="fa fa-github"></i></a>
        <a class="btn logout" href="#"><i class="fa fa-sign-out"></i></a>
    </nav>
    <h1>OK Documentation</h1>
    <div class="content">
</nav>

<script type="text/javascript">
(function (hljs, marked) {

///////////////////////////// 需要服务端渲染的数据 /////////////////////////////
const gnavText = `""" & gnavText & """`;
/////////////////////////////////////////////////////////////////////////////

var elGnavContent = document.querySelector("#gnav .content");
var renderer = new Renderer();
renderer.setMode(RendererMode.rmGnav | RendererMode.rmContent);
elGnavContent.innerHTML = renderer.html(gnavText);
}(hljs, marked));
</script>

</body>
</html>"""

template renderIndex*(gnavText: string): string = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8"/>
    <title>Menual</title>

    <link type="text/css" rel="stylesheet" href="/css/base.css"/>
    <link type="text/css" rel="stylesheet" href="/css/font-awesome/css/font-awesome.css"/>
    <link type="text/css" rel="stylesheet" href="/css/highlight/xcode-a.css"/>

    <script src="/js/highlight.min.js"></script>
    <script src="/js/marked.min.js"></script>
    <script src="/js/renderer.js"></script>
</head>
<body>

<nav id="gnav" class="fixer">
    <nav id="gmenu" class="fixer">
        <a class="btn flush" href="/flush"><i class="fa fa-level-up"></i></a>
        <a class="btn home" href="/"><i class="fa fa-home"></i></a>
        <a class="btn github" href="https://github.com/tulayang/okdoc"><i class="fa fa-github"></i></a>
        <a class="btn logout" href="#"><i class="fa fa-sign-out"></i></a>
    </nav>
    <div class="content major"></div>
</nav>

<script type="text/javascript">
(function (hljs, marked) {

///////////////////////////// 需要服务端渲染的数据 /////////////////////////////
const gnavText = `""" & gnavText & """`;
/////////////////////////////////////////////////////////////////////////////

var elGnavContent = document.querySelector("#gnav .content");
var renderer = new Renderer();
renderer.setMode(RendererMode.rmGnav | RendererMode.rmContent);
elGnavContent.innerHTML = renderer.html(gnavText);
}(hljs, marked));
</script>

</body>
</html>"""

template renderArticle*(articleUrl, articleText, gnavText: string): string = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8"/>
    <title>Menual</title>

    <link type="text/css" rel="stylesheet" href="/css/base.css"/>
    <link type="text/css" rel="stylesheet" href="/css/font-awesome/css/font-awesome.css"/>
    <link type="text/css" rel="stylesheet" href="/css/codemirror.css"/>
    <link type="text/css" rel="stylesheet" href="/css/highlight/xcode-a.css"/>

    <script src="/js/codemirror/lib/codemirror.js"></script>
    <script src="/js/codemirror/mode/markdown/markdown.js"></script>
    <script src="/js/highlight.min.js"></script>
    <script src="/js/marked.min.js"></script>
    <script src="/js/renderer.js"></script>
</head>
<body>

<div id="container">
    <nav id="gmenu" class="fixer">
        <a class="btn edit" href="#"><i class="fa fa-pencil-square-o"></i></a>
        <a class="btn goto" href="#"><i class="fa fa-th"></i></a>
        <a class="btn flush" href="/flush"><i class="fa fa-level-up"></i></a>
        <a class="btn home" href="/"><i class="fa fa-home"></i></a>
        <a class="btn github" href="https://github.com/tulayang/okdoc"><i class="fa fa-github"></i></a>
        <a class="btn logout" href="#"><i class="fa fa-sign-out"></i></a>
    </nav>
    <article id="article" class="major"></article>
    <aside id="article-archor" class="fixer"></aside>
</div>

<div id="writer" class="fixer none">
    <menu class="fixer">
        <a class="btn to-editor"><i class="fa fa-arrows-alt"></i></a>
        <a class="btn to-previewer"><i class="fa fa-eye"></i></a>
        <a class="btn update"><i class="fa fa-floppy-o"></i></a>
        <a class="btn close"><i class="fa fa-times"></i></a>
    </menu>
    <div class="layer r-middle editor"><textarea style="display: none;"></textarea></div>
    <div class="layer l-middle previewer"><article></article></div>
</div>

<nav id="gnav" class="fixer none">
    <menu class="fixer">
        <a class="btn flush" href="/flush"><i class="fa fa-level-up"></i></a>
        <a class="btn home" href="/"><i class="fa fa-home"></i></a>
        <a class="btn github" href="https://github.com/tulayang/okdoc"><i class="fa fa-github"></i></a>
        <a class="btn close"><i class="fa fa-times"></i></a>
    </menu>
    <div class="content major"></div>
</nav>

<script type="text/javascript">
(function (CodeMirror, Renderer, RendererMode) {

///////////////////////////// 需要服务端渲染的数据 /////////////////////////////
const articleUrl = `""" & articleUrl & """`;
const gnavText = `""" & gnavText & """`;
var articleText = `""" & articleText & """`;
/////////////////////////////////////////////////////////////////////////////

function hasClass(el, name) {
    return new RegExp('(?:^' + name + '$)' +
                      '|(?:\\s+' + name + '$)' + 
                      '|(?:^' + name + '\\s+)' + 
                      '|(?:\\s+' + name + '\\s+)').test(el.className);
}

function removeClass(el, name) {
    var reg = new RegExp('(?:^' + name + '$)' +
                         '|(?:\\s+' + name + '$)' + 
                         '|(?:^' + name + '\\s+)' + 
                         '|(?:\\s+' + name + '\\s+)');
    el.className = el.className.replace(reg, function (text) {
        return ' ';
    }).replace(/\\s{2,}/, ' ').trim();
}

function addClass(el, name) {
    if (!hasClass(el, name)) {
        el.className = (el.className + ' ' + name).trim();
    }
}

function click(el, f) {
    document.addEventListener('click', function (e) {
        if (el.contains(e.target)) {
            f(e);
        }
    }, false);
}

function keydown(condf, f) {
    document.addEventListener('keydown', function (e) {
        if (condf(e)) {
            f(e);
        }
    }, false);
}

function keyup(condf, f) {
    document.addEventListener('keyup', function (e) {
        if (condf(e)) {
            f(e);
        }
    }, false);
}

function isKeyUpdate(e) {
    return e.ctrlKey && e.keyCode === 83;
}

function isKeyCancel(e) {
    return e.keyCode === 27;
}

function cancelLeftClick() {
    document.addEventListener('click', function (e) {
        if (e.button !== 0) {
            e.preventDefault();
        }
    }, false);
}

const EditMode = Object.create(null);
EditMode.emNone = 0;
EditMode.emContainer = 1;
EditMode.emGnav = 2;
EditMode.emArticleEdit = 3;

const UpdateMode = Object.create(null);
UpdateMode.umNone = 0;
UpdateMode.umReady = 1;
UpdateMode.umBusy = 2;

var req = new XMLHttpRequest();
var renderer = new Renderer(articleUrl);
var editMode = EditMode.emNone;
var updateMode = UpdateMode.upNone;

var elContainer = document.querySelector("#container");
var elArchor = document.querySelector("#article-archor");
var elGnav = document.querySelector("#gnav");
var elGnavContent = elGnav.querySelector(".content");
var elGnavEdit = elGnav.querySelector(".edit");
var elGnavClose = elGnav.querySelector(".close");
var elArticle = document.querySelector("#article");
var elGoGnav = document.querySelector("#gmenu .goto");
var elArticleEdit = document.querySelector("#gmenu .edit");
var elWriter = document.querySelector("#writer");
var elToEditor = elWriter.querySelector(".to-editor");
var elToPreviewer = elWriter.querySelector(".to-previewer");
var elEditor = elWriter.querySelector(".editor");
var elPreviewer = elWriter.querySelector(".previewer");
var elPreviewerContent = elPreviewer.querySelector("article");
var elUpdate = elWriter.querySelector(".update");
var elUpdateIco = elUpdate.querySelector('i');
var elWriterClose = elWriter.querySelector(".close");
var codemirror = CodeMirror.fromTextArea(elEditor.querySelector("textarea"), { 
    lineWrapping: true,
    lineNumbers: true 
});

function get(url, callback) {    
    req.onload = function () {
        callback(req.responseText);
    };
    req.open('GET', url, true);
    req.send(null);
}

function post(url, data, callback) {
    req.onload = function () {
        callback(req.responseText);
    };
    req.open('POST', url, true);
    //req.setRequestHeader('Content-Type', 'application/json');
    //req.send(JSON.stringify(data));
    req.setRequestHeader('Content-Type', 'text/plain');
    req.send(data);
}

function show(el) {
    removeClass(el, 'none');
}

function hide(el) {
    addClass(el, 'none');
}

function setEditMode(mode) {
    editMode = mode;
}

function isEditContainer() {
    return editMode === EditMode.emContainer;
}

function isEditGnav() {
    return editMode === EditMode.emGnav;
}

function isEditArticle() {
    return editMode === EditMode.emArticleEdit;
}

function isUpdateBusy() {
    return updateMode = UpdateMode.umBusy;
}

function setUpdateMode(mode) {
    updateMode = mode;
}

function isUpdateReady() {
    return updateMode === UpdateMode.umReady;
}

function isUpdateBusy() {
    return updateMode = UpdateMode.umBusy;
}

function renderArticle(text) {
    articleText = text;
    renderer.setMode(RendererMode.rmArchor | RendererMode.rmContent);
    elArticle.innerHTML = renderer.html(text);
    elArchor.innerHTML = renderer.archor;
}

function renderArticlePriviewer(text) {
    renderer.setMode(RendererMode.rmContent);
    elPreviewerContent.innerHTML = renderer.html(text);
}

function renderGnav(text) {
    renderer.setMode(RendererMode.rmGnav | RendererMode.rmContent);
    elGnavContent.innerHTML = renderer.html(text);
}

renderArticle(articleText);
renderGnav(gnavText);
setEditMode(EditMode.emContainer);
setUpdateMode(UpdateMode.umReady);
//cancelLeftClick();
codemirror.on('change', function (codemirror, change) {
    if (isEditArticle()) {
        renderArticlePriviewer(codemirror.getDoc().getValue());
    }
});
click(elGoGnav, function (e) {
    setEditMode(EditMode.emGnav);
    show(elGnav);
    hide(elContainer);
    addClass(elWriter, 'on-gnav');
});
click(elGnavClose, function (e) {
    setEditMode(EditMode.emContainer);
    show(elContainer);
    hide(elGnav);
    removeClass(elWriter, 'on-gnav');
});
click(elArticleEdit, function (e) {
    if (isEditContainer()) {
        setEditMode(EditMode.emArticleEdit);
        show(elWriter);
        hide(elContainer);
        codemirror.getDoc().setValue(articleText);
    }
});
click(elWriterClose, function (e) {
    setEditMode(EditMode.emContainer);
    show(elContainer);
    hide(elWriter);
    removeClass(elEditor, 'r-middle');
    removeClass(elEditor, 'r-zero');
    removeClass(elPreviewer, 'l-middle');
    removeClass(elPreviewer, 'l-zero');
    addClass(elEditor, 'r-middle');
    addClass(elPreviewer, 'l-middle');
});
click(elToEditor, function (e) {
    if (hasClass(elEditor, 'r-middle')) {
        removeClass(elEditor, 'r-middle');
        removeClass(elPreviewer, 'l-middle');
        addClass(elPreviewer, 'l-zero');
    } else if (hasClass(elEditor, 'r-zero')) {
        removeClass(elEditor, 'r-zero');
        addClass(elPreviewer, 'l-middle');
        addClass(elEditor,  'r-middle');
    }
});
click(elToPreviewer, function (e) {
    if (hasClass(elPreviewer, 'l-middle')) {
        removeClass(elEditor, 'r-middle');
        removeClass(elPreviewer, 'l-middle');
        addClass(elEditor, 'r-zero');
    } else if (hasClass(elPreviewer, 'l-zero')) {
        removeClass(elPreviewer, 'l-zero');
        addClass(elEditor, 'r-middle');
        addClass(elPreviewer, 'l-middle');
    }
});
click(elUpdate, function (e) {
    if (isEditArticle() && isUpdateReady()) {
        var text = codemirror.getDoc().getValue();
        removeClass(elUpdateIco, 'fa-floppy-o');
        addClass(elUpdateIco, 'fa-refresh');
        addClass(elUpdateIco, 'fa-spin');
        setUpdateMode(UpdateMode.umBusy);
        post(articleUrl, text, function (data) {
            renderArticle(text);
            removeClass(elUpdateIco, 'fa-refresh');
            removeClass(elUpdateIco, 'fa-spin');
            addClass(elUpdateIco, 'fa-floppy-o');
            setUpdateMode(UpdateMode.umReady);
        });
    } 
});
keydown(function (e) {return isKeyUpdate(e);}, function (e) { 
    e.preventDefault();
}); 
keyup(function (e) {return isKeyUpdate(e);}, function (e) {
    if (isEditArticle() && isUpdateReady()) {
        removeClass(elUpdateIco, 'fa-floppy-o');
        addClass(elUpdateIco, 'fa-refresh');
        addClass(elUpdateIco, 'fa-spin');
        setUpdateMode(UpdateMode.umBusy);
        var text = codemirror.getDoc().getValue();
        post(articleUrl, text, function (data) {
            renderArticle(text);
            removeClass(elUpdateIco, 'fa-refresh');
            removeClass(elUpdateIco, 'fa-spin');
            addClass(elUpdateIco, 'fa-floppy-o');
            setUpdateMode(UpdateMode.umReady);
        });
    } 
});
keyup(function (e) {return isKeyCancel(e);}, function (e) {
    if (isEditArticle()) {
        setEditMode(EditMode.emContainer);
        show(elContainer);
        hide(elWriter);
        removeClass(elEditor, 'r-middle');
        removeClass(elEditor, 'r-zero');
        removeClass(elPreviewer, 'l-middle');
        removeClass(elPreviewer, 'l-zero');
        addClass(elEditor, 'r-middle');
        addClass(elPreviewer, 'l-middle');
    }
    if (isEditGnav()) {
        setEditMode(EditMode.emContainer);
        show(elContainer); 
        hide(elGnav);
        removeClass(elWriter, 'on-gnav');
    }
});
}(CodeMirror, Renderer, RendererMode));
</script>
</body>
</html>"""
