```
user  king  root;
worker_processes  4;

pid        logs/nginx.pid;
error_log  logs/error.log  info;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

	client_max_body_size         2M;
	client_body_buffer_size      128k;
	client_body_in_file_only     off;
	client_body_timeout          60;

	client_header_buffer_size    1K; 
	large_client_header_buffers  4 4K;
	client_header_timeout        60;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;

    gzip  on;
	gzip_buffers     16 8k;
	gzip_comp_level  6;
    gzip_vary        on;
    gzip_min_length  1000;
    gzip_proxied     any;
    gzip_types       text/plain text/css text/xml  text/javascript  
                     application/json application/x-javascript application/xml application/xml+rss;

    upstream node {
		ip_hash;
        server    127.0.0.1:8000;
        server    127.0.0.1:8001;
        keepalive 64;
    }

    server {
        listen       127.0.0.1:80;
        server_name  localhost;

        #access_log  logs/host.access.log  main;

        location  ~* (?:^\/(?:audio|video|img|js|css|flash|media)\/)|robots\.txt$|humans\.txt$|favicon\.ico$ {
            root       /home/king/node_worker/test/public/;
			access_log off;
          	expires    max;
        }

		location  ~ ^/(images)/ {
            root       /home/node_worker/test/images/;
			access_log off;
			add_header Cache-Control no-store;
        }

		location / {
			proxy_redirect         off;
			proxy_set_header       X-Real-IP        $remote_addr;
            proxy_set_header       X-Forwarded-For  $proxy_add_x_forwarded_for;
            proxy_set_header       Host             $host;
            proxy_set_header       X-NginX-Proxy    true;
            proxy_set_header       Connection "";
            proxy_http_version     1.1;
            proxy_pass             http://node;
			proxy_connect_timeout  15;
			proxy_send_timeout     15;
			proxy_read_timeout     15;
        }
	}
}
```
