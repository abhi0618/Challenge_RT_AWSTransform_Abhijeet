#!/bin/bash

# Variables (Set these at the beginning of the script)
S3_BUCKET_NAME="s3-pace-data-bucket"
LAMBDA_FUNCTION_NAME="your-lambda-function-name"

# Create an S3 event notification to trigger Lambda
aws s3api put-bucket-notification-configuration \
    --bucket $S3_BUCKET_NAME \
    --notification-configuration '{
        "LambdaFunctionConfigurations": [
            {
                "LambdaFunctionArn": "arn:aws:lambda:your-region:your-account-id:function:'$LAMBDA_FUNCTION_NAME'",
                "Events": ["s3:ObjectCreated:*"]
            }
        ]
    }'

echo "S3 trigger set for Lambda function $LAMBDA_FUNCTION_NAME."
