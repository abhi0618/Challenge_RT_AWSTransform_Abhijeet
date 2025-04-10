import json
import csv
import boto3
import os
import psycopg2
from datetime import datetime
from statistics import mean

# ================== VARIABLE DEFINITIONS ===================

# S3 Configuration
BUCKET_NAME = 's3-pace-data-bucket'
SOURCE_FILE_KEY = 'pace-data.csv'
ENRICHED_FILE_KEY = 'enriched.csv'

# Local temporary file path
ENRICHED_LOCAL_FILE = '/tmp/enriched.csv'

# RDS Configuration (to be set as Lambda environment variables)
RDS_HOST = os.environ['RDS_HOST']
RDS_DB = os.environ['RDS_DB']
RDS_USER = os.environ['RDS_USER']
RDS_PASSWORD = os.environ['RDS_PASSWORD']
RDS_PORT = int(os.environ.get('RDS_PORT', 5432))  # Default PostgreSQL port

# Target table name in RDS
RDS_TABLE_NAME = 'enriched_data'

# AWS Boto3 clients
s3_resource = boto3.resource('s3')
s3_client = boto3.client('s3')

# ================== LAMBDA HANDLER ===================

def lambda_handler(event, context):
    try:
        # Step 1: Read CSV from S3
        s3_object = s3_resource.Object(BUCKET_NAME, SOURCE_FILE_KEY)
        data = s3_object.get()['Body'].read().decode('utf-8').splitlines()
        csv_reader = csv.DictReader(data)
        rows = list(csv_reader)

        # Step 2: Normalize datetime
        for row in rows:
            try:
                row['MovementDateTime'] = datetime.strptime(row['MovementDateTime'], '%Y-%m-%d %H:%M:%S').isoformat()
            except Exception:
                row['MovementDateTime'] = None

        # Step 3: Handle average speed per CallSign
        call_signs = {}
        for row in rows:
            callsign = row['CallSign']
            if callsign not in call_signs:
                call_signs[callsign] = {'speeds': [], 'rows': []}
            try:
                speed = float(row['Speed']) if row['Speed'] and row['Speed'].lower() != 'nan' else 0
            except (ValueError, TypeError):
                speed = 0
            call_signs[callsign]['speeds'].append(speed)
            call_signs[callsign]['rows'].append(row)

        for callsign, group in call_signs.items():
            valid_speeds = [s for s in group['speeds'] if s > 0]
            avg_speed = mean(valid_speeds) if valid_speeds else 0
            for row in group['rows']:
                if row['MoveStatus'] == "Under way using engine":
                    try:
                        if not row['Speed'] or row['Speed'].lower() == 'nan' or float(row['Speed']) == 0:
                            row['Speed'] = avg_speed
                    except (ValueError, TypeError):
                        row['Speed'] = avg_speed

        # Step 4: Compute BeamRatio
        for row in rows:
            try:
                beam = float(row['Beam'])
                length = float(row['Length'])
                row['BeamRatio'] = round(beam / length, 4) if length != 0 else None
            except (ValueError, ZeroDivisionError):
                row['BeamRatio'] = None

        # Step 5: Save enriched CSV to local
        fieldnames = csv_reader.fieldnames + ['MovementDateTime', 'BeamRatio']
        with open(ENRICHED_LOCAL_FILE, 'w', newline='') as outfile:
            writer = csv.DictWriter(outfile, fieldnames=fieldnames)
            writer.writeheader()
            for row in rows:
                writer.writerow(row)

        # Step 6: Upload enriched CSV to S3
        s3_client.upload_file(ENRICHED_LOCAL_FILE, BUCKET_NAME, ENRICHED_FILE_KEY)

        # Step 7: Upload to RDS
        conn = psycopg2.connect(
            host=RDS_HOST,
            dbname=RDS_DB,
            user=RDS_USER,
            password=RDS_PASSWORD,
            port=RDS_PORT
        )
        cursor = conn.cursor()

        col_defs = ', '.join([f'"{col}" TEXT' for col in fieldnames])
        create_stmt = f'CREATE TABLE IF NOT EXISTS {RDS_TABLE_NAME} (id SERIAL PRIMARY KEY, {col_defs});'
        cursor.execute(create_stmt)

        for row in rows:
            values = [str(row.get(col, '')) for col in fieldnames]
            placeholders = ', '.join(['%s'] * len(values))
            col_names = ', '.join([f'"{col}"' for col in fieldnames])
            insert_stmt = f'INSERT INTO {RDS_TABLE_NAME} ({col_names}) VALUES ({placeholders});'
            cursor.execute(insert_stmt, values)

        conn.commit()
        cursor.close()
        conn.close()

        return {
            'statusCode': 200,
            'body': json.dumps('CSV processed, enriched, uploaded to S3 and RDS.')
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }
