#!/bin/bash

IAM_USER_NAME="abhrj5665-s3-bucket-user"
POLICY_NAME="AmazonS3FullAccess"

# 1. Create the IAM user
echo "Creating IAM user: $IAM_USER_NAME"
aws iam create-user --user-name "$IAM_USER_NAME"

# 2. Attach S3 full access policy to the user
echo "Attaching S3FullAccess policy..."
aws iam attach-user-policy \
  --user-name "$IAM_USER_NAME" \
  --policy-arn "arn:aws:iam::aws:policy/$POLICY_NAME"

# 3. Create access key for the user
echo "Creating access keys for user..."
aws iam create-access-key --user-name "$IAM_USER_NAME"
