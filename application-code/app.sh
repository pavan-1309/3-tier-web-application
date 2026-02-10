#!/bin/bash
set -euo pipefail

echo "Starting app.sh script..."

APP_DIR="/home/ec2-user/app-tier"
SRC_DIR="/home/ec2-user/application-code/app-tier"

echo "Cleaning old app directory..."
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR"

echo "Copying app-tier code..."
cp -r "$SRC_DIR"/* "$APP_DIR"/

echo "Fixing ownership..."
sudo chown -R ec2-user:ec2-user "$APP_DIR"

echo "Running Node.js setup as ec2-user..."

su - ec2-user <<'EOF'
set -e
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

cd $HOME/app-tier

npm install
npm install -g pm2

pm2 delete all || true
pm2 start index.js --name app-tier
pm2 startup systemd -u ec2-user --hp /home/ec2-user
pm2 save

pm2 status
EOF

echo "App tier setup complete!"
