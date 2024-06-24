data "aws_iam_policy_document" "glue_policy_document"{
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["glue.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "glue_role" {
    name = var.glue_role_name
    assume_role_policy = data.aws_iam_policy_document.glue_policy_document.json
}

resource "aws_iam_role_policy_attachment" "glue_service_role_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  
}


data "aws_iam_policy_document" "s3_access_policy_glue_document" {
  statement {
    effect =  "Allow"
    actions = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.bucket_name}" , "arn:aws:s3:::${var.bucket_name}/*"]
  }
}

resource "aws_iam_policy" "glue_s3_access_policy" {
  name = var.glue_custom_policy_name
  policy = data.aws_iam_policy_document.s3_access_policy_glue_document.json
}


resource "aws_iam_role_policy_attachment" "glue_s3_access_policy_attachment" {
  policy_arn = aws_iam_policy.glue_s3_access_policy.arn
  role     = aws_iam_role.glue_role.name
}

resource "aws_iam_role_policy_attachment" "dynamoDB_access_policy_attachment" {
  role      = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  
}

resource "aws_s3_object" "glue_etl_script" {
  bucket = var.bucket_name
  key    = var.bucket_key
  source = var.glue_script_local_path
  etag = filebase64sha256(var.glue_script_local_path) # This line ensures that the S3 object is updated whenever the content of the local script file changes.
}


resource "aws_glue_job" "my_etl_job" {
  name     = var.glue_job_name
  role_arn = aws_iam_role.glue_role.arn

  command {
    script_location = var.glue_job_script_location
    name            = "glueetl"
  }

  default_arguments = {
    "--job-language"        = "python"
    "--TempDir"             = var.glue_job_temp_dir
    # "--enable-metrics"      = ""
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-spark-ui"     = "true"
  }

  max_retries = var.max_retries
  timeout     = var.timeout  # Timeout in minutes
  max_capacity = var.max_capacity  # Number of DPUs allocated to this job
}


resource "aws_glue_trigger" "daily_glue_job_trigger" {
  name = var.glue_job_trigger_name

  type = "SCHEDULED"

  schedule = var.glue_job_schedule

  actions {
    job_name = aws_glue_job.my_etl_job.name
  }

  start_on_creation = false
}