#!/bin/bash

# Part 1: Create Custom Policy for S3 Upload

echo "Creating custom policy 'Chg_StepA-r3-s3-Upload-read-policy'..."

# Policy document in JSON format
cat > Chg-StepA-r2-s3-Upload-read-policy.json << EOL
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
           "arn:aws:s3:::*",
            "arn:aws:s3:::*/*" 
      ]
    }
  ]
}
EOL

# Create the policy using the above JSON document and capture the ARN in the response
create_policy_response=$(aws iam create-policy \
  --policy-name "Chg_StepA-r2-s3-Upload-read-policy" \
  --policy-document file://Chg_StepA-r2-s3-Upload-read-policy.json)

# Extract the Policy ARN from the response
POLICY_ARN=$(echo $create_policy_response | jq -r '.Policy.Arn')

echo "Custom policy 'Chg_StepA-r2-s3-Upload-read-policy' created successfully with ARN: $POLICY_ARN"





# Part 2 : Create IAM User with Custom S3 Access Policy (When AWS CLI is configured to the root user/or anther user with IAM creation priviliges)

# Creating the IAM user
echo "Creating IAM user 'abhi0618-r2-StepA-upload-s3-bucket'..."
aws iam create-user --user-name abhi0618-r2-StepA-upload-s3-bucket
if [ $? -eq 0 ]; then
    echo "IAM user 'abhi0618-r2-StepA-upload-s3-bucket' created successfully."
else
    echo "Error: Failed to create IAM user 'abhi0618-r2-StepA-upload-s3-bucket'."
    exit 1
fi

# Attaching AmazonS3 Custom policy to the IAM user
echo "Attaching custom policy to the IAM user..."
aws iam attach-user-policy \
    --user-name abhi0618-r2-StepA-upload-s3-bucket \
    --policy-arn $POLICY_ARN #Put the resp Policy arn for the resp user and policy
if [ $? -eq 0 ]; then
    echo "Custom policy 'Chg_StepA-r2-s3-Upload-read-policy' attached successfully."
else
    echo "Error: Failed to attach policy 'Chg_StepA-r2-s3-Upload-read-policy'."
    exit 1
fi


# Part 3: Generate Access Keys for the IAM User

echo "Generating access keys for IAM user 'abhi0618-r2-StepA-upload-s3-bucket'..."

# Generate the access keys
access_key_response=$(aws iam create-access-key --user-name abhi0618-r2-StepA-upload-s3-bucket)
if [ $? -eq 0 ]; then
    # Extracting the Access Key and Secret Access Key
    ACCESS_KEY=$(echo $access_key_response | jq -r '.AccessKey.AccessKeyId')
    SECRET_KEY=$(echo $access_key_response | jq -r '.AccessKey.SecretAccessKey')

    # Display the Access and Secret Keys (Optional, for debugging)
    echo "Access Key: $ACCESS_KEY"
    echo "Secret Key: $SECRET_KEY"
else
    echo "Error: Failed to generate access keys for IAM user 'abhi0618-r2-StepA-upload-s3-bucket'."
    exit 1
fi


# Part 4: Store Access Keys in AWS Systems Manager Parameter Store

echo "Storing Access and Secret keys in AWS Systems Manager Parameter Store..."

# Storing the access key
aws ssm put-parameter --name "/iam/abhi0618R2/access-key-ChgStepA" --type "SecureString" --value "$ACCESS_KEY" --tier "Standard"
if [ $? -eq 0 ]; then
    echo "Access key stored successfully in Parameter Store."
else
    echo "Error: Failed to store access key in Parameter Store."
    exit 1
fi

# Storing the secret key
aws ssm put-parameter --name "/iam/abhi0618R2/secret-key-ChgStepA" --type "SecureString" --value "$SECRET_KEY" --tier "Standard"
if [ $? -eq 0 ]; then
    echo "Secret key stored successfully in Parameter Store."
else
    echo "Error: Failed to store secret key in Parameter Store."
    exit 1
fi


# Part 5: Retrieve the Access Keys and Set AWS CLI Configuration

echo "Retrieving Access and Secret keys from AWS Systems Manager Parameter Store..."

# Retrieve the Access Key
ACCESS_KEY=$(aws ssm get-parameter --name "/iam/abhi0618R2/access-key-ChgStepA" --with-decryption --query "Parameter.Value" --output text)
if [ $? -eq 0 ]; then
    echo "Access key retrieved successfully from Parameter Store."
else
    echo "Error: Failed to retrieve access key from Parameter Store."
    exit 1
fi

# Retrieve the Secret Key
SECRET_KEY=$(aws ssm get-parameter --name "/iam/abhi0618R2/secret-key-ChgStepA" --with-decryption --query "Parameter.Value" --output text)
if [ $? -eq 0 ]; then
    echo "Secret key retrieved successfully from Parameter Store."
else
    echo "Error: Failed to retrieve secret key from Parameter Store."
    exit 1
fi

# Configure AWS CLI to use these credentials
aws configure set aws_access_key_id $ACCESS_KEY --profile abhi0618-r2-StepA-upload-s3-bucket
aws configure set aws_secret_access_key $SECRET_KEY --profile abhi0618-r2-StepA-upload-s3-bucket
aws configure set region us-east-1 --profile abhi0618-r2-StepA-upload-s3-bucket
if [ $? -eq 0 ]; then
    echo "AWS CLI configured successfully for user 'abhi0618-r2-StepA-upload-s3-bucket'."
else
    echo "Error: Failed to configure AWS CLI for user 'abhi0618-r2-StepA-upload-s3-bucket'."
    exit 1
fi

# Set AWS CLI to this profile
export AWS_PROFILE=abhi0618-r2-StepA-upload-s3-bucket

aws configure list

echo "AWS CLI profile set to 'abhi0618-r2-StepA-upload-s3-bucket'."

