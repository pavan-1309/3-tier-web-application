## \# AWS Three Tier Web Architecture Workshop

    1. VPC (12 Subnets, 10 Route Tables, 1 IGW, 3 NAT)
    2. Security Group (Cross-connection)
    3. EC2
    4. Auto Scaling Group (ASG with IAM & Launch Template)
    5. ALB (2 Target Groups)
    6. IAM (for Image Build & Access Control)
    7. RDS (MySQL)
    8. Secrets Manager
    9. S3 (Data + VPC Flow Logs)
    10. Cloud Watch
    11. SNS
    12. Cloud Trail
    13. Cloud Front
    14. ACM (SSL Certificates)
    15. WAF 
    16. Route 53

## Create a Security Group

| SG name             | Inbound Port | Access Source           | Description                                    |
|---------------------|--------------|-------------------------|------------------------------------------------|
| Jump Server         | 22           | MY-ip                   | Access from my laptop                          |
| web-frontend-alb    | 80           | 0.0.0.0/0               | All access from internet                       |
| Web-srv-sg          | 80, 22       | web-frontend-alb        | Only front-alb and jump server access          |
|                     |              | jump-server             |                                                |
| app-Internal-alb-sg | 80           | Web-srv-sg              | Only web-srv                                   |
| app-Srv-sg          | 4000, 22     | app-Internal-alb-sg     | Only app-Internal-alb-sg and jump server access|
|                     |              | jump-server             |                                                |
| DB-srv              | 3306, 22     | app-Srv-sg              | Only app-srv and jump server access            |
|                     | 3306         | jump-server             |                                                |

## Create a VPC

### VPC and Subnets

| #  | Component | Name                    | CIDR / Details |
|----|-----------|-------------------------|----------------|
| 1  | VPC       | 3-tier-vpc              | 10.0.0.0/16    |
| 12 | Subnets   | Public-Subnet-1a        | 10.0.16.0/20   |
|    |           | Public-Subnet-1b        | 10.0.32.0/20   |
|    |           | Public-Subnet-1c        | 10.0.48.0/20   |
|    |           | Web-Private-Subnet-1a   | 10.0.64.0/20   |
|    |           | Web-Private-Subnet-1b   | 10.0.80.0/20   |
|    |           | Web-Private-Subnet-1c   | 10.0.96.0/20   |
|    |           | App-Private-Subnet-1a   | 10.0.112.0/20  |
|    |           | App-Private-Subnet-1b   | 10.0.128.0/20  |
|    |           | App-Private-Subnet-1c   | 10.0.144.0/20  |
|    |           | DB-Private-Subnet-1a    | 10.0.160.0/20  |
|    |           | DB-Private-Subnet-1b    | 10.0.176.0/20  |
|    |           | DB-Private-Subnet-1c    | 10.0.192.0/20  |

### Internet Gateway, NAT Gateways, and Route Tables

| #  | Component       | Name/Route Table           | CIDR/Details  | NAT Gateway |
|----|-----------------|----------------------------|---------------|-------------|
| 1  | Internet Gateway| 3-tier-igw                 |               |             |
| 3  | NAT Gateway     | 3-tier-1a                  |               |             |
|    |                 | 3-tier-1b                  |               |             |
|    |                 | 3-tier-1c                  |               |             |
| 10 | Route Table     | 3-tier-Public-rt           |               |             |
|    |                 | 3-tier-web-Private-rt-1a   | 10.0.64.0/20  | nat-1a      |
|    |                 | 3-tier-web-Private-rt-1b   | 10.0.80.0/20  | nat-1b      |
|    |                 | 3-tier-web-Private-rt-1c   | 10.0.96.0/20  | nat-1c      |
|    |                 | 3-tier-app-Private-rt-1a   | 10.0.112.0/20 | nat-1a      |
|    |                 | 3-tier-app-Private-rt-1b   | 10.0.128.0/20 | nat-1b      |
|    |                 | 3-tier-app-Private-rt-1c   | 10.0.144.0/20 | nat-1c      |
|    |                 | 3-tier-db-Private-rt-1a    | 10.0.160.0/20 | nat-1a      |
|    |                 | 3-tier-db-Private-rt-1b    | 10.0.176.0/20 | nat-1b      |
|    |                 | 3-tier-db-Private-rt-1c    | 10.0.192.0/20 | nat-1c      |

## Setup the Ec2-instance and create the IAM (WEB Tier)

