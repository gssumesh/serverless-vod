resource "aws_iam_role" "iam_for_token_generation_lambda" {
  name = "iam_for_token_generation_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "iam_policy_for_token_generation_lambda" {
  name        = "iam_policy_for_token_generation_lambda"
  path        = "/"
  description = "IAM policy for token_generation_lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": ${var.cloudfront_secret_pem_arn},
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "vod_token_generation_lambda_policy" {
  role       = aws_iam_role.iam_for_token_generation_lambda.name
  policy_arn = aws_iam_policy.iam_policy_for_token_generation_lambda.arn
}

resource "aws_lambda_function" "vod_token_generation_lambda" {
  filename      = "lambdas/token_generation_lambda.zip"
  function_name = "vod_token_generation_lambda"
  role          = aws_iam_role.iam_for_token_generation_lambda.arn
  handler       = "index.handler"

  source_code_hash = filebase64sha256("lambdas/token_generation_lambda.zip")

  runtime = "nodejs12.x"

  environment {
    variables = {
      PemID = var.cloudfront_pem_id
      SecretPem = var.cloudfront_secret_pem_name
      Host =  aws_cloudfront_distribution.output_s3_distribution.domain_name 
    }
  }

}