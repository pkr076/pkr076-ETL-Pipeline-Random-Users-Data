resource "aws_iam_role" "lambda_exec_role" {
    name = "${var.lambda_function_name}_exec_role"     #"random_user_lambda_exec_role"
    assume_role_policy = jsonencode(
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
})
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "custom_policy" {
  statement {
    sid    = "ListObjectsInBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_name}"
    ]
  }

  statement {
    sid    = "AllObjectActions"
    effect = "Allow"

    actions = [
      "s3:*Object"
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_name}/*"
    ]
  }
}

# Create custom policy
resource "aws_iam_policy" "lambda_custom_policy" {
  name        = "${var.lambda_function_name}_custom_policy"
  description = "Custom policy for Lambda function"
  policy      = data.aws_iam_policy_document.custom_policy.json
}

# Attach custom policy to IAM role
resource "aws_iam_role_policy_attachment" "lambda_custom_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_custom_policy.arn
}

# Create a Lambda function with the IAM role
resource "aws_lambda_function" "my_lambda" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  timeout = var.lambda_timeout
  memory_size = var.lambda_memory_size
  filename = var.lambda_filename
  source_code_hash = filebase64sha256(var.lambda_filename)

  ephemeral_storage {
    size = var.ephemeral_storage_size # Min 512 MB and the Max 10240 MB
  }

  environment {
    variables = merge(
      var.environment_variables,
      { 
        BUCKET_NAME = var.bucket_name 
      }
    )
  }
}

