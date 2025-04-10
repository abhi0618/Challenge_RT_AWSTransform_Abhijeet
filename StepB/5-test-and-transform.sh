#!/bin/bash

# Variables
BUCKET_NAME="s3-pace-data-bucket"
S3_FILE_PATH="/mnt/e/Users/GithubRepos/RioTintoCodingChallenge/pace-data.csv" # Adjust path to the test file
ENRICHED_FILE="enriched.csv"
AWS_PROFILE="admin-profile"  # Set your AWS profile if required

# Upload test file to S3
echo "🔼 Uploading test file pace-data.csv to S3 bucket..."
aws s3 cp "$S3_FILE_PATH" s3://"$BUCKET_NAME"/ --profile "$AWS_PROFILE"

# Wait for Lambda to trigger and process (this may take a few seconds to a minute)
echo "⏳ Waiting for Lambda to process the file..."

# Optional: Add a short wait time to let Lambda trigger, adjust as needed
sleep 30

# Verify that the enriched.csv file exists in the bucket
echo "🔍 Checking if enriched.csv exists in the S3 bucket..."
aws s3 ls s3://"$BUCKET_NAME"/"$ENRICHED_FILE" --profile "$AWS_PROFILE"

# Check if the file is found and print the result
if [ $? -eq 0 ]; then
    echo "✅ Enriched file found: $ENRICHED_FILE"
else
    echo "❌ Enriched file not found!"
fi
