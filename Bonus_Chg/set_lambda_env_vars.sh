#!/bin/bash

# Variables (Set these at the beginning of the script)
LAMBDA_FUNCTION_NAME="your-lambda-function-name"
DB_HOST="your-db-hostname"  # Use the endpoint of the RDS instance
DB_NAME="your-db-name"
DB_USER="your-db-user"
DB_PASSWORD="your-db-password"

# Set environment variables for Lambda function
aws lambda update-function-configuration \
    --function-name $LAMBDA_FUNCTION_NAME \
    --environment "Variables={DB_HOST=$DB_HOST,DB_NAME=$DB_NAME,DB_USER=$DB_USER,DB_PASSWORD=$DB_PASSWORD}"

echo "Environment variables set for Lambda function $LAMBDA_FUNCTION_NAME."

