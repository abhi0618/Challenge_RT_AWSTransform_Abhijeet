#!/bin/bash

# Create a clean build directory
rm -rf lambda_build
mkdir lambda_build

# Ensure you're in the correct directory where requirements.txt is located
if [ ! -f requirements.txt ]; then
  echo "requirements.txt file not found!"
  exit 1
fi

# Install Python dependencies to the build folder
pip install -r requirements.txt --target lambda_build_new/

# Copy your lambda_function.py into the build folder
cp lambda_function.py lambda_build_new/

# Zip the contents into function.zip
cd lambda_build_new
zip -r ../function.zip .
cd ..

echo "✅ Lambda deployment package created: function.zip"
