module "s3_bucket" {
  source = "./modules/s3"
  bucket_name = "random-user-etl-data-bucket"
}

module "lambda" {
  source = "./modules/lambda"
  bucket_name = module.s3_bucket.created_s3_bucket_name
  lambda_function_name = "random_user_inc_load"
  lambda_handler = "lambda_function.lambda_handler"
  lambda_runtime = "python3.10"
  
  environment_variables = {
      BUCKET_NAME = module.s3_bucket.created_s3_bucket_name
      BOOKMARK_FILE = "bookmark"
      BASELINE_FILE = "user_data_2024-06-08-14.json"
      SOURCE_PREFIX = "landing"
      DESTINATION_PREFIX = "cleaned"
  }
   
  lambda_timeout = 210
  lambda_memory_size = 256
  lambda_filename = "../Module_2_IncLoadDataUsingLambda/inc_load_random_users.zip"
}

module "schedule_lambda" {
  source = "./modules/eventBridge"
  schedule_name = "random_user_inc_load_schedule"
  schedule_expression = "cron(15 18 * * ? *)"
  lambda_function_arn = module.lambda.lambda_function_arn
  
}

module "glue_s3_script_bucket" {
  source = "./modules/s3"
  bucket_name = "random-user-etl-glue-script-bucket"
  
}

module "glue" {
  source = "./modules/glue"
  glue_role_name = "random_user_etl_glue_role"
  bucket_name = module.glue_s3_script_bucket.created_s3_bucket_name
  bucket_key = "glue_scripts/etl_job_random_users.py"
  glue_script_local_path = "../Module_3_GlueETL/glue_jobs/etl_job_random_users.py"
  glue_custom_policy_name = "glue_custom_policy"
  glue_job_name = "random_user_etl_job"
  glue_job_script_location = "s3://${module.glue_s3_script_bucket.created_s3_bucket_name}/glue_scripts/etl_job_random_users.py"
  glue_job_temp_dir = "s3://${module.glue_s3_script_bucket.created_s3_bucket_name}/temp"
  max_retries = 1
  timeout = 5
  max_capacity = 2
  glue_job_trigger_name = "random_user_etl_job_trigger"
  glue_job_schedule = "cron(30 18 * * ? *)"  # Run daily at midnight IST
}