import boto3
from datetime import datetime, timedelta
import os

dynamodb = boto3.resource("dynamodb")
ce = boto3.client("ce")

TABLE_NAME = os.environ.get("TABLE_NAME", "cloud-cost-history")

def lambda_handler(event, context):
    today = datetime.utcnow().date()
    yesterday = today - timedelta(days=1)

    table = dynamodb.Table(TABLE_NAME)

    response = ce.get_cost_and_usage(
        TimePeriod={
            "Start": yesterday.strftime("%Y-%m-%d"),
            "End": today.strftime("%Y-%m-%d")
        },
        Granularity="DAILY",
        Metrics=["UnblendedCost"],
        GroupBy=[
            {
                "Type": "DIMENSION",
                "Key": "SERVICE"
            }
        ]
    )

    for group in response["ResultsByTime"][0]["Groups"]:
        service = group["Keys"][0]
        cost = float(group["Metrics"]["UnblendedCost"]["Amount"])

        table.put_item(
            Item={
                "date": str(yesterday),
                "service": service,
                "cost": cost
            }
        )

    return {
        "status": "stored",
        "date": str(yesterday)
    }
