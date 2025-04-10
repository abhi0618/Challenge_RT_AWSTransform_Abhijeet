#!/bin/bash

# Set up CLI for an IAM User

IAM_USER_PROFILE="admin-profile"
AWS_ACCESS_KEY_ID="AKIA5MSUBTA5QHQCHDQK"
AWS_SECRET_ACCESS_KEY="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"
AWS_REGION="us-east-1"

echo "🔧 Configuring AWS CLI for IAM user profile: $IAM_USER_PROFILE"

aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile "$IAM_USER_PROFILE"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile "$IAM_USER_PROFILE"
aws configure set region "$AWS_REGION" --profile "$IAM_USER_PROFILE"

# Optionally set it as the default for this terminal session
export AWS_PROFILE="$IAM_USER_PROFILE"

echo "✅ AWS CLI configured with IAM user profile: $IAM_USER_PROFILE"
aws sts get-caller-identity --profile "$IAM_USER_PROFILE"

#Attach Security policies

aws iam put-user-policy --user-name "$IAM_USER_PROFILE" --policy-name AllowAssumeLambdaRole --policy-document file://iam-user-full-access-policy.json
