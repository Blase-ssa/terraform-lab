import json
import os

import boto3


SQS_URL = os.environ['SQS_URL']
SQS = boto3.client('sqs')


def lambda_handler(event, context):
    payload = event['body']
    resp = SQS.send_message(
        QueueUrl=SQS_URL,
        DelaySeconds=10,
        MessageBody = payload
    )
    return {
        'statusCode': 200,
        "headers": {
             "Content-Type": "application/json"
        },
        'body': json.dumps(
        {
            'ok': True,
            'result': resp['MessageId']
        }
        )
    }
