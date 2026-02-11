# INSTALLING nginx
```bash
#!/bin/bash
sudo -su ec2-user
cd /home/ec2-user
```
```bash
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
sudo service nginx restart
sudo chkconfig nginx on
sudo yum install git -y
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

# in lieu of restarting the shell
\. "$HOME/.nvm/nvm.sh"

# Download and install Node.js:
nvm install 24

# Verify the Node.js version:
node -v # Should print "v24.13.1".

# Verify npm version:
npm -v # Should print "11.8.0".

```




## !!! IMP  --USER DATA SCRIPT !!!
## MODIFY BELOW CODE WITH YOUR S3 BUCKET NAME

```bash
#!/bin/bash
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "*** USER DATA STARTED ***"

export HOME=/home/ec2-user

yum update -y
yum install -y awscli dos2unix -y

mkdir -p /home/ec2-user/application-code
chown ec2-user:ec2-user /home/ec2-user/application-code

aws s3 cp s3://3-tier-s3bucket-10-02-2026/application-code/ /home/ec2-user/application-code --recursive

cd /home/ec2-user/application-code

# CRUCIAL FIX
dos2unix web.sh

chmod +x web.sh
bash web.sh

echo "*** USER DATA COMPLETED ***"
```


# Replace the Internal-alb-address in the nginx

# Create the Cloudtrial
my-aws-account-activity

Select --> Event History
