
variable "lambda_function_arn" {
  description = "The ARN of the Lambda function to trigger"
  type        = string
}

variable "schedule_expression" {
  description = "The schedule expression for the EventBridge rule"
  type        = string
}

variable "schedule_name" {
  description = "Name of the schedule"
  type        = string
  
}