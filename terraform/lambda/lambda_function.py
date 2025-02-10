### **`lambda/lambda_function.py`**
This file contains the Lambda function for security compliance checks.

```python
import boto3

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    s3 = boto3.client('s3')

    # Check for unencrypted S3 buckets
    buckets = s3.list_buckets()['Buckets']
    for bucket in buckets:
        try:
            encryption = s3.get_bucket_encryption(Bucket=bucket['Name'])
        except:
            print(f"Bucket {bucket['Name']} is not encrypted.")

    # Check for publicly accessible EC2 instances
    instances = ec2.describe_instances()['Reservations']
    for reservation in instances:
        for instance in reservation['Instances']:
            if instance.get('PublicIpAddress'):
                print(f"Instance {instance['InstanceId']} is publicly accessible.")

    return {
        'statusCode': 200,
        'body': 'Security compliance check completed.'
    }
