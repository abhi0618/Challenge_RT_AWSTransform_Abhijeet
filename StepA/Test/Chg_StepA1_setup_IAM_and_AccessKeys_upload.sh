#!/bin/bash

# Part 1: Create IAM User with Full S3 Access( When AWS CLI is configured to the root user )

# Creating the IAM user
echo "Creating IAM user 'StepA-upload-s3-bucket'..."
aws iam create-user --user-name StepA-upload-s3-bucket

# Attaching AmazonS3FullAccess policy to the IAM user
echo "Attaching custom policy to the IAM user..."
aws iam attach-user-policy \
    --user-name StepA-upload-s3-bucket \
    --policy-arn arn:aws:iam::920373008443:policy/Chg_StepA-s3-Upload-read-policy
    echo "IAM user created and policy attached successfully."


# Part 2: Generate Access Keys for the IAM User

echo "Generating access keys for IAM user 'StepA-upload-s3-bucket'..."

# Generate the access keys
access_key_response=$(aws iam create-access-key --user-name StepA-upload-s3-bucket)

# Extracting the Access Key and Secret Access Key
ACCESS_KEY=$(echo $access_key_response | jq -r '.AccessKey.AccessKeyId')
SECRET_KEY=$(echo $access_key_response | jq -r '.AccessKey.SecretAccessKey')

# Display the Access and Secret Keys (Optional, for debugging)
echo "Access Key: $ACCESS_KEY"
echo "Secret Key: $SECRET_KEY"


# Part 3: Store Access Keys in AWS Systems Manager Parameter Store

echo "Storing Access and Secret keys in AWS Systems Manager Parameter Store..."

# Storing the access key
aws ssm put-parameter --name "/iam/access-key" --type "SecureString" --value "$ACCESS_KEY" --tier "Standard"

# Storing the secret key
aws ssm put-parameter --name "/iam/secret-key" --type "SecureString" --value "$SECRET_KEY" --tier "Standard"

echo "Access and Secret keys stored successfully in Parameter Store."



# Part 4: Retrieve the Access Keys and Set AWS CLI Configuration

echo "Retrieving Access and Secret keys from AWS Systems Manager Parameter Store..."

# Retrieve the Access Key
ACCESS_KEY=$(aws ssm get-parameter --name "/iam/access-key" --with-decryption --query "Parameter.Value" --output text)

# Retrieve the Secret Key
SECRET_KEY=$(aws ssm get-parameter --name "/iam/secret-key" --with-decryption --query "Parameter.Value" --output text)

# Configure AWS CLI to use these credentials
aws configure set aws_access_key_id $ACCESS_KEY --profile StepA-upload-s3-bucket
aws configure set aws_secret_access_key $SECRET_KEY --profile StepA-upload-s3-bucket
aws configure set region us-east-1 --profile StepA-upload-s3-bucket

#Set AWS CLI to this profile 

export AWS_PROFILE=StepA-upload-s3-bucket


echo "AWS CLI configured successfully for user 'StepA-upload-s3-bucket'."
