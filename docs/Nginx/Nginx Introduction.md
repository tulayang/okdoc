nginx.conf
----------

    user  name  group;                        配置运行nginx进程的用户名用户组
    worker_processes  4;                      配置nginx进程数

    pid        logs/nginx.pid;                配置存放pid文件路径
    error_log  logs/error.log info;           配置错误文件路径、记录级别
                                              [debug info notice warn error crit]

    events{}                                  events模块，配置网络

    worker_connections  1024;                 配置nginx进程最大连接数
    accept_mutex        on;                   配置启用接受互斥锁打开套接字侦听
    accept_mutex_delay  500ms;                配置nginx进程再次获取资源前等待的时间

    http{}                                    http模块，配置http通信

server区段
----------

    server{}                                  server模块，配置服务器

    server_name  website.com  website.net;    配置主机名，对比请求头的host
    listen       127.0.0.1:80;                配置服务器侦听的套接字使用的IP地址和端口号
    listen       443 ssl;

location区段
------------

    location{}                                location模块，配置路由[= ~ ~* ^~ @]

    root     /var/www/                        配置访问的物理路径
    expires  max;                             配置缓存过期时间[max off time]
    expires  3d;

以下内容均可在http{...} server{...} location{...}定义
--------------------------------------------------

    include mime.types                        加载文件
    include node/static.conf

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"'; 

    access_log logs/access.log  main;         配置访问的客户端信息

    gzip  on;                                 配置启用GZIP压缩，
                                              响应体发送到客户端前进行GZIP算法压缩
    gzip_buffers     4 4k;                    配置存储响应头压缩的缓存数和大小
    gzip_comp_level  1;                       配置压缩级别[1 ~ 9]
    gzip_min_length  1000;                    配置低于该值的响应体不压缩
    gzip_proxied     any;                     配置启用压缩的策略
                                              [off any expired no-cache no_last_modified not_etag]
    gzip_types       text/plain ...;          配置压缩的MIME类型
    gzip_vary        on;                      配置向响应数据包中添加
                                              Vary:Accept-Encoding响应头
    gzip_window      MAX_WBITS;               配置窗口缓冲大小
    gzip_no_buffer   off;                     配置禁用TCP缓冲策略

    types{...}                                配置MIME--文件扩展名映射，
                                              结果放入响应头Content-Type
    default_type  text/plain;                 配置types找不到正确的扩展名映射使用的默认方式

    keepalive_out       75;                   配置keep-alive连接超时时间
    keepalive_requests  100;                  配置单个keep-alive连接提供的最大请求数

    send_timeout  60;                         配置传输超时时间，如果超时，关闭连接

    client_body_timeout          60;          配置请求体传输时，非活动的超时时间(秒)
                                              ，返回408错误，停止传输数据
    client_max_body_size         1M;          配置请求体最大值，如果超过，
                                              返回413错误(文件上传)
    lingering_time               30;          配置请求体超量时，等待关闭连接的时间
    client_body_buffer_size      8K|16K;      配置请求体缓存大小，如果超过，把请求体写到磁盘
    client_body_in_file_only     off;         配置请求体磁盘写入[off clean on]
    client_body_tmp_path         tmp;         配置请求体磁盘写入时的文件路径

    client_header_timeout        60;          配置请求头传输时，
                                              非活动的超时时间(秒)，返回408错误，停止传输数据
    client_header_buffer_size    1K;
                                              配置请求头缓存大小，通常1K;
                                              当有较大COOKIE或者较长URL，可以通过->
    large_client_header_buffers  4 4K;
                                              配置请求头较大时，分配的缓存个数和大小;
                                              请求头每一行大小不得超过1个缓存！
    ignore_invalid_headers       on;          配置忽略错误的请求头

    sendfile  on;                             配置启用sendfile内核调用处理文件传递

    tcp_nodelay  on;                          配置启用TCP_NODELAY(nagle缓冲算法)
                                              ，当经常发送小数据包时，可以禁用

    port_in_redirect  on;                     配置启用端口重定向

    if_modified_since  exact;                 配置If-Modified-Since逻辑，
                                              用户缓存策略[off exact before]，
                                              exact:  准确匹配时间，返回304，否则返回200
                                              before: 在文件修改时间之前或相同，返回304，否则返回200

    error_page  404  /not_found.html;         配置响应码，修改响应码，重定向文件
    error_page  404 =200 /not_found.html;
    error_page  500 501 /server_error.html;
    error_page  403 http://website.com;

    add_header  Cache-Control  no-store;      配置响应头
    add_header  Content-Type  text/plain;

SSL 只能用于http{} server{}区段
------------------------------

    ssl  on;                                  配置开启SSL
    ssl_certificate         cert/cert.pem;    配置PEM公钥路径
    ssl_certificate_key     cert/key.pem;     配置PEM密钥路径
    ssl_client_certificate  cert/c_cert.pem;  配置客户端PEM公钥存放路径
    ssl_protocols           SSLv2;            配置安全连接协议
    ssl_ciphers             ...;              配置使用的密码
    ssl_verify_client       off;              配置开启校验客户端提供的证书
    ssl_verify_depth        1;                配置校验客户端证书的深度
    ssl_session_cache       off;              配置SSL会话的缓存
    ssl_session_timeout     5m;               配置SSL会话过期时间

access代理模块
--------------

    allow  127.0.0.1;                         配置允许访问的IP
    deny   all;                               配置禁止访问的IP

proxy代理模块
------------

    proxy_pass  http://hostname:port;         配置代理目标HOSTNAME:PORT
    upstream up {                             配置负载均衡服务器
        ip_hash
        server 127.0.0.1:8080;
        server 127.0.0.1:8081;
    }
    proxy_pass  http://up;

    proxy_method               POST;          配置代理请求方法
    proxy_hide_header          Date;          配置代理转发忽略的请求头
    proxy_pass_header          Date;          配置代理强制转发的请求头
    proxy_pass_request_body    on;            配置代理转发请求体
    proxy_pass_request_header  on;            配置代理转发请求头
    proxy_redirect             off;           配置改写业务服务器重定向的URL
    proxy_buffer_size          4k;            配置存放业务响应的缓冲区大小
    proxy_tmp_path             tmp/proxy;     配置临时文件和缓存文件的路径

    proxy_connect_timeout      15;            配置业务服务器连接超时时间
    proxy_read_timeout         60;            配置从业务服务器读取数据超时时间
    proxy_send_timeout         60;            配置发送到业务服务器数据超时时间

    proxy_set_body             test;          配置一个静态请求体(调试目的)
    proxy_set_header           Host  $host;   配置重定义代理请求头的值，再转发

    proxy_set_header           X-Real-IP        $remote_addr;
    proxy_set_header           X-Forwarded-For  $proxy_add_x_forwarded_for;
    proxy_set_header           Host             $host;
    proxy_set_header           X-NginX-Proxy    true;
    proxy_set_header           Connection       "";


