data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../../python/process-sqs/process-sqs.py"
  output_path = "${path.module}/../../python/process-sqs/process-sqs.zip"
}
resource "aws_lambda_function" "test_lambda" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = var.function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "process-sqs.lambda_handler"

  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)

  runtime = var.runtime
}