resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "cloud-cost-dashboard-${random_id.bucket_suffix.hex}"

  tags = {
    Project = "cloud-cost-intelligence"
    Type    = "frontend"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.frontend_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.ownership,
    aws_s3_bucket_public_access_block.public_access
  ]

  bucket = aws_s3_bucket.frontend_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}
