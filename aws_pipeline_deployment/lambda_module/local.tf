locals {
  bucket_details = jsondecode(file("${path.module}/buckets.json"))
}