data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "app_sg" {
  name        = "shortener-sg-mumbai"
  description = "Allow HTTP, HTTPS, and SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "aws-sl-key"
  public_key = file(pathexpand("~/.ssh/aws-sl.pub"))
}

resource "aws_instance" "server" { 
  ami           = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  
  instance_type = "t3.micro"
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              service docker start
              usermod -a -G docker ec2-user
              
              
              mkdir -p /usr/local/lib/docker/cli-plugins/
              curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
              chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
              
             
              mkdir -p /home/ec2-user/Shortener/code/nginx
              
              cat <<EOT > /home/ec2-user/Shortener/code/nginx/nginx.conf
              events {
                  worker_connections 1024;
              }
              http {
                  server {
                      listen 80;
                      location / {
                          proxy_pass http://app:3000;
                          proxy_set_header Host \$host;
                          proxy_set_header X-Real-IP \$remote_addr;
                          proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                          proxy_set_header Cookie \$http_cookie;
                          proxy_pass_request_headers on;
                      }
                  }
              }
              EOT
              cat <<EOT > ~/Shortener/code/docker-compose.yml
              services:
                app:
                  image: ghcr.io/hawkeyexz/shortlink:latest
                  
                  container_name: shortener_app
                  restart: always

                  environment:
                    - PORT=3000
                    - REDIS_URL=redis://redis:6379
                    
                    
                  depends_on:
                    - redis

                redis:
                  image: redis:7-alpine
                  container_name: shortener_redis
                  restart: always
                  volumes:
                    - redis_data:/data

                nginx:
                  image: nginx:alpine
                  container_name: shortener_nginx
                  restart: always
                  ports:
                    - "80:80"
                  volumes:
                    - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
                  depends_on:
                    - app

              volumes:
                redis_data:

              EOT 
              chown -R ec2-user:ec2-user /home/ec2-user/Shortener
              EOF

  tags = {
    Name = "ShortLink-App-Server"
  }
}

output "server_public_ip" {
  value = aws_instance.server.public_ip
}