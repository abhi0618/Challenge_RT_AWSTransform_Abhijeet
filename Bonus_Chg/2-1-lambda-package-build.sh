#!/bin/bash

# Create a clean build directory
rm -rf s3_rds_function_package
mkdir s3_rds_function_package

# Ensure you're in the correct directory where requirements.txt is located
if [ ! -f requirements.txt ]; then
  echo "requirements.txt file not found!"
  exit 1
fi

# Install Python dependencies to the build folder
pip install -r requirements.txt --target s3_rds_function_package/

# Copy your lambda_function.py into the build folder
cp s3_rds_lambda_function.py s3_rds_function_package/

# Zip the contents into function.zip
cd s3_rds_function_package
zip -r ../s3_rds_function_package.zip .
cd ..

echo "✅ Lambda deployment package created: s3_rds_function_package.zip"
