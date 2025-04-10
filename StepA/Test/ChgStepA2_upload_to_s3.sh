#!/bin/bash

# Set variables
BUCKET_NAME="chg-stepa-uploadtos3bucket" 
S3_URL="https://data-engineer-technical-challenge.s3.ap-southeast-2.amazonaws.com/pace-data.txt"  # S3 link to the file
REGION="us-east-1"  

# Step 1: Create the S3 bucket (only if it doesn't exist)
# The bucket name must be globally unique
aws s3api head-bucket --bucket "$BUCKET_NAME" --region "$REGION" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Bucket does not exist. Creating the bucket: $BUCKET_NAME"
    if [ "$REGION" == "us-east-1" ]; then
        # No location constraint for us-east-1
        aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION"
    else
        # Specify location constraint for other regions
        aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" --create-bucket-configuration LocationConstraint="$REGION"
    fi
else
    echo "Bucket $BUCKET_NAME already exists."
fi

# Step 2: Choose the file source
echo "Do you want to upload the file from your local machine (1) or from the S3 URL (2)?"
read -p "Enter choice (1/2): " choice

if [ "$choice" -eq 1 ]; then
    # Case 1: Upload from local file system
    read -p "Please enter the local file path to upload: " FILE_PATH_LOCAL

    # Try to upload from the provided local path
    if [ -f "$FILE_PATH_LOCAL" ]; then
        echo "Uploading file from local machine..."
        aws s3 cp "$FILE_PATH_LOCAL" "s3://$BUCKET_NAME/"
        if [ $? -eq 0 ]; then
            echo "✅ File uploaded successfully from local path to s3://$BUCKET_NAME/$FILE_PATH_LOCAL"
        else
            echo "❌ Upload from local machine failed."
        fi
    else
        # If the file is not found or an error occurs, prompt the user to enter the path again or choose option 2
        echo "❌ Local file path not found or error in reading local file. Please enter the file path manually again or choose option 2 to upload from the S3 URL."
        echo "Enter 1 to attempt upload again with a new file path, or 2 to upload from S3 URL directly."
        read -p "Enter choice (1/2): " retry_choice
        if [ "$retry_choice" -eq 1 ]; then
            # Retry uploading from the new user-provided local path
            read -p "Please enter the new local file path to upload: " FILE_PATH_LOCAL
            if [ -f "$FILE_PATH_LOCAL" ]; then
                echo "Uploading file from local machine..."
                aws s3 cp "$FILE_PATH_LOCAL" "s3://$BUCKET_NAME/"
                if [ $? -eq 0 ]; then
                    echo "✅ File uploaded successfully from local path to s3://$BUCKET_NAME/$FILE_PATH_LOCAL"
                else
                    echo "❌ Upload from local machine failed."
                fi
            else
                echo "❌ File still not found at the provided path."
            fi
        elif [ "$retry_choice" -eq 2 ]; then
            # Proceed with uploading from the S3 URL if the user chooses option 2
            echo "Downloading file from S3 URL..."
            wget "$S3_URL" -O "pace-data.csv"   # Download the file locally first

            if [ $? -eq 0 ]; then
                # After downloading, upload to the new S3 bucket
                echo "Uploading file from downloaded path to the S3 bucket..."
                aws s3 cp "pace-data.csv" "s3://$BUCKET_NAME/"
                if [ $? -eq 0 ]; then
                    echo "✅ File uploaded successfully from S3 URL to s3://$BUCKET_NAME/pace-data.csv"
                else
                    echo "❌ Upload from S3 URL failed."
                fi
            else
                echo "❌ Failed to download file from S3 URL."
            fi
        else
            echo "❌ Invalid choice. Please select 1 or 2."
        fi
    fi
elif [ "$choice" -eq 2 ]; then
    # Case 2: Upload from S3 URL
    echo "Downloading file from S3 URL..."
    wget "$S3_URL" -O "pace-data.csv"   # Download the file locally first

    if [ $? -eq 0 ]; then
        # After downloading, upload to the new S3 bucket
        echo "Uploading file from downloaded path to the S3 bucket..."
        aws s3 cp "pace-data.csv" "s3://$BUCKET_NAME/"
        if [ $? -eq 0 ]; then
            echo "✅ File uploaded successfully from S3 URL to s3://$BUCKET_NAME/pace-data.csv"
        else
            echo "❌ Upload from S3 URL failed."
        fi
    else
        echo "❌ Failed to download file from S3 URL."
    fi
else
    echo "❌ Invalid choice. Please select 1 or 2."
fi
