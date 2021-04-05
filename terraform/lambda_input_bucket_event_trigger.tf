resource "aws_iam_role" "iam_for_input_bucket_event_trigger_lambda" {
  name = "iam_for_input_bucket_event_trigger_lambda"

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

resource "aws_iam_policy" "iam_policy_for_input_bucket_event_trigger_lambda" {
  name        = "iam_policy_for_input_bucket_event_trigger_lambda"
  path        = "/"
  description = "IAM policy for input_bucket_event_trigger_lambda"

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
        "mediaconvert:CreateJob",
        "mediaconvert:CreateJobTemplate",
        "mediaconvert:CreatePreset",
        "mediaconvert:DeleteJobTemplate",
        "mediaconvert:DeletePreset",
        "mediaconvert:DescribeEndpoints",
        "mediaconvert:GetJob",
        "mediaconvert:GetJobTemplate",
        "mediaconvert:GetQueue",
        "mediaconvert:GetPreset",
        "mediaconvert:ListJobTemplates",
        "mediaconvert:ListJobs",
        "mediaconvert:ListQueues",
        "mediaconvert:ListPresets",
        "mediaconvert:UpdateJobTemplate"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "iam:PassRole"
      ],
      "Resource": "${aws_iam_role.iam_for_mediaconvert_trigger_from_lambda.arn}",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "vod_input_bucket_event_trigger_lambda_policy" {
  role       = aws_iam_role.iam_for_input_bucket_event_trigger_lambda.name
  policy_arn = aws_iam_policy.iam_policy_for_input_bucket_event_trigger_lambda.arn
}

resource "aws_iam_role" "iam_for_mediaconvert_trigger_from_lambda" {
  name = "iam_for_mediaconvert_trigger_from_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "mediaconvert.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "iam_policy_for_mediaconvert_trigger_from_lambda" {
  name        = "iam_policy_for_mediaconvert_trigger_from_lambda"
  path        = "/"
  description = "IAM policy for mediaconvert_trigger_from_lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource":[
        "${aws_s3_bucket.input_bucket.arn}/*", 
        "${aws_s3_bucket.output_bucket.arn}/*"
       ],
      "Effect": "Allow"
    },
    {
      "Action": [
        "execute-api:Invoke"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "vod_mediaconvert_trigger_from_lambda_policy" {
  role       = aws_iam_role.iam_for_mediaconvert_trigger_from_lambda.name
  policy_arn = aws_iam_policy.iam_policy_for_mediaconvert_trigger_from_lambda.arn
}

resource "aws_lambda_function" "vod_input_bucket_event_trigger_lambda" {
  filename      = "lambdas/input_bucket_event_trigger_lambda.zip"
  function_name = "vod_input_bucket_event_trigger_lambda"
  role          = aws_iam_role.iam_for_input_bucket_event_trigger_lambda.arn
  handler       = "index.handler"

  source_code_hash = filebase64sha256("lambdas/input_bucket_event_trigger_lambda.zip")

  runtime = "nodejs12.x"
  timeout = 30

  environment {
    variables = {
      ARN_TEMPLATE = var.mediaconvert_template_arn
      MC_ROLE = aws_iam_role.iam_for_mediaconvert_trigger_from_lambda.arn
      OUTPUT_BUCKET =  aws_s3_bucket.output_bucket.id
    }
  }

}