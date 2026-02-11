# App-tier Setup 
## INSTALLING MYSQL IN AMAZON LINUX 2023
```bash
#!/bin/bash
sudo su - ec2-user
sudo wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
sudo dnf install mysql80-community-release-el9-1.noarch.rpm -y
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023
sudo dnf install mysql-community-client -y
mysql --version
```

## TO TEST CONNECTION BETWEEN APP-SERVER & DATABASE SERVER
```bash
mysql -h <RDS-Endpoint> -u <username> -p <Hit Enter & provide your password>
```

# INSTALLING Aws-Cli
# (REF: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```
# INSTALLING NODEJS 
# (REF: https://nodejs.org/en/download/)	
```bash
# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# Load nvm without restarting the shell
\. "$HOME/.nvm/nvm.sh"

# Download and install Node.js (latest LTS 24)
nvm install 24

# Verify Node.js & npm versions
node -v   # Should print "v24.13.1"
npm -v    # Should print "11.8.0"

# Install pm2 globally
npm install -g pm2

# Install yarn globally
npm install -g yarn

# Verify pm2 & yarn
pm2 -v
yarn -v
```

## !!! IMP  --USER DATA SCRIPT !!!
## MODIFY BELOW CODE WITH YOUR S3 BUCKET NAME

```bash
#!/bin/bash
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "=== App Tier User-data Started ==="

export HOME=/home/ec2-user

yum update -y
yum install -y awscli dos2unix -y

mkdir -p /home/ec2-user/application-code

aws s3 cp s3://<your source code bucket name>/application-code/ /home/ec2-user/application-code/ --recursive

# FIX PERMISSIONS
chown -R ec2-user:ec2-user /home/ec2-user/application-code

cd /home/ec2-user/application-code

dos2unix app.sh
chmod +x app.sh

bash app.sh

echo "=== App Tier User-data Completed ==="


```
curl http://localhost:4000/health #(To do the health check)
