import boto3
import os

dynamodb = boto3.resource("dynamodb")

TABLE_NAME = os.environ.get("TABLE_NAME", "cloud-cost-history")

def lambda_handler(event, context):
    table = dynamodb.Table(TABLE_NAME)

    # Expect date as query param later (default: latest)
    date = event.get("queryStringParameters", {}).get("date")

    if not date:
        return {
            "statusCode": 400,
            "body": "Missing required query parameter: date"
        }

    response = table.query(
        KeyConditionExpression=boto3.dynamodb.conditions.Key("date").eq(date)
    )

    return {
        "statusCode": 200,
        "body": response["Items"]
    }
