AWS Lambda CSV Enrichment and MySQL Upload Automation

Overview:
This project automates the ingestion and enrichment of a CSV file using AWS services. When a specific file is uploaded to an S3 bucket, a Lambda function is triggered to read, transform, and upload the enriched data to another S3 file and to a MySQL RDS database.

The project is organized in three main phases:
- Step A : Download csv from S# bucket, Perform Transformations, and uploading enriched.csv to Posgresql(Snapshot provided at RioTintoChallenge_StepA_output.png)
- Step B: IAM setup, S3 bucket creation, and Lambda trigger configuration
- Bonus: Lambda function for CSV processing and storing results to RDS using Mysql (to show proficiency with both mysql and rds) (Snapshot provided at RioTintoChallenge_StepB_output.png)


STEP A: The Notebook Challenge_1stStep.ipynb takes care of all operations using pandas
It first reads the csv from the S3 bukcket, performs transformations , and then saves contents of enriched csv to an Posgresql DB. Snapshot is included in RioTintoChallenge_StepA_output.png


------------------------------------------------------------
STEP B: S3 File Upload, IAM User, and Lambda Trigger Setup
------------------------------------------------------------

1. Create a Custom S3 Access Policy:
   - Grants specific permissions: s3:PutObject, s3:GetObject, s3:ListBucket.
   - Ensures security via least-privilege principle.
   - Policy file used: Chg_StepA-s3-Upload-read-policy.json.

2. Create IAM User and Attach Policy:
   - IAM user is named StepA-upload-s3-bucket.
   - This user is restricted to operate only on the required S3 bucket.
   - IAM policies are attached using CLI.

3. Store Access Keys in AWS Systems Manager Parameter Store:
   - Secrets are stored securely using SSM (Parameter Store).
   - This avoids hardcoding secrets and is free under AWS Free Tier.
   - Access keys are retrieved dynamically and used with AWS CLI profiles.

4. Upload File to S3:
   - File (pace-data.csv) can be uploaded from local or another S3 source.
   - This triggers the Lambda function set up in Step B.

------------------------------------------------------------
STEP B(BOnus): Lambda Setup, CSV Enrichment, and RDS Upload
------------------------------------------------------------

This step outlines the deployment of the core Lambda function which performs the data transformation and database insert.

1. IAM Setup:
   - Create an IAM user with permissions to access Lambda, S3, and RDS.
   - Attach AdministratorAccess to simplify full setup (for CLI-based operations).

2. IAM Role Creation for Lambda:
   - Create an IAM role for Lambda with trust policy allowing Lambda service to assume it.
   - Attach custom policy to allow access to required services: s3:GetObject, s3:PutObject, rds:Connect, etc.

3. Build and Package the Lambda Function:
   - Lambda reads a CSV file from S3, transforms data, and uploads it back to S3.
   - Adds new fields like BeamRatio, fills missing speed with average based on CallSign.
   - Writes data to a MySQL RDS table called pace_data.
   - Code is packaged into a .zip file and deployed to Lambda.

4. Deploy Lambda Function:
   - Create Lambda function using AWS CLI.
   - Specify handler, runtime (Python 3.11), role ARN, and zip file.

5. S3 Trigger Configuration:
   - Add an event notification to S3 to trigger the Lambda on 'put' event for a specific key (pace-data.csv).

6. Security Policies:
   - IAM User Full Access Policy: Enables user to manage all required AWS resources.
   - Lambda Execution Role: Grants Lambda access to S3 and RDS.
   - PassRole Policy: Allows the Lambda function to pass the IAM role during execution.

Data Processing Logic:
- Normalize MovementDateTime to ISO format.
- If MoveStatus is "Under way using engine" and Speed is missing/zero, fill with average Speed for that CallSign.
- Compute BeamRatio = Beam / Length.

------------------------------------------------------------
BONUS CHALLENGE: Lambda Layer with PyMySQL for MySQL
------------------------------------------------------------

To handle dependency size limitations and avoid packaging bulky modules in Lambda zip files, this challenge introduces a Lambda Layer for PyMySQL.

1. Lambda Layer Creation:
   - Create a folder named python/, install pymysql using pip into it.
   - Zip the python folder into pymysql-layer.zip.
   - Publish the layer using AWS CLI.

2. Attach Layer to Lambda:
   - Retrieve the Layer ARN and attach it to the Lambda function using aws lambda update-function-configuration.
   - Ensure both Lambda and the Layer are in the same region.

.

Important Notes:
- The layer must match the Python runtime (e.g., python3.11).
- The IAM user executing CLI commands must have permission to publish layers and update Lambda configurations.
- MySQL RDS security group must allow inbound connections from Lambda (consider using public access for test or within same VPC).
- Use of layers simplifies code deployment and decouples dependency management.

------------------------------------------------------------
Execution Summary:
------------------------------------------------------------

1. Upload pace-data.csv to S3 (trigger Lambda).
2. Lambda function reads the file, enriches it (Speed average, BeamRatio), and uploads enriched_upload_andRDS.csv to S3.
3. Processed data is inserted into pace_data table in MySQL RDS.

------------------------------------------------------------
Contact:
Abhijeet Bhattacharya
Email: abhibhattacharya618@gmail.com
