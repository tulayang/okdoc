server.js
----------

```
//@ •·→¸﹋ ﹌ ﹊ ˊ︽︾︿﹀︹︺︷︸︵︶﹄﹃︼︻〖【〗】«»‹›「」『』
//@
//@ -- https://twitter.com/ukyoi
//@    https://twitter.com/:username
//@ 
//@ -- https://twitter.com/ukyoi/media
//@    https://twitter.com/:username/media
//@ 
//@ -- https://twitter.com/ukyoi/media/572437280117243905
//@    https://twitter.com/ukyooooooooooooooooi/media/572437280117243905
//@    https://twitter.com/:username/media/:mediaId
//@

import * as Auth       from './user/auth'; 
import * as Account    from './user/account'; 
import * as Task       from './task';
import * as Fans       from './fans';
import * as Follower   from './follower';
import * as Media      from './media';
import * as Comment    from './comment';
import * as Space      from './space';
import * as Watcher    from './watcher';
import * as Rocore     from 'rocore';
import      Http       from 'http';
import      Qs         from 'querystring';
import      Fs         from 'fs';
import      Path       from 'path';
import      Formidable from 'formidable';
import      conf       from './conf';

let server = Http.createServer(),
    app    = Rocore.createApplication();
    
app
    .on('found', (route, req, res) => { 
        let incoming = new Formidable.IncomingForm(),
            body = {};
        req.cookies = Qs.parse(req.headers.cookie, /;\s*/, '=');  
        incoming.keepExtensions = conf.incoming.keepExtensions;
        incoming.uploadDir      = conf.incoming.uploadDir;
        incoming.multiples      = conf.incoming.multiples;
        incoming.maxFieldsSize  = conf.incoming.maxFieldsSize; 
        incoming
            .on('file', (name, file) => {
                if (!(body[name] instanceof Array)) {
                    body[name] = [];
                }
                body[name].push(file);
            })
            .on('field', (name, value) => { 
                body[name] = value; 
            })
            .on('end', () => {  
                req.body = body;  
                req.method = (req.body.__method || req.method).toLowerCase();
                app.exec(route, req, res);
            })
            .parse(req); 
    })  
    .on('notfound', (req, res) => { 
        res.writeHead(404);
        res.end('404 not found');
    })
    .get   ('/demos', Auth.authUser, demos)
    .get   ('/js/:item*', getSource(conf.publicPath, 'text/javascript'))
    .get   ('/source/:item*', getSource(conf.rootPath, 'image/jpeg'))
    .get   ('/join', getJoin)
    .post  ('/join', Auth.join)
    .get   ('/login', getLogin)
    .post  ('/login', Auth.login)
    .get   ('/logout', Auth.authUser, Auth.logout)
    .post  ('/users/:username/fans', Auth.authUser, Auth.isUser, Fans.create)
    .delete('/users/:username/fans', Auth.authUser, Auth.isUser, Fans.destroy)
    .post  ('/users/:username/followers', Auth.authUser, Auth.isUser, Follower.create)
    .delete('/users/:username/followers', Auth.authUser, Auth.isUser, Follower.destroy)
    .get   ('/tasks', Auth.authUser, Task.index)
    .get   ('/tasks/randoms', Auth.authUser, Task.showRandoms)
    .post  ('/tasks', Auth.authUser, Task.create)
    .put   ('/tasks/:taskId/locked', Auth.authUser, Task.lock)
    .put   ('/tasks/:taskId/pushed', Auth.authUser, Task.push)
    .put   ('/tasks/:taskId/accepted', Auth.authUser, Task.save, Task.accept)
    .get   ('/users/:username/tasks/published', Auth.authUser, Auth.isUser, Task.showPublishes) 
    .get   ('/users/:username/tasks/finished', Auth.authUser, Auth.isUser, Task.showFinishes)
    .post  ('/users/:username/medias/:mediaId/comments', Auth.authUser, Media.exists, Comment.create)
    .put   ('/users/:username/medias/:mediaId/comments/:commentId', Auth.authUser, Comment.exists, Comment.update)
    .delete('/users/:username/medias/:mediaId/comments/:commentId', Auth.authUser, Comment.exists, Comment.destroy) 
    .get   ('/users/:username/medias/:mediaId', Auth.authUser, Media.exists, Media.showWithComments)
    .get   ('/users/:username/medias', Auth.authUser, Auth.isUser, Media.showMedias)
    .get   ('/users/:username', Auth.authUser, Auth.isUser, Space.index)
    .post  ('/users/:username/icos', Auth.authUser, Account.saveIco)
    .get   ('/watching', Watcher.get)
    ;

server
    .on('request', (req, res) => { 
        app.match(req, res); 
    })
    .on('error', (error) => { 
        console.log('Server Nodejs %s', error); 
    })
    .on('listening', () => { 
        Watcher.watching(server);
        console.log('Server Nodejs online listening %s %d', conf.hostname, conf.port); 
    })
    .listen(conf.port, conf.hostname)
    ;


// Web测试 

import * as page    from './view/page';
import * as Session from './user/session';

function getSource(rootPath, content_type) {
    return function* (ynext, next, req, res) { 
        let pathname = Path.join(rootPath, decodeURI(req.pathname)),
            fmtime, 
            rmtime; 
        Fs.stat(pathname, (err, stats) => {
            if (err || !stats.isFile()) {
                res.writeHead(404);
                return res.end();
            } 
            rmtime = req.headers['if-modified-since'] 
                        ? (new Date(req.headers['if-modified-since'])).getTime() 
                        : 0;
            fmtime = new Date(stats.mtime.toString()).getTime();
            if (fmtime - rmtime > 0) { 
                res.writeHead(200, {
                    'cache-control' : 'max-age=31536000',
                    'last-modified' : stats.mtime.toString(),
                    'content-type'  : content_type
                });
                Fs.createReadStream(pathname).pipe(res);
            } else {
                res.writeHead(304, {
                    'cache-control' : 'max-age=31536000',
                    'content-type'  : content_type
                });
                res.end();
            }
        });
    }    
}

function* getJoin(ynext, next, req, res) { 
    if (req.cookies.sid) {
        let [err, user] = yield Session.get(req.cookies.sid, ynext); 
        if (err) {
            res.writeHead(500);
            return res.end();
        } 
        if (user) { 
            res.writeHead(302, { 'location':'/users/' + user.username });
            return res.end();
        }
    }   
    res.writeHead(200, { 'content-type':'text/html' });
    res.end(page.join);
}

function* getLogin(ynext, next, req, res) {
    if (req.cookies.sid) {
        let [err, user] = yield Session.get(req.cookies.sid, ynext);
        if (err) {
            res.writeHead(500);
            res.end();
            return;
        } 
        if (user) { 
            res.writeHead(302, { 'location':'/users/' + user.username });
            res.end();
            return;
        }
    }   
    res.writeHead(200, { 'content-type':'text/html' });
    res.end(page.login);
}

function* demos(ynext, next, req, res) { 
    res.writeHead(200, { 'content-type':'text/html' });
    res.end(page.demo(req.session.username)); 
}


```