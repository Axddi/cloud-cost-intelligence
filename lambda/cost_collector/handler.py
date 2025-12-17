import boto3
from datetime import datetime, timedelta
import os

dynamodb = boto3.resource("dynamodb")
ce = boto3.client("ce")
sns = boto3.client("sns")

TABLE_NAME = os.environ["TABLE_NAME"]
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]
DAILY_THRESHOLD = float(os.environ.get("DAILY_THRESHOLD", "5"))

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
        GroupBy=[{"Type": "DIMENSION", "Key": "SERVICE"}]
    )

    total_cost = 0

    for group in response["ResultsByTime"][0]["Groups"]:
        service = group["Keys"][0]
        cost = float(group["Metrics"]["UnblendedCost"]["Amount"])
        total_cost += cost

        table.put_item(
            Item={
                "date": str(yesterday),
                "service": service,
                "cost": cost
            }
        )

    if total_cost > DAILY_THRESHOLD:
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject="AWS Daily Cost Alert",
            Message=f"Daily AWS cost for {yesterday} exceeded threshold.\nTotal Cost: ${total_cost:.2f}"
        )

    return {
        "date": str(yesterday),
        "total_cost": total_cost,
        "alert_sent": total_cost > DAILY_THRESHOLD
    }
