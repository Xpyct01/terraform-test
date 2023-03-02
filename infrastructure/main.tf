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

module "kms" {
  source = "terraform-aws-modules/kms/aws"

  aliases = ["aboba-key"]
  deletion_window_in_days = 7
  key_owners = [data.aws_caller_identity.current.account_id]
  key_administrators = [data.aws_caller_identity.current.account_id]
}