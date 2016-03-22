(function (hljs, marked) {
function listhead(n) {
    var result = "";
    for (var i = 1; i <= n; i++) {
        result += '<ul>';
    }
    return result;
}

function listfoot(n) {
    var result = "";
    for (var i = 1; i <= n; i++) {
        result += '</ul>';
    }
    return result;
}

function listitem(headId, text) {
    return  '<li class="linker">' + 
                '<i class="fa fa-plus"></i>' + 
                '<a class="text-ellipsis" href="#user-content-' + headId + '">' +
                    text + 
                '</a>' +
            '</li>';
}

const RendererMode = Object.create(null);
RendererMode.rmArchor = 0x0001;
RendererMode.rmContent = 0x0002;
RendererMode.rmGnav = 0x0004;

function Renderer(articleUrl) {
    var R = this;
    R.mode = RendererMode.rmArchor | RendererMode.rmContent;
    R.lastlevel = -1;
    R.headId = -1;
    R.archor = "";
    R.articleUrl = articleUrl;
    R.divClose = false;
    R.renderer = new marked.Renderer();
    R.renderer.heading = R.heading();
    R.renderer.listitem = R.listitem();
    R.renderer.link = R.link();
    marked.setOptions({
        renderer: R.renderer,
        gfm: true,
        tables: true,
        breaks: false,
        pedantic: false,
        sanitize: false,
        smartLists: true,
        smartypants: false,
        highlight: function (code, lang) {
            if (typeof lang === 'string' && lang.length > 0) {
                try {
                    var obj = hljs.highlight(lang, code, true, false);
                    return obj.value;
                } catch (e) {
                    return code;
                }
            }
            return hljs.highlightAuto(code).value;
        }
    });
}
  
Renderer.prototype.heading = function () {
    var R = this;
    return function (text, level) { 
        if (R.mode & RendererMode.rmContent) {
            var modifier = '';
            var headClass = ''; 
            if (level === 2 && text === '#') { 
                R.divClose = true;
                return '</div>';
            }
            if (level === 3) {
                if (/^\s*$/.test(text)) { 
                    R.divClose = true;
                    return '</div>';
                }
                if (R.divClose) {
                    modifier = '<div class="fragment">';
                    R.divClose = false;
                } else {
                    modifier = '</div><div class="fragment">';
                }
            }
            if (/^\s*:\s*/.test(text)) { 
                text = RegExp.rightContext;
                headClass = ' class="archor"';
                modifier = '</div><div class="fragment code">';
            }
            if (R.mode & RendererMode.rmArchor) {
                ++R.headId;
                if (level > 1) {
                    if (R.lastlevel < 0) {
                        R.archor += listhead(level - 1) + listitem(R.headId, text);
                        R.lastlevel = level;
                    } else if (R.lastlevel > level) {
                        R.archor += listfoot(R.lastlevel - level) + listitem(R.headId, text);
                        R.lastlevel = level;
                    } else if (R.lastlevel === level) {
                        R.archor += listitem(R.headId, text);
                    } else {
                        R.archor += listhead(level - R.lastlevel) + listitem(R.headId, text);
                        R.lastlevel = level;
                    }
                }
                
            } 
            return  modifier + 
                        '<h' + level + headClass + '>' +
                            '<a id="user-content-' + R.headId + '" class="anchor" href="#user-content-' + R.headId + '">' +
                                '<span class="header-link"></span>' + 
                            '</a>' +
                            text +
                        '</h' + level + '>';
        } else {
            throw new Error("renderer need mode: rmContent");
        }
    };
};

Renderer.prototype.listitem = function () {
    var R = this;
    return function (text) {
        if (R.mode & RendererMode.rmGnav) {
            return '<li class="linker">' + '<i class="fa fa-plus"></i>' + text + '</li>';
        } else {
            return '<li>' + text + '</li>';
        }
    };
};

Renderer.prototype.link = function () {
    var R = this;
    return function (href, title, text) {
        if (R.mode & RendererMode.rmGnav) {
            if (href === R.articleUrl) {
                return '<a class="active" href="' + href + '" title="' + title + '">' + 
                           text + '</a>';
            }
            return '<a href="' + href + '" title="' + title + '">' + 
                       text + '</a>';
        } else {
            return '<a href="' + href + '" title="' + title + '">' + text + '</a>';
        }
    };
};

Renderer.prototype.setMode = function (mode) {
    this.mode = mode;
};

Renderer.prototype.html = function (text) {
    var result = "";
    var R = this;
    if (R.mode & RendererMode.rmContent) {
        if (R.mode & RendererMode.rmArchor) {
            var headId = R.headId;
            var archor = R.archor;
            var level = R.lastlevel;
            R.archor = ""; 
            R.lastlevel = -1;
            R.headId = -1;      // 重新计算 head 标题的序号
            marked(text, function (err, content) {
                if (!err) {
                    R.archor += listfoot(R.lastlevel - 1);
                    result = content; 
                } else {
                    R.archor = "";
                    R.headId = headId;
                    R.archor = archor;
                    R.lastlevel = level;
                    result = text;
                }
            }); 
            return result;
        } else if (R.mode & RendererMode.rmGnav) {
            marked(text, function (err, content) {
                result = err ? text : content; 
            }); 
            return result;
        } else {
            marked(text, function (err, content) {
                result = err ? text : content; 
            }); 
            return result;
        }
    } else {
        throw new Error("renderer need mode: rmContent");
    }
};
window.Renderer = Renderer;
window.RendererMode = RendererMode;
}(hljs, marked));