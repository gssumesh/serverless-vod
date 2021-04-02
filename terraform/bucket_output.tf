resource "aws_s3_bucket" "output_bucket" {
  acl    = "private"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    allowed_origins = ["*"]
    expose_headers  = ["x-amz-server-side-encryption", "x-amz-request-id", "x-amz-id-2", "ETag"]
    max_age_seconds = 3000
  }

}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "OAI created by Terraform"
}


resource "aws_s3_bucket_policy" "output_bucket_policy" {
  bucket = aws_s3_bucket.output_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "output_bucket_policy"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.origin_access_identity.id}"
        }
        Action    = "s3:getObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.output_bucket.id}/*"
      }
    ]
  })

}

resource "aws_iam_role_policy" "output_bucket_access_to_authrole_policy" {
  name = "output_bucket_access_to_authrole_policy"
  role = var.authenticated_role_arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "s3:GetObject"
        Effect   = "Allow"
        Resource = ["arn:aws:s3:::${aws_s3_bucket.output_bucket.id}/$${cognito-identity.amazonaws.com:sub}/*"]
      },
    ]
  })
}