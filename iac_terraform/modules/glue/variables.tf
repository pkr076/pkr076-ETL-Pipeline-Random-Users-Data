variable "glue_role_name" {
  description = "The name of the IAM role for Glue"
  type        = string
  
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  
}

variable "bucket_key" {
  description = "used to simulate folders in AWS S3 bucket"
    type        = string
    default = ""
}

variable "glue_script_local_path" {
  description = "The path to the Glue script"
  type        = string
  
}
variable "glue_custom_policy_name" {
  description = "The name of the custom policy for Glue"
  type        = string
  
}

variable "glue_job_name" {
  description = "The name of the Glue job"
  type        = string
  
}

variable "glue_job_script_location" {
  description = "The location of the Glue job script"
  type        = string
  
}

variable "glue_job_temp_dir" {
  description = "The location of the Glue job temp directory"
  type        = string
 
}

variable "max_retries" {
    description = "The maximum number of retries for the Glue job"
    type        = number
    default     = 1
  
}

variable "timeout" {
    description = "The timeout for the Glue job"
    type        = number
    default     = 5
  
}

variable "max_capacity" {
    description = "The maximum capacity for the Glue job"
    type        = number
    default     = 2
  
}

variable "glue_job_trigger_name" {
    description = "The name of the Glue trigger"
    type        = string
    # default     = "default_glue_job_trigger"
  
}

variable "glue_job_schedule" {
    description = "The schedule for the Glue job"
    type        = string
    # default     = "cron(30 18 * * ? *)"  # Run daily at midnight IST
    
  
}