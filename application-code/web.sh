#!/bin/bash
set -euo pipefail

echo "=== Starting web.sh script ==="

WEB_SRC="/home/ec2-user/application-code/web-tier"
WEB_DST="/home/ec2-user/web-tier"

echo "Cleaning old web directory..."
rm -rf "$WEB_DST"
mkdir -p "$WEB_DST"

echo "Copying web-tier source..."
cp -r "$WEB_SRC"/* "$WEB_DST"/

echo "Fixing ownership..."
chown -R ec2-user:ec2-user "$WEB_DST"

echo "Running Node.js build as ec2-user..."

su - ec2-user <<'EOF'
set -e

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

# Install Node.js 24
nvm install 24
nvm use 24
nvm alias default 24

cd $HOME/web-tier

npm install
npm run build

EOF

echo "Setting permission for nginx to read web-tier..."
chmod -R 755 /home/ec2-user
chmod -R 755 /home/ec2-user/web-tier
chmod -R 755 /home/ec2-user/web-tier/build
chown -R ec2-user:nginx /home/ec2-user/web-tier

echo "Writing nginx.conf..."
cat <<'NGINXEOF' > /etc/nginx/nginx.conf
user nginx;
worker_processes auto;

error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    include /etc/nginx/conf.d/*.conf;

    server {
        listen 80;
        listen [::]:80;
        server_name _;

        # health
        location /health {
            default_type text/html;
            return 200 "<h1>Web Tier Healthy</h1>\n";
        }

        # backend API
        location /api/ {
            rewrite ^/api/(.*)$ /$1 break;

            proxy_pass http://internal-app-1443345930.ap-south-1.elb.amazonaws.com:80/;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        # React app
        location / {
            root /home/ec2-user/web-tier/build;
            index index.html;
            try_files $uri /index.html;
        }
    }
}
NGINXEOF

echo "Testing nginx..."
nginx -t

echo "Restarting nginx..."
systemctl restart nginx
systemctl enable nginx

echo "=== Web tier deployed successfully ==="
