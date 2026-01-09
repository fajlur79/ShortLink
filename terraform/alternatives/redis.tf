resource "aws_security_group" "redis_sg" {
  name        = "ShortLink-Redis-SG"
  description = "Allow Redis port 6379 from App Servers"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "redis_server" {
  ami           = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  
  vpc_security_group_ids = [aws_security_group.redis_sg.id]
  private_ip = "172.31.4.126"

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name = "ShortLink-Redis-DB"
  }

  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y redis6
              
              sed -i 's/^bind 127.0.0.1/bind 0.0.0.0/' /etc/redis6/redis6.conf
              
              sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis6/redis6.conf
              sed -i 's/^appendonly no/appendonly yes/' /etc/redis6/redis6.conf

              systemctl enable redis6
              systemctl start redis6
              EOF
}

output "redis_private_ip" {
  value = aws_instance.redis_server.private_ip
}