#!/bin/bash

# Variables (Set these at the beginning of the script)
LAMBDA_FUNCTION_NAME="your-lambda-function-name"
ZIP_FILE="lambda-deployment-package.zip"

# Update Lambda function with the deployment package
aws lambda update-function-code \
    --function-name $LAMBDA_FUNCTION_NAME \
    --zip-file fileb://$ZIP_FILE

echo "Lambda function $LAMBDA_FUNCTION_NAME deployed successfully."
