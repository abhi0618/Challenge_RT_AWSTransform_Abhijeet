#!/bin/bash

# Set the necessary variables
DB_INSTANCE_IDENTIFIER="my-rds-instance"     # RDS instance identifier
DB_INSTANCE_CLASS="db.t2.micro"              # Free tier class for testing
DB_ENGINE="postgres"                         # Choose "mysql" for MySQL DB
DB_NAME="my_database"                        # Database name
DB_USERNAME="admin"                          # Master username
DB_PASSWORD="adminpassword"                  # Master password (update with a strong password)
DB_PORT="5432"                               # Default PostgreSQL port
VPC_SECURITY_GROUP_ID="sg-xxxxxxx"           # Security group ID for VPC (update accordingly)
SUBNET_IDS="subnet-xxxxxx,subnet-yyyyyy"      # Subnet IDs (update accordingly)
DB_STORAGE="20"                              # Allocated storage in GB
DB_BACKUP_RETENTION="7"                      # Backup retention period in days
DB_ENGINE_VERSION="12.4"                     # PostgreSQL engine version (optional)
DB_AUTO_MINOR_VERSION_UPGRADE="false"         # Set to true if you want auto minor version upgrades
DB_MULTI_AZ="false"                          # Set to true if you want multi-AZ deployment

# Set the AWS Region (modify as needed)
AWS_REGION="us-east-1"

# Create the RDS instance using AWS CLI
aws rds create-db-instance \
    --db-instance-identifier "$DB_INSTANCE_IDENTIFIER" \
    --db-instance-class "$DB_INSTANCE_CLASS" \
    --engine "$DB_ENGINE" \
    --allocated-storage "$DB_STORAGE" \
    --db-name "$DB_NAME" \
    --master-username "$DB_USERNAME" \
    --master-user-password "$DB_PASSWORD" \
    --vpc-security-group-ids "$VPC_SECURITY_GROUP_ID" \
    --db-subnet-group-name "default" \
    --backup-retention-period "$DB_BACKUP_RETENTION" \
    --port "$DB_PORT" \
    --storage-type "gp2" \
    --multi-az "$DB_MULTI_AZ" \
    --auto-minor-version-upgrade "$DB_AUTO_MINOR_VERSION_UPGRADE" \
    --region "$AWS_REGION" \
    --engine-version "$DB_ENGINE_VERSION" \
    --no-publicly-accessible

echo "RDS instance creation initiated. Please wait..."

# Wait until DB instance is available
aws rds wait db-instance-available --db-instance-identifier "$DB_INSTANCE_IDENTIFIER" --region "$AWS_REGION"

echo "RDS instance $DB_INSTANCE_IDENTIFIER is now available."
