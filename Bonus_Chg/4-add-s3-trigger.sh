#!/bin/bash

# === Variables ===
BUCKET_NAME="s3-pace-data-bucket"
FUNCTION_NAME="s3-rds-transformation-function"
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# === Add Permission for S3 to Invoke Lambda ===
aws lambda add-permission \
  --function-name $FUNCTION_NAME \
  --statement-id s3invoke \
  --action "lambda:InvokeFunction" \
  --principal s3.amazonaws.com \
  --source-arn arn:aws:s3:::$BUCKET_NAME \
  --region $REGION

# === Set Notification Configuration for S3 ===
cat <<EOF > s3-notification-config.json
{
  "LambdaFunctionConfigurations": [
    {
      "LambdaFunctionArn": "arn:aws:lambda:$REGION:$ACCOUNT_ID:function:$FUNCTION_NAME",
      "Events": ["s3:ObjectCreated:*"],
      "Filter": {
        "Key": {
          "FilterRules": [
            {
              "Name": "suffix",
              "Value": "pace-data.csv"
            }
          ]
        }
      }
    }
  ]
}
EOF

aws s3api put-bucket-notification-configuration \
  --bucket $BUCKET_NAME \
  --notification-configuration file://s3-notification-config.json
