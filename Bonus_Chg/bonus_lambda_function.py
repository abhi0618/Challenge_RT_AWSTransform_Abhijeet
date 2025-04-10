import json
import csv
import boto3
import psycopg2
from datetime import datetime
from statistics import mean
import math
import os

# Set the necessary variables
bucket_name = 's3-pace-data-bucket'
input_key = 'pace-data.csv'
output_key = 'enriched.csv'
rds_host = os.environ['RDS_HOST']
rds_db = os.environ['RDS_DB']
rds_user = os.environ['RDS_USER']
rds_password = os.environ['RDS_PASSWORD']
rds_port = os.environ['RDS_PORT']

s3_resource = boto3.resource('s3')
s3_client = boto3.client('s3')

def lambda_handler(event, context):
    try:
        # Read the CSV from S3
        s3_object = s3_resource.Object(bucket_name, input_key)
        data = s3_object.get()['Body'].read().decode('utf-8').splitlines()

        # Create CSV reader object
        csv_reader = csv.DictReader(data)
        rows = list(csv_reader)

        # Normalize MovementDateTime to ISO format
        for row in rows:
            try:
                row['MovementDateTime'] = datetime.strptime(row['MovementDateTime'], '%Y-%m-%d %H:%M:%S').isoformat()
            except Exception:
                row['MovementDateTime'] = None

        # Group by CallSign for average speed calculation
        call_signs = {}
        for row in rows:
            callsign = row['CallSign']
            if callsign not in call_signs:
                call_signs[callsign] = {'speeds': [], 'rows': []}
            try:
                # Handle NaN or invalid speed values by converting them to 0
                speed = float(row['Speed']) if row['Speed'] and row['Speed'].lower() != 'nan' else 0
            except (ValueError, TypeError):
                speed = 0
            call_signs[callsign]['speeds'].append(speed)
            call_signs[callsign]['rows'].append(row)

        # Fill missing or zero speeds for "Under way using engine"
        for callsign, data_group in call_signs.items():
            valid_speeds = [s for s in data_group['speeds'] if s > 0]
            avg_speed = mean(valid_speeds) if valid_speeds else 0

            for row in data_group['rows']:
                if row['MoveStatus'] == "Under way using engine":
                    try:
                        if not row['Speed'] or row['Speed'].lower() == 'nan' or float(row['Speed']) == 0:
                            row['Speed'] = avg_speed
                    except (ValueError, TypeError):
                        row['Speed'] = avg_speed

        # Create BeamRatio as Beam / Length
        for row in rows:
            try:
                beam = float(row['Beam'])
                length = float(row['Length'])
                row['BeamRatio'] = round(beam / length, 4) if length != 0 else None
            except (ValueError, TypeError):
                row['BeamRatio'] = None

        # Save enriched data to CSV
        with open('/tmp/enriched.csv', 'w', newline='') as file:
            fieldnames = list(rows[0].keys())
            csv_writer = csv.DictWriter(file, fieldnames=fieldnames)
            csv_writer.writeheader()
            csv_writer.writerows(rows)

        # Upload enriched data to S3
        s3_client.upload_file('/tmp/enriched.csv', bucket_name, output_key)

        return {
            'statusCode': 200,
            'body': json.dumps(f"File enriched and uploaded successfully: {output_key}")
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps('An error occurred')
        }
