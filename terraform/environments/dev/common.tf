terraform {
  #   backend "s3" {
  #     profile        = "cap-aws-mykidz-dev"
  #     region         = "ap-southeast-1"
  #     key            = "cap-aws-mykidz-dev/terraform.tfstate"
  #     bucket         = "cap-aws-mykidz-dev-tfstate"
  #     dynamodb_table = "cap-aws-mykidz-dev-tfstate-lock"
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
