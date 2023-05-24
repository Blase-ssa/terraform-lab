import json
import os
import io

import boto3


S3_BUCKET = os.environ['S3_BUCKET']
S3_KEY = os.environ['S3_KEY']

s3_client = boto3.client('s3')


def lambda_handler(event, context):
    for record in event['Records']:
        # we put record.body into the key
        s3_client.upload_fileobj(
            io.BytesIO(bytes(record['body'], 'utf8')),
            S3_BUCKET,
            S3_KEY
        )
    print('OK')

