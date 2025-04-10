#!/bin/bash

# Variables (Set these at the beginning of the script)
DB_INSTANCE_IDENTIFIER="rtc-transformation-instance-mysql"
DB_NAME="rtc"
DB_USER="abhi0618"
DB_PASSWORD="abhi1234"  # Make sure the password follows RDS password policies
DB_INSTANCE_CLASS="db.t3.micro"  # Modify instance class as needed
DB_ENGINE="mysql"
DB_STORAGE="20"  # Storage in GB
DB_PORT="3306"  # Default port for PostgreSQL
AWS_REGION="us-east-1"



# Create RDS instance
aws rds create-db-instance \
    --db-instance-identifier $DB_INSTANCE_IDENTIFIER \
    --db-name $DB_NAME \
    --engine $DB_ENGINE \
    --master-username $DB_USER \
    --master-user-password $DB_PASSWORD \
    --db-instance-class $DB_INSTANCE_CLASS \
    --allocated-storage $DB_STORAGE \
    --port $DB_PORT \
    --no-publicly-accessible \
    --region $AWS_REGION \
    ##--storage-type gp2

echo "RDS instance $DB_INSTANCE_IDENTIFIER created."



