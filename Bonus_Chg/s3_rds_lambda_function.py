import json
import csv
import boto3
import pymysql
from datetime import datetime
from statistics import mean

# S3 & RDS Configuration
RDS_HOST = 'rtc-transformation-instance-mysql.cmpcqkmi2y1q.us-east-1.rds.amazonaws.com'
RDS_DB = 'rtc'
RDS_USER = 'abhi0618'
RDS_PASSWORD = 'abhi1234'
RDS_PORT = 3306

s3 = boto3.client('s3')
s3_resource = boto3.resource('s3')

def lambda_handler(event, context):
    bucket = 's3-pace-data-bucket'
    key = 'pace-data.csv'
    
    try:
        # Fetch CSV from S3
        obj = s3_resource.Object(bucket, key)
        data = obj.get()['Body'].read().decode('utf-8').splitlines()
        reader = csv.DictReader(data)
        rows = list(reader)

        for row in rows:
            try:
                row['MovementDateTime'] = datetime.strptime(row['MovementDateTime'], '%Y-%m-%d %H:%M:%S').isoformat()
            except Exception:
                row['MovementDateTime'] = None

        call_signs = {}
        for row in rows:
            callsign = row['CallSign']
            call_signs.setdefault(callsign, {'speeds': [], 'rows': []})
            speed = float(row['Speed']) if row['Speed'] and row['Speed'].lower() != 'nan' else 0
            call_signs[callsign]['speeds'].append(speed)
            call_signs[callsign]['rows'].append(row)

        for data_group in call_signs.values():
            valid_speeds = [s for s in data_group['speeds'] if s > 0]
            avg_speed = mean(valid_speeds) if valid_speeds else 0
            for row in data_group['rows']:
                if row['MoveStatus'] == "Under way using engine" and (not row['Speed'] or row['Speed'] == "0"):
                    row['Speed'] = avg_speed

        for row in rows:
            try:
                beam = float(row['Beam'])
                length = float(row['Length'])
                row['BeamRatio'] = round(beam / length, 4) if length != 0 else None
            except Exception:
                row['BeamRatio'] = None

        # Save enriched CSV
        output_path = '/tmp/enriched_upload_andRDS.csv'
        with open(output_path, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=reader.fieldnames + ['MovementDateTime', 'BeamRatio'])
            writer.writeheader()
            writer.writerows(rows)

        # Upload enriched file to S3
        s3.upload_file(output_path, bucket, 'enriched_upload_andRDS.csv')

        # Upload rows to RDS MySQL
        conn = pymysql.connect(
            host=RDS_HOST,
            user=RDS_USER,
            password=RDS_PASSWORD,
            database=RDS_DB,
            port=RDS_PORT
        )
        with conn.cursor() as cursor:
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS pace_data (
                    MMSI VARCHAR(255),
                    VesselName VARCHAR(255),
                    CallSign VARCHAR(255),
                    Speed FLOAT,
                    Length FLOAT,
                    Beam FLOAT,
                    MoveStatus VARCHAR(255),
                    MovementDateTime DATETIME,
                    BeamRatio FLOAT
                )
            """)
            for row in rows:
                cursor.execute("""
                    INSERT INTO pace_data (MMSI, VesselName, CallSign, Speed, Length, Beam, MoveStatus, MovementDateTime, BeamRatio)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                """, (
                    row.get('MMSI'), row.get('VesselName'), row.get('CallSign'),
                    float(row.get('Speed', 0)), float(row.get('Length', 0)), float(row.get('Beam', 0)),
                    row.get('MoveStatus'), row.get('MovementDateTime'), row.get('BeamRatio')
                ))
            conn.commit()
        conn.close()

        return {
            'statusCode': 200,
            'body': json.dumps('CSV enriched and uploaded to RDS successfully.')
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }
