FUNCTION_NAME="s3-rds-transformation-function"
ROLE_NAME="lambda-s3-rds-role"
ZIP_FILE_NAME="s3_rds_function_package.zip"
S3_BUCKET_NAME="s3-pace-data-bucket"
HANDLER="s3_rds_function_package.s3_rds_lambda_function.lambda_handler"
RUNTIME="python3.11"
TIMEOUT=30
MEMORY=512
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# === Create Lambda Function using code from S3 bucket ===
aws lambda create-function \
  --function-name $FUNCTION_NAME \
  --runtime $RUNTIME \
  --role arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME \
  --handler $HANDLER \
  --timeout $TIMEOUT \
  --memory-size $MEMORY \
  --code S3Bucket=$S3_BUCKET_NAME,S3Key=$ZIP_FILE_NAME \
  --region $REGION
