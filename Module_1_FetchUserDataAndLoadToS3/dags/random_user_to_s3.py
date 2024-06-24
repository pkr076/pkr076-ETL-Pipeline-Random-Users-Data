import requests
import boto3
import json
import os
import pendulum
import logging
from datetime import datetime as dt
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.hooks.base import BaseHook

logger = logging.getLogger('user_data_pipeline')
logger.setLevel(logging.INFO)
handler = logging.FileHandler('/opt/airflow/logs/user_data_pipeline.log')
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

local_tz = pendulum.timezone("Asia/Kolkata")
default_args = {
    'owner': 'pkr076',
    'start_date': dt(2024, 4, 15, tzinfo=local_tz)
    }
# curr_date = dt.now().strftime('%Y-%m-%d-%-H') # removing leading zero from date for linux
# curr_date = dt.now().strftime('%Y-%m-%d-%#H') # removing leading zero from date for windows

curr_date = pendulum.now('Asia/Kolkata')
curr_date = curr_date.strftime('%Y-%m-%d-%-H')
file_name = f'user_data_{curr_date}.json'

local_file_path = f'/opt/airflow/user_data/{file_name}'
s3_bucket_name = 'random-user-etl-data-bucket'
s3_file_key = f'landing/{file_name}'

def download_users_data():
   
    with open(local_file_path, 'a') as file:
        all_users = []
        
        for i in range(5):
            
            res = requests.get('https://randomuser.me/api/')
            if res.status_code == 200:
                user_data = res.json()
                all_users.append(user_data)
            else:
                # print(f"Failed to fetch data: {res.status_code}")
                logger.error(f"Failed to fetch data: {res.status_code}")

        file.write(json.dumps(all_users))
            
        # print(f"Data written to {file_name}")
        logger.info(f"Data written to {file_name}")


def upload_to_s3(local_file_path, s3_bucket_name, s3_file_key):

    aws_conn = BaseHook.get_connection('aws_demo')
    session = boto3.Session(
        aws_access_key_id=aws_conn.login,
        aws_secret_access_key=aws_conn.password,
        region_name=aws_conn.extra_dejson.get('region_name', 'us-east-1')
    )
    s3_client = session.client('s3')

    try:
        s3_client.upload_file(local_file_path, s3_bucket_name, s3_file_key)
    except Exception as e:
        logger.error(f"Failed to upload to S3: {str(e)}")
        raise Exception(f"Failed to upload to S3: {str(e)}")

def delete_local_file(local_file_path):
    
    if os.path.exists(local_file_path):
        os.remove(local_file_path)
    else:
        logger.error(f"File not found: {local_file_path}")
        raise Exception(f"File not found: {local_file_path}")

with DAG(
    'user_data_pipeline',
    default_args=default_args,
    description='A simple data pipeline to fetch, upload, and delete user data',
    schedule_interval= '@hourly',
    catchup=False) as dag:

    download_users_data = PythonOperator(task_id='download_users_data', python_callable=download_users_data)
    upload_to_s3 = PythonOperator(task_id='upload_to_s3', python_callable=upload_to_s3, op_args=[local_file_path, s3_bucket_name, s3_file_key])
    delete_local_file = PythonOperator(task_id='delete_local_file', python_callable=delete_local_file, op_args=[local_file_path])

    download_users_data >> upload_to_s3 >> delete_local_file