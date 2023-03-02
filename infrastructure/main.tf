terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">=1.2.0"
}

provider "aws" {
  region = "us-east-2"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "kms-cross-account-policy" {
  statement {
    principals {
      identifiers = ["arn:aws:iam::918914117713:root"]
      type = "AWS"
    }
    actions = ["kms:*"]
    resources = ["*"]
  }

}

resource "aws_iam_policy" "kms-cross-account-policy" {
  name   = "kms-cross-account-policy"
  policy = data.aws_iam_policy_document.kms-cross-account-policy.json
}
