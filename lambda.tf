resource "aws_cloudwatch_log_group" "ext-ing-lambda-cloudwatch" {
  provider          = aws.ext-ing-primary-region
  name              = "/aws/lambda/${aws_lambda_function.ext-ing-lambda.function_name}"
  retention_in_days = 30
}

resource "aws_lambda_permission" "ext-ing-primary-lambda-permisson" {
  provider      = aws.ext-ing-primary-region
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ext-ing-lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.ext-ing-topic-us-east-1.arn
}

resource "aws_lambda_permission" "ext-ing-secondary-ingress-lambda-permisson" {
  provider      = aws.ext-ing-primary-region
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ext-ing-lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.ext-ing-topic-us-west-2.arn
}

resource "aws_lambda_function" "ext-ing-lambda" {
  provider         = aws.ext-ing-primary-region
  filename         = "ext_ing_lambda_payload.zip"
  function_name    = "ext-ing-lambda"
  role             = aws_iam_role.ext-ing-lambda-iam-role.arn
  source_code_hash = filebase64sha256("ext_ing_lambda_payload.zip")
  runtime          = "nodejs12.x"
  handler          = "index.handler"

  tags = {
    Product = "ext-ing"
    Name    = "ext-ing-lamdba"
  }
}

resource "aws_iam_role" "ext-ing-lambda-iam-role" {
  provider           = aws.ext-ing-primary-region
  name               = "ext-ing-lambda-lambda-iam-role"
  assume_role_policy = data.aws_iam_policy_document.ext-ing-lambda-policy-document.json
}

data "aws_iam_policy_document" "ext-ing-lambda-policy-document" {
  provider = aws.ext-ing-primary-region
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ext-ing-primary-log-policy" {
  provider = aws.ext-ing-primary-region
  statement {
    effect  = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
  statement {
    effect  = "Allow"
    actions = [
      "dynamodb:Get*",
      "dynamodb:Delete*",
      "dynamodb:Update*",
      "dynamodb:PutItem"
    ]
    resources = ["arn:aws:dynamodb:*:*:table/ext-ing-events-table"]
  }
}

resource "aws_iam_role_policy" "ext-ing-primary-log-notification-policy" {
  provider = aws.ext-ing-primary-region
  name     = "ext-ing-primary-log-notification-policy"
  role     = aws_iam_role.ext-ing-lambda-iam-role.id
  policy   = data.aws_iam_policy_document.ext-ing-primary-log-policy.json
}


#resource "aws_iam_role_policy" "insight-support-extensible-ingress-notification-policy" {
#  name   = "insight-support-extensible-ingress-notification-policy"
#  role   = aws_iam_role.insight-support-extensible-ingress-lambda-iam-role.id
#  policy = data.aws_iam_policy_document.insight-support-dynamo-db-table-policy.json
#}
#
#
resource "aws_dynamodb_table" "ext-ing-events-table" {
  name           = "ext-ing-events-table"
  hash_key       = "timestamp"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  attribute {
    name = "timestamp"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Product = "ext-ing"
    Name    = "ext-ing-events-dynamodb-table"
  }
}


#resource "aws_appautoscaling_target" "insight-support-dynamodb-table-write-target" {
#  max_capacity       = 10000
#  min_capacity       = 5
#  resource_id        = "table/insight-support-extensible-ingress-dynamodb-table"
#  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
#  service_namespace  = "dynamodb"
#}
#
#resource "aws_appautoscaling_policy" "insight-support-dynamodb-table-write-policy" {
#  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.insight-support-dynamodb-table-write-target.resource_id}"
#  policy_type        = "TargetTrackingScaling"
#  resource_id        = aws_appautoscaling_target.insight-support-dynamodb-table-write-target.resource_id
#  scalable_dimension = aws_appautoscaling_target.insight-support-dynamodb-table-write-target.scalable_dimension
#  service_namespace  = aws_appautoscaling_target.insight-support-dynamodb-table-write-target.service_namespace
#
#  target_tracking_scaling_policy_configuration {
#    predefined_metric_specification {
#      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
#    }
#
#    target_value = 80
#  }
#}




