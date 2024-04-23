terraform {
  #   backend "s3" {
  #     profile        = "cap-aws-mykidz-prod"
  #     region         = "ap-southeast-1"
  #     key            = "cap-aws-mykidz-prod/terraform.tfstate"
  #     bucket         = "cap-aws-mykidz-prod-tfstate"
  #     dynamodb_table = "cap-aws-mykidz-prod-tfstate-lock"
  #   }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.46.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = "default"
}
