#!/bin/bash

LAMBDA_FUNCTION_NAME="ProcessAndUpdateS3File"
ZIP_PATH="/mnt/e/Users/GithubRepos/RioTintoCodingChallenge/StepB/function.zip"
ROLE_NAME="lambda-s3-rds-role"
ACCOUNT_ID="920373008443"
REGION="us-east-1"


echo "🚀 Creating Lambda Function..."
aws lambda create-function \
  --function-name "$LAMBDA_FUNCTION_NAME" \
  --zip-file fileb://$ZIP_PATH \
  --handler lambda_function.lambda_handler \
  --runtime python3.11 \
  --role arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME\
  --profile admin-profile\
  --region "$REGION" \
  --debug \
  


  

  ##Update the Lambda function with new zip file (if needed to update)

  ##aws lambda update-function-code --function-name $LAMBDA_FUNCTION_NAME --zip-file fileb://function.zip
  
  ## Or Upload from an S3 bucket

  aws lambda update-function-code \
  --function-name $LAMBDA_FUNCTION_NAME \
  --s3-bucket s3-pace-data-bucket \
  --s3-key function.zip
