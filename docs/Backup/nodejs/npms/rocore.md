```
    Message Queue
        
                       head(next,prev)     
                   +-> * 
                   |   |         
                   |   |         
                   |   |  
                   |   |                      
      indexes(key) |   v lnode(next,data,head)   head(next,prev)   node(next,prev,data)   node(next,prev,data) 
    A -------------+-> * --------------------> * <-------------> * <------------------> *
    |              |   |                       ^                                        ^ 
    |              |   |                       |                                        | 
    |              |   |                       +----------------------------------------+
    |              |   |
    | indexes(key) |   v lnode(next,data,head)   head(next,prev)   node(next,prev,data)   node(next,prev,data) 
    B -------------+-> * --------------------> * <-------------> * <------------------> *
                                               ^                                        ^ 
                                               |                                        |           
                                               +----------------------------------------+
```

rocore.js
----------


```

import pregexp from 'path-to-regexp';
import Http    from 'http';
import Url     from 'url';
import Events  from 'events';
import Fs      from 'fs';
import Path    from 'path';

export function scc(g) {
    let iter = g((...ctx) => iter.next(ctx));
    iter.next();
}

export function mcc(g, callback) {
	let num = 0; 
    let coll = {};
    let iter = g((key) => function () {
				              coll[key] = arguments;
				              if (--num === 0 && typeof callback === 'function') {
				                  callback(coll);
				              }
                          });
    while(!iter.next().done) {
        num += 1;
    }
}

function rename(method, pathname) {
    return method + '::' + pathname;
}

/*
    struct Application {
        indexes : Hash,
        routes  : Route[]
    }

    struct Route {
        regpath    : RegExp,
        method     : String,
        params     : Hash,
        generators : Genarator[]
    }
*/

export class Application extends Events.EventEmitter {
    constructor() {
        super();
        this._indexes = {};
        this._routes = [];
    }

    insert(method, pathname, ...generators) {
        if (generators.length < 1) {
            throw new Error('Application.insert: no generator');
        } 
        let routes = this._routes;
        let indexes = this._indexes;
        let type = rename(method, pathname);
        let route;
        if (type in indexes) { 
            route = routes[indexes[type]];
        } else {
        	let keys = [];
            let regpath = pregexp(pathname, keys);
            let j = 0;
            let length = keys.length;
            let params = {};
            while (j < length) {
                params[keys[j].name] = j + 1;
                j++;
            } 
            route = {
                regpath    : regpath,
                method     : method,
                params     : params,
                generators : []
            };
            routes.push(route);
            indexes[type] = routes.length - 1;
        }
        for (let g of generators) {
            route.generators.push(g);
        }
        return this;
    }

    match(req, res) {
    	let app = this;
        let routes = this._routes;
        let url = Url.parse(req.url, true);
        let method = url.query.__method ? url.query.__method.toLowerCase() : req.method.toLowerCase(); 
        let input = null;
        for (let route of routes) {
        	if (route.method === method) {
        		input = route.regpath.exec(url.pathname);
        		if (input !== null) {
                    req.params = {};
                    for (let key in route.params) {
                        req.params[key] = input[route.params[key]];
                    }
                    req.protocol = url.protocol;
                    req.auth     = url.auth;
                    req.hostname = url.hostname;
                    req.port     = url.port;
                    req.pathname = url.pathname;
                    req.query    = url.query;
                    req.hash     = url.hash;
                    app.emit('found', route, req, res);
                    return true;
                }
        	}
        }
        // not exists route
        app.emit('notfound', req, res);
        return false;
    }

    exec(route, req, res, ...context) {
        let app = this;
        let iters = [];
	    let mainIter;
	    let iter = (function* () {}());
	    let ynext = function (...ctx) {
	        if (mainIter.next(ctx).done) {
	            app.emit('finish', req, res);
	        }
	    };
        for (let i = route.generators.length - 1; i >= 0; i--) {
            iter = route.generators[i](ynext, iter, req, res, ...context);
            iters.unshift(iter);
        }
	    mainIter = iters[0];
	    if (mainIter.next().done) {
	        app.emit('finish', req, res);
	    }
        return app;
    }

    get(pathname, ...generators) {
        this.insert('get', pathname, ...generators);
        return this;
    }

    post(pathname, ...generators) {
        this.insert('post', pathname, ...generators);
        return this;
    }

    delete (pathname, ...generators) {
        this.insert('delete', pathname, ...generators);
        return this;
    }

    put(pathname, ...generators) {
        this.insert('put', pathname, ...generators);
        return this;
    }

    head(pathname, ...generators) {
        this.insert('head', pathname, ...generators);
        return this;
    }
}

export function createApplication() {
    return new Application();
}

export function request(opt, callback) {
    let req = http.request(opt, (res) => { 
        let data = '';
        res.setEncoding('utf8');
        res.on('data', function (d) {
            data += d;
        });
        res.on('end', function () {
        	if (res.headers['content-type'] === 'application/json') {
        		try {
        			res.body = JSON.parse(data);
        		} catch (e) {
        			res.body = {};
        		}
        	} else {
        		res.body = data;
        	}
            callback(res);
        });
    }); 
    if (typeof opt.body === 'string' || opt.body instanceof Buffer) {
        req.end(opt.body);
    } else if (typeof opt.body === 'object' && opt.body !== null) {
        req.end(JSON.stringify(opt.body));
    } else {
        req.end();
    }
}

export function curry(f/*, length*/) {
    let length = typeof arguments[1] === 'number' && arguments[1] > 0 ? arguments[1] : f.length;
    return (function recurry (args) {
        return function (/*arg1, arg2, ...*/) {
            if (arguments.length === 0) throw new TypeError('Function called with no arguments');
            let newArgs = args.concat(Array.prototype.slice.call(arguments, 0));
            return newArgs.length >= length ? f.apply(this, newArgs) : recurry(newArgs);
        };
    }([])); 
}

/*	
      head:node(next,prev)    fnode:mnode(next, data)
	* --> * --> * --> * --> *
	^                       ^
	|                       |
	+-----------------------+

    struct FileData {
        filename     : String,
        filetype     : String,
        basename     : String,
        deep         : Number,
        offset       : Number,
        index        : Number,
        parentOffset : Number
    }
*/

export function readFiles(filename, options) {
    let nodes = [{
        filename     : filename,
        filetype     : 'F',
        basename     : Path.basename(filename),
        deep         : 0,
        offset       : 0,
        index        : 0,
        parentOffset : -1
    }];
    let curr;
	return (function walk(i, offset, deep) { 
        curr = nodes[i];
		if (typeof curr === 'undefined') { 
            return options.callback(null, nodes);
        }
        Fs.stat(curr.filename, (err, stats) => {
        	if (err) {
                options.callback(err, null);
            } else {
            	offset = deep === curr.deep ? offset : -1;
            	if (stats.isFile()) {
                    curr.filetype = 'F';
            		if (typeof options.read === 'string' 
                        || (typeof options.read === 'object' && options.read !== null)) {
                        Fs.readFile(curr.filename, options.read, (err, content) => {
                            if (err) {
                                options.callback(err, null);
                            } else {
                                curr.content = content; 
                                options.foundFile(curr);
                                walk(i + 1, offset, curr.deep);
                            }
                        });
                    } else {
                        options.foundf(curr);
                        walk(i + 1, offset, curr.deep);
                    }
            	} else if (stats.isDirectory()) {
            		Fs.readdir(curr.filename, (err, names) => {
                        if (err) {
                            callback(err, null);
                        } else {
                            let n = 0, childDeep = curr.deep + 1;
                            names.forEach((name, i) => {
                                if (typeof options.ignore === 'function' && options.ignore(name)) {
                                    return;
                                }
                                nodes.push({
                                    filename     : Path.join(curr.filename, name),
                                    filetype     : 'F',
                                    basename     : name,
                                    deep         : childDeep,
                                    offset       : offset + n + 1,
                                    index        : n,
                                    parentOffset : curr.offset
                                });
                                n = n + 1;
                            });
                            curr.filetype = 'D';
                            options.foundDir(curr);
                            walk(i + 1, offset + n, curr.deep);
                        }
                    });
            	} else {
            		walk(i + 1, offset, curr.deep);
            	}
            }
        });
	}(0, -1, -1));
}

export function readFilesSync(filename, options) {
    let nodes = [{
        filename     : filename,
        filetype     : 'F',
        basename     : Path.basename(filename),
        deep         : 0,
        offset       : 0,
        index        : 0,
        parentOffset : -1
    }];
    let curr;
	return (function walk(i, offset, deep) { 
		curr = nodes[i];
        if (typeof curr === 'undefined') { 
            return options.callback(null, nodes);
        }
        try {
        	var stats = Fs.statSync(curr.filename);
        } catch (e) {
        	return options.callback(e, null);
        }
        offset = deep === curr.deep ? offset : -1;
        if (stats.isFile()) {
    		curr.filetype = 'F';
    		if (typeof options.read === 'string' 
                || (typeof options.read === 'object' && options.read !== null)) {
    			try {
    				var content = Fs.readFileSync(curr.filename, options.read);
    			} catch (e) {
        			return options.callback(e, null);
        		}
        		// setFileContent(curr.data, content);
                curr.content = content; 
                options.foundFile(curr);
                walk(i + 1, offset, curr.deep);
            } else {
                options.foundf(curr);
                walk(i + 1, offset, curr.deep);
            }
    	} else if (stats.isDirectory()) {
    		try {
    			var names = Fs.readdirSync(curr.filename);
    		} catch (e) {
    			return options.callback(e, null);
    		}
    		var n = 0, childDeep = curr.deep + 1; 
            names.forEach((name, i) => {
                if (typeof options.ignore === 'function' && options.ignore(name)) {
                    return;
                }
                nodes.push({
                    filename     : Path.join(curr.filename, name),
                    filetype     : 'F',
                    basename     : name,
                    deep         : childDeep,
                    offset       : offset + n + 1,
                    index        : n,
                    parentOffset : curr.offset
                });
                n = n + 1;
            });
            curr.filetype = 'D';
            options.foundDir(curr);
            walk(i + 1, offset + n, curr.deep);
    	} else {
    		walk(i + 1, offset, curr.deep);
    	}
    }(0, -1, -1));
}

/*
console.log('\x1B[36m%s\x1B[0m', info);  //cyan
console.log('\x1B[33m%s\x1b[0m:', path);  //yellow
var styles = {
    'bold'          : ['\x1B[1m',  '\x1B[22m'],
    'italic'        : ['\x1B[3m',  '\x1B[23m'],
    'underline'     : ['\x1B[4m',  '\x1B[24m'],
    'inverse'       : ['\x1B[7m',  '\x1B[27m'],
    'strikethrough' : ['\x1B[9m',  '\x1B[29m'],
    'white'         : ['\x1B[37m', '\x1B[39m'],
    'grey'          : ['\x1B[90m', '\x1B[39m'],
    'black'         : ['\x1B[30m', '\x1B[39m'],
    'blue'          : ['\x1B[34m', '\x1B[39m'],
    'cyan'          : ['\x1B[36m', '\x1B[39m'],
    'green'         : ['\x1B[32m', '\x1B[39m'],
    'magenta'       : ['\x1B[35m', '\x1B[39m'],
    'red'           : ['\x1B[31m', '\x1B[39m'],
    'yellow'        : ['\x1B[33m', '\x1B[39m'],
    'whiteBG'       : ['\x1B[47m', '\x1B[49m'],
    'greyBG'        : ['\x1B[49;5;8m', '\x1B[49m'],
    'blackBG'       : ['\x1B[40m', '\x1B[49m'],
    'blueBG'        : ['\x1B[44m', '\x1B[49m'],
    'cyanBG'        : ['\x1B[46m', '\x1B[49m'],
    'greenBG'       : ['\x1B[42m', '\x1B[49m'],
    'magentaBG'     : ['\x1B[45m', '\x1B[49m'],
    'redBG'         : ['\x1B[41m', '\x1B[49m'],
    'yellowBG'      : ['\x1B[43m', '\x1B[49m']
};
*/
export function describe(description, data) {
	if (typeof data === 'object' && data !== null) {
		data = JSON.stringify(data, null, 4);
	} else if (data === '') {
		data = '';
    } else {
		data = String(data);
	}
	console.log('\n\x1B[32m→ %s\x1B[39m\n\n\x1B[36m%s\x1B[0m\n', 
                description, 
                data);
}

```

