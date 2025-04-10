#!/bin/bash

# Variables 
ROLE_NAME="lambda-rds-s3-role"
POLICY_NAME="lambda-rds-s3-policy" #This should be in the directory where the script is run as json file

# Create the IAM Role for Lambda
aws iam create-role \
    --role-name $ROLE_NAME \
    --assume-role-policy-document file://trust-policy.json  # Assume role policy document (Create this separately)

# Attach the necessary policies to the IAM role
aws iam put-role-policy \
    --role-name $ROLE_NAME \
    --policy-name $POLICY_NAME \
    --policy-document file://lambda-rds-s3-policy.json  # IAM policy for Lambda to access RDS and S3

echo "IAM role $ROLE_NAME created and policies attached."
