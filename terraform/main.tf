data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "app_sg" {
  name        = "ShortLink-Server-SG"
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
    security_groups = [aws_security_group.nginx_lb_sg.id]
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
  
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  lifecycle {
    ignore_changes = [ami]
  }

  user_data = templatefile("setup.sh", {
    nginx_config          = file("../nginx/nginx.conf")
    docker_compose_config = file("../docker-compose.yml")
    foot_terminfo         = file("foot.terminfo.tpl")
})


  tags = {
    Name = "ShortLink-App-Server"
  }
}

resource "aws_instance" "server_2" { 
  ami           = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  
  instance_type = "t3.micro"
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  
  lifecycle {
    ignore_changes = [ami]
  }

  user_data = templatefile("setup.sh", {
    nginx_config          = file("../nginx/nginx.conf")
    docker_compose_config = file("../docker-compose.yml")
    foot_terminfo         = file("foot.terminfo.tpl")
})


  tags = {
    Name = "ShortLink-App-Server-2"
  }
}

resource "aws_eip" "server_1_eip" {
  instance = aws_instance.server.id
  domain   = "vpc"
}

resource "aws_eip" "server_2_eip" {
  instance = aws_instance.server_2.id
  domain   = "vpc"
}

resource "aws_eip" "lb_eip" {
  instance = aws_instance.nginx_lb.id
  domain   = "vpc"
}



#output "load_balancer_dns" {
#  value = aws_lb.app_lb.dns_name
#}

output "server_1_static_ip" {
  value = aws_eip.server_1_eip.public_ip
}

output "server_2_static_ip" {
  value = aws_eip.server_2_eip.public_ip
}

output "load_balancer_static_ip" {
  value = aws_eip.lb_eip.public_ip
}