upstream backend_servers {
    server ${server1_ip}:80 max_fails=3 fail_timeout=30s;
    server ${server2_ip}:80 max_fails=3 fail_timeout=30s;
}

server {
    listen 80;
        
    location / {
        proxy_pass http://backend_servers;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;


        proxy_set_header Cookie $http_cookie;
        proxy_pass_request_headers on;
    }
}
