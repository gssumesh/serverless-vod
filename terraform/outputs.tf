output "input_bucket_arn" {
  value = aws_s3_bucket.input_bucket.arn
}

output "input_bucket_name" {
  value = aws_s3_bucket.input_bucket.id
}