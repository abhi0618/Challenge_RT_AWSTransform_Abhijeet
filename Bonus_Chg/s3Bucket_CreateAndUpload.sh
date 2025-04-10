#!/bin/bash

BUCKET_NAME="s3-pace-data-bucket"
FILE_TO_UPLOAD="/mnt/e/Users/GithubRepos/RioTintoCodingChallenge/pace-data.csv"

# Step 1: Create an S3 bucket 
aws s3 mb s3://$BUCKET_NAME

# Check if the bucket was created successfully
if [ $? -eq 0 ]; then
  echo "Bucket $BUCKET_NAME created successfully."
else
  echo "Bucket $BUCKET_NAME already exists or there was an error."
fi

# Step 2: Upload the CSV file to the S3 bucket
aws s3 cp $FILE_TO_UPLOAD s3://$BUCKET_NAME/

# Check if the file was uploaded successfully
if [ $? -eq 0 ]; then
  echo "File $FILE_TO_UPLOAD uploaded successfully to s3://$BUCKET_NAME/"
else
  echo "Error uploading file $FILE_TO_UPLOAD."
fi
