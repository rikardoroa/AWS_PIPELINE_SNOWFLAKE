#glue role and policy
resource "aws_iam_role_policy" "glue_execution_job" {
  name   = "DevGluePolicy"
  role   = var.iam_for_dev_name
  policy = var.policy_name_json
}


resource "aws_s3_object" "test_deploy_script_s3" {
  bucket = var.target_bucket
  key = "glue/scripts/GlueJobScript.py"
  source = "${path.module}/glue_script/GlueJobScript.py"
  etag = filemd5("${path.module}/glue_script/GlueJobScript.py")

}



resource "aws_glue_job" "glue_deployment_task" {
  glue_version = "4.0"
  name = "IncidentsDataV2" 
  description = "Glue Job Deployment for capture incremental data" 
  role_arn = var.iam_for_dev_arn 
  number_of_workers = 10 
  worker_type = "G.2X"
  command {
    script_location = "s3://${var.target_bucket}/glue/scripts/GlueJobScript.py"
  }
  default_arguments = {
    "--bucket"                   = "dev-fire-incidents-dt"
    "--folder"                   = "fire_incidents/"
    "--kmskey"                   = "arn:aws:kms:us-east-2:163257074638:key/8e202b7d-8060-424b-a568-1ee33532a6dd"
    "--target_bucket"            = "dev-fire-incidents-dt-all"
  }
}



resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "run_job_machine"
  role_arn = var.iam_for_dev_arn 
  publish  = true
  type     = "STANDARD"

  definition = <<EOF
{
  "Comment": "Machine for Incremental capture of fire incidents",
  "StartAt": "Glue StartJobRun",
  "States": {
    "Glue StartJobRun": {
      "Type": "Task",
      "Resource": "arn:aws:states:::glue:startJobRun",
       "Parameters": {
        "JobName": "${aws_glue_job.glue_deployment_task.name}"
      },
      "End": true
    }
  }
}
EOF
}


resource "aws_scheduler_schedule" "step_functions_schedule" {
  name       = "stp_glue_schedule"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "rate(1 day)"
  start_date = "2024-10-19T22:15:00Z"

  target {
    arn      = aws_sfn_state_machine.sfn_state_machine.arn
    role_arn = var.iam_for_dev_arn
  }
}