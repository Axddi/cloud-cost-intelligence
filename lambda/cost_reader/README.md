# Cost Reader Lambda

Read-only Lambda function that fetches AWS cost data
from DynamoDB for dashboard and API consumption.

## Responsibilities
- Query DynamoDB by date
- Return service-wise cost data
- Used by API Gateway (next step)

## IAM Permissions Required
- dynamodb:Query

## Status
API logic complete, gateway pending
