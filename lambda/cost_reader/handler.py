import boto3
import os
import json
from boto3.dynamodb.conditions import Key
from decimal import Decimal

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["TABLE_NAME"]

def convert_decimals(obj):
    if isinstance(obj, list):
        return [convert_decimals(i) for i in obj]
    elif isinstance(obj, dict):
        return {k: convert_decimals(v) for k, v in obj.items()}
    elif isinstance(obj, Decimal):
        return float(obj)
    else:
        return obj

def lambda_handler(event, context):
    print("EVENT:", json.dumps(event))

    table = dynamodb.Table(TABLE_NAME)

    params = event.get("queryStringParameters") or {}
    date = params.get("date")

    if not date:
        return {
            "statusCode": 400,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "error": "Missing required query parameter: date"
            }),
            "isBase64Encoded": False
        }

    response = table.query(
        KeyConditionExpression=Key("date").eq(date)
    )

    result = response.get("Items", [])

 
    result = convert_decimals(result)

    print("RESPONSE:", json.dumps(result))

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(result),
        "isBase64Encoded": False
    }
