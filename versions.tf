terraform {
  required_version = ">= 1.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.22"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.2"
    }
  }
}
