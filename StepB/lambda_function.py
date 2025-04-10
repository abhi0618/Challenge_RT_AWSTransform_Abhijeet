import json
import csv
import boto3
from datetime import datetime
from statistics import mean
import math

s3_resource = boto3.resource('s3')
s3_client = boto3.client('s3')

def lambda_handler(event, context):
    try:
        # Manually set bucket and key
        bucket = 's3-pace-data-bucket'
        key = 'pace-data.csv'

        # Read the CSV from S3
        s3_object = s3_resource.Object(bucket, key)
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
            # Ensure there are valid speeds to calculate the mean
            valid_speeds = [s for s in data_group['speeds'] if s > 0]
            if valid_speeds:
                avg_speed = mean(valid_speeds)
            else:
                avg_speed = 0  # Fallback if no valid speeds are found

            for row in data_group['rows']:
                if row['MoveStatus'] == "Under way using engine":
                    try:
                        # Only replace if Speed is missing or 0
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
            except (ValueError, ZeroDivisionError):
                row['BeamRatio'] = None

        # Add the new columns to the existing fieldnames
        fieldnames = csv_reader.fieldnames + ['MovementDateTime', 'BeamRatio']

        # Save enriched file
        output_file = '/tmp/enriched.csv'
        with open(output_file, 'w', newline='') as outfile:
            csv_writer = csv.DictWriter(outfile, fieldnames=fieldnames)
            csv_writer.writeheader()
            for row in rows:
                # Write each row with all original and new columns
                csv_writer.writerow(row)

        # Upload the enriched file to S3
        s3_client.upload_file(output_file, bucket, 'enriched.csv')

        return {
            'statusCode': 200,
            'body': json.dumps('CSV processed and enriched successfully.')
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error processing file: {str(e)}')
        }