test-rocore.js
---------------

```
import * as Rocore from '../lib/rocore';
import      Assert from 'assert';
import      Path   from 'path';

Rocore.scc(function* (ynext) {
	var v = 0;
	[v] = yield (setTimeout(() => ynext(2 + v), 100));
	Assert.strictEqual(v, 2);
	[v] = yield (setTimeout(() => ynext(1 + v), 100));
	Assert.strictEqual(v, 3);
});

Rocore.mcc(function* (ynext) {
	var v = 0;
	yield (setTimeout(() => ynext('a')(2 + v), 100));
	yield (setTimeout(() => ynext('b')(1 + v), 100));
}, (ctx) => {
	Assert.strictEqual(ctx.a[0], 2);
	Assert.strictEqual(ctx.b[0], 1);
});

var app = new Rocore.Application();
var value = 0;

app.put('/:username+/e', 
	    function* (ynext, next) {value += 1; console.log('value 1:', value); yield* next;}, 
	    function* (ynext, next) {value += 1; console.log('value 2:', value); yield* next;})
   .on('found', (route, req, res) => {
	   app.exec(route, req, res);
   })
   .on('finish', (route, req, res) => {
       console.log('finish');		
       Assert.strictEqual(value, 2);
   });
var match = app.match({method: 'put', url: 'http://127.0.0.1:8000/a/a/e'}, null);
Assert.ok(match);

Rocore.readFiles(Path.join(__dirname, './files'), {
	                 read: 'utf-8',
	                 ignore: function (basename) { 
	                     return /~$/.test(basename);
	                 },
					 foundFile: function (data) {
                         console.log('file', data);	
					 },
					 foundDir: function (data) {
                         console.log('directory', data);	
					 },
				     callback: function (err, list) {
                     	 console.log(list);
				     }
	            });

Rocore.readFilesSync(Path.join(__dirname, './files'), {
		                read: 'utf-8',
		                ignore: function (basename) { 
		                    return /~$/.test(basename);
		                },
						foundFile: function (data) {
	                        console.log('file', data);	
						},
						foundDir: function (data) {
	                        console.log('directory', data);	
						},
					    callback: function (err, list) {
	                     	console.log(list);
					    }
	                });

Rocore.describe('Description data', {data:'hello'});
Rocore.describe('Description data', 'hello');
Rocore.describe('Description data', {data:'hello'});
```