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
  statement {
    principals {
      identifiers = ["arn:aws:iam::918914117713:user/dev"]
      type = "AWS"
    }
    actions = ["kms:Create*", "kms:Describe*", "kms:Enable*", "kms:List*", "kms:Put*", "kms:Update*",
                "kms:Revoke*", "kms:Disable*", "kms:Get*", "kms:Delete*", "kms:TagResource",
                "kms:UntagResource", "kms:ScheduleKeyDeletion", "kms:CancelKeyDeletion"]
    resources = ["*"]
  }
  statement {
    principals {
      identifiers = [var.codepipeline-role-arn, var.iam_admin_user_arn]
      type = "AWS"
    }
    actions = ["kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:DescribeKey"]
    resources = ["*"]
  }
  statement {
    principals {
      identifiers = [var.codepipeline-role-arn, var.iam_admin_user_arn]
      type = "AWS"
    }
    actions = ["kms:CreateGrant", "kms:ListGrants", "kms:RevokeGrant"]
    resources = ["*"]
    condition {
      test     = "Bool"
      values   = [true]
      variable = "kms:GrantIsForAWSResource"
    }
  }
}

resource "aws_iam_policy" "kms-cross-account-policy" {
  name   = "kms-cross-account-policy"
  policy = data.aws_iam_policy_document.kms-cross-account-policy.json
}
