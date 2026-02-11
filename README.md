# AWS Three Tier Web Architecture Workshop

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

| SG name             | Inbound Port | Access Source                    | Description                                     |
|---------------------|--------------|----------------------------------|-------------------------------------------------|
| Jump Server         | 22           | MY-ip                            | Access from my laptop                           |
| web-frontend-alb    | 80           | 0.0.0.0/0                        | All access from internet                        |
| Web-srv-sg          | 80, 22       | web-frontend-alb, jump-server    | Only front-alb and jump server access           |
| app-Internal-alb-sg | 80           | Web-srv-sg                       | Only web-srv                                    |
| app-Srv-sg          | 4000, 22     | app-Internal-alb-sg, jump-server | Only app-Internal-alb-sg and jump server access |
| DB-srv              | 3306, 22     | app-Srv-sg, jump-server          | Only app-srv and jump server access             |

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

| #  | Component        | Name/Route Table           | CIDR/Details  | NAT Gateway |
|----|------------------|----------------------------|---------------|-------------|
| 1  | Internet Gateway | 3-tier-igw                 |               |             |
| 3  | NAT Gateway      | 3-tier-1a                  |               |             |
|    |                  | 3-tier-1b                  |               |             |
|    |                  | 3-tier-1c                  |               |             |
| 10 | Route Table      | 3-tier-Public-rt           |               |             |
|    |                  | 3-tier-web-Private-rt-1a   | 10.0.64.0/20  | nat-1a      |
|    |                  | 3-tier-web-Private-rt-1b   | 10.0.80.0/20  | nat-1b      |
|    |                  | 3-tier-web-Private-rt-1c   | 10.0.96.0/20  | nat-1c      |
|    |                  | 3-tier-app-Private-rt-1a   | 10.0.112.0/20 | nat-1a      |
|    |                  | 3-tier-app-Private-rt-1b   | 10.0.128.0/20 | nat-1b      |
|    |                  | 3-tier-app-Private-rt-1c   | 10.0.144.0/20 | nat-1c      |
|    |                  | 3-tier-db-Private-rt-1a    | 10.0.160.0/20 | nat-1a      |
|    |                  | 3-tier-db-Private-rt-1b    | 10.0.176.0/20 | nat-1b      |
|    |                  | 3-tier-db-Private-rt-1c    | 10.0.192.0/20 | nat-1c      |

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

git clone https://github.com/pavan-1309/3-tier-web-application.git

1.  3-tier-aws-project-8745
2.  3tier-vpc-flow-log-8745 (attach immediately)

## Create a Mysql in the RDS

### First Create the subnet Group

| Parameter | Value                                                                |
|-----------|----------------------------------------------------------------------|
| Name      | three-subnet-gp-rds                                                  |
| VPC       | three-tier-rds-subnetgroup                                           |
| AZ        | 1a, b, c                                                             |
| Subnets   | DB-Private-Subnet-1a, DB-Private-Subnet-1b, DB-Private-Subnet-1c    |

### DB Parameters

