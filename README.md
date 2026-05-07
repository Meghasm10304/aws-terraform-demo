# Automated Cloud Infrastructure Provisioning Using Terraform and AWS

## Project Overview
This project demonstrates automated provisioning of AWS cloud infrastructure using Terraform.  
It eliminates manual setup by defining infrastructure as code, ensuring reproducibility, scalability, and security.

## Problem Statement
Manual cloud provisioning is slow, error-prone, and insecure.  
This project solves it by automating infrastructure provisioning and deployment using Terraform and AWS.

## Solution Approach
- **Infrastructure as Code (IaC):** Modular Terraform configurations for VPC, EC2, ALB, and Auto Scaling Group.
- **Security:** IAM roles, deny-by-default security groups, encrypted remote state in S3 with DynamoDB locking.
- **Scalability:** Auto Scaling Group behind an Application Load Balancer.
- **Monitoring:** CloudWatch, CloudTrail, VPC Flow Logs, and WAF.

## Technology Stack
- Terraform (HCL)
- AWS VPC, Subnets, Internet Gateway, NAT Gateway, Route Tables
- AWS EC2 (Auto Scaling Group + Launch Template)
- AWS Application Load Balancer (ALB)
- AWS IAM, Security Groups
- AWS S3 + DynamoDB (state management)
- AWS CloudWatch, CloudTrail, WAF

## Prerequisites
- AWS account with appropriate IAM permissions
- Terraform installed (latest version recommended)
- AWS CLI configured with credentials
- Git installed for version control

## Setup Instructions
1. Clone the repository:
   ```bash
   git clone https://github.com/<your-username>/<repo-name>.git
   cd <repo-name>
Initialize Terraform:

   ```bash
   terraform init

Review the plan:
```bash
   terraform plan

Apply the configuration:

```bash
   terraform apply

Usage
Running terraform apply provisions the infrastructure:

VPC with public and private subnets

Internet Gateway and NAT Gateway

EC2 instances in an Auto Scaling Group

Application Load Balancer with security group

Monitoring resources (CloudWatch, CloudTrail, VPC Flow Logs, WAF)

After deployment, Terraform outputs will include identifiers such as the ALB DNS name.
Use the ALB DNS name to access the application.

**Architecture**
The architecture consists of:

A VPC with public and private subnets

Public subnet containing ALB, NAT Gateway, and Bastion Host

Private subnet containing EC2 instances in an Auto Scaling Group

Terraform state stored in S3 with DynamoDB for state locking

Monitoring and logging with CloudWatch, CloudTrail, and VPC Flow Logs

Security enforced with IAM roles, security groups, and WAF

**Screenshots**
(Add screenshots of AWS Console resources such as VPC, ALB, EC2 Auto Scaling Group, and CloudWatch dashboards.)

**Author**
Intern: Meghana M

Email: meghasm1023@gmail.com

Date: May 2026
