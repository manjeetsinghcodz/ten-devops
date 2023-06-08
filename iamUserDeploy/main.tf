terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.1.0"
    }
  }
}
provider "aws" {
  region = "ap-southeast-2"
  profile = "default"
}

