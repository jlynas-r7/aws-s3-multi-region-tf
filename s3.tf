resource "aws_s3_bucket" "ext-ing-primary-region-bucket" {
  provider = aws.ext-ing-primary-region

  bucket = "ext-ing-bucket-us-east-1"

  tags = {
    Product = "insight-support"
    Name    = "insight-support-extensible-ingress-s3-mr"
  }
}

resource "aws_s3_bucket" "ext-ing-secondary-region-bucket" {
  provider = aws.ext-ing-secondary-region

  bucket = "ext-ing-bucket-us-west-2"

  tags = {
    Product = "insight-support"
    Name    = "insight-support-extensible-ingress-s3-mr"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "ext-ing-topic-us-east-1-bucket-config" {
  provider = aws.ext-ing-primary-region
  bucket   = aws_s3_bucket.ext-ing-primary-region-bucket.bucket

  rule {
    id = "ext-ing-topic-us-east-1-file-expiration-rule"

    expiration {
      days = 1
    }

    filter {
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "ext-ing-topic-us-west-2-bucket-config" {
  provider = aws.ext-ing-secondary-region
  bucket   = aws_s3_bucket.ext-ing-secondary-region-bucket.bucket

  rule {
    id = "ext-ing-topic-us-west-2-file-expiration-rule"

    expiration {
      days = 1
    }

    filter {
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
    status = "Enabled"
  }
}


resource "aws_s3_bucket_ownership_controls" "ext-ing-primary-region-bucket-controls" {
  provider = aws.ext-ing-primary-region
  bucket   = aws_s3_bucket.ext-ing-primary-region-bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_ownership_controls" "ext-ing-secondary-region-bucket-controls" {
  provider = aws.ext-ing-secondary-region
  bucket   = aws_s3_bucket.ext-ing-secondary-region-bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_notification" "ext-ing-primary-region-bucket-notification" {
  provider = aws.ext-ing-primary-region
  bucket   = aws_s3_bucket.ext-ing-primary-region-bucket.id

  topic {
    topic_arn = aws_sns_topic.ext-ing-topic-us-east-1.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*", "s3:LifecycleExpiration:Delete"]
  }
}

resource "aws_s3_bucket_notification" "ext-ing-secondary-region-bucket-notification" {
  provider = aws.ext-ing-secondary-region
  bucket   = aws_s3_bucket.ext-ing-secondary-region-bucket.id

  topic {
    topic_arn = aws_sns_topic.ext-ing-topic-us-west-2.arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*", "s3:LifecycleExpiration:Delete"]
  }
}


resource "aws_s3control_multi_region_access_point" "ext-ing-s3-mrap" {
  details {
    name = "ext-ing-s3-mrap"

    region {
      bucket = aws_s3_bucket.ext-ing-primary-region-bucket.id
    }

    region {
      bucket = aws_s3_bucket.ext-ing-secondary-region-bucket.id
    }
  }

}

#resource "aws_s3_bucket_replication_configuration" "ext-ing-secondary-primary-replication" {
#  provider = aws.ext-ing-secondary-region
#
#  role   = aws_iam_role.west_replication.arn
#  bucket = aws_s3_bucket.ext-ing-secondary-region-bucket.id
#
#  rule {
#    id = "foobar"
#
#    filter {
#      prefix = "foo"
#    }
#
#    status = "Enabled"
#
#    destination {
#      bucket        = aws_s3_bucket.ext-ing-primary-region-bucket.arn
#      storage_class = "STANDARD"
#    }
#  }