#!/bin/bash

yum update -y
yum install -y docker
service docker start
usermod -a -G docker ec2-user

mkdir -p /usr/local/lib/docker/cli-plugins/
curl -SL  https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

mkdir -p /home/ec2-user/Shortener/code/nginx

cat <<'TERMINFO_EOT' > /tmp/foot.terminfo
${foot_terminfo}
TERMINFO_EOT
export TERM=xterm

/usr/bin/tic -x /tmp/foot.terminfo 
              
/usr/bin/infocmp foot > /var/log/foot_terminfo_check.log 2>&1

            

cat <<'EOT' > /home/ec2-user/Shortener/code/nginx/nginx.conf
${nginx_config}
EOT

cat <<'EOT' > /home/ec2-user/Shortener/code/docker-compose.yml
${docker_compose_config}
EOT

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
MY_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "PUBLIC_IP=$MY_IP" >/home/ec2-user/Shortener/code/.env

chown -R ec2-user:ec2-user /home/ec2-user/Shortener

