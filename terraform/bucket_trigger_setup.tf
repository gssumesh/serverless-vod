resource "aws_lambda_permission" "input_bucket_trigger_permission" {
  action            = "lambda:InvokeFunction"
  function_name     = aws_lambda_function.vod_input_bucket_event_trigger_lambda.function_name
  principal         = "s3.amazonaws.com"
  source_account    = var.aws_account_id
}

resource "aws_lambda_permission" "output_bucket_trigger_permission" {
  action            = "lambda:InvokeFunction"
  function_name     = aws_lambda_function.vod_output_bucket_event_trigger_lambda.function_name
  principal         = "s3.amazonaws.com"
  source_account    = var.aws_account_id
}