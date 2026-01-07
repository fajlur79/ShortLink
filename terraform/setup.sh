#!/bin/bash

yum update -y
yum install -y docker git
service docker start
usermod -a -G docker ec2-user

mkdir -p /usr/local/lib/docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

mkdir -p /var/www/ShortLink/nginx

cat <<'TERMINFO_EOT' > /tmp/foot.terminfo
${foot_terminfo}
TERMINFO_EOT
export TERM=xterm
/usr/bin/tic -x /tmp/foot.terminfo 


cat <<'EOT' > /var/www/ShortLink/nginx/nginx.conf
${nginx_config}
EOT

cat <<'EOT' > /var/www/ShortLink/docker-compose.yml
${docker_compose_config}
EOT

cat <<'EOT' > /var/www/ShortLink/alert_rules.yml
${alert_config}
EOT

cat <<'EOT' > /var/www/ShortLink/prometheus.yml
${prometheus_config}
EOT



chown -R ec2-user:ec2-user /var/www/ShortLink

cd /var/www/ShortLink
PORT=${app_port} REDIS_URL=${redis_url} BASE_URL=${domain_name} docker compose up -d