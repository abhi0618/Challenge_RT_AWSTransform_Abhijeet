#!/bin/bash

# Source the .env file to load the environment variables
source .env

# Set AWS credentials using environment variables
aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set region us-east-1

# Verify the IAM user is active by calling AWS STS
aws sts get-caller-identity
