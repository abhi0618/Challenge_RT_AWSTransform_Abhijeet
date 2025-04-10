#!/bin/bash

ROLE_NAME="lambda-s3-rds-role"
SESSION_NAME="LambdaCLISession"
CLI_PROFILE="lambda-temp-session"
ACCOUNT_ID="920373008443"
REGION="us-east-1"

ROLE_ARN="arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME"

echo "🔄 Assuming role '$ROLE_NAME'..."
creds=$(aws sts assume-role \
  --role-arn "$ROLE_ARN" \
  --role-session-name "$SESSION_NAME"\
  --region "$REGION")

ACCESS_KEY=$(echo "$creds" | jq -r '.Credentials.AccessKeyId')
SECRET_KEY=$(echo "$creds" | jq -r '.Credentials.SecretAccessKey')
SESSION_TOKEN=$(echo "$creds" | jq -r '.Credentials.SessionToken')

aws configure set aws_access_key_id "$ACCESS_KEY" --profile "$CLI_PROFILE"
aws configure set aws_secret_access_key "$SECRET_KEY" --profile "$CLI_PROFILE"
aws configure set aws_session_token "$SESSION_TOKEN" --profile "$CLI_PROFILE"
aws configure set region "$REGION" --profile "$CLI_PROFILE"

export AWS_PROFILE="$CLI_PROFILE"
echo "✅ Profile '$CLI_PROFILE' is set with temp credentials."
