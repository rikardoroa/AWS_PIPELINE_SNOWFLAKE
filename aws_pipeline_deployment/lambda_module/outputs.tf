output "bucket_output" {
  value  = local.bucket_details
}

output "glue_bucket" {
  value = aws_s3_bucket.bucket_creation["dev-fire-incidents-dt-glue-python"].id
}

output "iam_for_dev_name" {
  value = aws_iam_role.iam_for_dev.name
}

output "policy_for_dev" {
  value = data.aws_iam_policy_document.pipeline_dev_policy.json
}

output "iam_for_dev_arn" {
  value = aws_iam_role.iam_for_dev.arn
}