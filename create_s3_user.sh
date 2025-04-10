#!/bin/bash

# Define the IAM user and policy
IAM_USER_NAME="abhrj5665-s3-bucket-user"
POLICY_NAME="AmazonS3FullAccess"

# Step 1: Create the IAM user
echo "Creating IAM user: $IAM_USER_NAME"
aws iam create-user --user-name "$IAM_USER_NAME"

# Step 2: Attach S3 full access policy to the user
echo "Attaching AmazonS3FullAccess policy to $IAM_USER_NAME..."
aws iam attach-user-policy \
  --user-name "$IAM_USER_NAME" \
  --policy-arn "arn:aws:iam::aws:policy/$POLICY_NAME"

# Step 3: Create access keys for the user
echo "Creating access keys for user: $IAM_USER_NAME..."
aws iam create-access-key --user-name "$IAM_USER_NAME" > access_keys.json

# Extract and display the Access Key ID and Secret Access Key
ACCESS_KEY_ID=$(jq -r '.AccessKey.AccessKeyId' access_keys.json)
SECRET_ACCESS_KEY=$(jq -r '.AccessKey.SecretAccessKey' access_keys.json)

echo "Access Key ID: $ACCESS_KEY_ID"
echo "Secret Access Key: $SECRET_ACCESS_KEY"

# Save the credentials to an .env file 
echo "AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID" >> .env
echo "AWS_SECRET_ACCESS_KEY=$SECRET_ACCESS_KEY" >> .env

echo "IAM user $IAM_USER_NAME has been created successfully with the policy $POLICY_NAME."
echo "Access keys have been saved to .env (if needed)."

