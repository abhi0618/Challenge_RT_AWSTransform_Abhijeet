#!/bin/bash

BUCKET_NAME="s3-pace-data-bucket"
LAMBDA_FUNCTION_NAME="ProcessAndUpdateS3File"
REGION="us-east-1"
ACCOUNT_ID="920373008443"

echo "🔐 Adding Lambda invoke permission from S3..."
aws lambda add-permission \
  --function-name "$LAMBDA_FUNCTION_NAME" \
  --principal s3.amazonaws.com \
  --statement-id s3invoke \
  --action "lambda:InvokeFunction" \
  --source-arn arn:aws:s3:::$BUCKET_NAME \
  --source-account "$ACCOUNT_ID"

echo "🔁 Setting S3 Event Notification for pace-data.csv only..."
aws s3api put-bucket-notification-configuration --bucket "$BUCKET_NAME" \
  --notification-configuration "{
    \"LambdaFunctionConfigurations\": [
      {
        \"LambdaFunctionArn\": \"arn:aws:lambda:$REGION:$ACCOUNT_ID:function:$LAMBDA_FUNCTION_NAME\",
        \"Events\": [\"s3:ObjectCreated:*\"],
        \"Filter\": {
          \"Key\": {
            \"FilterRules\": [
              {
                \"Name\": \"suffix\",
                \"Value\": \"pace-data.csv\"
              }
            ]
          }
        }
      }
    ]
  }"
