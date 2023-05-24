import os
import io
import json

import boto3

S3 = boto3.resource('s3')

BUCKET_NAME = os.environ['S3_BUCKET']
KEY = os.environ['S3_KEY']
BUCKET = S3.Bucket(BUCKET_NAME)


def lambda_handler(event, context):
    fobj = io.BytesIO()
    BUCKET.download_fileobj(KEY, fobj)
    fobj.seek(0)

    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': fobj.read()
    }