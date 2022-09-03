data "aws_caller_identity" "aws-account" {}

resource "aws_sns_topic" "ext-ing-topic-us-east-1" {
  provider = aws.ext-ing-primary-region
  name     = "ext-ing-topic-us-east-1"
}


resource "aws_sns_topic" "ext-ing-topic-us-west-2" {
  provider = aws.ext-ing-secondary-region
  name     = "ext-ing-topic-us-west-2"
}

resource "aws_sns_topic_policy" "ext-ing-topic-policy-us-east-1" {
  provider = aws.ext-ing-primary-region
  arn      = aws_sns_topic.ext-ing-topic-us-east-1.arn
  policy   = data.aws_iam_policy_document.ext-ing-topic-policy-document-us-east-1.json
}

resource "aws_sns_topic_policy" "ext-ing-topic-policy-us-west-2" {
  provider = aws.ext-ing-secondary-region
  arn      = aws_sns_topic.ext-ing-topic-us-west-2.arn
  policy   = data.aws_iam_policy_document.ext-ing-topic-policy-document-us-west-2.json
}

data "aws_iam_policy_document" "ext-ing-topic-policy-document-us-east-1" {
  provider = aws.ext-ing-primary-region

  statement {
    actions = [
      "SNS:Publish",
    ]

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:s3:*:*:ext-ing*"]
    }

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.ext-ing-topic-us-east-1.arn
    ]

  }
}

data "aws_iam_policy_document" "ext-ing-topic-policy-document-us-west-2" {
  provider = aws.ext-ing-secondary-region

  statement {
    actions = [
      "SNS:Publish",
    ]

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:s3:*:*:ext-ing*"]
    }

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.ext-ing-topic-us-west-2.arn
    ]

  }
}
