#lambda role and policy
resource "aws_iam_role_policy" "lambda_s3_monitoring" {
  name   = "lambda_logging_with_layer"
  role   = aws_iam_role.iam_for_dev.name
  policy = data.aws_iam_policy_document.pipeline_dev_policy.json
}

# wait 10 seconds until image aprovisioning
resource "null_resource" "wait_for_image" {
  provisioner "local-exec" {
    # command = "powershell -Command Start-Sleep -Seconds 10"  # Esperar 10 segundos
     command = "sleep 10"  # Esperar 10 segundos
  }

  depends_on = [
    null_resource.push_image
  ]
}


# after image aprovisioning, the lambda creation starts using ECR repository
resource "aws_lambda_function" "lambda_function" {
  function_name = "api-incd-docker-lambda"
  image_uri     = "${aws_ecr_repository.lambda_repository.repository_url}:latest"
  package_type  = "Image"
  role          = aws_iam_role.iam_for_dev.arn
  timeout =     var.lambda_timeout
  memory_size   = 500
  
    environment {
    variables = {
      bucket = "dev-fire-incidents-dt"
      key = "arn:aws:kms:us-east-2:163257074638:key/8e202b7d-8060-424b-a568-1ee33532a6dd"
    }
    }
  depends_on = [
    null_resource.wait_for_image
  ]
}


# event bridge rule for lambda execution
resource "aws_scheduler_schedule" "lambda_schedule" {
  name       = "lbd_schedule"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "rate(1 day)"
  start_date = "2024-10-19T18:05:00Z"

  target {
    arn      = aws_lambda_function.lambda_function.arn
    role_arn = aws_iam_role.iam_for_dev.arn
  }
}