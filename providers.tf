terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.70"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2"
    }
  }

  backend "local" {
    # PRO TIP: use remote state (i.e. S3) instead of local
  }
}

provider "aws" {
  region = var.region
}
