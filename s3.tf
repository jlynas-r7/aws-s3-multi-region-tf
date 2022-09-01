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