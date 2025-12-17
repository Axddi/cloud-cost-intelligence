import boto3
from datetime import datetime, timedelta
import os

def lambda_handler(event, context):


    ce = boto3.client("ce")

    today = datetime.utcnow().date()
    yesterday = today - timedelta(days=1)

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

    costs = []

    for group in response["ResultsByTime"][0]["Groups"]:
        service_name = group["Keys"][0]
        amount = float(group["Metrics"]["UnblendedCost"]["Amount"])

        costs.append({
            "service": service_name,
            "cost": amount
        })

    return {
        "date": str(yesterday),
        "service_costs": costs
    }
