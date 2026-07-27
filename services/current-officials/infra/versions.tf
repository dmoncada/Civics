terraform {
  required_version = ">= 1.8.0"
  backend "s3" {}
  required_providers {
    aws        = { source = "hashicorp/aws", version = "~> 6.0" }
    cloudflare = { source = "cloudflare/cloudflare", version = "~> 5.0" }
  }
}

provider "aws" {
  region = var.region
  default_tags { tags = { Application = "civics-current-officials", Environment = var.environment, ManagedBy = "OpenTofu" } }
}

provider "cloudflare" { api_token = var.cloudflare_api_token }