| Parameter              | Value              |
|------------------------|--------------------|
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
chown -R ec2-user:ec2-user /home/ec2-user/application-code
cd /home/ec2-user/application-code
dos2unix app.sh
chmod +x app.sh
bash app.sh
echo "=== App Tier User-data Completed ==="
```

## Create Target Groups

| Tier     | Name     | Port | Health-check |
|----------|----------|------|--------------|
| Web Tier | Web-tier | 80   | /            |
| App Tier | App-tier | 4000 | /health      |

## Create Load Balancers

| LB Name | Type            | Subnets             | SG                  | Listener       |
|---------|-----------------|---------------------|---------------------|----------------|
| app-alb | Internal-facing | App-private-subnets | app-Internal-alb-sg | 80 -> app-tier |
| web-alb | Internet-facing | Public subnets      | web-frontend-alb    | 80 -> web-tier |

## Create Auto Scaling Groups

| Name         | Launch Template | Instance | Subnets     | LB       | Desired | Min | Max | Notifications |
|--------------|-----------------|----------|-------------|----------|---------|-----|-----|---------------|
| web-tier-asg | web-tier-lb     | t2.micro | Web subnets | web-tier | 3       | 3   | 6   | web-tier-sns  |
| app-tier-asg | app-tier-lb     | t2.micro | App subnets | app-tier | 3       | 3   | 6   | app-tier-sns  |

## Configure CloudWatch Alarms

1. **Web Tier CPU Alarm**
   - Metric: CPUUtilization > 70%
   - Action: Scale up web-tier-asg
   - SNS: Cloudwatch-sns

2. **App Tier CPU Alarm**
   - Metric: CPUUtilization > 70%
   - Action: Scale up app-tier-asg
   - SNS: Cloudwatch-sns

3. **RDS Connection Alarm**
   - Metric: DatabaseConnections > 80
   - SNS: Cloudwatch-sns

## Setup CloudFront Distribution

1. **Origin**: web-alb DNS name
2. **Viewer Protocol**: Redirect HTTP to HTTPS
3. **Allowed HTTP Methods**: GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE
4. **Cache Policy**: CachingOptimized
5. **Origin Protocol**: HTTP only

## Configure ACM (SSL Certificate)

1. Request public certificate
2. Domain name: yourdomain.com, *.yourdomain.com
3. Validation: DNS validation
4. Attach to CloudFront distribution

## Setup WAF (Web Application Firewall)

1. **Web ACL Name**: 3-tier-waf
2. **Resource**: CloudFront distribution
3. **Rules**:
   - AWS Managed Rules - Core rule set
   - AWS Managed Rules - Known bad inputs
   - Rate limiting: 2000 requests per 5 minutes

## Configure Route 53

1. **Hosted Zone**: yourdomain.com
2. **Record**:
   - Name: www.yourdomain.com
   - Type: A (Alias)
   - Target: CloudFront distribution

## Testing

1. Access CloudFront URL or custom domain
2. Verify web tier loads correctly
3. Test database connectivity through app tier
4. Check auto-scaling triggers
5. Monitor CloudWatch metrics
6. Verify SNS notifications

## Cleanup

1. Delete CloudFront distribution
2. Delete Auto Scaling Groups
3. Delete Load Balancers
4. Delete Target Groups
5. Delete Launch Templates
6. Delete RDS instance
7. Delete NAT Gateways
8. Delete VPC
9. Delete S3 buckets
10. Delete CloudWatch alarms
11. Delete SNS topics
12. Delete Secrets Manager secrets
13. Delete CloudTrail
14. Delete WAF Web ACL
15. Delete Route 53 records

## Architecture Diagram

```
Internet
    |
    v
Route 53 → CloudFront (CDN) → WAF
                |
                v
        Internet Gateway
                |
                v
        Public Subnets (3 AZs)
                |
                v
        Web ALB (Internet-facing)
                |
                v
        Web Tier ASG (Private Subnets)
                |
                v
        App ALB (Internal)
                |
                v
        App Tier ASG (Private Subnets)
                |
                v
        RDS MySQL (Multi-AZ)
```

## Cost Optimization Tips

- Use t3.micro instead of t2.micro for better performance
- Enable RDS automated backups with 7-day retention
- Use S3 lifecycle policies for old logs
- Delete unused NAT Gateways during testing
- Use Reserved Instances for production

## Security Best Practices

✅ All instances in private subnets
✅ Security groups with least privilege
✅ Database credentials in Secrets Manager
✅ VPC Flow Logs enabled
✅ CloudTrail for audit logging
✅ WAF for application protection
✅ SSL/TLS encryption with ACM
✅ IAM roles instead of access keys

## Monitoring & Alerts

- CloudWatch dashboards for all tiers
- SNS notifications for critical events
- VPC Flow Logs in S3
- CloudTrail logs for API activity
- RDS performance insights
- ALB access logs

---

**Project Status**: ✅ Production Ready

**Last Updated**: February 2026
