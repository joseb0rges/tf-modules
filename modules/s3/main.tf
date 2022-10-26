resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket

  tags = {
    CreatedBy = "Terraform"
  }
}

resource "aws_s3_bucket_acl" "bucket-acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}