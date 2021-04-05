resource "aws_iam_role" "iam_for_output_bucket_event_trigger_lambda" {
  name = "iam_for_output_bucket_event_trigger_lambda"

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

resource "aws_iam_policy" "iam_policy_for_output_bucket_event_trigger_lambda" {
  name        = "iam_policy_for_output_bucket_event_trigger_lambda"
  path        = "/"
  description = "IAM policy for output_bucket_event_trigger_lambda"

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
        "s3:PutObjectAcl"
      ],
      "Resource": [
        "${aws_s3_bucket.output_bucket.arn}/*",
        "${aws_s3_bucket.output_bucket.arn}" 
        ],
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "vod_output_bucket_event_trigger_lambda_policy" {
  role       = aws_iam_role.iam_for_output_bucket_event_trigger_lambda.name
  policy_arn = aws_iam_policy.iam_policy_for_output_bucket_event_trigger_lambda.arn
}

resource "aws_lambda_function" "vod_output_bucket_event_trigger_lambda" {
  filename      = "lambdas/output_bucket_event_trigger_lambda.zip"
  function_name = "vod_output_bucket_event_trigger_lambda"
  role          = aws_iam_role.iam_for_output_bucket_event_trigger_lambda.arn
  handler       = "index.handler"

  source_code_hash = filebase64sha256("lambdas/output_bucket_event_trigger_lambda.zip")

  runtime = "nodejs12.x"
  timeout = 30

}