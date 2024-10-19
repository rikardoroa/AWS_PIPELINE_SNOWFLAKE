data "aws_caller_identity" "current" {}

resource "aws_kms_key" "dts_kms_key" {
  description             = "Key for encryption"
  enable_key_rotation     = true
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  
}

resource "aws_kms_key_policy" "bucket_kms_key" {
  key_id = aws_kms_key.example.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "dts_kms_alias" {
  name          = "alias/dt-ft-key"
  target_key_id = aws_kms_key.dts_kms_key.key_id
}


resource "aws_s3_bucket" "bucket_creation" {

   for_each = {
    for bucket in  local.bucket_details.buckets:
    bucket.name => bucket
  }

  bucket = each.value.name
  force_destroy = true
}


resource "aws_s3_bucket_public_access_block" "public_access_block" {
  for_each = aws_s3_bucket.bucket_creation

  bucket = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}



resource "aws_s3_bucket_server_side_encryption_configuration" "ss_kms_key" {
  for_each = aws_s3_bucket.bucket_creation

  bucket = each.value.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.dts_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}