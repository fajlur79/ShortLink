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

  lifecycle {
    ignore_changes = [ami]
  }

  iam_instance_profile   = aws_iam_instance_profile.lb_profile.name

  tags = {
    Name = "ShortLink-LoadBalancer"
  }

 user_data = <<-EOF
#!/bin/bash
yum update -y
yum install -y nginx aws-cli unzip

echo "Downloading cert from s3"
aws s3 cp s3://${aws_s3_bucket.cert_bucket.id}/certs.zip /tmp/certs.zip

if [ -f /tmp/certs.zip ]; then
    echo "Found backup. Restoring..."
    unzip /tmp/certs.zip -d /
    chmod -R 755 /etc/letsencrypt
    rm -f /tmp/certs.zip
else
    echo "CRITICAL: No cert found in S3!"
fi


cat <<'TERMINFO_EOT' > /tmp/foot.terminfo
${file("${path.module}/foot.terminfo.tpl")}
TERMINFO_EOT

export TERM=xterm
/usr/bin/tic -x /tmp/foot.terminfo
/usr/bin/infocmp foot > /var/log/foot_terminfo_check.log 2>&1

cat <<'EOT' > /etc/nginx/nginx.conf
${templatefile("${path.module}/nginx.conf.tpl", {
server1_ip = aws_instance.server.private_ip
server2_ip = aws_instance.server_2.private_ip
})}
EOT

systemctl enable nginx
systemctl start nginx
EOF
}
