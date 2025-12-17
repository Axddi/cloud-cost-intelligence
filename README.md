Cloud Cost Intelligence Platform 
A production-grade, serverless cloud cost monitoring system built on AWS that automatically tracks daily service-wise cloud costs, persists historical data, and sends proactive alerts when spending exceeds defined thresholds.

This project demonstrates real-world cloud engineering, FinOps principles, and Infrastructure as Code (IaC) using Terraform.

Project Objective
Build an automated, cloud-native system to monitor AWS costs, store daily cost history, and notify stakeholders when cloud spending crosses safe limits — without manual intervention.

High-Level Architecture

EventBridge (Daily Scheduler)
          ↓
AWS Lambda (Cost Collector)
          ↓
AWS Cost Explorer
          ↓
DynamoDB (Cost History Storage)
          ↓
SNS (Email Alerts)

Tech Stack

AWS Lambda – Serverless compute

AWS Cost Explorer – Cost analytics

Amazon DynamoDB – Persistent cost storage

Amazon EventBridge – Daily automation

Amazon SNS – Email notifications

Amazon CloudWatch – Logs & monitoring

Terraform – Infrastructure as Code

Python (boto3) – AWS SDK

Terraform Infrastructure Breakdown

Each Terraform file has a clear responsibility, following production IaC standards.

provider.tf
Initializes AWS as the cloud provider and sets the deployment region.


provider "aws" {
  region = var.aws_region
}

variables.tf

Centralized configuration for:

AWS region

Alert email

Environment flexibility

iam.tf (Security & Least Privilege)

Creates:

IAM Role for Lambda

Trust policy (Lambda can assume role)

Fine-grained permissions:

Cost Explorer (read-only)

DynamoDB (write-only)

SNS (publish only)

CloudWatch Logs

Follows least-privilege IAM design

lambda.tf
![alt text](<Screenshot 2025-12-17 184727.png>)

Defines the AWS Lambda function:

Python 3.11 runtime

Connects IAM role

Injects environment variables

Packages source code automatically

logs.tf
![alt text](<Screenshot 2025-12-17 184816.png>)
![alt text](<Screenshot 2025-12-17 185000.png>)

Creates a dedicated CloudWatch log group:

Controlled log retention (7 days)

Prevents unlimited logging costs

eventbridge.tf
![alt text](<Screenshot 2025-12-17 184916.png>)

Schedules the Lambda function:

Runs once per day

Fully serverless automation

No manual triggers needed

dynamodb.tf
![alt text](<Screenshot 2025-12-17 184841.png>)

Creates the cloud-cost-history table:

Partition key: date

Sort key: service

On-demand billing (cost-efficient)

sns.tf

Creates:

SNS topic for alerts

Email subscription for notifications

Lambda Function Logic

The Lambda performs the following steps:

Fetches yesterday’s AWS cost data

Groups costs service-wise (EC2, S3, RDS, etc.)

Stores each service cost in DynamoDB

Calculates total daily spend

Sends an alert email if threshold is exceeded

Features

Fully automated daily cost tracking

Service-wise cost breakdown

Persistent historical cost data

Budget threshold alerting

Serverless & scalable

Infrastructure as Code (Terraform)

Production IAM security model

Real-World Use Cases

FinOps cost monitoring

Cloud budget governance

Early detection of cloud overspending

DevOps & SRE cost visibility

Project Status

Fully deployed
Automated & monitored
Production-ready

Future Enhancements

Web dashboard (React + API Gateway)

Multi-account AWS support

Cost trend visualization

Monthly budget forecasting