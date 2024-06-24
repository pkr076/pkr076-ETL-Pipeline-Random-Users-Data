import os
from botocore.errorfactory import ClientError
from util import read_bookmarked_file, get_next_file_name
from util import copy_file_in_another_bucket, update_bookmark

def lambda_handler(event, context):
    bucket_name = os.environ.get('BUCKET_NAME')
    bookmark_file = os.environ.get('BOOKMARK_FILE')
    baseline_file = os.environ.get('BASELINE_FILE')
    source_prefix = os.environ.get('SOURCE_PREFIX')
    dest_prefix = os.environ.get('DESTINATION_PREFIX')

    while True:
        try:
            prev_file = read_bookmarked_file(bucket_name, source_prefix, bookmark_file,baseline_file)
            next_file = get_next_file_name(prev_file)
            copy_file_in_another_bucket(bucket_name, source_prefix, dest_prefix, next_file)
            update_bookmark(bucket_name, source_prefix, bookmark_file, next_file )
        except ClientError as e:
            if e.response['Error']['Code']=='NoSuchKey':
                print("seems like all files are processed!! ")
                break
            else:
                print(e)
                break