Only Packages: - Nginx - nvm

## Setup the Ec2-instance and create the IAM (APP Tier)

Only Packages: - mysql client - nvm - pm2

## Create images for both web and app Tier

-   Web-Tier-IAM-IMAGE
-   APP-Tier-IAM-IMAGE

## Create a Cloud-Trail

-   Name: my-aws-Account-Activity

## Create the S3 Buckets

git clone [https://github.com/pavan-1309/3-tier-web-application.git](https://github.com/pavan-1309/3-tier-web-application.git)

1.  3-tier-aws-project-8745\
2.  3tier-vpc-flow-log-8745 (attach immediately)

## Create a Mysql in the RDS

### First Create the subnet Group

| Parameter | Value                                                      |
|-----------|------------------------------------------------------------||
| Name      | three-subnet-gp-rds                                        |
| VPC       | three-tier-rds-subnetgroup                                 |
| AZ        | 1a, b, c                                                   |
| Subnets   | DB-Private-Subnet-1a, DB-Private-Subnet-1b, DB-Private-Subnet-1c |

### DB Parameters

| Parameter              | Value              |
|------------------------|--------------------||
| DB instance identifier | db-3tier           |
| Master username        | admin              |
| Password               | SuperadminPassword |
| Instance class         | db.t3.small        |
| Storage                | 20GB               |
| VPC                    | 3-tier-vpc         |
| Security Group         | db-srv             |

## Secrets Manager

    DB_HOST=<your rds Endpoint>
    DB_USER=admin
    DB_PWD=SuperadminPassword
    DB_DATABASE=webappdb

## Insert Data into RDS

``` bash
mysql -h <RDS-ENDPOINT> -u admin -p
```

``` sql
CREATE DATABASE webappdb;
USE webappdb;
CREATE TABLE IF NOT EXISTS transactions(id INT NOT NULL AUTO_INCREMENT, amount DECIMAL(10,2), description VARCHAR(100), PRIMARY KEY(id));
INSERT INTO transactions (amount,description) VALUES ('400','groceries');
SELECT * FROM transactions;
```

## Create SNS Topics

-   web-tier-sns
-   app-tier-sns
-   Cloudwatch-sns

## Create IAM Roles

### Web Role:

-   AmazonS3ReadOnlyAccess
-   AmazonSSMManagedInstanceCore

### App Role:

-   AmazonS3ReadOnlyAccess
-   AmazonSSMManagedInstanceCore
-   SecretsManagerReadWrite

## Create Web Launch Template

User Data:

``` bash
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

## Create App Launch Template

User Data:

``` bash
#!/bin/bash
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1
echo "=== App Tier User-data Started ==="
export HOME=/home/ec2-user
yum update -y
yum install -y awscli dos2unix -y
mkdir -p /home/ec2-user/application-code
aws s3 cp s3://3-tier-s3bucket-10-02-2026/application-code/ /home/ec2-user/application-code/ --recursive
# FIX PERMISSIONS
chown -R ec2-user:ec2-user /home/ec2-user/application-code
cd /home/ec2-user/application-code
dos2unix app.sh
chmod +x app.sh
bash app.sh
echo "=== App Tier User-data Completed ==="
```

## Create Target Groups

| Tier     | Name     | Port | Health-check |
|----------|----------|------|--------------||
| Web Tier | Web-tier | 80   | /            |
| App Tier | App-tier | 4000 | /health      |

## Create Load Balancers

| LB Name | Type            | Subnets             | SG                  | Listener        |
|---------|-----------------|---------------------|---------------------|-----------------||
| app-alb | Internal-facing | App-private-subnets | app-Internal-alb-sg | 80 -> app-tier  |
| web-alb | Internet-facing | Public subnets      | web-frontend-alb    | 80 -> web-tier  |

## Create Auto Scaling Groups

| Name         | Launch Template | Instance | Subnets     | LB       | Desired | Min | Max | Notifications |
|--------------|-----------------|----------|-------------|----------|---------|-----|-----|---------------||
| web-tier-asg | web-tier-lb     | t2.micro | Web subnets | web-tier | 3       | 3   | 6   | web-tier-sns  |
| app-tier-asg | app-tier-lb     | t2.micro | App subnets | app-tier | 3       | 3   | 6   | app-tier-sns  |

## CloudWatch

-   all alarms → EC2 → ASG → CPU utilization

## CloudFront

## ACM

## WAF

## Route53
