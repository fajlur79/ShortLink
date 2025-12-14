resource "aws_security_group" "nginx_lb_sg" {
  name        = "ShortLink-Nginx-LB-SG"
  description = "Allow HTTP from the world"
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

resource "aws_instance" "nginx_lb" {
  ami           = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  
  
  vpc_security_group_ids = [aws_security_group.nginx_lb_sg.id]

  tags = {
    Name = "ShortLink-LoadBalancer"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              
              ${templatefile("footconfig.sh",{
                foot_terminfo   = file("foot.terminfo.tpl")

              })}

              cat <<'EOT' > /etc/nginx/conf.d/shortlink.conf
              ${templatefile("${path.module}/nginx.conf.tpl", {
                server1_ip = aws_instance.server.private_ip
                server2_ip = aws_instance.server_2.private_ip
              })}
              EOT
              
              
              systemctl enable nginx
              systemctl start nginx
              EOF
}

output "load_balancer_ip" {
  value = aws_instance.nginx_lb.public_ip
}