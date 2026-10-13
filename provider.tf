# -----------------------------------------------------------------------------
# Provider Configuration
# -----------------------------------------------------------------------------
# This file configures the AWS provider that Terraform will use to create
# resources. Credentials are NOT hardcoded here — they're picked up from
# your AWS CLI configuration (~/.aws/credentials) or environment variables,
# which is the secure, recommended approach.

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
