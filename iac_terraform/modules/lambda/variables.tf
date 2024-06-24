variable "lambda_function_name" {
  description = "The name of the IAM role for the Lambda function"
  type        = string
  default     = "default_lambda_function_name"
  
}

variable "bucket_name" {
  description = "The name of the S3 bucket on which the Lambda function will operate"
  type        = string
  default     = "default_bucket_name"
  
}

variable "lambda_handler" {
    description = "The name of the Lambda handler function"
    type        = string
    default     = "default_lambda_handler"
}

variable "lambda_runtime" {
    description = "The runtime for the Lambda function"
    type        = string
    default     = "default_lambda_runtime"
  
}

variable "environment_variables" {
  description = "A map of environment variables to set for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "lambda_timeout" {
  description = "The amount of time the Lambda function has to run before it times out"
  type        = number
  default     = 180
  
}

variable "lambda_memory_size" {
  description = "The amount of memory to allocate to the Lambda function"
  type        = number
  default     = 128
  
}

variable "ephemeral_storage_size" {
  description = "The amount of ephemeral storage to allocate to the Lambda function"
  type        = number
  default     = 512
}

variable "lambda_filename" {
  description = "The filename of the Lambda function code"
  type        = string
  default     = "lambda_function.zip"
  
}