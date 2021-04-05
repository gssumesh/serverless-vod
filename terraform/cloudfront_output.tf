resource "aws_cloudfront_distribution" "output_s3_distribution" {
  
  price_class = "PriceClass_All"
  enabled = true
  
  default_cache_behavior {
    forwarded_values = {
      query_string = false
      cookies = {
        forward = "all"
      }
    }
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy = "allow-all"
    trusted_signers = "self"
    target_origin_id = "vodS3Origin"
  }

  origin {
    domain_name = aws_s3_bucket.output_bucket.bucket_domain_name
    origin_id   = "vodS3Origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

}