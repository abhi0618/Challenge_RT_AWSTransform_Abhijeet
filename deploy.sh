#!/bin/bash

# Set environment variables
STACK_NAME="riotinto-challenge-stack"
S3_BUCKET_NAME="s3-pace-data"
LAMBDA_CODE_S3_BUCKET="code-s3-bucket"
LAMBDA_CODE_ZIP="/mnt/e/Users/GithubRepos/RioTintoCodingChallenge/lambda_code.zip"
CF_TEMPLATE="/mnt/e/Users/GithubRepos/RioTintoCodingChallenge/cloudformation-template.yaml"
AWS_REGION="us-east-1"

# Function to deploy CloudFormation stack
deploy_stack() {
    echo "Deploying CloudFormation stack: $STACK_NAME..."

    aws cloudformation deploy \
      --stack-name $STACK_NAME \
      --template-file $CF_TEMPLATE \
      --capabilities CAPABILITY_NAMED_IAM \
      --region $AWS_REGION

    if [ $? -eq 0 ]; then
        echo "CloudFormation stack deployed successfully."
    else
        echo "Failed to deploy CloudFormation stack."
        exit 1
    fi
}

# Function to retrieve CloudFormation stack outputs
get_cf_outputs() {
    echo "Retrieving CloudFormation stack outputs..."

    DB_HOST=$(aws cloudformation describe-stacks \
        --stack-name $STACK_NAME \
        --query "Stacks[0].Outputs[?OutputKey=='DBHost'].OutputValue" \
        --output text \
        --region $AWS_REGION)

    DB_NAME=$(aws cloudformation describe-stacks \
        --stack-name $STACK_NAME \
        --query "Stacks[0].Outputs[?OutputKey=='DBName'].OutputValue" \
        --output text \
        --region $AWS_REGION)

    DB_USER=$(aws cloudformation describe-stacks \
        --stack-name $STACK_NAME \
        --query "Stacks[0].Outputs[?OutputKey=='DBUser'].OutputValue" \
        --output text \
        --region $AWS_REGION)

    DB_PASSWORD=$(aws cloudformation describe-stacks \
        --stack-name $STACK_NAME \
        --query "Stacks[0].Outputs[?OutputKey=='DBPassword'].OutputValue" \
        --output text \
        --region $AWS_REGION)

    echo "DB Host: $DB_HOST"
    echo "DB Name: $DB_NAME"
    echo "DB User: $DB_USER"
    echo "DB Password: $DB_PASSWORD"
}

# Function to upload Lambda code to S3
upload_lambda_code_to_s3() {
    echo "Uploading Lambda code to S3 bucket: $LAMBDA_CODE_S3_BUCKET..."

    aws s3 cp $LAMBDA_CODE_ZIP s3://$LAMBDA_CODE_S3_BUCKET/lambda-code.zip --region $AWS_REGION

    if [ $? -eq 0 ]; then
        echo "Lambda code uploaded successfully."
    else
        echo "Failed to upload Lambda code."
        exit 1
    fi
}

# Function to trigger Lambda by uploading a test file to S3
trigger_lambda_function() {
    echo "Uploading test file (pace-data.csv) to S3 bucket: $S3_BUCKET_NAME..."

    # Create a sample pace-data.csv file for testing
    echo "Creating pace-data.csv file for testing..."
    echo "existing_column" > pace-data.csv
    echo "5" >> pace-data.csv
    echo "10" >> pace-data.csv
    echo "15" >> pace-data.csv

    aws s3 cp pace-data.csv s3://$S3_BUCKET_NAME/pace-data.csv --region $AWS_REGION

    if [ $? -eq 0 ]; then
        echo "Test file uploaded successfully. Lambda function should be triggered."
    else
        echo "Failed to upload test file."
        exit 1
    fi
}

# Function to check CloudFormation stack status
check_stack_status() {
    echo "Checking CloudFormation stack status..."

    STACK_STATUS=$(aws cloudformation describe-stacks \
        --stack-name $STACK_NAME \
        --query "Stacks[0].StackStatus" \
        --output text \
        --region $AWS_REGION)

    if [ "$STACK_STATUS" == "CREATE_COMPLETE" ]; then
        echo "Stack creation complete!"
    else
        echo "Stack creation failed or is in progress. Current status: $STACK_STATUS"
        exit 1
    fi
}

# Function to check Lambda logs in CloudWatch
check_lambda_logs() {
    echo "Checking Lambda execution logs in CloudWatch..."

    LOG_GROUP_NAME="/aws/lambda/processFileFunctiononTrigger"  # Your Lambda function's log group
    LOG_STREAM_NAME="log-stream"  # Can be modified based on your Lambda function's log stream

    # Fetch logs from CloudWatch (you can specify a specific log stream or fetch the latest logs)
    aws logs filter-log-events \
        --log-group-name $LOG_GROUP_NAME \
        --limit 5 \
        --region $AWS_REGION

    if [ $? -eq 0 ]; then
        echo "Lambda logs retrieved successfully."
    else
        echo "Failed to fetch Lambda logs."
        exit 1
    fi
}

# Main function to run all tasks
main() {
    deploy_stack
    get_cf_outputs  # Get DB details from CloudFormation outputs
    upload_lambda_code_to_s3
    check_stack_status
    trigger_lambda_function
    check_lambda_logs
}

# Run the script
main
