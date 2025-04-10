#!/bin/bash

# Variables
ROLE_NAME="lambda-s3-rds-role"
TRUST_POLICY_FILE="trust-policy.json"
POLICY_FILE="iam-user-full-access-policy.json"
POLICY_NAME="iam-user-full-access-policy"
AWS_REGION="us-east-1"
ACCOUNT_ID="920373008443"

echo "🔐 Creating IAM Role '$ROLE_NAME'..."
aws iam create-role \
  --role-name "$ROLE_NAME" \
  --assume-role-policy-document file://$TRUST_POLICY_FILE

echo "🔗 Creating and Attaching IAM Policy '$POLICY_NAME'..."
aws iam create-policy \
  --policy-name "$POLICY_NAME" \
  --policy-document file://$POLICY_FILE

aws iam attach-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/$POLICY_NAME
###
aws configure --profile admin-profile