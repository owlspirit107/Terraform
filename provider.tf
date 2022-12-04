terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.45.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "upgradterraformbucket1"
    key            = "terraform_file/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform"
  }
}
