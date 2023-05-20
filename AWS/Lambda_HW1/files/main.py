# AWS Lambda example
import json
def lambda_handler(event, context):
    return {
        'statusCode': 200,
        "headers": {
            "Content-Type": "application/json"
        },
        'body': json.dumps(
        {
            'ok': True,
            'result': 'Hello, AWS Serverless'
        }
        )
    }