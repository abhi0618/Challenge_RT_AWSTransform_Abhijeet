#!/bin/bash

# === Variables ===
FUNCTION_NAME="s3-rds-transformation-function"
ROLE_NAME="lambda-rds-s3-role"
ZIP_FILE="s3_rds_function_package.zip"
HANDLER="s3_rds_function_package.s3_rds_lambda_function.lambda_handler"
RUNTIME="python3.11"
TIMEOUT=30
MEMORY=512
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# === Create Lambda Function ===
aws lambda create-function \
  --function-name $FUNCTION_NAME \
  --runtime $RUNTIME \
  --role arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME \
  --handler $HANDLER \
  --timeout $TIMEOUT \
  --memory-size $MEMORY \
  --zip-file fileb://$ZIP_FILE \
  --region $REGION
