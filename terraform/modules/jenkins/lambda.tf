##########################################
# Lambda Function
##########################################

resource "aws_lambda_function" "jenkins_lambda" {
  function_name    = "jenkinsLambdaFunction"
  runtime          = "python3.8"
  handler          = "lambda_function.lambda_handler"
  filename         = "${path.module}/lambda/funcs/lambda_function.zip"
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = filebase64sha256("${path.module}/lambda/funcs/lambda_function.zip")

  environment {
    variables = {
      JENKINS_URL = "${aws_instance.this.public_dns}"
      API_TOKEN   = "s3_trigger"
    }
  }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.jenkins_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.this.arn
}

##########################################
# IAM Role for Lambda
##########################################

resource "aws_iam_role" "lambda_exec" {
  name = "${var.resource_name_prefix}-lambda-exec-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags, {
    "TERRAFORM:Resource" = "aws_iam_role"
    "TERRAFORM:Module"   = "jenkins"
  })
}

##########################################
# IAM Policy Attachment for Lambda
##########################################

resource "aws_iam_policy_attachment" "lambda_exec_attachment" {
  name       = "${var.resource_name_prefix}-lambda-exec-policy-attachment"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

##########################################
# S3 Event Notification
##########################################

resource "aws_s3_bucket_notification" "this" {
  bucket = aws_s3_bucket.this.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.jenkins_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".yaml"
  }

  depends_on = [ aws_lambda_permission.allow_bucket ]
}
