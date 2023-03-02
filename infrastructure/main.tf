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

resource "aws_iam_policy" "kms-cross-account-policy" {
  name = "iris-kms-cross-account-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = [
            data.aws_caller_identity.current.account_id
          ]
        },
        Action = "kms:*",
        Resource = "*"
      },
      {
        Effect = "Allow",
        Principal = {
          AWS = var.iam_user_arn
        },
        Action = [
          "kms:Create*", "kms:Describe*", "kms:Enable*", "kms:List*", "kms:Put*", "kms:Update*", "kms:Revoke*",
          "kms:Disable*", "kms:Get*", "kms:Delete*", "kms:TagResource", "kms:UntagResource",
          "kms:ScheduleKeyDeletion", "kms:CancelKeyDeletion"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow",
        Principal = {
          AWS = [var.codepipeline-role-arn, var.iam_admin_user_arn]
        },
        Action = [
          "kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:DescribeKey"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Principal = {
          AWS = [var.codepipeline-role-arn, var.iam_admin_user_arn]
        },
        Action = [
          "kms:CreateGrant", "kms:ListGrants", "kms:RevokeGrant"
        ],
        Resource = "*",
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource": "true"
          }
        }
      }
    ]
  })
}