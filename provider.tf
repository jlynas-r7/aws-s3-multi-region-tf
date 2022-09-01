terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "ext_ing_primary_region"
}

provider "aws" {
  region = "us-west-2"
  alias  = "ext_ing_secondary_region"
}
