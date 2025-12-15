user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;


events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;
    sendfile            on;
    keepalive_timeout   65;

    
    upstream backend_servers {
        server ${server1_ip}:80 max_fails=3 fail_timeout=30s;
        server ${server2_ip}:80 max_fails=3 fail_timeout=30s;
    }

    server {
        listen 80;
        server_name shorts.codes www.shorts.codes;
        return 301 https://$host$request_uri;
    }

    
    server {
        listen 443 ssl;
        server_name shorts.codes www.shorts.codes;

        ssl_certificate /etc/letsencrypt/live/shorts.codes/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/shorts.codes/privkey.pem;

        location / {
            proxy_pass http://backend_servers;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}