from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from pprint import pprint
from awsglue.dynamicframe import DynamicFrame
from awsglue.job import Job
import boto3
from pyspark.sql.functions import explode, col, concat, lit
from pyspark.sql.types import *

sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

s3_bucket = 'random-user-etl-data-bucket'
s3_prefix = 'cleaned'

region_name = 'us-east-1'                                      
ddb_table_name='random_users'

# sdf = spark.read.json('/home/glue_user/workspace/jupyter_workspace/user_data_2024-04-28-13.json')
sdf = spark.read.json(f"s3://{s3_bucket}/{s3_prefix}/")
# sdf.show(2)

df = sdf.select(explode('results').alias('results'))
# df.show(2)

df.select('results.name.first').show(2)

df = df.withColumn('Name', concat('results.name.first', lit(" "), 'results.name.last'))
df = df.withColumn('Gender', col('results.gender'))
df = df.withColumn('Date of birth', col('results.dob.date'))
df = df.withColumn('Email', col('results.email'))
df = df.withColumn('Cell', col('results.cell'))
df = df.withColumn('Phone', col('results.phone'))
df = df.withColumn('Full address', concat('results.location.street.name', lit(", "), 'results.location.street.number'\
                                         , lit(", "), 'results.location.city' , lit(", "), 'results.location.postcode'\
                   , lit(", "), 'results.location.state',  lit(", "), 'results.location.country'))
df = df.withColumn('Citizenship', col('results.nat'))
df = df.withColumn('Login details', col('results.login'))
df = df.withColumn('Picture', col('results.picture.large'))

df = df.drop('results')

# df.show(5)

dynamic_frame = DynamicFrame.fromDF(df, glueContext, "dynamic_frame")

dynamodb = boto3.resource('dynamodb', region_name=region_name)

table_status = dynamodb.create_table(
    TableName=ddb_table_name,
    KeySchema=[
        {'AttributeName': 'Username', 'KeyType': 'HASH'}
    ],
    AttributeDefinitions=[
        {'AttributeName': 'Username', 'AttributeType': 'S'}
    ],
    BillingMode='PAY_PER_REQUEST'
)

# Wait until the table exists.
table_status.meta.client.get_waiter('table_exists').wait(TableName=ddb_table_name)
# pprint(table_status)

glueContext.write_dynamic_frame.from_options(
    frame=dynamic_frame,
    connection_type="dynamodb",
    connection_options={
        "dynamodb.output.tableName": dynamodb_table_name
    }
)

# df.count()
