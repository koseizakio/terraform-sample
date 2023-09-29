# Terraformの設定
terraform {
  required_version = "~>1.5.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Providerの設定
provider "aws" {
  region = "ap-northeast-1"
}