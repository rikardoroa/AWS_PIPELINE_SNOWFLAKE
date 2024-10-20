

variable "lambda_timeout" {
  description = "The timeout for the Lambda function in seconds"
  type        = number
  default     = 360 # 6 minutes
}

variable "aws_region"{
  description = "aws region"
  type = string
  default = "us-east-2"

}

variable "lambda_bucket"{
  description = "Bucket to store the API Call data execute by the AWS Lambda Function"
  type = string
  default = "dev-fire-incidents-dt"

}


