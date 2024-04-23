terraform {
  #   backend "s3" {
  #     profile        = "cap-aws-mykidz-stg"
  #     region         = "ap-southeast-1"
  #     key            = "cap-aws-mykidz-stg/terraform.tfstate"
  #     bucket         = "cap-aws-mykidz-stg-tfstate"
  #     dynamodb_table = "cap-aws-mykidz-stg-tfstate-lock"
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
