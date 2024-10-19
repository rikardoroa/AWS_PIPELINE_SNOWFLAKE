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

