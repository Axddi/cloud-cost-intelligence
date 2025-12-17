# Cost Collector Lambda

This AWS Lambda function fetches daily AWS service-wise costs using the
AWS Cost Explorer API.

## Responsibilities
- Fetch yesterday's AWS costs
- Group costs by service
- Return structured cost data

## AWS Permissions Required (later)
- ce:GetCostAndUsage

## Status
🚧 Code complete, deployment pending
