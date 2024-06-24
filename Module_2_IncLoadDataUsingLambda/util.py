import boto3
from botocore.errorfactory import ClientError
from datetime import datetime as dt
from datetime import timedelta as td



def get_s3_client():
    return boto3.client('s3')


def read_bookmarked_file(bucket, file_prefix, bookmark_file, baseline_file):
    
    try:
        s3_client = get_s3_client()
        bookmark_file_res = s3_client.get_object(Bucket = bucket, Key = f'{file_prefix}/{bookmark_file}')
        prev_filename = bookmark_file_res['Body'].read().decode('utf-8')

    except ClientError as e:
        if e.response['Error']['Code'] == 'NoSuchKey':
            prev_filename = baseline_file
        else:
            raise

    return prev_filename

def get_next_file_name(prev_file_name):
    # user_data_2024-05-12-1.json
    date_part = prev_file_name.split('.')[0].split('_')[2]
    inc_date = dt.strptime(date_part, '%Y-%m-%d-%H') + td(hours=1)
    date_after_rm_leading_zero_hr = dt.strftime(inc_date, '%Y-%m-%d-%-H')  # Removing leading zero from Hour part
    next_file_name = f'user_data_{date_after_rm_leading_zero_hr}.json'
    print(next_file_name)
    return next_file_name

def copy_file_in_another_bucket(bucket_name, source_prefix, dest_prefix, filename):
    
    # file_date = dt.strftime(dt.strptime(filename.split('.')[0].split('_')[2], '%Y-%m-%d-%H'), '%Y-%m-%d')

    source_key = f'{source_prefix}/{filename}'
    # dest_key =  f'{dest_prefix}/{file_date}/{filename}'
    dest_key =  f'{dest_prefix}/{filename}'
    
    try:

        s3_client = get_s3_client()
        res = s3_client.copy_object(Bucket = bucket_name, Key = dest_key,\
                            CopySource = {'Bucket' : bucket_name, 'Key' : source_key})
        
        print(f'File {filename} copied to {bucket_name}/{dest_prefix} successfully')
    except:
        raise



def update_bookmark(bucket, file_prefix, bookmark_filename, file_content):

    s3_client = get_s3_client()
    s3_client.put_object(Bucket = bucket, Key = f'{file_prefix}/{bookmark_filename}', \
                         Body = file_content.encode('utf-8'))

